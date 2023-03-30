
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
  80004a:	e8 47 18 00 00       	call   801896 <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 3d 18 00 00       	call   801896 <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  800060:	e8 5b 05 00 00       	call   8005c0 <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 eb 2e 80 00 	movl   $0x802eeb,(%esp)
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
  80008d:	e8 b4 16 00 00       	call   801746 <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 fa 2e 80 00       	push   $0x802efa
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
  8000c2:	e8 7f 16 00 00       	call   801746 <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 f5 2e 80 00       	push   $0x802ef5
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
  8000f6:	e8 0f 15 00 00       	call   80160a <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 03 15 00 00       	call   80160a <close>
	opencons();
  800107:	e8 27 03 00 00       	call   800433 <opencons>
	opencons();
  80010c:	e8 22 03 00 00       	call   800433 <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 08 2f 80 00       	push   $0x802f08
  80011b:	e8 89 1a 00 00       	call   801ba9 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 e7 00 00 00    	js     800214 <umain+0x129>
	if ((wfd = pipe(pfds)) < 0)
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 5c 27 00 00       	call   802895 <pipe>
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	85 c0                	test   %eax,%eax
  80013e:	0f 88 e2 00 00 00    	js     800226 <umain+0x13b>
	wfd = pfds[1];
  800144:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	68 a4 2e 80 00       	push   $0x802ea4
  80014f:	e8 6c 04 00 00       	call   8005c0 <cprintf>
	if ((r = fork()) < 0)
  800154:	e8 8d 11 00 00       	call   8012e6 <fork>
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	85 c0                	test   %eax,%eax
  80015e:	0f 88 d4 00 00 00    	js     800238 <umain+0x14d>
	if (r == 0) {
  800164:	75 6f                	jne    8001d5 <umain+0xea>
		dup(rfd, 0);
  800166:	83 ec 08             	sub    $0x8,%esp
  800169:	6a 00                	push   $0x0
  80016b:	53                   	push   %ebx
  80016c:	e8 eb 14 00 00       	call   80165c <dup>
		dup(wfd, 1);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	6a 01                	push   $0x1
  800176:	56                   	push   %esi
  800177:	e8 e0 14 00 00       	call   80165c <dup>
		close(rfd);
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 86 14 00 00       	call   80160a <close>
		close(wfd);
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 7e 14 00 00       	call   80160a <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  80018c:	6a 00                	push   $0x0
  80018e:	68 45 2f 80 00       	push   $0x802f45
  800193:	68 12 2f 80 00       	push   $0x802f12
  800198:	68 48 2f 80 00       	push   $0x802f48
  80019d:	e8 19 20 00 00       	call   8021bb <spawnl>
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	83 c4 20             	add    $0x20,%esp
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	0f 88 9b 00 00 00    	js     80024a <umain+0x15f>
		close(0);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	6a 00                	push   $0x0
  8001b4:	e8 51 14 00 00       	call   80160a <close>
		close(1);
  8001b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001c0:	e8 45 14 00 00       	call   80160a <close>
		wait(r);
  8001c5:	89 3c 24             	mov    %edi,(%esp)
  8001c8:	e8 45 28 00 00       	call   802a12 <wait>
		exit();
  8001cd:	e8 f9 02 00 00       	call   8004cb <exit>
  8001d2:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	53                   	push   %ebx
  8001d9:	e8 2c 14 00 00       	call   80160a <close>
	close(wfd);
  8001de:	89 34 24             	mov    %esi,(%esp)
  8001e1:	e8 24 14 00 00       	call   80160a <close>
	rfd = pfds[0];
  8001e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001ec:	83 c4 08             	add    $0x8,%esp
  8001ef:	6a 00                	push   $0x0
  8001f1:	68 56 2f 80 00       	push   $0x802f56
  8001f6:	e8 ae 19 00 00       	call   801ba9 <open>
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
  800215:	68 15 2f 80 00       	push   $0x802f15
  80021a:	6a 13                	push   $0x13
  80021c:	68 2b 2f 80 00       	push   $0x802f2b
  800221:	e8 bf 02 00 00       	call   8004e5 <_panic>
		panic("pipe: %e", wfd);
  800226:	50                   	push   %eax
  800227:	68 3c 2f 80 00       	push   $0x802f3c
  80022c:	6a 15                	push   $0x15
  80022e:	68 2b 2f 80 00       	push   $0x802f2b
  800233:	e8 ad 02 00 00       	call   8004e5 <_panic>
		panic("fork: %e", r);
  800238:	50                   	push   %eax
  800239:	68 b8 33 80 00       	push   $0x8033b8
  80023e:	6a 1a                	push   $0x1a
  800240:	68 2b 2f 80 00       	push   $0x802f2b
  800245:	e8 9b 02 00 00       	call   8004e5 <_panic>
			panic("spawn: %e", r);
  80024a:	50                   	push   %eax
  80024b:	68 4c 2f 80 00       	push   $0x802f4c
  800250:	6a 21                	push   $0x21
  800252:	68 2b 2f 80 00       	push   $0x802f2b
  800257:	e8 89 02 00 00       	call   8004e5 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  80025c:	50                   	push   %eax
  80025d:	68 c8 2e 80 00       	push   $0x802ec8
  800262:	6a 2c                	push   $0x2c
  800264:	68 2b 2f 80 00       	push   $0x802f2b
  800269:	e8 77 02 00 00       	call   8004e5 <_panic>
			panic("reading testshell.out: %e", n1);
  80026e:	53                   	push   %ebx
  80026f:	68 64 2f 80 00       	push   $0x802f64
  800274:	6a 33                	push   $0x33
  800276:	68 2b 2f 80 00       	push   $0x802f2b
  80027b:	e8 65 02 00 00       	call   8004e5 <_panic>
			panic("reading testshell.key: %e", n2);
  800280:	50                   	push   %eax
  800281:	68 7e 2f 80 00       	push   $0x802f7e
  800286:	6a 35                	push   $0x35
  800288:	68 2b 2f 80 00       	push   $0x802f2b
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
  8002ba:	e8 87 14 00 00       	call   801746 <read>
  8002bf:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002c1:	83 c4 0c             	add    $0xc,%esp
  8002c4:	6a 01                	push   $0x1
  8002c6:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff 75 d4             	push   -0x2c(%ebp)
  8002cd:	e8 74 14 00 00       	call   801746 <read>
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
  8002fb:	68 98 2f 80 00       	push   $0x802f98
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
  80031d:	68 ad 2f 80 00       	push   $0x802fad
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
  8003ec:	e8 55 13 00 00       	call   801746 <read>
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
  800414:	e8 c4 10 00 00       	call   8014dd <fd_lookup>
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
  80043d:	e8 4b 10 00 00       	call   80148d <fd_alloc>
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
  80047b:	e8 e6 0f 00 00       	call   801466 <fd2num>
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
  8004d1:	e8 61 11 00 00       	call   801637 <close_all>
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
  800503:	68 c4 2f 80 00       	push   $0x802fc4
  800508:	e8 b3 00 00 00       	call   8005c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80050d:	83 c4 18             	add    $0x18,%esp
  800510:	53                   	push   %ebx
  800511:	ff 75 10             	push   0x10(%ebp)
  800514:	e8 56 00 00 00       	call   80056f <vcprintf>
	cprintf("\n");
  800519:	c7 04 24 f8 2e 80 00 	movl   $0x802ef8,(%esp)
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
  800622:	e8 09 26 00 00       	call   802c30 <__udivdi3>
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
  800660:	e8 eb 26 00 00       	call   802d50 <__umoddi3>
  800665:	83 c4 14             	add    $0x14,%esp
  800668:	0f be 80 e7 2f 80 00 	movsbl 0x802fe7(%eax),%eax
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
  800722:	ff 24 85 20 31 80 00 	jmp    *0x803120(,%eax,4)
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
  8007f0:	8b 14 85 80 32 80 00 	mov    0x803280(,%eax,4),%edx
  8007f7:	85 d2                	test   %edx,%edx
  8007f9:	74 18                	je     800813 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8007fb:	52                   	push   %edx
  8007fc:	68 81 34 80 00       	push   $0x803481
  800801:	53                   	push   %ebx
  800802:	56                   	push   %esi
  800803:	e8 92 fe ff ff       	call   80069a <printfmt>
  800808:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80080b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80080e:	e9 66 02 00 00       	jmp    800a79 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800813:	50                   	push   %eax
  800814:	68 ff 2f 80 00       	push   $0x802fff
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
  80083b:	b8 f8 2f 80 00       	mov    $0x802ff8,%eax
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
  800f47:	68 df 32 80 00       	push   $0x8032df
  800f4c:	6a 2a                	push   $0x2a
  800f4e:	68 fc 32 80 00       	push   $0x8032fc
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
  800fc8:	68 df 32 80 00       	push   $0x8032df
  800fcd:	6a 2a                	push   $0x2a
  800fcf:	68 fc 32 80 00       	push   $0x8032fc
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
  80100a:	68 df 32 80 00       	push   $0x8032df
  80100f:	6a 2a                	push   $0x2a
  801011:	68 fc 32 80 00       	push   $0x8032fc
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
  80104c:	68 df 32 80 00       	push   $0x8032df
  801051:	6a 2a                	push   $0x2a
  801053:	68 fc 32 80 00       	push   $0x8032fc
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
  80108e:	68 df 32 80 00       	push   $0x8032df
  801093:	6a 2a                	push   $0x2a
  801095:	68 fc 32 80 00       	push   $0x8032fc
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
  8010d0:	68 df 32 80 00       	push   $0x8032df
  8010d5:	6a 2a                	push   $0x2a
  8010d7:	68 fc 32 80 00       	push   $0x8032fc
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
  801112:	68 df 32 80 00       	push   $0x8032df
  801117:	6a 2a                	push   $0x2a
  801119:	68 fc 32 80 00       	push   $0x8032fc
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
  801176:	68 df 32 80 00       	push   $0x8032df
  80117b:	6a 2a                	push   $0x2a
  80117d:	68 fc 32 80 00       	push   $0x8032fc
  801182:	e8 5e f3 ff ff       	call   8004e5 <_panic>

00801187 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80118d:	ba 00 00 00 00       	mov    $0x0,%edx
  801192:	b8 0e 00 00 00       	mov    $0xe,%eax
  801197:	89 d1                	mov    %edx,%ecx
  801199:	89 d3                	mov    %edx,%ebx
  80119b:	89 d7                	mov    %edx,%edi
  80119d:	89 d6                	mov    %edx,%esi
  80119f:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	57                   	push   %edi
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b7:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011bc:	89 df                	mov    %ebx,%edi
  8011be:	89 de                	mov    %ebx,%esi
  8011c0:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8011dd:	89 df                	mov    %ebx,%edi
  8011df:	89 de                	mov    %ebx,%esi
  8011e1:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011f0:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  8011f2:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011f6:	0f 84 8e 00 00 00    	je     80128a <pgfault+0xa2>
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	c1 e8 0c             	shr    $0xc,%eax
  801201:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801208:	f6 c4 08             	test   $0x8,%ah
  80120b:	74 7d                	je     80128a <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  80120d:	e8 46 fd ff ff       	call   800f58 <sys_getenvid>
  801212:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	6a 07                	push   $0x7
  801219:	68 00 f0 7f 00       	push   $0x7ff000
  80121e:	50                   	push   %eax
  80121f:	e8 72 fd ff ff       	call   800f96 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 73                	js     80129e <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  80122b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	68 00 10 00 00       	push   $0x1000
  801239:	56                   	push   %esi
  80123a:	68 00 f0 7f 00       	push   $0x7ff000
  80123f:	e8 ec fa ff ff       	call   800d30 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801244:	83 c4 08             	add    $0x8,%esp
  801247:	56                   	push   %esi
  801248:	53                   	push   %ebx
  801249:	e8 cd fd ff ff       	call   80101b <sys_page_unmap>
  80124e:	83 c4 10             	add    $0x10,%esp
  801251:	85 c0                	test   %eax,%eax
  801253:	78 5b                	js     8012b0 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801255:	83 ec 0c             	sub    $0xc,%esp
  801258:	6a 07                	push   $0x7
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	68 00 f0 7f 00       	push   $0x7ff000
  801261:	53                   	push   %ebx
  801262:	e8 72 fd ff ff       	call   800fd9 <sys_page_map>
  801267:	83 c4 20             	add    $0x20,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 54                	js     8012c2 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	68 00 f0 7f 00       	push   $0x7ff000
  801276:	53                   	push   %ebx
  801277:	e8 9f fd ff ff       	call   80101b <sys_page_unmap>
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 51                	js     8012d4 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  801283:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801286:	5b                   	pop    %ebx
  801287:	5e                   	pop    %esi
  801288:	5d                   	pop    %ebp
  801289:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80128a:	83 ec 04             	sub    $0x4,%esp
  80128d:	68 0c 33 80 00       	push   $0x80330c
  801292:	6a 1d                	push   $0x1d
  801294:	68 88 33 80 00       	push   $0x803388
  801299:	e8 47 f2 ff ff       	call   8004e5 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  80129e:	50                   	push   %eax
  80129f:	68 44 33 80 00       	push   $0x803344
  8012a4:	6a 29                	push   $0x29
  8012a6:	68 88 33 80 00       	push   $0x803388
  8012ab:	e8 35 f2 ff ff       	call   8004e5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8012b0:	50                   	push   %eax
  8012b1:	68 68 33 80 00       	push   $0x803368
  8012b6:	6a 2e                	push   $0x2e
  8012b8:	68 88 33 80 00       	push   $0x803388
  8012bd:	e8 23 f2 ff ff       	call   8004e5 <_panic>
		panic("pgfault: page map failed (%e)", r);
  8012c2:	50                   	push   %eax
  8012c3:	68 93 33 80 00       	push   $0x803393
  8012c8:	6a 30                	push   $0x30
  8012ca:	68 88 33 80 00       	push   $0x803388
  8012cf:	e8 11 f2 ff ff       	call   8004e5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8012d4:	50                   	push   %eax
  8012d5:	68 68 33 80 00       	push   $0x803368
  8012da:	6a 32                	push   $0x32
  8012dc:	68 88 33 80 00       	push   $0x803388
  8012e1:	e8 ff f1 ff ff       	call   8004e5 <_panic>

008012e6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	57                   	push   %edi
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
  8012ec:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  8012ef:	68 e8 11 80 00       	push   $0x8011e8
  8012f4:	e8 68 17 00 00       	call   802a61 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012f9:	b8 07 00 00 00       	mov    $0x7,%eax
  8012fe:	cd 30                	int    $0x30
  801300:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 2d                	js     801337 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80130a:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80130f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801313:	75 73                	jne    801388 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801315:	e8 3e fc ff ff       	call   800f58 <sys_getenvid>
  80131a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80131f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801322:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801327:	a3 00 50 80 00       	mov    %eax,0x805000
		return 0;
  80132c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80132f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5f                   	pop    %edi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801337:	50                   	push   %eax
  801338:	68 b1 33 80 00       	push   $0x8033b1
  80133d:	6a 78                	push   $0x78
  80133f:	68 88 33 80 00       	push   $0x803388
  801344:	e8 9c f1 ff ff       	call   8004e5 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	ff 75 e4             	push   -0x1c(%ebp)
  80134f:	57                   	push   %edi
  801350:	ff 75 dc             	push   -0x24(%ebp)
  801353:	57                   	push   %edi
  801354:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801357:	56                   	push   %esi
  801358:	e8 7c fc ff ff       	call   800fd9 <sys_page_map>
	if(r<0) return r;
  80135d:	83 c4 20             	add    $0x20,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	78 cb                	js     80132f <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801364:	83 ec 0c             	sub    $0xc,%esp
  801367:	ff 75 e4             	push   -0x1c(%ebp)
  80136a:	57                   	push   %edi
  80136b:	56                   	push   %esi
  80136c:	57                   	push   %edi
  80136d:	56                   	push   %esi
  80136e:	e8 66 fc ff ff       	call   800fd9 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801373:	83 c4 20             	add    $0x20,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 76                	js     8013f0 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80137a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801380:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801386:	74 75                	je     8013fd <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801388:	89 d8                	mov    %ebx,%eax
  80138a:	c1 e8 16             	shr    $0x16,%eax
  80138d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801394:	a8 01                	test   $0x1,%al
  801396:	74 e2                	je     80137a <fork+0x94>
  801398:	89 de                	mov    %ebx,%esi
  80139a:	c1 ee 0c             	shr    $0xc,%esi
  80139d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8013a4:	a8 01                	test   $0x1,%al
  8013a6:	74 d2                	je     80137a <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8013a8:	e8 ab fb ff ff       	call   800f58 <sys_getenvid>
  8013ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8013b0:	89 f7                	mov    %esi,%edi
  8013b2:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8013b5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8013bc:	89 c1                	mov    %eax,%ecx
  8013be:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8013c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8013c7:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8013ce:	f6 c6 04             	test   $0x4,%dh
  8013d1:	0f 85 72 ff ff ff    	jne    801349 <fork+0x63>
		perm &= ~PTE_W;
  8013d7:	25 05 0e 00 00       	and    $0xe05,%eax
  8013dc:	80 cc 08             	or     $0x8,%ah
  8013df:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8013e5:	0f 44 c1             	cmove  %ecx,%eax
  8013e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013eb:	e9 59 ff ff ff       	jmp    801349 <fork+0x63>
  8013f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f5:	0f 4f c2             	cmovg  %edx,%eax
  8013f8:	e9 32 ff ff ff       	jmp    80132f <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8013fd:	83 ec 04             	sub    $0x4,%esp
  801400:	6a 07                	push   $0x7
  801402:	68 00 f0 bf ee       	push   $0xeebff000
  801407:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80140a:	57                   	push   %edi
  80140b:	e8 86 fb ff ff       	call   800f96 <sys_page_alloc>
	if(r<0) return r;
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	85 c0                	test   %eax,%eax
  801415:	0f 88 14 ff ff ff    	js     80132f <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	68 d7 2a 80 00       	push   $0x802ad7
  801423:	57                   	push   %edi
  801424:	e8 b8 fc ff ff       	call   8010e1 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	0f 88 fb fe ff ff    	js     80132f <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	6a 02                	push   $0x2
  801439:	57                   	push   %edi
  80143a:	e8 1e fc ff ff       	call   80105d <sys_env_set_status>
	if(r<0) return r;
  80143f:	83 c4 10             	add    $0x10,%esp
	return envid;
  801442:	85 c0                	test   %eax,%eax
  801444:	0f 49 c7             	cmovns %edi,%eax
  801447:	e9 e3 fe ff ff       	jmp    80132f <fork+0x49>

0080144c <sfork>:

// Challenge!
int
sfork(void)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801452:	68 c1 33 80 00       	push   $0x8033c1
  801457:	68 a1 00 00 00       	push   $0xa1
  80145c:	68 88 33 80 00       	push   $0x803388
  801461:	e8 7f f0 ff ff       	call   8004e5 <_panic>

00801466 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	05 00 00 00 30       	add    $0x30000000,%eax
  801471:	c1 e8 0c             	shr    $0xc,%eax
}
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801481:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801486:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    

0080148d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801495:	89 c2                	mov    %eax,%edx
  801497:	c1 ea 16             	shr    $0x16,%edx
  80149a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a1:	f6 c2 01             	test   $0x1,%dl
  8014a4:	74 29                	je     8014cf <fd_alloc+0x42>
  8014a6:	89 c2                	mov    %eax,%edx
  8014a8:	c1 ea 0c             	shr    $0xc,%edx
  8014ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b2:	f6 c2 01             	test   $0x1,%dl
  8014b5:	74 18                	je     8014cf <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8014b7:	05 00 10 00 00       	add    $0x1000,%eax
  8014bc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014c1:	75 d2                	jne    801495 <fd_alloc+0x8>
  8014c3:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8014c8:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8014cd:	eb 05                	jmp    8014d4 <fd_alloc+0x47>
			return 0;
  8014cf:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8014d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d7:	89 02                	mov    %eax,(%edx)
}
  8014d9:	89 c8                	mov    %ecx,%eax
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e3:	83 f8 1f             	cmp    $0x1f,%eax
  8014e6:	77 30                	ja     801518 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014e8:	c1 e0 0c             	shl    $0xc,%eax
  8014eb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f0:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014f6:	f6 c2 01             	test   $0x1,%dl
  8014f9:	74 24                	je     80151f <fd_lookup+0x42>
  8014fb:	89 c2                	mov    %eax,%edx
  8014fd:	c1 ea 0c             	shr    $0xc,%edx
  801500:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801507:	f6 c2 01             	test   $0x1,%dl
  80150a:	74 1a                	je     801526 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80150c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150f:	89 02                	mov    %eax,(%edx)
	return 0;
  801511:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    
		return -E_INVAL;
  801518:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151d:	eb f7                	jmp    801516 <fd_lookup+0x39>
		return -E_INVAL;
  80151f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801524:	eb f0                	jmp    801516 <fd_lookup+0x39>
  801526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152b:	eb e9                	jmp    801516 <fd_lookup+0x39>

0080152d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801537:	b8 00 00 00 00       	mov    $0x0,%eax
  80153c:	bb 20 40 80 00       	mov    $0x804020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801541:	39 13                	cmp    %edx,(%ebx)
  801543:	74 37                	je     80157c <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801545:	83 c0 01             	add    $0x1,%eax
  801548:	8b 1c 85 54 34 80 00 	mov    0x803454(,%eax,4),%ebx
  80154f:	85 db                	test   %ebx,%ebx
  801551:	75 ee                	jne    801541 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801553:	a1 00 50 80 00       	mov    0x805000,%eax
  801558:	8b 40 48             	mov    0x48(%eax),%eax
  80155b:	83 ec 04             	sub    $0x4,%esp
  80155e:	52                   	push   %edx
  80155f:	50                   	push   %eax
  801560:	68 d8 33 80 00       	push   $0x8033d8
  801565:	e8 56 f0 ff ff       	call   8005c0 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801572:	8b 55 0c             	mov    0xc(%ebp),%edx
  801575:	89 1a                	mov    %ebx,(%edx)
}
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    
			return 0;
  80157c:	b8 00 00 00 00       	mov    $0x0,%eax
  801581:	eb ef                	jmp    801572 <dev_lookup+0x45>

00801583 <fd_close>:
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	57                   	push   %edi
  801587:	56                   	push   %esi
  801588:	53                   	push   %ebx
  801589:	83 ec 24             	sub    $0x24,%esp
  80158c:	8b 75 08             	mov    0x8(%ebp),%esi
  80158f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801592:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801595:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801596:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80159c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80159f:	50                   	push   %eax
  8015a0:	e8 38 ff ff ff       	call   8014dd <fd_lookup>
  8015a5:	89 c3                	mov    %eax,%ebx
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 05                	js     8015b3 <fd_close+0x30>
	    || fd != fd2)
  8015ae:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8015b1:	74 16                	je     8015c9 <fd_close+0x46>
		return (must_exist ? r : 0);
  8015b3:	89 f8                	mov    %edi,%eax
  8015b5:	84 c0                	test   %al,%al
  8015b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bc:	0f 44 d8             	cmove  %eax,%ebx
}
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	ff 36                	push   (%esi)
  8015d2:	e8 56 ff ff ff       	call   80152d <dev_lookup>
  8015d7:	89 c3                	mov    %eax,%ebx
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	85 c0                	test   %eax,%eax
  8015de:	78 1a                	js     8015fa <fd_close+0x77>
		if (dev->dev_close)
  8015e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015e3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	74 0b                	je     8015fa <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	56                   	push   %esi
  8015f3:	ff d0                	call   *%eax
  8015f5:	89 c3                	mov    %eax,%ebx
  8015f7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015fa:	83 ec 08             	sub    $0x8,%esp
  8015fd:	56                   	push   %esi
  8015fe:	6a 00                	push   $0x0
  801600:	e8 16 fa ff ff       	call   80101b <sys_page_unmap>
	return r;
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	eb b5                	jmp    8015bf <fd_close+0x3c>

0080160a <close>:

int
close(int fdnum)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	ff 75 08             	push   0x8(%ebp)
  801617:	e8 c1 fe ff ff       	call   8014dd <fd_lookup>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	79 02                	jns    801625 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801623:	c9                   	leave  
  801624:	c3                   	ret    
		return fd_close(fd, 1);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	6a 01                	push   $0x1
  80162a:	ff 75 f4             	push   -0xc(%ebp)
  80162d:	e8 51 ff ff ff       	call   801583 <fd_close>
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	eb ec                	jmp    801623 <close+0x19>

00801637 <close_all>:

void
close_all(void)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	53                   	push   %ebx
  801647:	e8 be ff ff ff       	call   80160a <close>
	for (i = 0; i < MAXFD; i++)
  80164c:	83 c3 01             	add    $0x1,%ebx
  80164f:	83 c4 10             	add    $0x10,%esp
  801652:	83 fb 20             	cmp    $0x20,%ebx
  801655:	75 ec                	jne    801643 <close_all+0xc>
}
  801657:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	57                   	push   %edi
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801665:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	ff 75 08             	push   0x8(%ebp)
  80166c:	e8 6c fe ff ff       	call   8014dd <fd_lookup>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 7f                	js     8016f9 <dup+0x9d>
		return r;
	close(newfdnum);
  80167a:	83 ec 0c             	sub    $0xc,%esp
  80167d:	ff 75 0c             	push   0xc(%ebp)
  801680:	e8 85 ff ff ff       	call   80160a <close>

	newfd = INDEX2FD(newfdnum);
  801685:	8b 75 0c             	mov    0xc(%ebp),%esi
  801688:	c1 e6 0c             	shl    $0xc,%esi
  80168b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801694:	89 3c 24             	mov    %edi,(%esp)
  801697:	e8 da fd ff ff       	call   801476 <fd2data>
  80169c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80169e:	89 34 24             	mov    %esi,(%esp)
  8016a1:	e8 d0 fd ff ff       	call   801476 <fd2data>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016ac:	89 d8                	mov    %ebx,%eax
  8016ae:	c1 e8 16             	shr    $0x16,%eax
  8016b1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b8:	a8 01                	test   $0x1,%al
  8016ba:	74 11                	je     8016cd <dup+0x71>
  8016bc:	89 d8                	mov    %ebx,%eax
  8016be:	c1 e8 0c             	shr    $0xc,%eax
  8016c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016c8:	f6 c2 01             	test   $0x1,%dl
  8016cb:	75 36                	jne    801703 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016cd:	89 f8                	mov    %edi,%eax
  8016cf:	c1 e8 0c             	shr    $0xc,%eax
  8016d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d9:	83 ec 0c             	sub    $0xc,%esp
  8016dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e1:	50                   	push   %eax
  8016e2:	56                   	push   %esi
  8016e3:	6a 00                	push   $0x0
  8016e5:	57                   	push   %edi
  8016e6:	6a 00                	push   $0x0
  8016e8:	e8 ec f8 ff ff       	call   800fd9 <sys_page_map>
  8016ed:	89 c3                	mov    %eax,%ebx
  8016ef:	83 c4 20             	add    $0x20,%esp
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	78 33                	js     801729 <dup+0xcd>
		goto err;

	return newfdnum;
  8016f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016f9:	89 d8                	mov    %ebx,%eax
  8016fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fe:	5b                   	pop    %ebx
  8016ff:	5e                   	pop    %esi
  801700:	5f                   	pop    %edi
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801703:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80170a:	83 ec 0c             	sub    $0xc,%esp
  80170d:	25 07 0e 00 00       	and    $0xe07,%eax
  801712:	50                   	push   %eax
  801713:	ff 75 d4             	push   -0x2c(%ebp)
  801716:	6a 00                	push   $0x0
  801718:	53                   	push   %ebx
  801719:	6a 00                	push   $0x0
  80171b:	e8 b9 f8 ff ff       	call   800fd9 <sys_page_map>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 20             	add    $0x20,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	79 a4                	jns    8016cd <dup+0x71>
	sys_page_unmap(0, newfd);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	56                   	push   %esi
  80172d:	6a 00                	push   $0x0
  80172f:	e8 e7 f8 ff ff       	call   80101b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801734:	83 c4 08             	add    $0x8,%esp
  801737:	ff 75 d4             	push   -0x2c(%ebp)
  80173a:	6a 00                	push   $0x0
  80173c:	e8 da f8 ff ff       	call   80101b <sys_page_unmap>
	return r;
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	eb b3                	jmp    8016f9 <dup+0x9d>

00801746 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	83 ec 18             	sub    $0x18,%esp
  80174e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801751:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801754:	50                   	push   %eax
  801755:	56                   	push   %esi
  801756:	e8 82 fd ff ff       	call   8014dd <fd_lookup>
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 3c                	js     80179e <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801762:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801765:	83 ec 08             	sub    $0x8,%esp
  801768:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176b:	50                   	push   %eax
  80176c:	ff 33                	push   (%ebx)
  80176e:	e8 ba fd ff ff       	call   80152d <dev_lookup>
  801773:	83 c4 10             	add    $0x10,%esp
  801776:	85 c0                	test   %eax,%eax
  801778:	78 24                	js     80179e <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80177a:	8b 43 08             	mov    0x8(%ebx),%eax
  80177d:	83 e0 03             	and    $0x3,%eax
  801780:	83 f8 01             	cmp    $0x1,%eax
  801783:	74 20                	je     8017a5 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801788:	8b 40 08             	mov    0x8(%eax),%eax
  80178b:	85 c0                	test   %eax,%eax
  80178d:	74 37                	je     8017c6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80178f:	83 ec 04             	sub    $0x4,%esp
  801792:	ff 75 10             	push   0x10(%ebp)
  801795:	ff 75 0c             	push   0xc(%ebp)
  801798:	53                   	push   %ebx
  801799:	ff d0                	call   *%eax
  80179b:	83 c4 10             	add    $0x10,%esp
}
  80179e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017a5:	a1 00 50 80 00       	mov    0x805000,%eax
  8017aa:	8b 40 48             	mov    0x48(%eax),%eax
  8017ad:	83 ec 04             	sub    $0x4,%esp
  8017b0:	56                   	push   %esi
  8017b1:	50                   	push   %eax
  8017b2:	68 19 34 80 00       	push   $0x803419
  8017b7:	e8 04 ee ff ff       	call   8005c0 <cprintf>
		return -E_INVAL;
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c4:	eb d8                	jmp    80179e <read+0x58>
		return -E_NOT_SUPP;
  8017c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017cb:	eb d1                	jmp    80179e <read+0x58>

008017cd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	57                   	push   %edi
  8017d1:	56                   	push   %esi
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 0c             	sub    $0xc,%esp
  8017d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017d9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e1:	eb 02                	jmp    8017e5 <readn+0x18>
  8017e3:	01 c3                	add    %eax,%ebx
  8017e5:	39 f3                	cmp    %esi,%ebx
  8017e7:	73 21                	jae    80180a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017e9:	83 ec 04             	sub    $0x4,%esp
  8017ec:	89 f0                	mov    %esi,%eax
  8017ee:	29 d8                	sub    %ebx,%eax
  8017f0:	50                   	push   %eax
  8017f1:	89 d8                	mov    %ebx,%eax
  8017f3:	03 45 0c             	add    0xc(%ebp),%eax
  8017f6:	50                   	push   %eax
  8017f7:	57                   	push   %edi
  8017f8:	e8 49 ff ff ff       	call   801746 <read>
		if (m < 0)
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	85 c0                	test   %eax,%eax
  801802:	78 04                	js     801808 <readn+0x3b>
			return m;
		if (m == 0)
  801804:	75 dd                	jne    8017e3 <readn+0x16>
  801806:	eb 02                	jmp    80180a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801808:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80180a:	89 d8                	mov    %ebx,%eax
  80180c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180f:	5b                   	pop    %ebx
  801810:	5e                   	pop    %esi
  801811:	5f                   	pop    %edi
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	56                   	push   %esi
  801818:	53                   	push   %ebx
  801819:	83 ec 18             	sub    $0x18,%esp
  80181c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801822:	50                   	push   %eax
  801823:	53                   	push   %ebx
  801824:	e8 b4 fc ff ff       	call   8014dd <fd_lookup>
  801829:	83 c4 10             	add    $0x10,%esp
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 37                	js     801867 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801830:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801839:	50                   	push   %eax
  80183a:	ff 36                	push   (%esi)
  80183c:	e8 ec fc ff ff       	call   80152d <dev_lookup>
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	85 c0                	test   %eax,%eax
  801846:	78 1f                	js     801867 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801848:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80184c:	74 20                	je     80186e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80184e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801851:	8b 40 0c             	mov    0xc(%eax),%eax
  801854:	85 c0                	test   %eax,%eax
  801856:	74 37                	je     80188f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801858:	83 ec 04             	sub    $0x4,%esp
  80185b:	ff 75 10             	push   0x10(%ebp)
  80185e:	ff 75 0c             	push   0xc(%ebp)
  801861:	56                   	push   %esi
  801862:	ff d0                	call   *%eax
  801864:	83 c4 10             	add    $0x10,%esp
}
  801867:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186a:	5b                   	pop    %ebx
  80186b:	5e                   	pop    %esi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80186e:	a1 00 50 80 00       	mov    0x805000,%eax
  801873:	8b 40 48             	mov    0x48(%eax),%eax
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	53                   	push   %ebx
  80187a:	50                   	push   %eax
  80187b:	68 35 34 80 00       	push   $0x803435
  801880:	e8 3b ed ff ff       	call   8005c0 <cprintf>
		return -E_INVAL;
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80188d:	eb d8                	jmp    801867 <write+0x53>
		return -E_NOT_SUPP;
  80188f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801894:	eb d1                	jmp    801867 <write+0x53>

00801896 <seek>:

int
seek(int fdnum, off_t offset)
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80189c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	ff 75 08             	push   0x8(%ebp)
  8018a3:	e8 35 fc ff ff       	call   8014dd <fd_lookup>
  8018a8:	83 c4 10             	add    $0x10,%esp
  8018ab:	85 c0                	test   %eax,%eax
  8018ad:	78 0e                	js     8018bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	83 ec 18             	sub    $0x18,%esp
  8018c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cd:	50                   	push   %eax
  8018ce:	53                   	push   %ebx
  8018cf:	e8 09 fc ff ff       	call   8014dd <fd_lookup>
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 c0                	test   %eax,%eax
  8018d9:	78 34                	js     80190f <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018db:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018de:	83 ec 08             	sub    $0x8,%esp
  8018e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e4:	50                   	push   %eax
  8018e5:	ff 36                	push   (%esi)
  8018e7:	e8 41 fc ff ff       	call   80152d <dev_lookup>
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 1c                	js     80190f <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f3:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8018f7:	74 1d                	je     801916 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fc:	8b 40 18             	mov    0x18(%eax),%eax
  8018ff:	85 c0                	test   %eax,%eax
  801901:	74 34                	je     801937 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	ff 75 0c             	push   0xc(%ebp)
  801909:	56                   	push   %esi
  80190a:	ff d0                	call   *%eax
  80190c:	83 c4 10             	add    $0x10,%esp
}
  80190f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801912:	5b                   	pop    %ebx
  801913:	5e                   	pop    %esi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    
			thisenv->env_id, fdnum);
  801916:	a1 00 50 80 00       	mov    0x805000,%eax
  80191b:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80191e:	83 ec 04             	sub    $0x4,%esp
  801921:	53                   	push   %ebx
  801922:	50                   	push   %eax
  801923:	68 f8 33 80 00       	push   $0x8033f8
  801928:	e8 93 ec ff ff       	call   8005c0 <cprintf>
		return -E_INVAL;
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801935:	eb d8                	jmp    80190f <ftruncate+0x50>
		return -E_NOT_SUPP;
  801937:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80193c:	eb d1                	jmp    80190f <ftruncate+0x50>

0080193e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	56                   	push   %esi
  801942:	53                   	push   %ebx
  801943:	83 ec 18             	sub    $0x18,%esp
  801946:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801949:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80194c:	50                   	push   %eax
  80194d:	ff 75 08             	push   0x8(%ebp)
  801950:	e8 88 fb ff ff       	call   8014dd <fd_lookup>
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 49                	js     8019a5 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80195c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801965:	50                   	push   %eax
  801966:	ff 36                	push   (%esi)
  801968:	e8 c0 fb ff ff       	call   80152d <dev_lookup>
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	78 31                	js     8019a5 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801974:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801977:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80197b:	74 2f                	je     8019ac <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80197d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801980:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801987:	00 00 00 
	stat->st_isdir = 0;
  80198a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801991:	00 00 00 
	stat->st_dev = dev;
  801994:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80199a:	83 ec 08             	sub    $0x8,%esp
  80199d:	53                   	push   %ebx
  80199e:	56                   	push   %esi
  80199f:	ff 50 14             	call   *0x14(%eax)
  8019a2:	83 c4 10             	add    $0x10,%esp
}
  8019a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a8:	5b                   	pop    %ebx
  8019a9:	5e                   	pop    %esi
  8019aa:	5d                   	pop    %ebp
  8019ab:	c3                   	ret    
		return -E_NOT_SUPP;
  8019ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b1:	eb f2                	jmp    8019a5 <fstat+0x67>

008019b3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b8:	83 ec 08             	sub    $0x8,%esp
  8019bb:	6a 00                	push   $0x0
  8019bd:	ff 75 08             	push   0x8(%ebp)
  8019c0:	e8 e4 01 00 00       	call   801ba9 <open>
  8019c5:	89 c3                	mov    %eax,%ebx
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	78 1b                	js     8019e9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019ce:	83 ec 08             	sub    $0x8,%esp
  8019d1:	ff 75 0c             	push   0xc(%ebp)
  8019d4:	50                   	push   %eax
  8019d5:	e8 64 ff ff ff       	call   80193e <fstat>
  8019da:	89 c6                	mov    %eax,%esi
	close(fd);
  8019dc:	89 1c 24             	mov    %ebx,(%esp)
  8019df:	e8 26 fc ff ff       	call   80160a <close>
	return r;
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	89 f3                	mov    %esi,%ebx
}
  8019e9:	89 d8                	mov    %ebx,%eax
  8019eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	5d                   	pop    %ebp
  8019f1:	c3                   	ret    

008019f2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	89 c6                	mov    %eax,%esi
  8019f9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019fb:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801a02:	74 27                	je     801a2b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a04:	6a 07                	push   $0x7
  801a06:	68 00 60 80 00       	push   $0x806000
  801a0b:	56                   	push   %esi
  801a0c:	ff 35 00 70 80 00    	push   0x807000
  801a12:	e8 4d 11 00 00       	call   802b64 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a17:	83 c4 0c             	add    $0xc,%esp
  801a1a:	6a 00                	push   $0x0
  801a1c:	53                   	push   %ebx
  801a1d:	6a 00                	push   $0x0
  801a1f:	e8 d9 10 00 00       	call   802afd <ipc_recv>
}
  801a24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	6a 01                	push   $0x1
  801a30:	e8 83 11 00 00       	call   802bb8 <ipc_find_env>
  801a35:	a3 00 70 80 00       	mov    %eax,0x807000
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	eb c5                	jmp    801a04 <fsipc+0x12>

00801a3f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a45:	8b 45 08             	mov    0x8(%ebp),%eax
  801a48:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a53:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a58:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5d:	b8 02 00 00 00       	mov    $0x2,%eax
  801a62:	e8 8b ff ff ff       	call   8019f2 <fsipc>
}
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <devfile_flush>:
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a72:	8b 40 0c             	mov    0xc(%eax),%eax
  801a75:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a7a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7f:	b8 06 00 00 00       	mov    $0x6,%eax
  801a84:	e8 69 ff ff ff       	call   8019f2 <fsipc>
}
  801a89:	c9                   	leave  
  801a8a:	c3                   	ret    

00801a8b <devfile_stat>:
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 04             	sub    $0x4,%esp
  801a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a95:	8b 45 08             	mov    0x8(%ebp),%eax
  801a98:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9b:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa5:	b8 05 00 00 00       	mov    $0x5,%eax
  801aaa:	e8 43 ff ff ff       	call   8019f2 <fsipc>
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 2c                	js     801adf <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ab3:	83 ec 08             	sub    $0x8,%esp
  801ab6:	68 00 60 80 00       	push   $0x806000
  801abb:	53                   	push   %ebx
  801abc:	e8 d9 f0 ff ff       	call   800b9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ac1:	a1 80 60 80 00       	mov    0x806080,%eax
  801ac6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801acc:	a1 84 60 80 00       	mov    0x806084,%eax
  801ad1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <devfile_write>:
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	8b 45 10             	mov    0x10(%ebp),%eax
  801aed:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af2:	39 d0                	cmp    %edx,%eax
  801af4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801af7:	8b 55 08             	mov    0x8(%ebp),%edx
  801afa:	8b 52 0c             	mov    0xc(%edx),%edx
  801afd:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b03:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b08:	50                   	push   %eax
  801b09:	ff 75 0c             	push   0xc(%ebp)
  801b0c:	68 08 60 80 00       	push   $0x806008
  801b11:	e8 1a f2 ff ff       	call   800d30 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801b16:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  801b20:	e8 cd fe ff ff       	call   8019f2 <fsipc>
}
  801b25:	c9                   	leave  
  801b26:	c3                   	ret    

00801b27 <devfile_read>:
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b32:	8b 40 0c             	mov    0xc(%eax),%eax
  801b35:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b3a:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b40:	ba 00 00 00 00       	mov    $0x0,%edx
  801b45:	b8 03 00 00 00       	mov    $0x3,%eax
  801b4a:	e8 a3 fe ff ff       	call   8019f2 <fsipc>
  801b4f:	89 c3                	mov    %eax,%ebx
  801b51:	85 c0                	test   %eax,%eax
  801b53:	78 1f                	js     801b74 <devfile_read+0x4d>
	assert(r <= n);
  801b55:	39 f0                	cmp    %esi,%eax
  801b57:	77 24                	ja     801b7d <devfile_read+0x56>
	assert(r <= PGSIZE);
  801b59:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b5e:	7f 33                	jg     801b93 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b60:	83 ec 04             	sub    $0x4,%esp
  801b63:	50                   	push   %eax
  801b64:	68 00 60 80 00       	push   $0x806000
  801b69:	ff 75 0c             	push   0xc(%ebp)
  801b6c:	e8 bf f1 ff ff       	call   800d30 <memmove>
	return r;
  801b71:	83 c4 10             	add    $0x10,%esp
}
  801b74:	89 d8                	mov    %ebx,%eax
  801b76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    
	assert(r <= n);
  801b7d:	68 68 34 80 00       	push   $0x803468
  801b82:	68 6f 34 80 00       	push   $0x80346f
  801b87:	6a 7c                	push   $0x7c
  801b89:	68 84 34 80 00       	push   $0x803484
  801b8e:	e8 52 e9 ff ff       	call   8004e5 <_panic>
	assert(r <= PGSIZE);
  801b93:	68 8f 34 80 00       	push   $0x80348f
  801b98:	68 6f 34 80 00       	push   $0x80346f
  801b9d:	6a 7d                	push   $0x7d
  801b9f:	68 84 34 80 00       	push   $0x803484
  801ba4:	e8 3c e9 ff ff       	call   8004e5 <_panic>

00801ba9 <open>:
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
  801bac:	56                   	push   %esi
  801bad:	53                   	push   %ebx
  801bae:	83 ec 1c             	sub    $0x1c,%esp
  801bb1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bb4:	56                   	push   %esi
  801bb5:	e8 a5 ef ff ff       	call   800b5f <strlen>
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bc2:	7f 6c                	jg     801c30 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bca:	50                   	push   %eax
  801bcb:	e8 bd f8 ff ff       	call   80148d <fd_alloc>
  801bd0:	89 c3                	mov    %eax,%ebx
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	78 3c                	js     801c15 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801bd9:	83 ec 08             	sub    $0x8,%esp
  801bdc:	56                   	push   %esi
  801bdd:	68 00 60 80 00       	push   $0x806000
  801be2:	e8 b3 ef ff ff       	call   800b9a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bea:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf7:	e8 f6 fd ff ff       	call   8019f2 <fsipc>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 19                	js     801c1e <open+0x75>
	return fd2num(fd);
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	ff 75 f4             	push   -0xc(%ebp)
  801c0b:	e8 56 f8 ff ff       	call   801466 <fd2num>
  801c10:	89 c3                	mov    %eax,%ebx
  801c12:	83 c4 10             	add    $0x10,%esp
}
  801c15:	89 d8                	mov    %ebx,%eax
  801c17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c1a:	5b                   	pop    %ebx
  801c1b:	5e                   	pop    %esi
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    
		fd_close(fd, 0);
  801c1e:	83 ec 08             	sub    $0x8,%esp
  801c21:	6a 00                	push   $0x0
  801c23:	ff 75 f4             	push   -0xc(%ebp)
  801c26:	e8 58 f9 ff ff       	call   801583 <fd_close>
		return r;
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	eb e5                	jmp    801c15 <open+0x6c>
		return -E_BAD_PATH;
  801c30:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c35:	eb de                	jmp    801c15 <open+0x6c>

00801c37 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c42:	b8 08 00 00 00       	mov    $0x8,%eax
  801c47:	e8 a6 fd ff ff       	call   8019f2 <fsipc>
}
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    

00801c4e <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c5a:	6a 00                	push   $0x0
  801c5c:	ff 75 08             	push   0x8(%ebp)
  801c5f:	e8 45 ff ff ff       	call   801ba9 <open>
  801c64:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c6a:	83 c4 10             	add    $0x10,%esp
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	0f 88 aa 04 00 00    	js     80211f <spawn+0x4d1>
  801c75:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c77:	83 ec 04             	sub    $0x4,%esp
  801c7a:	68 00 02 00 00       	push   $0x200
  801c7f:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c85:	50                   	push   %eax
  801c86:	57                   	push   %edi
  801c87:	e8 41 fb ff ff       	call   8017cd <readn>
  801c8c:	83 c4 10             	add    $0x10,%esp
  801c8f:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c94:	75 57                	jne    801ced <spawn+0x9f>
	    || elf->e_magic != ELF_MAGIC) {
  801c96:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801c9d:	45 4c 46 
  801ca0:	75 4b                	jne    801ced <spawn+0x9f>
  801ca2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ca7:	cd 30                	int    $0x30
  801ca9:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	0f 88 5c 04 00 00    	js     802113 <spawn+0x4c5>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cb7:	25 ff 03 00 00       	and    $0x3ff,%eax
  801cbc:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801cbf:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801cc5:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801ccb:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cd0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cd2:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801cd8:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801cde:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801ce3:	be 00 00 00 00       	mov    $0x0,%esi
  801ce8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801ceb:	eb 4b                	jmp    801d38 <spawn+0xea>
		close(fd);
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801cf6:	e8 0f f9 ff ff       	call   80160a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801cfb:	83 c4 0c             	add    $0xc,%esp
  801cfe:	68 7f 45 4c 46       	push   $0x464c457f
  801d03:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801d09:	68 9b 34 80 00       	push   $0x80349b
  801d0e:	e8 ad e8 ff ff       	call   8005c0 <cprintf>
		return -E_NOT_EXEC;
  801d13:	83 c4 10             	add    $0x10,%esp
  801d16:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801d1d:	ff ff ff 
  801d20:	e9 fa 03 00 00       	jmp    80211f <spawn+0x4d1>
		string_size += strlen(argv[argc]) + 1;
  801d25:	83 ec 0c             	sub    $0xc,%esp
  801d28:	50                   	push   %eax
  801d29:	e8 31 ee ff ff       	call   800b5f <strlen>
  801d2e:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801d32:	83 c3 01             	add    $0x1,%ebx
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d3f:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d42:	85 c0                	test   %eax,%eax
  801d44:	75 df                	jne    801d25 <spawn+0xd7>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d46:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801d4c:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801d52:	b8 00 10 40 00       	mov    $0x401000,%eax
  801d57:	29 f0                	sub    %esi,%eax
  801d59:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d5b:	89 c2                	mov    %eax,%edx
  801d5d:	83 e2 fc             	and    $0xfffffffc,%edx
  801d60:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d67:	29 c2                	sub    %eax,%edx
  801d69:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d6f:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d72:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d77:	0f 86 14 04 00 00    	jbe    802191 <spawn+0x543>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	6a 07                	push   $0x7
  801d82:	68 00 00 40 00       	push   $0x400000
  801d87:	6a 00                	push   $0x0
  801d89:	e8 08 f2 ff ff       	call   800f96 <sys_page_alloc>
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	85 c0                	test   %eax,%eax
  801d93:	0f 88 fd 03 00 00    	js     802196 <spawn+0x548>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801d99:	be 00 00 00 00       	mov    $0x0,%esi
  801d9e:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801da4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801da7:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801dad:	7e 32                	jle    801de1 <spawn+0x193>
		argv_store[i] = UTEMP2USTACK(string_store);
  801daf:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801db5:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801dbb:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801dbe:	83 ec 08             	sub    $0x8,%esp
  801dc1:	ff 34 b3             	push   (%ebx,%esi,4)
  801dc4:	57                   	push   %edi
  801dc5:	e8 d0 ed ff ff       	call   800b9a <strcpy>
		string_store += strlen(argv[i]) + 1;
  801dca:	83 c4 04             	add    $0x4,%esp
  801dcd:	ff 34 b3             	push   (%ebx,%esi,4)
  801dd0:	e8 8a ed ff ff       	call   800b5f <strlen>
  801dd5:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801dd9:	83 c6 01             	add    $0x1,%esi
  801ddc:	83 c4 10             	add    $0x10,%esp
  801ddf:	eb c6                	jmp    801da7 <spawn+0x159>
	}
	argv_store[argc] = 0;
  801de1:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801de7:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801ded:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801df4:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801dfa:	0f 85 8c 00 00 00    	jne    801e8c <spawn+0x23e>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e00:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e06:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801e0c:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801e0f:	89 c8                	mov    %ecx,%eax
  801e11:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801e17:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e1a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801e1f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	6a 07                	push   $0x7
  801e2a:	68 00 d0 bf ee       	push   $0xeebfd000
  801e2f:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e35:	68 00 00 40 00       	push   $0x400000
  801e3a:	6a 00                	push   $0x0
  801e3c:	e8 98 f1 ff ff       	call   800fd9 <sys_page_map>
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	83 c4 20             	add    $0x20,%esp
  801e46:	85 c0                	test   %eax,%eax
  801e48:	0f 88 50 03 00 00    	js     80219e <spawn+0x550>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e4e:	83 ec 08             	sub    $0x8,%esp
  801e51:	68 00 00 40 00       	push   $0x400000
  801e56:	6a 00                	push   $0x0
  801e58:	e8 be f1 ff ff       	call   80101b <sys_page_unmap>
  801e5d:	89 c3                	mov    %eax,%ebx
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	0f 88 34 03 00 00    	js     80219e <spawn+0x550>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e6a:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e70:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e77:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e7d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801e84:	00 00 00 
  801e87:	e9 4e 01 00 00       	jmp    801fda <spawn+0x38c>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e8c:	68 28 35 80 00       	push   $0x803528
  801e91:	68 6f 34 80 00       	push   $0x80346f
  801e96:	68 f2 00 00 00       	push   $0xf2
  801e9b:	68 b5 34 80 00       	push   $0x8034b5
  801ea0:	e8 40 e6 ff ff       	call   8004e5 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ea5:	83 ec 04             	sub    $0x4,%esp
  801ea8:	6a 07                	push   $0x7
  801eaa:	68 00 00 40 00       	push   $0x400000
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 e0 f0 ff ff       	call   800f96 <sys_page_alloc>
  801eb6:	83 c4 10             	add    $0x10,%esp
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	0f 88 6c 02 00 00    	js     80212d <spawn+0x4df>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ec1:	83 ec 08             	sub    $0x8,%esp
  801ec4:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801eca:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ed0:	50                   	push   %eax
  801ed1:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801ed7:	e8 ba f9 ff ff       	call   801896 <seek>
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	0f 88 4d 02 00 00    	js     802134 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ee7:	83 ec 04             	sub    $0x4,%esp
  801eea:	89 f8                	mov    %edi,%eax
  801eec:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801ef2:	ba 00 10 00 00       	mov    $0x1000,%edx
  801ef7:	39 d0                	cmp    %edx,%eax
  801ef9:	0f 47 c2             	cmova  %edx,%eax
  801efc:	50                   	push   %eax
  801efd:	68 00 00 40 00       	push   $0x400000
  801f02:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801f08:	e8 c0 f8 ff ff       	call   8017cd <readn>
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	0f 88 23 02 00 00    	js     80213b <spawn+0x4ed>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f18:	83 ec 0c             	sub    $0xc,%esp
  801f1b:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801f21:	56                   	push   %esi
  801f22:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f28:	68 00 00 40 00       	push   $0x400000
  801f2d:	6a 00                	push   $0x0
  801f2f:	e8 a5 f0 ff ff       	call   800fd9 <sys_page_map>
  801f34:	83 c4 20             	add    $0x20,%esp
  801f37:	85 c0                	test   %eax,%eax
  801f39:	78 7c                	js     801fb7 <spawn+0x369>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801f3b:	83 ec 08             	sub    $0x8,%esp
  801f3e:	68 00 00 40 00       	push   $0x400000
  801f43:	6a 00                	push   $0x0
  801f45:	e8 d1 f0 ff ff       	call   80101b <sys_page_unmap>
  801f4a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801f4d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f53:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f59:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f5f:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801f65:	76 65                	jbe    801fcc <spawn+0x37e>
		if (i >= filesz) {
  801f67:	39 df                	cmp    %ebx,%edi
  801f69:	0f 87 36 ff ff ff    	ja     801ea5 <spawn+0x257>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f6f:	83 ec 04             	sub    $0x4,%esp
  801f72:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801f78:	56                   	push   %esi
  801f79:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f7f:	e8 12 f0 ff ff       	call   800f96 <sys_page_alloc>
  801f84:	83 c4 10             	add    $0x10,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	79 c2                	jns    801f4d <spawn+0x2ff>
  801f8b:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801f8d:	83 ec 0c             	sub    $0xc,%esp
  801f90:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f96:	e8 7c ef ff ff       	call   800f17 <sys_env_destroy>
	close(fd);
  801f9b:	83 c4 04             	add    $0x4,%esp
  801f9e:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801fa4:	e8 61 f6 ff ff       	call   80160a <close>
	return r;
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801fb2:	e9 68 01 00 00       	jmp    80211f <spawn+0x4d1>
				panic("spawn: sys_page_map data: %e", r);
  801fb7:	50                   	push   %eax
  801fb8:	68 c1 34 80 00       	push   $0x8034c1
  801fbd:	68 25 01 00 00       	push   $0x125
  801fc2:	68 b5 34 80 00       	push   $0x8034b5
  801fc7:	e8 19 e5 ff ff       	call   8004e5 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fcc:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801fd3:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801fda:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801fe1:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801fe7:	7e 67                	jle    802050 <spawn+0x402>
		if (ph->p_type != ELF_PROG_LOAD)
  801fe9:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801fef:	83 39 01             	cmpl   $0x1,(%ecx)
  801ff2:	75 d8                	jne    801fcc <spawn+0x37e>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ff4:	8b 41 18             	mov    0x18(%ecx),%eax
  801ff7:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801ffd:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802000:	83 f8 01             	cmp    $0x1,%eax
  802003:	19 c0                	sbb    %eax,%eax
  802005:	83 e0 fe             	and    $0xfffffffe,%eax
  802008:	83 c0 07             	add    $0x7,%eax
  80200b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802011:	8b 51 04             	mov    0x4(%ecx),%edx
  802014:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  80201a:	8b 79 10             	mov    0x10(%ecx),%edi
  80201d:	8b 59 14             	mov    0x14(%ecx),%ebx
  802020:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802026:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  802029:	89 f0                	mov    %esi,%eax
  80202b:	25 ff 0f 00 00       	and    $0xfff,%eax
  802030:	74 14                	je     802046 <spawn+0x3f8>
		va -= i;
  802032:	29 c6                	sub    %eax,%esi
		memsz += i;
  802034:	01 c3                	add    %eax,%ebx
  802036:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  80203c:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80203e:	29 c2                	sub    %eax,%edx
  802040:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  802046:	bb 00 00 00 00       	mov    $0x0,%ebx
  80204b:	e9 09 ff ff ff       	jmp    801f59 <spawn+0x30b>
	close(fd);
  802050:	83 ec 0c             	sub    $0xc,%esp
  802053:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802059:	e8 ac f5 ff ff       	call   80160a <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  80205e:	e8 f5 ee ff ff       	call   800f58 <sys_getenvid>
  802063:	89 c6                	mov    %eax,%esi
  802065:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  802068:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80206d:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  802073:	eb 12                	jmp    802087 <spawn+0x439>
  802075:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80207b:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  802081:	0f 84 bb 00 00 00    	je     802142 <spawn+0x4f4>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  802087:	89 d8                	mov    %ebx,%eax
  802089:	c1 e8 16             	shr    $0x16,%eax
  80208c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802093:	a8 01                	test   $0x1,%al
  802095:	74 de                	je     802075 <spawn+0x427>
  802097:	89 d8                	mov    %ebx,%eax
  802099:	c1 e8 0c             	shr    $0xc,%eax
  80209c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020a3:	f6 c2 01             	test   $0x1,%dl
  8020a6:	74 cd                	je     802075 <spawn+0x427>
  8020a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020af:	f6 c6 04             	test   $0x4,%dh
  8020b2:	74 c1                	je     802075 <spawn+0x427>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  8020b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020bb:	83 ec 0c             	sub    $0xc,%esp
  8020be:	25 07 0e 00 00       	and    $0xe07,%eax
  8020c3:	50                   	push   %eax
  8020c4:	53                   	push   %ebx
  8020c5:	57                   	push   %edi
  8020c6:	53                   	push   %ebx
  8020c7:	56                   	push   %esi
  8020c8:	e8 0c ef ff ff       	call   800fd9 <sys_page_map>
  8020cd:	83 c4 20             	add    $0x20,%esp
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	79 a1                	jns    802075 <spawn+0x427>
		panic("copy_shared_pages: %e", r);
  8020d4:	50                   	push   %eax
  8020d5:	68 0f 35 80 00       	push   $0x80350f
  8020da:	68 82 00 00 00       	push   $0x82
  8020df:	68 b5 34 80 00       	push   $0x8034b5
  8020e4:	e8 fc e3 ff ff       	call   8004e5 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  8020e9:	50                   	push   %eax
  8020ea:	68 de 34 80 00       	push   $0x8034de
  8020ef:	68 86 00 00 00       	push   $0x86
  8020f4:	68 b5 34 80 00       	push   $0x8034b5
  8020f9:	e8 e7 e3 ff ff       	call   8004e5 <_panic>
		panic("sys_env_set_status: %e", r);
  8020fe:	50                   	push   %eax
  8020ff:	68 f8 34 80 00       	push   $0x8034f8
  802104:	68 89 00 00 00       	push   $0x89
  802109:	68 b5 34 80 00       	push   $0x8034b5
  80210e:	e8 d2 e3 ff ff       	call   8004e5 <_panic>
		return r;
  802113:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802119:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  80211f:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802128:	5b                   	pop    %ebx
  802129:	5e                   	pop    %esi
  80212a:	5f                   	pop    %edi
  80212b:	5d                   	pop    %ebp
  80212c:	c3                   	ret    
  80212d:	89 c7                	mov    %eax,%edi
  80212f:	e9 59 fe ff ff       	jmp    801f8d <spawn+0x33f>
  802134:	89 c7                	mov    %eax,%edi
  802136:	e9 52 fe ff ff       	jmp    801f8d <spawn+0x33f>
  80213b:	89 c7                	mov    %eax,%edi
  80213d:	e9 4b fe ff ff       	jmp    801f8d <spawn+0x33f>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802142:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802149:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80214c:	83 ec 08             	sub    $0x8,%esp
  80214f:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802155:	50                   	push   %eax
  802156:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80215c:	e8 3e ef ff ff       	call   80109f <sys_env_set_trapframe>
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	85 c0                	test   %eax,%eax
  802166:	78 81                	js     8020e9 <spawn+0x49b>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802168:	83 ec 08             	sub    $0x8,%esp
  80216b:	6a 02                	push   $0x2
  80216d:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802173:	e8 e5 ee ff ff       	call   80105d <sys_env_set_status>
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	85 c0                	test   %eax,%eax
  80217d:	0f 88 7b ff ff ff    	js     8020fe <spawn+0x4b0>
	return child;
  802183:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802189:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80218f:	eb 8e                	jmp    80211f <spawn+0x4d1>
		return -E_NO_MEM;
  802191:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802196:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80219c:	eb 81                	jmp    80211f <spawn+0x4d1>
	sys_page_unmap(0, UTEMP);
  80219e:	83 ec 08             	sub    $0x8,%esp
  8021a1:	68 00 00 40 00       	push   $0x400000
  8021a6:	6a 00                	push   $0x0
  8021a8:	e8 6e ee ff ff       	call   80101b <sys_page_unmap>
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8021b6:	e9 64 ff ff ff       	jmp    80211f <spawn+0x4d1>

008021bb <spawnl>:
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	56                   	push   %esi
  8021bf:	53                   	push   %ebx
	va_start(vl, arg0);
  8021c0:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  8021c3:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  8021c8:	eb 05                	jmp    8021cf <spawnl+0x14>
		argc++;
  8021ca:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  8021cd:	89 ca                	mov    %ecx,%edx
  8021cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8021d2:	83 3a 00             	cmpl   $0x0,(%edx)
  8021d5:	75 f3                	jne    8021ca <spawnl+0xf>
	const char *argv[argc+2];
  8021d7:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  8021de:	89 d3                	mov    %edx,%ebx
  8021e0:	83 e3 f0             	and    $0xfffffff0,%ebx
  8021e3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8021e9:	89 e1                	mov    %esp,%ecx
  8021eb:	29 d1                	sub    %edx,%ecx
  8021ed:	39 cc                	cmp    %ecx,%esp
  8021ef:	74 10                	je     802201 <spawnl+0x46>
  8021f1:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  8021f7:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  8021fe:	00 
  8021ff:	eb ec                	jmp    8021ed <spawnl+0x32>
  802201:	89 da                	mov    %ebx,%edx
  802203:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802209:	29 d4                	sub    %edx,%esp
  80220b:	85 d2                	test   %edx,%edx
  80220d:	74 05                	je     802214 <spawnl+0x59>
  80220f:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802214:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  802218:	89 da                	mov    %ebx,%edx
  80221a:	c1 ea 02             	shr    $0x2,%edx
  80221d:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  802220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802223:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  80222a:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  802231:	00 
	va_start(vl, arg0);
  802232:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802235:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802237:	b8 00 00 00 00       	mov    $0x0,%eax
  80223c:	eb 0b                	jmp    802249 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  80223e:	83 c0 01             	add    $0x1,%eax
  802241:	8b 31                	mov    (%ecx),%esi
  802243:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  802246:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802249:	39 d0                	cmp    %edx,%eax
  80224b:	75 f1                	jne    80223e <spawnl+0x83>
	return spawn(prog, argv);
  80224d:	83 ec 08             	sub    $0x8,%esp
  802250:	53                   	push   %ebx
  802251:	ff 75 08             	push   0x8(%ebp)
  802254:	e8 f5 f9 ff ff       	call   801c4e <spawn>
}
  802259:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    

00802260 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  802266:	68 4e 35 80 00       	push   $0x80354e
  80226b:	ff 75 0c             	push   0xc(%ebp)
  80226e:	e8 27 e9 ff ff       	call   800b9a <strcpy>
	return 0;
}
  802273:	b8 00 00 00 00       	mov    $0x0,%eax
  802278:	c9                   	leave  
  802279:	c3                   	ret    

0080227a <devsock_close>:
{
  80227a:	55                   	push   %ebp
  80227b:	89 e5                	mov    %esp,%ebp
  80227d:	53                   	push   %ebx
  80227e:	83 ec 10             	sub    $0x10,%esp
  802281:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802284:	53                   	push   %ebx
  802285:	e8 67 09 00 00       	call   802bf1 <pageref>
  80228a:	89 c2                	mov    %eax,%edx
  80228c:	83 c4 10             	add    $0x10,%esp
		return 0;
  80228f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  802294:	83 fa 01             	cmp    $0x1,%edx
  802297:	74 05                	je     80229e <devsock_close+0x24>
}
  802299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80229e:	83 ec 0c             	sub    $0xc,%esp
  8022a1:	ff 73 0c             	push   0xc(%ebx)
  8022a4:	e8 b7 02 00 00       	call   802560 <nsipc_close>
  8022a9:	83 c4 10             	add    $0x10,%esp
  8022ac:	eb eb                	jmp    802299 <devsock_close+0x1f>

008022ae <devsock_write>:
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8022b4:	6a 00                	push   $0x0
  8022b6:	ff 75 10             	push   0x10(%ebp)
  8022b9:	ff 75 0c             	push   0xc(%ebp)
  8022bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bf:	ff 70 0c             	push   0xc(%eax)
  8022c2:	e8 79 03 00 00       	call   802640 <nsipc_send>
}
  8022c7:	c9                   	leave  
  8022c8:	c3                   	ret    

008022c9 <devsock_read>:
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8022cf:	6a 00                	push   $0x0
  8022d1:	ff 75 10             	push   0x10(%ebp)
  8022d4:	ff 75 0c             	push   0xc(%ebp)
  8022d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022da:	ff 70 0c             	push   0xc(%eax)
  8022dd:	e8 ef 02 00 00       	call   8025d1 <nsipc_recv>
}
  8022e2:	c9                   	leave  
  8022e3:	c3                   	ret    

008022e4 <fd2sockid>:
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8022ea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022ed:	52                   	push   %edx
  8022ee:	50                   	push   %eax
  8022ef:	e8 e9 f1 ff ff       	call   8014dd <fd_lookup>
  8022f4:	83 c4 10             	add    $0x10,%esp
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	78 10                	js     80230b <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8022fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fe:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  802304:	39 08                	cmp    %ecx,(%eax)
  802306:	75 05                	jne    80230d <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802308:	8b 40 0c             	mov    0xc(%eax),%eax
}
  80230b:	c9                   	leave  
  80230c:	c3                   	ret    
		return -E_NOT_SUPP;
  80230d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802312:	eb f7                	jmp    80230b <fd2sockid+0x27>

00802314 <alloc_sockfd>:
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	56                   	push   %esi
  802318:	53                   	push   %ebx
  802319:	83 ec 1c             	sub    $0x1c,%esp
  80231c:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80231e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802321:	50                   	push   %eax
  802322:	e8 66 f1 ff ff       	call   80148d <fd_alloc>
  802327:	89 c3                	mov    %eax,%ebx
  802329:	83 c4 10             	add    $0x10,%esp
  80232c:	85 c0                	test   %eax,%eax
  80232e:	78 43                	js     802373 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802330:	83 ec 04             	sub    $0x4,%esp
  802333:	68 07 04 00 00       	push   $0x407
  802338:	ff 75 f4             	push   -0xc(%ebp)
  80233b:	6a 00                	push   $0x0
  80233d:	e8 54 ec ff ff       	call   800f96 <sys_page_alloc>
  802342:	89 c3                	mov    %eax,%ebx
  802344:	83 c4 10             	add    $0x10,%esp
  802347:	85 c0                	test   %eax,%eax
  802349:	78 28                	js     802373 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  80234b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234e:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802354:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802356:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802359:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802360:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802363:	83 ec 0c             	sub    $0xc,%esp
  802366:	50                   	push   %eax
  802367:	e8 fa f0 ff ff       	call   801466 <fd2num>
  80236c:	89 c3                	mov    %eax,%ebx
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	eb 0c                	jmp    80237f <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  802373:	83 ec 0c             	sub    $0xc,%esp
  802376:	56                   	push   %esi
  802377:	e8 e4 01 00 00       	call   802560 <nsipc_close>
		return r;
  80237c:	83 c4 10             	add    $0x10,%esp
}
  80237f:	89 d8                	mov    %ebx,%eax
  802381:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5d                   	pop    %ebp
  802387:	c3                   	ret    

00802388 <accept>:
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80238e:	8b 45 08             	mov    0x8(%ebp),%eax
  802391:	e8 4e ff ff ff       	call   8022e4 <fd2sockid>
  802396:	85 c0                	test   %eax,%eax
  802398:	78 1b                	js     8023b5 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80239a:	83 ec 04             	sub    $0x4,%esp
  80239d:	ff 75 10             	push   0x10(%ebp)
  8023a0:	ff 75 0c             	push   0xc(%ebp)
  8023a3:	50                   	push   %eax
  8023a4:	e8 0e 01 00 00       	call   8024b7 <nsipc_accept>
  8023a9:	83 c4 10             	add    $0x10,%esp
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	78 05                	js     8023b5 <accept+0x2d>
	return alloc_sockfd(r);
  8023b0:	e8 5f ff ff ff       	call   802314 <alloc_sockfd>
}
  8023b5:	c9                   	leave  
  8023b6:	c3                   	ret    

008023b7 <bind>:
{
  8023b7:	55                   	push   %ebp
  8023b8:	89 e5                	mov    %esp,%ebp
  8023ba:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8023bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c0:	e8 1f ff ff ff       	call   8022e4 <fd2sockid>
  8023c5:	85 c0                	test   %eax,%eax
  8023c7:	78 12                	js     8023db <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8023c9:	83 ec 04             	sub    $0x4,%esp
  8023cc:	ff 75 10             	push   0x10(%ebp)
  8023cf:	ff 75 0c             	push   0xc(%ebp)
  8023d2:	50                   	push   %eax
  8023d3:	e8 31 01 00 00       	call   802509 <nsipc_bind>
  8023d8:	83 c4 10             	add    $0x10,%esp
}
  8023db:	c9                   	leave  
  8023dc:	c3                   	ret    

008023dd <shutdown>:
{
  8023dd:	55                   	push   %ebp
  8023de:	89 e5                	mov    %esp,%ebp
  8023e0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8023e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e6:	e8 f9 fe ff ff       	call   8022e4 <fd2sockid>
  8023eb:	85 c0                	test   %eax,%eax
  8023ed:	78 0f                	js     8023fe <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8023ef:	83 ec 08             	sub    $0x8,%esp
  8023f2:	ff 75 0c             	push   0xc(%ebp)
  8023f5:	50                   	push   %eax
  8023f6:	e8 43 01 00 00       	call   80253e <nsipc_shutdown>
  8023fb:	83 c4 10             	add    $0x10,%esp
}
  8023fe:	c9                   	leave  
  8023ff:	c3                   	ret    

00802400 <connect>:
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802406:	8b 45 08             	mov    0x8(%ebp),%eax
  802409:	e8 d6 fe ff ff       	call   8022e4 <fd2sockid>
  80240e:	85 c0                	test   %eax,%eax
  802410:	78 12                	js     802424 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  802412:	83 ec 04             	sub    $0x4,%esp
  802415:	ff 75 10             	push   0x10(%ebp)
  802418:	ff 75 0c             	push   0xc(%ebp)
  80241b:	50                   	push   %eax
  80241c:	e8 59 01 00 00       	call   80257a <nsipc_connect>
  802421:	83 c4 10             	add    $0x10,%esp
}
  802424:	c9                   	leave  
  802425:	c3                   	ret    

00802426 <listen>:
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80242c:	8b 45 08             	mov    0x8(%ebp),%eax
  80242f:	e8 b0 fe ff ff       	call   8022e4 <fd2sockid>
  802434:	85 c0                	test   %eax,%eax
  802436:	78 0f                	js     802447 <listen+0x21>
	return nsipc_listen(r, backlog);
  802438:	83 ec 08             	sub    $0x8,%esp
  80243b:	ff 75 0c             	push   0xc(%ebp)
  80243e:	50                   	push   %eax
  80243f:	e8 6b 01 00 00       	call   8025af <nsipc_listen>
  802444:	83 c4 10             	add    $0x10,%esp
}
  802447:	c9                   	leave  
  802448:	c3                   	ret    

00802449 <socket>:

int
socket(int domain, int type, int protocol)
{
  802449:	55                   	push   %ebp
  80244a:	89 e5                	mov    %esp,%ebp
  80244c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80244f:	ff 75 10             	push   0x10(%ebp)
  802452:	ff 75 0c             	push   0xc(%ebp)
  802455:	ff 75 08             	push   0x8(%ebp)
  802458:	e8 41 02 00 00       	call   80269e <nsipc_socket>
  80245d:	83 c4 10             	add    $0x10,%esp
  802460:	85 c0                	test   %eax,%eax
  802462:	78 05                	js     802469 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  802464:	e8 ab fe ff ff       	call   802314 <alloc_sockfd>
}
  802469:	c9                   	leave  
  80246a:	c3                   	ret    

0080246b <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80246b:	55                   	push   %ebp
  80246c:	89 e5                	mov    %esp,%ebp
  80246e:	53                   	push   %ebx
  80246f:	83 ec 04             	sub    $0x4,%esp
  802472:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802474:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  80247b:	74 26                	je     8024a3 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80247d:	6a 07                	push   $0x7
  80247f:	68 00 80 80 00       	push   $0x808000
  802484:	53                   	push   %ebx
  802485:	ff 35 00 90 80 00    	push   0x809000
  80248b:	e8 d4 06 00 00       	call   802b64 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802490:	83 c4 0c             	add    $0xc,%esp
  802493:	6a 00                	push   $0x0
  802495:	6a 00                	push   $0x0
  802497:	6a 00                	push   $0x0
  802499:	e8 5f 06 00 00       	call   802afd <ipc_recv>
}
  80249e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024a1:	c9                   	leave  
  8024a2:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8024a3:	83 ec 0c             	sub    $0xc,%esp
  8024a6:	6a 02                	push   $0x2
  8024a8:	e8 0b 07 00 00       	call   802bb8 <ipc_find_env>
  8024ad:	a3 00 90 80 00       	mov    %eax,0x809000
  8024b2:	83 c4 10             	add    $0x10,%esp
  8024b5:	eb c6                	jmp    80247d <nsipc+0x12>

008024b7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024b7:	55                   	push   %ebp
  8024b8:	89 e5                	mov    %esp,%ebp
  8024ba:	56                   	push   %esi
  8024bb:	53                   	push   %ebx
  8024bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8024bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c2:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8024c7:	8b 06                	mov    (%esi),%eax
  8024c9:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8024ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d3:	e8 93 ff ff ff       	call   80246b <nsipc>
  8024d8:	89 c3                	mov    %eax,%ebx
  8024da:	85 c0                	test   %eax,%eax
  8024dc:	79 09                	jns    8024e7 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8024de:	89 d8                	mov    %ebx,%eax
  8024e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024e3:	5b                   	pop    %ebx
  8024e4:	5e                   	pop    %esi
  8024e5:	5d                   	pop    %ebp
  8024e6:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8024e7:	83 ec 04             	sub    $0x4,%esp
  8024ea:	ff 35 10 80 80 00    	push   0x808010
  8024f0:	68 00 80 80 00       	push   $0x808000
  8024f5:	ff 75 0c             	push   0xc(%ebp)
  8024f8:	e8 33 e8 ff ff       	call   800d30 <memmove>
		*addrlen = ret->ret_addrlen;
  8024fd:	a1 10 80 80 00       	mov    0x808010,%eax
  802502:	89 06                	mov    %eax,(%esi)
  802504:	83 c4 10             	add    $0x10,%esp
	return r;
  802507:	eb d5                	jmp    8024de <nsipc_accept+0x27>

00802509 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802509:	55                   	push   %ebp
  80250a:	89 e5                	mov    %esp,%ebp
  80250c:	53                   	push   %ebx
  80250d:	83 ec 08             	sub    $0x8,%esp
  802510:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802513:	8b 45 08             	mov    0x8(%ebp),%eax
  802516:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80251b:	53                   	push   %ebx
  80251c:	ff 75 0c             	push   0xc(%ebp)
  80251f:	68 04 80 80 00       	push   $0x808004
  802524:	e8 07 e8 ff ff       	call   800d30 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802529:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  80252f:	b8 02 00 00 00       	mov    $0x2,%eax
  802534:	e8 32 ff ff ff       	call   80246b <nsipc>
}
  802539:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80253c:	c9                   	leave  
  80253d:	c3                   	ret    

0080253e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80253e:	55                   	push   %ebp
  80253f:	89 e5                	mov    %esp,%ebp
  802541:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802544:	8b 45 08             	mov    0x8(%ebp),%eax
  802547:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  80254c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80254f:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  802554:	b8 03 00 00 00       	mov    $0x3,%eax
  802559:	e8 0d ff ff ff       	call   80246b <nsipc>
}
  80255e:	c9                   	leave  
  80255f:	c3                   	ret    

00802560 <nsipc_close>:

int
nsipc_close(int s)
{
  802560:	55                   	push   %ebp
  802561:	89 e5                	mov    %esp,%ebp
  802563:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802566:	8b 45 08             	mov    0x8(%ebp),%eax
  802569:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  80256e:	b8 04 00 00 00       	mov    $0x4,%eax
  802573:	e8 f3 fe ff ff       	call   80246b <nsipc>
}
  802578:	c9                   	leave  
  802579:	c3                   	ret    

0080257a <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80257a:	55                   	push   %ebp
  80257b:	89 e5                	mov    %esp,%ebp
  80257d:	53                   	push   %ebx
  80257e:	83 ec 08             	sub    $0x8,%esp
  802581:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802584:	8b 45 08             	mov    0x8(%ebp),%eax
  802587:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80258c:	53                   	push   %ebx
  80258d:	ff 75 0c             	push   0xc(%ebp)
  802590:	68 04 80 80 00       	push   $0x808004
  802595:	e8 96 e7 ff ff       	call   800d30 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80259a:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  8025a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8025a5:	e8 c1 fe ff ff       	call   80246b <nsipc>
}
  8025aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025ad:	c9                   	leave  
  8025ae:	c3                   	ret    

008025af <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8025af:	55                   	push   %ebp
  8025b0:	89 e5                	mov    %esp,%ebp
  8025b2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8025b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b8:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  8025bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c0:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  8025c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8025ca:	e8 9c fe ff ff       	call   80246b <nsipc>
}
  8025cf:	c9                   	leave  
  8025d0:	c3                   	ret    

008025d1 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8025d1:	55                   	push   %ebp
  8025d2:	89 e5                	mov    %esp,%ebp
  8025d4:	56                   	push   %esi
  8025d5:	53                   	push   %ebx
  8025d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8025d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025dc:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  8025e1:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  8025e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8025ea:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025ef:	b8 07 00 00 00       	mov    $0x7,%eax
  8025f4:	e8 72 fe ff ff       	call   80246b <nsipc>
  8025f9:	89 c3                	mov    %eax,%ebx
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	78 22                	js     802621 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  8025ff:	b8 3f 06 00 00       	mov    $0x63f,%eax
  802604:	39 c6                	cmp    %eax,%esi
  802606:	0f 4e c6             	cmovle %esi,%eax
  802609:	39 c3                	cmp    %eax,%ebx
  80260b:	7f 1d                	jg     80262a <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80260d:	83 ec 04             	sub    $0x4,%esp
  802610:	53                   	push   %ebx
  802611:	68 00 80 80 00       	push   $0x808000
  802616:	ff 75 0c             	push   0xc(%ebp)
  802619:	e8 12 e7 ff ff       	call   800d30 <memmove>
  80261e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  802621:	89 d8                	mov    %ebx,%eax
  802623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802626:	5b                   	pop    %ebx
  802627:	5e                   	pop    %esi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80262a:	68 5a 35 80 00       	push   $0x80355a
  80262f:	68 6f 34 80 00       	push   $0x80346f
  802634:	6a 62                	push   $0x62
  802636:	68 6f 35 80 00       	push   $0x80356f
  80263b:	e8 a5 de ff ff       	call   8004e5 <_panic>

00802640 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802640:	55                   	push   %ebp
  802641:	89 e5                	mov    %esp,%ebp
  802643:	53                   	push   %ebx
  802644:	83 ec 04             	sub    $0x4,%esp
  802647:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80264a:	8b 45 08             	mov    0x8(%ebp),%eax
  80264d:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  802652:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802658:	7f 2e                	jg     802688 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80265a:	83 ec 04             	sub    $0x4,%esp
  80265d:	53                   	push   %ebx
  80265e:	ff 75 0c             	push   0xc(%ebp)
  802661:	68 0c 80 80 00       	push   $0x80800c
  802666:	e8 c5 e6 ff ff       	call   800d30 <memmove>
	nsipcbuf.send.req_size = size;
  80266b:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  802671:	8b 45 14             	mov    0x14(%ebp),%eax
  802674:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  802679:	b8 08 00 00 00       	mov    $0x8,%eax
  80267e:	e8 e8 fd ff ff       	call   80246b <nsipc>
}
  802683:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802686:	c9                   	leave  
  802687:	c3                   	ret    
	assert(size < 1600);
  802688:	68 7b 35 80 00       	push   $0x80357b
  80268d:	68 6f 34 80 00       	push   $0x80346f
  802692:	6a 6d                	push   $0x6d
  802694:	68 6f 35 80 00       	push   $0x80356f
  802699:	e8 47 de ff ff       	call   8004e5 <_panic>

0080269e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80269e:	55                   	push   %ebp
  80269f:	89 e5                	mov    %esp,%ebp
  8026a1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8026a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8026a7:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8026ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026af:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  8026b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8026b7:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  8026bc:	b8 09 00 00 00       	mov    $0x9,%eax
  8026c1:	e8 a5 fd ff ff       	call   80246b <nsipc>
}
  8026c6:	c9                   	leave  
  8026c7:	c3                   	ret    

008026c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8026c8:	55                   	push   %ebp
  8026c9:	89 e5                	mov    %esp,%ebp
  8026cb:	56                   	push   %esi
  8026cc:	53                   	push   %ebx
  8026cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8026d0:	83 ec 0c             	sub    $0xc,%esp
  8026d3:	ff 75 08             	push   0x8(%ebp)
  8026d6:	e8 9b ed ff ff       	call   801476 <fd2data>
  8026db:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8026dd:	83 c4 08             	add    $0x8,%esp
  8026e0:	68 87 35 80 00       	push   $0x803587
  8026e5:	53                   	push   %ebx
  8026e6:	e8 af e4 ff ff       	call   800b9a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8026eb:	8b 46 04             	mov    0x4(%esi),%eax
  8026ee:	2b 06                	sub    (%esi),%eax
  8026f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8026f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8026fd:	00 00 00 
	stat->st_dev = &devpipe;
  802700:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  802707:	40 80 00 
	return 0;
}
  80270a:	b8 00 00 00 00       	mov    $0x0,%eax
  80270f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802712:	5b                   	pop    %ebx
  802713:	5e                   	pop    %esi
  802714:	5d                   	pop    %ebp
  802715:	c3                   	ret    

00802716 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802716:	55                   	push   %ebp
  802717:	89 e5                	mov    %esp,%ebp
  802719:	53                   	push   %ebx
  80271a:	83 ec 0c             	sub    $0xc,%esp
  80271d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802720:	53                   	push   %ebx
  802721:	6a 00                	push   $0x0
  802723:	e8 f3 e8 ff ff       	call   80101b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802728:	89 1c 24             	mov    %ebx,(%esp)
  80272b:	e8 46 ed ff ff       	call   801476 <fd2data>
  802730:	83 c4 08             	add    $0x8,%esp
  802733:	50                   	push   %eax
  802734:	6a 00                	push   $0x0
  802736:	e8 e0 e8 ff ff       	call   80101b <sys_page_unmap>
}
  80273b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80273e:	c9                   	leave  
  80273f:	c3                   	ret    

00802740 <_pipeisclosed>:
{
  802740:	55                   	push   %ebp
  802741:	89 e5                	mov    %esp,%ebp
  802743:	57                   	push   %edi
  802744:	56                   	push   %esi
  802745:	53                   	push   %ebx
  802746:	83 ec 1c             	sub    $0x1c,%esp
  802749:	89 c7                	mov    %eax,%edi
  80274b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80274d:	a1 00 50 80 00       	mov    0x805000,%eax
  802752:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802755:	83 ec 0c             	sub    $0xc,%esp
  802758:	57                   	push   %edi
  802759:	e8 93 04 00 00       	call   802bf1 <pageref>
  80275e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802761:	89 34 24             	mov    %esi,(%esp)
  802764:	e8 88 04 00 00       	call   802bf1 <pageref>
		nn = thisenv->env_runs;
  802769:	8b 15 00 50 80 00    	mov    0x805000,%edx
  80276f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802772:	83 c4 10             	add    $0x10,%esp
  802775:	39 cb                	cmp    %ecx,%ebx
  802777:	74 1b                	je     802794 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802779:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80277c:	75 cf                	jne    80274d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80277e:	8b 42 58             	mov    0x58(%edx),%eax
  802781:	6a 01                	push   $0x1
  802783:	50                   	push   %eax
  802784:	53                   	push   %ebx
  802785:	68 8e 35 80 00       	push   $0x80358e
  80278a:	e8 31 de ff ff       	call   8005c0 <cprintf>
  80278f:	83 c4 10             	add    $0x10,%esp
  802792:	eb b9                	jmp    80274d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802794:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802797:	0f 94 c0             	sete   %al
  80279a:	0f b6 c0             	movzbl %al,%eax
}
  80279d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027a0:	5b                   	pop    %ebx
  8027a1:	5e                   	pop    %esi
  8027a2:	5f                   	pop    %edi
  8027a3:	5d                   	pop    %ebp
  8027a4:	c3                   	ret    

008027a5 <devpipe_write>:
{
  8027a5:	55                   	push   %ebp
  8027a6:	89 e5                	mov    %esp,%ebp
  8027a8:	57                   	push   %edi
  8027a9:	56                   	push   %esi
  8027aa:	53                   	push   %ebx
  8027ab:	83 ec 28             	sub    $0x28,%esp
  8027ae:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8027b1:	56                   	push   %esi
  8027b2:	e8 bf ec ff ff       	call   801476 <fd2data>
  8027b7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8027b9:	83 c4 10             	add    $0x10,%esp
  8027bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8027c1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8027c4:	75 09                	jne    8027cf <devpipe_write+0x2a>
	return i;
  8027c6:	89 f8                	mov    %edi,%eax
  8027c8:	eb 23                	jmp    8027ed <devpipe_write+0x48>
			sys_yield();
  8027ca:	e8 a8 e7 ff ff       	call   800f77 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8027cf:	8b 43 04             	mov    0x4(%ebx),%eax
  8027d2:	8b 0b                	mov    (%ebx),%ecx
  8027d4:	8d 51 20             	lea    0x20(%ecx),%edx
  8027d7:	39 d0                	cmp    %edx,%eax
  8027d9:	72 1a                	jb     8027f5 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8027db:	89 da                	mov    %ebx,%edx
  8027dd:	89 f0                	mov    %esi,%eax
  8027df:	e8 5c ff ff ff       	call   802740 <_pipeisclosed>
  8027e4:	85 c0                	test   %eax,%eax
  8027e6:	74 e2                	je     8027ca <devpipe_write+0x25>
				return 0;
  8027e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027f0:	5b                   	pop    %ebx
  8027f1:	5e                   	pop    %esi
  8027f2:	5f                   	pop    %edi
  8027f3:	5d                   	pop    %ebp
  8027f4:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8027f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027f8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8027fc:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8027ff:	89 c2                	mov    %eax,%edx
  802801:	c1 fa 1f             	sar    $0x1f,%edx
  802804:	89 d1                	mov    %edx,%ecx
  802806:	c1 e9 1b             	shr    $0x1b,%ecx
  802809:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80280c:	83 e2 1f             	and    $0x1f,%edx
  80280f:	29 ca                	sub    %ecx,%edx
  802811:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802815:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802819:	83 c0 01             	add    $0x1,%eax
  80281c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80281f:	83 c7 01             	add    $0x1,%edi
  802822:	eb 9d                	jmp    8027c1 <devpipe_write+0x1c>

00802824 <devpipe_read>:
{
  802824:	55                   	push   %ebp
  802825:	89 e5                	mov    %esp,%ebp
  802827:	57                   	push   %edi
  802828:	56                   	push   %esi
  802829:	53                   	push   %ebx
  80282a:	83 ec 18             	sub    $0x18,%esp
  80282d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802830:	57                   	push   %edi
  802831:	e8 40 ec ff ff       	call   801476 <fd2data>
  802836:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802838:	83 c4 10             	add    $0x10,%esp
  80283b:	be 00 00 00 00       	mov    $0x0,%esi
  802840:	3b 75 10             	cmp    0x10(%ebp),%esi
  802843:	75 13                	jne    802858 <devpipe_read+0x34>
	return i;
  802845:	89 f0                	mov    %esi,%eax
  802847:	eb 02                	jmp    80284b <devpipe_read+0x27>
				return i;
  802849:	89 f0                	mov    %esi,%eax
}
  80284b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80284e:	5b                   	pop    %ebx
  80284f:	5e                   	pop    %esi
  802850:	5f                   	pop    %edi
  802851:	5d                   	pop    %ebp
  802852:	c3                   	ret    
			sys_yield();
  802853:	e8 1f e7 ff ff       	call   800f77 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802858:	8b 03                	mov    (%ebx),%eax
  80285a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80285d:	75 18                	jne    802877 <devpipe_read+0x53>
			if (i > 0)
  80285f:	85 f6                	test   %esi,%esi
  802861:	75 e6                	jne    802849 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802863:	89 da                	mov    %ebx,%edx
  802865:	89 f8                	mov    %edi,%eax
  802867:	e8 d4 fe ff ff       	call   802740 <_pipeisclosed>
  80286c:	85 c0                	test   %eax,%eax
  80286e:	74 e3                	je     802853 <devpipe_read+0x2f>
				return 0;
  802870:	b8 00 00 00 00       	mov    $0x0,%eax
  802875:	eb d4                	jmp    80284b <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802877:	99                   	cltd   
  802878:	c1 ea 1b             	shr    $0x1b,%edx
  80287b:	01 d0                	add    %edx,%eax
  80287d:	83 e0 1f             	and    $0x1f,%eax
  802880:	29 d0                	sub    %edx,%eax
  802882:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80288a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80288d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802890:	83 c6 01             	add    $0x1,%esi
  802893:	eb ab                	jmp    802840 <devpipe_read+0x1c>

00802895 <pipe>:
{
  802895:	55                   	push   %ebp
  802896:	89 e5                	mov    %esp,%ebp
  802898:	56                   	push   %esi
  802899:	53                   	push   %ebx
  80289a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80289d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028a0:	50                   	push   %eax
  8028a1:	e8 e7 eb ff ff       	call   80148d <fd_alloc>
  8028a6:	89 c3                	mov    %eax,%ebx
  8028a8:	83 c4 10             	add    $0x10,%esp
  8028ab:	85 c0                	test   %eax,%eax
  8028ad:	0f 88 23 01 00 00    	js     8029d6 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028b3:	83 ec 04             	sub    $0x4,%esp
  8028b6:	68 07 04 00 00       	push   $0x407
  8028bb:	ff 75 f4             	push   -0xc(%ebp)
  8028be:	6a 00                	push   $0x0
  8028c0:	e8 d1 e6 ff ff       	call   800f96 <sys_page_alloc>
  8028c5:	89 c3                	mov    %eax,%ebx
  8028c7:	83 c4 10             	add    $0x10,%esp
  8028ca:	85 c0                	test   %eax,%eax
  8028cc:	0f 88 04 01 00 00    	js     8029d6 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8028d2:	83 ec 0c             	sub    $0xc,%esp
  8028d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028d8:	50                   	push   %eax
  8028d9:	e8 af eb ff ff       	call   80148d <fd_alloc>
  8028de:	89 c3                	mov    %eax,%ebx
  8028e0:	83 c4 10             	add    $0x10,%esp
  8028e3:	85 c0                	test   %eax,%eax
  8028e5:	0f 88 db 00 00 00    	js     8029c6 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028eb:	83 ec 04             	sub    $0x4,%esp
  8028ee:	68 07 04 00 00       	push   $0x407
  8028f3:	ff 75 f0             	push   -0x10(%ebp)
  8028f6:	6a 00                	push   $0x0
  8028f8:	e8 99 e6 ff ff       	call   800f96 <sys_page_alloc>
  8028fd:	89 c3                	mov    %eax,%ebx
  8028ff:	83 c4 10             	add    $0x10,%esp
  802902:	85 c0                	test   %eax,%eax
  802904:	0f 88 bc 00 00 00    	js     8029c6 <pipe+0x131>
	va = fd2data(fd0);
  80290a:	83 ec 0c             	sub    $0xc,%esp
  80290d:	ff 75 f4             	push   -0xc(%ebp)
  802910:	e8 61 eb ff ff       	call   801476 <fd2data>
  802915:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802917:	83 c4 0c             	add    $0xc,%esp
  80291a:	68 07 04 00 00       	push   $0x407
  80291f:	50                   	push   %eax
  802920:	6a 00                	push   $0x0
  802922:	e8 6f e6 ff ff       	call   800f96 <sys_page_alloc>
  802927:	89 c3                	mov    %eax,%ebx
  802929:	83 c4 10             	add    $0x10,%esp
  80292c:	85 c0                	test   %eax,%eax
  80292e:	0f 88 82 00 00 00    	js     8029b6 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802934:	83 ec 0c             	sub    $0xc,%esp
  802937:	ff 75 f0             	push   -0x10(%ebp)
  80293a:	e8 37 eb ff ff       	call   801476 <fd2data>
  80293f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802946:	50                   	push   %eax
  802947:	6a 00                	push   $0x0
  802949:	56                   	push   %esi
  80294a:	6a 00                	push   $0x0
  80294c:	e8 88 e6 ff ff       	call   800fd9 <sys_page_map>
  802951:	89 c3                	mov    %eax,%ebx
  802953:	83 c4 20             	add    $0x20,%esp
  802956:	85 c0                	test   %eax,%eax
  802958:	78 4e                	js     8029a8 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80295a:	a1 58 40 80 00       	mov    0x804058,%eax
  80295f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802962:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802964:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802967:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80296e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802971:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802973:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802976:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80297d:	83 ec 0c             	sub    $0xc,%esp
  802980:	ff 75 f4             	push   -0xc(%ebp)
  802983:	e8 de ea ff ff       	call   801466 <fd2num>
  802988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80298b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80298d:	83 c4 04             	add    $0x4,%esp
  802990:	ff 75 f0             	push   -0x10(%ebp)
  802993:	e8 ce ea ff ff       	call   801466 <fd2num>
  802998:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80299b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80299e:	83 c4 10             	add    $0x10,%esp
  8029a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029a6:	eb 2e                	jmp    8029d6 <pipe+0x141>
	sys_page_unmap(0, va);
  8029a8:	83 ec 08             	sub    $0x8,%esp
  8029ab:	56                   	push   %esi
  8029ac:	6a 00                	push   $0x0
  8029ae:	e8 68 e6 ff ff       	call   80101b <sys_page_unmap>
  8029b3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8029b6:	83 ec 08             	sub    $0x8,%esp
  8029b9:	ff 75 f0             	push   -0x10(%ebp)
  8029bc:	6a 00                	push   $0x0
  8029be:	e8 58 e6 ff ff       	call   80101b <sys_page_unmap>
  8029c3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8029c6:	83 ec 08             	sub    $0x8,%esp
  8029c9:	ff 75 f4             	push   -0xc(%ebp)
  8029cc:	6a 00                	push   $0x0
  8029ce:	e8 48 e6 ff ff       	call   80101b <sys_page_unmap>
  8029d3:	83 c4 10             	add    $0x10,%esp
}
  8029d6:	89 d8                	mov    %ebx,%eax
  8029d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029db:	5b                   	pop    %ebx
  8029dc:	5e                   	pop    %esi
  8029dd:	5d                   	pop    %ebp
  8029de:	c3                   	ret    

008029df <pipeisclosed>:
{
  8029df:	55                   	push   %ebp
  8029e0:	89 e5                	mov    %esp,%ebp
  8029e2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e8:	50                   	push   %eax
  8029e9:	ff 75 08             	push   0x8(%ebp)
  8029ec:	e8 ec ea ff ff       	call   8014dd <fd_lookup>
  8029f1:	83 c4 10             	add    $0x10,%esp
  8029f4:	85 c0                	test   %eax,%eax
  8029f6:	78 18                	js     802a10 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8029f8:	83 ec 0c             	sub    $0xc,%esp
  8029fb:	ff 75 f4             	push   -0xc(%ebp)
  8029fe:	e8 73 ea ff ff       	call   801476 <fd2data>
  802a03:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a08:	e8 33 fd ff ff       	call   802740 <_pipeisclosed>
  802a0d:	83 c4 10             	add    $0x10,%esp
}
  802a10:	c9                   	leave  
  802a11:	c3                   	ret    

00802a12 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802a12:	55                   	push   %ebp
  802a13:	89 e5                	mov    %esp,%ebp
  802a15:	56                   	push   %esi
  802a16:	53                   	push   %ebx
  802a17:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802a1a:	85 f6                	test   %esi,%esi
  802a1c:	74 13                	je     802a31 <wait+0x1f>
	e = &envs[ENVX(envid)];
  802a1e:	89 f3                	mov    %esi,%ebx
  802a20:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a26:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802a29:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802a2f:	eb 1b                	jmp    802a4c <wait+0x3a>
	assert(envid != 0);
  802a31:	68 a6 35 80 00       	push   $0x8035a6
  802a36:	68 6f 34 80 00       	push   $0x80346f
  802a3b:	6a 09                	push   $0x9
  802a3d:	68 b1 35 80 00       	push   $0x8035b1
  802a42:	e8 9e da ff ff       	call   8004e5 <_panic>
		sys_yield();
  802a47:	e8 2b e5 ff ff       	call   800f77 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a4c:	8b 43 48             	mov    0x48(%ebx),%eax
  802a4f:	39 f0                	cmp    %esi,%eax
  802a51:	75 07                	jne    802a5a <wait+0x48>
  802a53:	8b 43 54             	mov    0x54(%ebx),%eax
  802a56:	85 c0                	test   %eax,%eax
  802a58:	75 ed                	jne    802a47 <wait+0x35>
}
  802a5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a5d:	5b                   	pop    %ebx
  802a5e:	5e                   	pop    %esi
  802a5f:	5d                   	pop    %ebp
  802a60:	c3                   	ret    

00802a61 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a61:	55                   	push   %ebp
  802a62:	89 e5                	mov    %esp,%ebp
  802a64:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802a67:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  802a6e:	74 0a                	je     802a7a <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a70:	8b 45 08             	mov    0x8(%ebp),%eax
  802a73:	a3 04 90 80 00       	mov    %eax,0x809004
}
  802a78:	c9                   	leave  
  802a79:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802a7a:	e8 d9 e4 ff ff       	call   800f58 <sys_getenvid>
  802a7f:	83 ec 04             	sub    $0x4,%esp
  802a82:	68 07 0e 00 00       	push   $0xe07
  802a87:	68 00 f0 bf ee       	push   $0xeebff000
  802a8c:	50                   	push   %eax
  802a8d:	e8 04 e5 ff ff       	call   800f96 <sys_page_alloc>
		if (r < 0) {
  802a92:	83 c4 10             	add    $0x10,%esp
  802a95:	85 c0                	test   %eax,%eax
  802a97:	78 2c                	js     802ac5 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802a99:	e8 ba e4 ff ff       	call   800f58 <sys_getenvid>
  802a9e:	83 ec 08             	sub    $0x8,%esp
  802aa1:	68 d7 2a 80 00       	push   $0x802ad7
  802aa6:	50                   	push   %eax
  802aa7:	e8 35 e6 ff ff       	call   8010e1 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802aac:	83 c4 10             	add    $0x10,%esp
  802aaf:	85 c0                	test   %eax,%eax
  802ab1:	79 bd                	jns    802a70 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802ab3:	50                   	push   %eax
  802ab4:	68 fc 35 80 00       	push   $0x8035fc
  802ab9:	6a 28                	push   $0x28
  802abb:	68 32 36 80 00       	push   $0x803632
  802ac0:	e8 20 da ff ff       	call   8004e5 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802ac5:	50                   	push   %eax
  802ac6:	68 bc 35 80 00       	push   $0x8035bc
  802acb:	6a 23                	push   $0x23
  802acd:	68 32 36 80 00       	push   $0x803632
  802ad2:	e8 0e da ff ff       	call   8004e5 <_panic>

00802ad7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ad7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ad8:	a1 04 90 80 00       	mov    0x809004,%eax
	call *%eax
  802add:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802adf:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802ae2:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802ae6:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802ae9:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802aed:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802af1:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802af3:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802af6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802af7:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802afa:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802afb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802afc:	c3                   	ret    

00802afd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802afd:	55                   	push   %ebp
  802afe:	89 e5                	mov    %esp,%ebp
  802b00:	56                   	push   %esi
  802b01:	53                   	push   %ebx
  802b02:	8b 75 08             	mov    0x8(%ebp),%esi
  802b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802b0b:	85 c0                	test   %eax,%eax
  802b0d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802b12:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802b15:	83 ec 0c             	sub    $0xc,%esp
  802b18:	50                   	push   %eax
  802b19:	e8 28 e6 ff ff       	call   801146 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802b1e:	83 c4 10             	add    $0x10,%esp
  802b21:	85 f6                	test   %esi,%esi
  802b23:	74 14                	je     802b39 <ipc_recv+0x3c>
  802b25:	ba 00 00 00 00       	mov    $0x0,%edx
  802b2a:	85 c0                	test   %eax,%eax
  802b2c:	78 09                	js     802b37 <ipc_recv+0x3a>
  802b2e:	8b 15 00 50 80 00    	mov    0x805000,%edx
  802b34:	8b 52 74             	mov    0x74(%edx),%edx
  802b37:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802b39:	85 db                	test   %ebx,%ebx
  802b3b:	74 14                	je     802b51 <ipc_recv+0x54>
  802b3d:	ba 00 00 00 00       	mov    $0x0,%edx
  802b42:	85 c0                	test   %eax,%eax
  802b44:	78 09                	js     802b4f <ipc_recv+0x52>
  802b46:	8b 15 00 50 80 00    	mov    0x805000,%edx
  802b4c:	8b 52 78             	mov    0x78(%edx),%edx
  802b4f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802b51:	85 c0                	test   %eax,%eax
  802b53:	78 08                	js     802b5d <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802b55:	a1 00 50 80 00       	mov    0x805000,%eax
  802b5a:	8b 40 70             	mov    0x70(%eax),%eax
}
  802b5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b60:	5b                   	pop    %ebx
  802b61:	5e                   	pop    %esi
  802b62:	5d                   	pop    %ebp
  802b63:	c3                   	ret    

00802b64 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b64:	55                   	push   %ebp
  802b65:	89 e5                	mov    %esp,%ebp
  802b67:	57                   	push   %edi
  802b68:	56                   	push   %esi
  802b69:	53                   	push   %ebx
  802b6a:	83 ec 0c             	sub    $0xc,%esp
  802b6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b70:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802b76:	85 db                	test   %ebx,%ebx
  802b78:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b7d:	0f 44 d8             	cmove  %eax,%ebx
  802b80:	eb 05                	jmp    802b87 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802b82:	e8 f0 e3 ff ff       	call   800f77 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802b87:	ff 75 14             	push   0x14(%ebp)
  802b8a:	53                   	push   %ebx
  802b8b:	56                   	push   %esi
  802b8c:	57                   	push   %edi
  802b8d:	e8 91 e5 ff ff       	call   801123 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802b92:	83 c4 10             	add    $0x10,%esp
  802b95:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802b98:	74 e8                	je     802b82 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802b9a:	85 c0                	test   %eax,%eax
  802b9c:	78 08                	js     802ba6 <ipc_send+0x42>
	}while (r<0);

}
  802b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba1:	5b                   	pop    %ebx
  802ba2:	5e                   	pop    %esi
  802ba3:	5f                   	pop    %edi
  802ba4:	5d                   	pop    %ebp
  802ba5:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802ba6:	50                   	push   %eax
  802ba7:	68 40 36 80 00       	push   $0x803640
  802bac:	6a 3d                	push   $0x3d
  802bae:	68 54 36 80 00       	push   $0x803654
  802bb3:	e8 2d d9 ff ff       	call   8004e5 <_panic>

00802bb8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802bb8:	55                   	push   %ebp
  802bb9:	89 e5                	mov    %esp,%ebp
  802bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802bbe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802bc3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802bc6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802bcc:	8b 52 50             	mov    0x50(%edx),%edx
  802bcf:	39 ca                	cmp    %ecx,%edx
  802bd1:	74 11                	je     802be4 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802bd3:	83 c0 01             	add    $0x1,%eax
  802bd6:	3d 00 04 00 00       	cmp    $0x400,%eax
  802bdb:	75 e6                	jne    802bc3 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  802be2:	eb 0b                	jmp    802bef <ipc_find_env+0x37>
			return envs[i].env_id;
  802be4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802be7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802bec:	8b 40 48             	mov    0x48(%eax),%eax
}
  802bef:	5d                   	pop    %ebp
  802bf0:	c3                   	ret    

00802bf1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802bf1:	55                   	push   %ebp
  802bf2:	89 e5                	mov    %esp,%ebp
  802bf4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802bf7:	89 c2                	mov    %eax,%edx
  802bf9:	c1 ea 16             	shr    $0x16,%edx
  802bfc:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802c03:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802c08:	f6 c1 01             	test   $0x1,%cl
  802c0b:	74 1c                	je     802c29 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802c0d:	c1 e8 0c             	shr    $0xc,%eax
  802c10:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802c17:	a8 01                	test   $0x1,%al
  802c19:	74 0e                	je     802c29 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802c1b:	c1 e8 0c             	shr    $0xc,%eax
  802c1e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802c25:	ef 
  802c26:	0f b7 d2             	movzwl %dx,%edx
}
  802c29:	89 d0                	mov    %edx,%eax
  802c2b:	5d                   	pop    %ebp
  802c2c:	c3                   	ret    
  802c2d:	66 90                	xchg   %ax,%ax
  802c2f:	90                   	nop

00802c30 <__udivdi3>:
  802c30:	f3 0f 1e fb          	endbr32 
  802c34:	55                   	push   %ebp
  802c35:	57                   	push   %edi
  802c36:	56                   	push   %esi
  802c37:	53                   	push   %ebx
  802c38:	83 ec 1c             	sub    $0x1c,%esp
  802c3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802c3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802c43:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802c4b:	85 c0                	test   %eax,%eax
  802c4d:	75 19                	jne    802c68 <__udivdi3+0x38>
  802c4f:	39 f3                	cmp    %esi,%ebx
  802c51:	76 4d                	jbe    802ca0 <__udivdi3+0x70>
  802c53:	31 ff                	xor    %edi,%edi
  802c55:	89 e8                	mov    %ebp,%eax
  802c57:	89 f2                	mov    %esi,%edx
  802c59:	f7 f3                	div    %ebx
  802c5b:	89 fa                	mov    %edi,%edx
  802c5d:	83 c4 1c             	add    $0x1c,%esp
  802c60:	5b                   	pop    %ebx
  802c61:	5e                   	pop    %esi
  802c62:	5f                   	pop    %edi
  802c63:	5d                   	pop    %ebp
  802c64:	c3                   	ret    
  802c65:	8d 76 00             	lea    0x0(%esi),%esi
  802c68:	39 f0                	cmp    %esi,%eax
  802c6a:	76 14                	jbe    802c80 <__udivdi3+0x50>
  802c6c:	31 ff                	xor    %edi,%edi
  802c6e:	31 c0                	xor    %eax,%eax
  802c70:	89 fa                	mov    %edi,%edx
  802c72:	83 c4 1c             	add    $0x1c,%esp
  802c75:	5b                   	pop    %ebx
  802c76:	5e                   	pop    %esi
  802c77:	5f                   	pop    %edi
  802c78:	5d                   	pop    %ebp
  802c79:	c3                   	ret    
  802c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802c80:	0f bd f8             	bsr    %eax,%edi
  802c83:	83 f7 1f             	xor    $0x1f,%edi
  802c86:	75 48                	jne    802cd0 <__udivdi3+0xa0>
  802c88:	39 f0                	cmp    %esi,%eax
  802c8a:	72 06                	jb     802c92 <__udivdi3+0x62>
  802c8c:	31 c0                	xor    %eax,%eax
  802c8e:	39 eb                	cmp    %ebp,%ebx
  802c90:	77 de                	ja     802c70 <__udivdi3+0x40>
  802c92:	b8 01 00 00 00       	mov    $0x1,%eax
  802c97:	eb d7                	jmp    802c70 <__udivdi3+0x40>
  802c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ca0:	89 d9                	mov    %ebx,%ecx
  802ca2:	85 db                	test   %ebx,%ebx
  802ca4:	75 0b                	jne    802cb1 <__udivdi3+0x81>
  802ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  802cab:	31 d2                	xor    %edx,%edx
  802cad:	f7 f3                	div    %ebx
  802caf:	89 c1                	mov    %eax,%ecx
  802cb1:	31 d2                	xor    %edx,%edx
  802cb3:	89 f0                	mov    %esi,%eax
  802cb5:	f7 f1                	div    %ecx
  802cb7:	89 c6                	mov    %eax,%esi
  802cb9:	89 e8                	mov    %ebp,%eax
  802cbb:	89 f7                	mov    %esi,%edi
  802cbd:	f7 f1                	div    %ecx
  802cbf:	89 fa                	mov    %edi,%edx
  802cc1:	83 c4 1c             	add    $0x1c,%esp
  802cc4:	5b                   	pop    %ebx
  802cc5:	5e                   	pop    %esi
  802cc6:	5f                   	pop    %edi
  802cc7:	5d                   	pop    %ebp
  802cc8:	c3                   	ret    
  802cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cd0:	89 f9                	mov    %edi,%ecx
  802cd2:	ba 20 00 00 00       	mov    $0x20,%edx
  802cd7:	29 fa                	sub    %edi,%edx
  802cd9:	d3 e0                	shl    %cl,%eax
  802cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  802cdf:	89 d1                	mov    %edx,%ecx
  802ce1:	89 d8                	mov    %ebx,%eax
  802ce3:	d3 e8                	shr    %cl,%eax
  802ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802ce9:	09 c1                	or     %eax,%ecx
  802ceb:	89 f0                	mov    %esi,%eax
  802ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802cf1:	89 f9                	mov    %edi,%ecx
  802cf3:	d3 e3                	shl    %cl,%ebx
  802cf5:	89 d1                	mov    %edx,%ecx
  802cf7:	d3 e8                	shr    %cl,%eax
  802cf9:	89 f9                	mov    %edi,%ecx
  802cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802cff:	89 eb                	mov    %ebp,%ebx
  802d01:	d3 e6                	shl    %cl,%esi
  802d03:	89 d1                	mov    %edx,%ecx
  802d05:	d3 eb                	shr    %cl,%ebx
  802d07:	09 f3                	or     %esi,%ebx
  802d09:	89 c6                	mov    %eax,%esi
  802d0b:	89 f2                	mov    %esi,%edx
  802d0d:	89 d8                	mov    %ebx,%eax
  802d0f:	f7 74 24 08          	divl   0x8(%esp)
  802d13:	89 d6                	mov    %edx,%esi
  802d15:	89 c3                	mov    %eax,%ebx
  802d17:	f7 64 24 0c          	mull   0xc(%esp)
  802d1b:	39 d6                	cmp    %edx,%esi
  802d1d:	72 19                	jb     802d38 <__udivdi3+0x108>
  802d1f:	89 f9                	mov    %edi,%ecx
  802d21:	d3 e5                	shl    %cl,%ebp
  802d23:	39 c5                	cmp    %eax,%ebp
  802d25:	73 04                	jae    802d2b <__udivdi3+0xfb>
  802d27:	39 d6                	cmp    %edx,%esi
  802d29:	74 0d                	je     802d38 <__udivdi3+0x108>
  802d2b:	89 d8                	mov    %ebx,%eax
  802d2d:	31 ff                	xor    %edi,%edi
  802d2f:	e9 3c ff ff ff       	jmp    802c70 <__udivdi3+0x40>
  802d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802d3b:	31 ff                	xor    %edi,%edi
  802d3d:	e9 2e ff ff ff       	jmp    802c70 <__udivdi3+0x40>
  802d42:	66 90                	xchg   %ax,%ax
  802d44:	66 90                	xchg   %ax,%ax
  802d46:	66 90                	xchg   %ax,%ax
  802d48:	66 90                	xchg   %ax,%ax
  802d4a:	66 90                	xchg   %ax,%ax
  802d4c:	66 90                	xchg   %ax,%ax
  802d4e:	66 90                	xchg   %ax,%ax

00802d50 <__umoddi3>:
  802d50:	f3 0f 1e fb          	endbr32 
  802d54:	55                   	push   %ebp
  802d55:	57                   	push   %edi
  802d56:	56                   	push   %esi
  802d57:	53                   	push   %ebx
  802d58:	83 ec 1c             	sub    $0x1c,%esp
  802d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  802d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802d63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802d67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802d6b:	89 f0                	mov    %esi,%eax
  802d6d:	89 da                	mov    %ebx,%edx
  802d6f:	85 ff                	test   %edi,%edi
  802d71:	75 15                	jne    802d88 <__umoddi3+0x38>
  802d73:	39 dd                	cmp    %ebx,%ebp
  802d75:	76 39                	jbe    802db0 <__umoddi3+0x60>
  802d77:	f7 f5                	div    %ebp
  802d79:	89 d0                	mov    %edx,%eax
  802d7b:	31 d2                	xor    %edx,%edx
  802d7d:	83 c4 1c             	add    $0x1c,%esp
  802d80:	5b                   	pop    %ebx
  802d81:	5e                   	pop    %esi
  802d82:	5f                   	pop    %edi
  802d83:	5d                   	pop    %ebp
  802d84:	c3                   	ret    
  802d85:	8d 76 00             	lea    0x0(%esi),%esi
  802d88:	39 df                	cmp    %ebx,%edi
  802d8a:	77 f1                	ja     802d7d <__umoddi3+0x2d>
  802d8c:	0f bd cf             	bsr    %edi,%ecx
  802d8f:	83 f1 1f             	xor    $0x1f,%ecx
  802d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802d96:	75 40                	jne    802dd8 <__umoddi3+0x88>
  802d98:	39 df                	cmp    %ebx,%edi
  802d9a:	72 04                	jb     802da0 <__umoddi3+0x50>
  802d9c:	39 f5                	cmp    %esi,%ebp
  802d9e:	77 dd                	ja     802d7d <__umoddi3+0x2d>
  802da0:	89 da                	mov    %ebx,%edx
  802da2:	89 f0                	mov    %esi,%eax
  802da4:	29 e8                	sub    %ebp,%eax
  802da6:	19 fa                	sbb    %edi,%edx
  802da8:	eb d3                	jmp    802d7d <__umoddi3+0x2d>
  802daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802db0:	89 e9                	mov    %ebp,%ecx
  802db2:	85 ed                	test   %ebp,%ebp
  802db4:	75 0b                	jne    802dc1 <__umoddi3+0x71>
  802db6:	b8 01 00 00 00       	mov    $0x1,%eax
  802dbb:	31 d2                	xor    %edx,%edx
  802dbd:	f7 f5                	div    %ebp
  802dbf:	89 c1                	mov    %eax,%ecx
  802dc1:	89 d8                	mov    %ebx,%eax
  802dc3:	31 d2                	xor    %edx,%edx
  802dc5:	f7 f1                	div    %ecx
  802dc7:	89 f0                	mov    %esi,%eax
  802dc9:	f7 f1                	div    %ecx
  802dcb:	89 d0                	mov    %edx,%eax
  802dcd:	31 d2                	xor    %edx,%edx
  802dcf:	eb ac                	jmp    802d7d <__umoddi3+0x2d>
  802dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802dd8:	8b 44 24 04          	mov    0x4(%esp),%eax
  802ddc:	ba 20 00 00 00       	mov    $0x20,%edx
  802de1:	29 c2                	sub    %eax,%edx
  802de3:	89 c1                	mov    %eax,%ecx
  802de5:	89 e8                	mov    %ebp,%eax
  802de7:	d3 e7                	shl    %cl,%edi
  802de9:	89 d1                	mov    %edx,%ecx
  802deb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802def:	d3 e8                	shr    %cl,%eax
  802df1:	89 c1                	mov    %eax,%ecx
  802df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  802df7:	09 f9                	or     %edi,%ecx
  802df9:	89 df                	mov    %ebx,%edi
  802dfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802dff:	89 c1                	mov    %eax,%ecx
  802e01:	d3 e5                	shl    %cl,%ebp
  802e03:	89 d1                	mov    %edx,%ecx
  802e05:	d3 ef                	shr    %cl,%edi
  802e07:	89 c1                	mov    %eax,%ecx
  802e09:	89 f0                	mov    %esi,%eax
  802e0b:	d3 e3                	shl    %cl,%ebx
  802e0d:	89 d1                	mov    %edx,%ecx
  802e0f:	89 fa                	mov    %edi,%edx
  802e11:	d3 e8                	shr    %cl,%eax
  802e13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e18:	09 d8                	or     %ebx,%eax
  802e1a:	f7 74 24 08          	divl   0x8(%esp)
  802e1e:	89 d3                	mov    %edx,%ebx
  802e20:	d3 e6                	shl    %cl,%esi
  802e22:	f7 e5                	mul    %ebp
  802e24:	89 c7                	mov    %eax,%edi
  802e26:	89 d1                	mov    %edx,%ecx
  802e28:	39 d3                	cmp    %edx,%ebx
  802e2a:	72 06                	jb     802e32 <__umoddi3+0xe2>
  802e2c:	75 0e                	jne    802e3c <__umoddi3+0xec>
  802e2e:	39 c6                	cmp    %eax,%esi
  802e30:	73 0a                	jae    802e3c <__umoddi3+0xec>
  802e32:	29 e8                	sub    %ebp,%eax
  802e34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802e38:	89 d1                	mov    %edx,%ecx
  802e3a:	89 c7                	mov    %eax,%edi
  802e3c:	89 f5                	mov    %esi,%ebp
  802e3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802e42:	29 fd                	sub    %edi,%ebp
  802e44:	19 cb                	sbb    %ecx,%ebx
  802e46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802e4b:	89 d8                	mov    %ebx,%eax
  802e4d:	d3 e0                	shl    %cl,%eax
  802e4f:	89 f1                	mov    %esi,%ecx
  802e51:	d3 ed                	shr    %cl,%ebp
  802e53:	d3 eb                	shr    %cl,%ebx
  802e55:	09 e8                	or     %ebp,%eax
  802e57:	89 da                	mov    %ebx,%edx
  802e59:	83 c4 1c             	add    $0x1c,%esp
  802e5c:	5b                   	pop    %ebx
  802e5d:	5e                   	pop    %esi
  802e5e:	5f                   	pop    %edi
  802e5f:	5d                   	pop    %ebp
  802e60:	c3                   	ret    
