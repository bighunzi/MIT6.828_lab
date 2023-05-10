
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
  80004a:	e8 4d 18 00 00       	call   80189c <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 43 18 00 00       	call   80189c <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  800060:	e8 5e 05 00 00       	call   8005c3 <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 0b 2f 80 00 	movl   $0x802f0b,(%esp)
  80006c:	e8 52 05 00 00       	call   8005c3 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 5a 0e 00 00       	call   800edd <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 ba 16 00 00       	call   80174c <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 1a 2f 80 00       	push   $0x802f1a
  8000a1:	e8 1d 05 00 00       	call   8005c3 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 25 0e 00 00       	call   800edd <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 85 16 00 00       	call   80174c <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 15 2f 80 00       	push   $0x802f15
  8000d6:	e8 e8 04 00 00       	call   8005c3 <cprintf>
	exit();
  8000db:	e8 ee 03 00 00       	call   8004ce <exit>
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
  8000f6:	e8 15 15 00 00       	call   801610 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 09 15 00 00       	call   801610 <close>
	opencons();
  800107:	e8 27 03 00 00       	call   800433 <opencons>
	opencons();
  80010c:	e8 22 03 00 00       	call   800433 <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 28 2f 80 00       	push   $0x802f28
  80011b:	e8 8f 1a 00 00       	call   801baf <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 e7 00 00 00    	js     800214 <umain+0x129>
	if ((wfd = pipe(pfds)) < 0)
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 65 27 00 00       	call   80289e <pipe>
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	85 c0                	test   %eax,%eax
  80013e:	0f 88 e2 00 00 00    	js     800226 <umain+0x13b>
	wfd = pfds[1];
  800144:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	68 c4 2e 80 00       	push   $0x802ec4
  80014f:	e8 6f 04 00 00       	call   8005c3 <cprintf>
	if ((r = fork()) < 0)
  800154:	e8 90 11 00 00       	call   8012e9 <fork>
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	85 c0                	test   %eax,%eax
  80015e:	0f 88 d4 00 00 00    	js     800238 <umain+0x14d>
	if (r == 0) {
  800164:	75 6f                	jne    8001d5 <umain+0xea>
		dup(rfd, 0);
  800166:	83 ec 08             	sub    $0x8,%esp
  800169:	6a 00                	push   $0x0
  80016b:	53                   	push   %ebx
  80016c:	e8 f1 14 00 00       	call   801662 <dup>
		dup(wfd, 1);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	6a 01                	push   $0x1
  800176:	56                   	push   %esi
  800177:	e8 e6 14 00 00       	call   801662 <dup>
		close(rfd);
  80017c:	89 1c 24             	mov    %ebx,(%esp)
  80017f:	e8 8c 14 00 00       	call   801610 <close>
		close(wfd);
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 84 14 00 00       	call   801610 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  80018c:	6a 00                	push   $0x0
  80018e:	68 65 2f 80 00       	push   $0x802f65
  800193:	68 32 2f 80 00       	push   $0x802f32
  800198:	68 68 2f 80 00       	push   $0x802f68
  80019d:	e8 22 20 00 00       	call   8021c4 <spawnl>
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	83 c4 20             	add    $0x20,%esp
  8001a7:	85 c0                	test   %eax,%eax
  8001a9:	0f 88 9b 00 00 00    	js     80024a <umain+0x15f>
		close(0);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	6a 00                	push   $0x0
  8001b4:	e8 57 14 00 00       	call   801610 <close>
		close(1);
  8001b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001c0:	e8 4b 14 00 00       	call   801610 <close>
		wait(r);
  8001c5:	89 3c 24             	mov    %edi,(%esp)
  8001c8:	e8 4e 28 00 00       	call   802a1b <wait>
		exit();
  8001cd:	e8 fc 02 00 00       	call   8004ce <exit>
  8001d2:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	53                   	push   %ebx
  8001d9:	e8 32 14 00 00       	call   801610 <close>
	close(wfd);
  8001de:	89 34 24             	mov    %esi,(%esp)
  8001e1:	e8 2a 14 00 00       	call   801610 <close>
	rfd = pfds[0];
  8001e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001ec:	83 c4 08             	add    $0x8,%esp
  8001ef:	6a 00                	push   $0x0
  8001f1:	68 76 2f 80 00       	push   $0x802f76
  8001f6:	e8 b4 19 00 00       	call   801baf <open>
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
  800215:	68 35 2f 80 00       	push   $0x802f35
  80021a:	6a 13                	push   $0x13
  80021c:	68 4b 2f 80 00       	push   $0x802f4b
  800221:	e8 c2 02 00 00       	call   8004e8 <_panic>
		panic("pipe: %e", wfd);
  800226:	50                   	push   %eax
  800227:	68 5c 2f 80 00       	push   $0x802f5c
  80022c:	6a 15                	push   $0x15
  80022e:	68 4b 2f 80 00       	push   $0x802f4b
  800233:	e8 b0 02 00 00       	call   8004e8 <_panic>
		panic("fork: %e", r);
  800238:	50                   	push   %eax
  800239:	68 d8 33 80 00       	push   $0x8033d8
  80023e:	6a 1a                	push   $0x1a
  800240:	68 4b 2f 80 00       	push   $0x802f4b
  800245:	e8 9e 02 00 00       	call   8004e8 <_panic>
			panic("spawn: %e", r);
  80024a:	50                   	push   %eax
  80024b:	68 6c 2f 80 00       	push   $0x802f6c
  800250:	6a 21                	push   $0x21
  800252:	68 4b 2f 80 00       	push   $0x802f4b
  800257:	e8 8c 02 00 00       	call   8004e8 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  80025c:	50                   	push   %eax
  80025d:	68 e8 2e 80 00       	push   $0x802ee8
  800262:	6a 2c                	push   $0x2c
  800264:	68 4b 2f 80 00       	push   $0x802f4b
  800269:	e8 7a 02 00 00       	call   8004e8 <_panic>
			panic("reading testshell.out: %e", n1);
  80026e:	53                   	push   %ebx
  80026f:	68 84 2f 80 00       	push   $0x802f84
  800274:	6a 33                	push   $0x33
  800276:	68 4b 2f 80 00       	push   $0x802f4b
  80027b:	e8 68 02 00 00       	call   8004e8 <_panic>
			panic("reading testshell.key: %e", n2);
  800280:	50                   	push   %eax
  800281:	68 9e 2f 80 00       	push   $0x802f9e
  800286:	6a 35                	push   $0x35
  800288:	68 4b 2f 80 00       	push   $0x802f4b
  80028d:	e8 56 02 00 00       	call   8004e8 <_panic>
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
  8002ba:	e8 8d 14 00 00       	call   80174c <read>
  8002bf:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002c1:	83 c4 0c             	add    $0xc,%esp
  8002c4:	6a 01                	push   $0x1
  8002c6:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff 75 d4             	push   -0x2c(%ebp)
  8002cd:	e8 7a 14 00 00       	call   80174c <read>
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
  8002fb:	68 b8 2f 80 00       	push   $0x802fb8
  800300:	e8 be 02 00 00       	call   8005c3 <cprintf>
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
  80031d:	68 cd 2f 80 00       	push   $0x802fcd
  800322:	ff 75 0c             	push   0xc(%ebp)
  800325:	e8 73 08 00 00       	call   800b9d <strcpy>
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
  800364:	e8 ca 09 00 00       	call   800d33 <memmove>
		sys_cputs(buf, m);
  800369:	83 c4 08             	add    $0x8,%esp
  80036c:	53                   	push   %ebx
  80036d:	57                   	push   %edi
  80036e:	e8 6a 0b 00 00       	call   800edd <sys_cputs>
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
  80039a:	e8 db 0b 00 00       	call   800f7a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80039f:	e8 57 0b 00 00       	call   800efb <sys_cgetc>
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
  8003d4:	e8 04 0b 00 00       	call   800edd <sys_cputs>
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
  8003ec:	e8 5b 13 00 00       	call   80174c <read>
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
  800414:	e8 ca 10 00 00       	call   8014e3 <fd_lookup>
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
  80043d:	e8 51 10 00 00       	call   801493 <fd_alloc>
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	85 c0                	test   %eax,%eax
  800447:	78 3a                	js     800483 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800449:	83 ec 04             	sub    $0x4,%esp
  80044c:	68 07 04 00 00       	push   $0x407
  800451:	ff 75 f4             	push   -0xc(%ebp)
  800454:	6a 00                	push   $0x0
  800456:	e8 3e 0b 00 00       	call   800f99 <sys_page_alloc>
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
  80047b:	e8 ec 0f 00 00       	call   80146c <fd2num>
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
  800490:	e8 c6 0a 00 00       	call   800f5b <sys_getenvid>
  800495:	25 ff 03 00 00       	and    $0x3ff,%eax
  80049a:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8004a0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004a5:	a3 00 50 80 00       	mov    %eax,0x805000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004aa:	85 db                	test   %ebx,%ebx
  8004ac:	7e 07                	jle    8004b5 <libmain+0x30>
		binaryname = argv[0];
  8004ae:	8b 06                	mov    (%esi),%eax
  8004b0:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	56                   	push   %esi
  8004b9:	53                   	push   %ebx
  8004ba:	e8 2c fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004bf:	e8 0a 00 00 00       	call   8004ce <exit>
}
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ca:	5b                   	pop    %ebx
  8004cb:	5e                   	pop    %esi
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004d4:	e8 64 11 00 00       	call   80163d <close_all>
	sys_env_destroy(0);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 37 0a 00 00       	call   800f1a <sys_env_destroy>
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	56                   	push   %esi
  8004ec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004ed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f0:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004f6:	e8 60 0a 00 00       	call   800f5b <sys_getenvid>
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	ff 75 0c             	push   0xc(%ebp)
  800501:	ff 75 08             	push   0x8(%ebp)
  800504:	56                   	push   %esi
  800505:	50                   	push   %eax
  800506:	68 e4 2f 80 00       	push   $0x802fe4
  80050b:	e8 b3 00 00 00       	call   8005c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800510:	83 c4 18             	add    $0x18,%esp
  800513:	53                   	push   %ebx
  800514:	ff 75 10             	push   0x10(%ebp)
  800517:	e8 56 00 00 00       	call   800572 <vcprintf>
	cprintf("\n");
  80051c:	c7 04 24 18 2f 80 00 	movl   $0x802f18,(%esp)
  800523:	e8 9b 00 00 00       	call   8005c3 <cprintf>
  800528:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80052b:	cc                   	int3   
  80052c:	eb fd                	jmp    80052b <_panic+0x43>

0080052e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	53                   	push   %ebx
  800532:	83 ec 04             	sub    $0x4,%esp
  800535:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800538:	8b 13                	mov    (%ebx),%edx
  80053a:	8d 42 01             	lea    0x1(%edx),%eax
  80053d:	89 03                	mov    %eax,(%ebx)
  80053f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800542:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800546:	3d ff 00 00 00       	cmp    $0xff,%eax
  80054b:	74 09                	je     800556 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80054d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	68 ff 00 00 00       	push   $0xff
  80055e:	8d 43 08             	lea    0x8(%ebx),%eax
  800561:	50                   	push   %eax
  800562:	e8 76 09 00 00       	call   800edd <sys_cputs>
		b->idx = 0;
  800567:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb db                	jmp    80054d <putch+0x1f>

00800572 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80057b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800582:	00 00 00 
	b.cnt = 0;
  800585:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80058c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80058f:	ff 75 0c             	push   0xc(%ebp)
  800592:	ff 75 08             	push   0x8(%ebp)
  800595:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80059b:	50                   	push   %eax
  80059c:	68 2e 05 80 00       	push   $0x80052e
  8005a1:	e8 14 01 00 00       	call   8006ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005a6:	83 c4 08             	add    $0x8,%esp
  8005a9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8005af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005b5:	50                   	push   %eax
  8005b6:	e8 22 09 00 00       	call   800edd <sys_cputs>

	return b.cnt;
}
  8005bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c1:	c9                   	leave  
  8005c2:	c3                   	ret    

008005c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005c3:	55                   	push   %ebp
  8005c4:	89 e5                	mov    %esp,%ebp
  8005c6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005cc:	50                   	push   %eax
  8005cd:	ff 75 08             	push   0x8(%ebp)
  8005d0:	e8 9d ff ff ff       	call   800572 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    

008005d7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	57                   	push   %edi
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 1c             	sub    $0x1c,%esp
  8005e0:	89 c7                	mov    %eax,%edi
  8005e2:	89 d6                	mov    %edx,%esi
  8005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005ea:	89 d1                	mov    %edx,%ecx
  8005ec:	89 c2                	mov    %eax,%edx
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8005f7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800604:	39 c2                	cmp    %eax,%edx
  800606:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800609:	72 3e                	jb     800649 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80060b:	83 ec 0c             	sub    $0xc,%esp
  80060e:	ff 75 18             	push   0x18(%ebp)
  800611:	83 eb 01             	sub    $0x1,%ebx
  800614:	53                   	push   %ebx
  800615:	50                   	push   %eax
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	ff 75 e4             	push   -0x1c(%ebp)
  80061c:	ff 75 e0             	push   -0x20(%ebp)
  80061f:	ff 75 dc             	push   -0x24(%ebp)
  800622:	ff 75 d8             	push   -0x28(%ebp)
  800625:	e8 26 26 00 00       	call   802c50 <__udivdi3>
  80062a:	83 c4 18             	add    $0x18,%esp
  80062d:	52                   	push   %edx
  80062e:	50                   	push   %eax
  80062f:	89 f2                	mov    %esi,%edx
  800631:	89 f8                	mov    %edi,%eax
  800633:	e8 9f ff ff ff       	call   8005d7 <printnum>
  800638:	83 c4 20             	add    $0x20,%esp
  80063b:	eb 13                	jmp    800650 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	56                   	push   %esi
  800641:	ff 75 18             	push   0x18(%ebp)
  800644:	ff d7                	call   *%edi
  800646:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800649:	83 eb 01             	sub    $0x1,%ebx
  80064c:	85 db                	test   %ebx,%ebx
  80064e:	7f ed                	jg     80063d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	83 ec 04             	sub    $0x4,%esp
  800657:	ff 75 e4             	push   -0x1c(%ebp)
  80065a:	ff 75 e0             	push   -0x20(%ebp)
  80065d:	ff 75 dc             	push   -0x24(%ebp)
  800660:	ff 75 d8             	push   -0x28(%ebp)
  800663:	e8 08 27 00 00       	call   802d70 <__umoddi3>
  800668:	83 c4 14             	add    $0x14,%esp
  80066b:	0f be 80 07 30 80 00 	movsbl 0x803007(%eax),%eax
  800672:	50                   	push   %eax
  800673:	ff d7                	call   *%edi
}
  800675:	83 c4 10             	add    $0x10,%esp
  800678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5f                   	pop    %edi
  80067e:	5d                   	pop    %ebp
  80067f:	c3                   	ret    

00800680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800680:	55                   	push   %ebp
  800681:	89 e5                	mov    %esp,%ebp
  800683:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800686:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	3b 50 04             	cmp    0x4(%eax),%edx
  80068f:	73 0a                	jae    80069b <sprintputch+0x1b>
		*b->buf++ = ch;
  800691:	8d 4a 01             	lea    0x1(%edx),%ecx
  800694:	89 08                	mov    %ecx,(%eax)
  800696:	8b 45 08             	mov    0x8(%ebp),%eax
  800699:	88 02                	mov    %al,(%edx)
}
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <printfmt>:
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006a6:	50                   	push   %eax
  8006a7:	ff 75 10             	push   0x10(%ebp)
  8006aa:	ff 75 0c             	push   0xc(%ebp)
  8006ad:	ff 75 08             	push   0x8(%ebp)
  8006b0:	e8 05 00 00 00       	call   8006ba <vprintfmt>
}
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <vprintfmt>:
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	57                   	push   %edi
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
  8006c0:	83 ec 3c             	sub    $0x3c,%esp
  8006c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006cc:	eb 0a                	jmp    8006d8 <vprintfmt+0x1e>
			putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	50                   	push   %eax
  8006d3:	ff d6                	call   *%esi
  8006d5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d8:	83 c7 01             	add    $0x1,%edi
  8006db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006df:	83 f8 25             	cmp    $0x25,%eax
  8006e2:	74 0c                	je     8006f0 <vprintfmt+0x36>
			if (ch == '\0')
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	75 e6                	jne    8006ce <vprintfmt+0x14>
}
  8006e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    
		padc = ' ';
  8006f0:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8006f4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8006fb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800702:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800709:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8d 47 01             	lea    0x1(%edi),%eax
  800711:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800714:	0f b6 17             	movzbl (%edi),%edx
  800717:	8d 42 dd             	lea    -0x23(%edx),%eax
  80071a:	3c 55                	cmp    $0x55,%al
  80071c:	0f 87 bb 03 00 00    	ja     800add <vprintfmt+0x423>
  800722:	0f b6 c0             	movzbl %al,%eax
  800725:	ff 24 85 40 31 80 00 	jmp    *0x803140(,%eax,4)
  80072c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80072f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800733:	eb d9                	jmp    80070e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800738:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80073c:	eb d0                	jmp    80070e <vprintfmt+0x54>
  80073e:	0f b6 d2             	movzbl %dl,%edx
  800741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80074c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80074f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800753:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800756:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800759:	83 f9 09             	cmp    $0x9,%ecx
  80075c:	77 55                	ja     8007b3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80075e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800761:	eb e9                	jmp    80074c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8b 00                	mov    (%eax),%eax
  800768:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 40 04             	lea    0x4(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800777:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80077b:	79 91                	jns    80070e <vprintfmt+0x54>
				width = precision, precision = -1;
  80077d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800780:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800783:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80078a:	eb 82                	jmp    80070e <vprintfmt+0x54>
  80078c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80078f:	85 d2                	test   %edx,%edx
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	0f 49 c2             	cmovns %edx,%eax
  800799:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80079c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80079f:	e9 6a ff ff ff       	jmp    80070e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8007a7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007ae:	e9 5b ff ff ff       	jmp    80070e <vprintfmt+0x54>
  8007b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b9:	eb bc                	jmp    800777 <vprintfmt+0xbd>
			lflag++;
  8007bb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007c1:	e9 48 ff ff ff       	jmp    80070e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8d 78 04             	lea    0x4(%eax),%edi
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	ff 30                	push   (%eax)
  8007d2:	ff d6                	call   *%esi
			break;
  8007d4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007d7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007da:	e9 9d 02 00 00       	jmp    800a7c <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 78 04             	lea    0x4(%eax),%edi
  8007e5:	8b 10                	mov    (%eax),%edx
  8007e7:	89 d0                	mov    %edx,%eax
  8007e9:	f7 d8                	neg    %eax
  8007eb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007ee:	83 f8 0f             	cmp    $0xf,%eax
  8007f1:	7f 23                	jg     800816 <vprintfmt+0x15c>
  8007f3:	8b 14 85 a0 32 80 00 	mov    0x8032a0(,%eax,4),%edx
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	74 18                	je     800816 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8007fe:	52                   	push   %edx
  8007ff:	68 a1 34 80 00       	push   $0x8034a1
  800804:	53                   	push   %ebx
  800805:	56                   	push   %esi
  800806:	e8 92 fe ff ff       	call   80069d <printfmt>
  80080b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80080e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800811:	e9 66 02 00 00       	jmp    800a7c <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800816:	50                   	push   %eax
  800817:	68 1f 30 80 00       	push   $0x80301f
  80081c:	53                   	push   %ebx
  80081d:	56                   	push   %esi
  80081e:	e8 7a fe ff ff       	call   80069d <printfmt>
  800823:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800826:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800829:	e9 4e 02 00 00       	jmp    800a7c <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80082e:	8b 45 14             	mov    0x14(%ebp),%eax
  800831:	83 c0 04             	add    $0x4,%eax
  800834:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80083c:	85 d2                	test   %edx,%edx
  80083e:	b8 18 30 80 00       	mov    $0x803018,%eax
  800843:	0f 45 c2             	cmovne %edx,%eax
  800846:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800849:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80084d:	7e 06                	jle    800855 <vprintfmt+0x19b>
  80084f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800853:	75 0d                	jne    800862 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800855:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800858:	89 c7                	mov    %eax,%edi
  80085a:	03 45 e0             	add    -0x20(%ebp),%eax
  80085d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800860:	eb 55                	jmp    8008b7 <vprintfmt+0x1fd>
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	ff 75 d8             	push   -0x28(%ebp)
  800868:	ff 75 cc             	push   -0x34(%ebp)
  80086b:	e8 0a 03 00 00       	call   800b7a <strnlen>
  800870:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800873:	29 c1                	sub    %eax,%ecx
  800875:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80087d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800881:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800884:	eb 0f                	jmp    800895 <vprintfmt+0x1db>
					putch(padc, putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	ff 75 e0             	push   -0x20(%ebp)
  80088d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80088f:	83 ef 01             	sub    $0x1,%edi
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 ff                	test   %edi,%edi
  800897:	7f ed                	jg     800886 <vprintfmt+0x1cc>
  800899:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80089c:	85 d2                	test   %edx,%edx
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	0f 49 c2             	cmovns %edx,%eax
  8008a6:	29 c2                	sub    %eax,%edx
  8008a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008ab:	eb a8                	jmp    800855 <vprintfmt+0x19b>
					putch(ch, putdat);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	53                   	push   %ebx
  8008b1:	52                   	push   %edx
  8008b2:	ff d6                	call   *%esi
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008ba:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bc:	83 c7 01             	add    $0x1,%edi
  8008bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c3:	0f be d0             	movsbl %al,%edx
  8008c6:	85 d2                	test   %edx,%edx
  8008c8:	74 4b                	je     800915 <vprintfmt+0x25b>
  8008ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ce:	78 06                	js     8008d6 <vprintfmt+0x21c>
  8008d0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8008d4:	78 1e                	js     8008f4 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8008da:	74 d1                	je     8008ad <vprintfmt+0x1f3>
  8008dc:	0f be c0             	movsbl %al,%eax
  8008df:	83 e8 20             	sub    $0x20,%eax
  8008e2:	83 f8 5e             	cmp    $0x5e,%eax
  8008e5:	76 c6                	jbe    8008ad <vprintfmt+0x1f3>
					putch('?', putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	53                   	push   %ebx
  8008eb:	6a 3f                	push   $0x3f
  8008ed:	ff d6                	call   *%esi
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	eb c3                	jmp    8008b7 <vprintfmt+0x1fd>
  8008f4:	89 cf                	mov    %ecx,%edi
  8008f6:	eb 0e                	jmp    800906 <vprintfmt+0x24c>
				putch(' ', putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	6a 20                	push   $0x20
  8008fe:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800900:	83 ef 01             	sub    $0x1,%edi
  800903:	83 c4 10             	add    $0x10,%esp
  800906:	85 ff                	test   %edi,%edi
  800908:	7f ee                	jg     8008f8 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80090a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80090d:	89 45 14             	mov    %eax,0x14(%ebp)
  800910:	e9 67 01 00 00       	jmp    800a7c <vprintfmt+0x3c2>
  800915:	89 cf                	mov    %ecx,%edi
  800917:	eb ed                	jmp    800906 <vprintfmt+0x24c>
	if (lflag >= 2)
  800919:	83 f9 01             	cmp    $0x1,%ecx
  80091c:	7f 1b                	jg     800939 <vprintfmt+0x27f>
	else if (lflag)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 63                	je     800985 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8b 00                	mov    (%eax),%eax
  800927:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092a:	99                   	cltd   
  80092b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80092e:	8b 45 14             	mov    0x14(%ebp),%eax
  800931:	8d 40 04             	lea    0x4(%eax),%eax
  800934:	89 45 14             	mov    %eax,0x14(%ebp)
  800937:	eb 17                	jmp    800950 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800939:	8b 45 14             	mov    0x14(%ebp),%eax
  80093c:	8b 50 04             	mov    0x4(%eax),%edx
  80093f:	8b 00                	mov    (%eax),%eax
  800941:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800944:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8d 40 08             	lea    0x8(%eax),%eax
  80094d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800950:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800953:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800956:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80095b:	85 c9                	test   %ecx,%ecx
  80095d:	0f 89 ff 00 00 00    	jns    800a62 <vprintfmt+0x3a8>
				putch('-', putdat);
  800963:	83 ec 08             	sub    $0x8,%esp
  800966:	53                   	push   %ebx
  800967:	6a 2d                	push   $0x2d
  800969:	ff d6                	call   *%esi
				num = -(long long) num;
  80096b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80096e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800971:	f7 da                	neg    %edx
  800973:	83 d1 00             	adc    $0x0,%ecx
  800976:	f7 d9                	neg    %ecx
  800978:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80097b:	bf 0a 00 00 00       	mov    $0xa,%edi
  800980:	e9 dd 00 00 00       	jmp    800a62 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8b 00                	mov    (%eax),%eax
  80098a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098d:	99                   	cltd   
  80098e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800991:	8b 45 14             	mov    0x14(%ebp),%eax
  800994:	8d 40 04             	lea    0x4(%eax),%eax
  800997:	89 45 14             	mov    %eax,0x14(%ebp)
  80099a:	eb b4                	jmp    800950 <vprintfmt+0x296>
	if (lflag >= 2)
  80099c:	83 f9 01             	cmp    $0x1,%ecx
  80099f:	7f 1e                	jg     8009bf <vprintfmt+0x305>
	else if (lflag)
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	74 32                	je     8009d7 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8009a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a8:	8b 10                	mov    (%eax),%edx
  8009aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009af:	8d 40 04             	lea    0x4(%eax),%eax
  8009b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009b5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8009ba:	e9 a3 00 00 00       	jmp    800a62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8009bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c2:	8b 10                	mov    (%eax),%edx
  8009c4:	8b 48 04             	mov    0x4(%eax),%ecx
  8009c7:	8d 40 08             	lea    0x8(%eax),%eax
  8009ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009cd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8009d2:	e9 8b 00 00 00       	jmp    800a62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8009d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009da:	8b 10                	mov    (%eax),%edx
  8009dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e1:	8d 40 04             	lea    0x4(%eax),%eax
  8009e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009e7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8009ec:	eb 74                	jmp    800a62 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8009ee:	83 f9 01             	cmp    $0x1,%ecx
  8009f1:	7f 1b                	jg     800a0e <vprintfmt+0x354>
	else if (lflag)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 2c                	je     800a23 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8009f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fa:	8b 10                	mov    (%eax),%edx
  8009fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a01:	8d 40 04             	lea    0x4(%eax),%eax
  800a04:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a07:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800a0c:	eb 54                	jmp    800a62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800a0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a11:	8b 10                	mov    (%eax),%edx
  800a13:	8b 48 04             	mov    0x4(%eax),%ecx
  800a16:	8d 40 08             	lea    0x8(%eax),%eax
  800a19:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a1c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800a21:	eb 3f                	jmp    800a62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800a23:	8b 45 14             	mov    0x14(%ebp),%eax
  800a26:	8b 10                	mov    (%eax),%edx
  800a28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2d:	8d 40 04             	lea    0x4(%eax),%eax
  800a30:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a33:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800a38:	eb 28                	jmp    800a62 <vprintfmt+0x3a8>
			putch('0', putdat);
  800a3a:	83 ec 08             	sub    $0x8,%esp
  800a3d:	53                   	push   %ebx
  800a3e:	6a 30                	push   $0x30
  800a40:	ff d6                	call   *%esi
			putch('x', putdat);
  800a42:	83 c4 08             	add    $0x8,%esp
  800a45:	53                   	push   %ebx
  800a46:	6a 78                	push   $0x78
  800a48:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4d:	8b 10                	mov    (%eax),%edx
  800a4f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a54:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a57:	8d 40 04             	lea    0x4(%eax),%eax
  800a5a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a5d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800a62:	83 ec 0c             	sub    $0xc,%esp
  800a65:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800a69:	50                   	push   %eax
  800a6a:	ff 75 e0             	push   -0x20(%ebp)
  800a6d:	57                   	push   %edi
  800a6e:	51                   	push   %ecx
  800a6f:	52                   	push   %edx
  800a70:	89 da                	mov    %ebx,%edx
  800a72:	89 f0                	mov    %esi,%eax
  800a74:	e8 5e fb ff ff       	call   8005d7 <printnum>
			break;
  800a79:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a7f:	e9 54 fc ff ff       	jmp    8006d8 <vprintfmt+0x1e>
	if (lflag >= 2)
  800a84:	83 f9 01             	cmp    $0x1,%ecx
  800a87:	7f 1b                	jg     800aa4 <vprintfmt+0x3ea>
	else if (lflag)
  800a89:	85 c9                	test   %ecx,%ecx
  800a8b:	74 2c                	je     800ab9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800a8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a90:	8b 10                	mov    (%eax),%edx
  800a92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a97:	8d 40 04             	lea    0x4(%eax),%eax
  800a9a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a9d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800aa2:	eb be                	jmp    800a62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa7:	8b 10                	mov    (%eax),%edx
  800aa9:	8b 48 04             	mov    0x4(%eax),%ecx
  800aac:	8d 40 08             	lea    0x8(%eax),%eax
  800aaf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ab2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800ab7:	eb a9                	jmp    800a62 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800ab9:	8b 45 14             	mov    0x14(%ebp),%eax
  800abc:	8b 10                	mov    (%eax),%edx
  800abe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac3:	8d 40 04             	lea    0x4(%eax),%eax
  800ac6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ac9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800ace:	eb 92                	jmp    800a62 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	53                   	push   %ebx
  800ad4:	6a 25                	push   $0x25
  800ad6:	ff d6                	call   *%esi
			break;
  800ad8:	83 c4 10             	add    $0x10,%esp
  800adb:	eb 9f                	jmp    800a7c <vprintfmt+0x3c2>
			putch('%', putdat);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	53                   	push   %ebx
  800ae1:	6a 25                	push   $0x25
  800ae3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae5:	83 c4 10             	add    $0x10,%esp
  800ae8:	89 f8                	mov    %edi,%eax
  800aea:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800aee:	74 05                	je     800af5 <vprintfmt+0x43b>
  800af0:	83 e8 01             	sub    $0x1,%eax
  800af3:	eb f5                	jmp    800aea <vprintfmt+0x430>
  800af5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800af8:	eb 82                	jmp    800a7c <vprintfmt+0x3c2>

00800afa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	83 ec 18             	sub    $0x18,%esp
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b09:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b0d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	74 26                	je     800b41 <vsnprintf+0x47>
  800b1b:	85 d2                	test   %edx,%edx
  800b1d:	7e 22                	jle    800b41 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b1f:	ff 75 14             	push   0x14(%ebp)
  800b22:	ff 75 10             	push   0x10(%ebp)
  800b25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b28:	50                   	push   %eax
  800b29:	68 80 06 80 00       	push   $0x800680
  800b2e:	e8 87 fb ff ff       	call   8006ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b36:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b3c:	83 c4 10             	add    $0x10,%esp
}
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    
		return -E_INVAL;
  800b41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b46:	eb f7                	jmp    800b3f <vsnprintf+0x45>

00800b48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b4e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b51:	50                   	push   %eax
  800b52:	ff 75 10             	push   0x10(%ebp)
  800b55:	ff 75 0c             	push   0xc(%ebp)
  800b58:	ff 75 08             	push   0x8(%ebp)
  800b5b:	e8 9a ff ff ff       	call   800afa <vsnprintf>
	va_end(ap);

	return rc;
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	eb 03                	jmp    800b72 <strlen+0x10>
		n++;
  800b6f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b72:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b76:	75 f7                	jne    800b6f <strlen+0xd>
	return n;
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b80:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
  800b88:	eb 03                	jmp    800b8d <strnlen+0x13>
		n++;
  800b8a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b8d:	39 d0                	cmp    %edx,%eax
  800b8f:	74 08                	je     800b99 <strnlen+0x1f>
  800b91:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b95:	75 f3                	jne    800b8a <strnlen+0x10>
  800b97:	89 c2                	mov    %eax,%edx
	return n;
}
  800b99:	89 d0                	mov    %edx,%eax
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	53                   	push   %ebx
  800ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800bb0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800bb3:	83 c0 01             	add    $0x1,%eax
  800bb6:	84 d2                	test   %dl,%dl
  800bb8:	75 f2                	jne    800bac <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bba:	89 c8                	mov    %ecx,%eax
  800bbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 10             	sub    $0x10,%esp
  800bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bcb:	53                   	push   %ebx
  800bcc:	e8 91 ff ff ff       	call   800b62 <strlen>
  800bd1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bd4:	ff 75 0c             	push   0xc(%ebp)
  800bd7:	01 d8                	add    %ebx,%eax
  800bd9:	50                   	push   %eax
  800bda:	e8 be ff ff ff       	call   800b9d <strcpy>
	return dst;
}
  800bdf:	89 d8                	mov    %ebx,%eax
  800be1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be4:	c9                   	leave  
  800be5:	c3                   	ret    

00800be6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	8b 75 08             	mov    0x8(%ebp),%esi
  800bee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf6:	89 f0                	mov    %esi,%eax
  800bf8:	eb 0f                	jmp    800c09 <strncpy+0x23>
		*dst++ = *src;
  800bfa:	83 c0 01             	add    $0x1,%eax
  800bfd:	0f b6 0a             	movzbl (%edx),%ecx
  800c00:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c03:	80 f9 01             	cmp    $0x1,%cl
  800c06:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800c09:	39 d8                	cmp    %ebx,%eax
  800c0b:	75 ed                	jne    800bfa <strncpy+0x14>
	}
	return ret;
}
  800c0d:	89 f0                	mov    %esi,%eax
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 10             	mov    0x10(%ebp),%edx
  800c21:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c23:	85 d2                	test   %edx,%edx
  800c25:	74 21                	je     800c48 <strlcpy+0x35>
  800c27:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c2b:	89 f2                	mov    %esi,%edx
  800c2d:	eb 09                	jmp    800c38 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c2f:	83 c1 01             	add    $0x1,%ecx
  800c32:	83 c2 01             	add    $0x1,%edx
  800c35:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800c38:	39 c2                	cmp    %eax,%edx
  800c3a:	74 09                	je     800c45 <strlcpy+0x32>
  800c3c:	0f b6 19             	movzbl (%ecx),%ebx
  800c3f:	84 db                	test   %bl,%bl
  800c41:	75 ec                	jne    800c2f <strlcpy+0x1c>
  800c43:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c45:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c48:	29 f0                	sub    %esi,%eax
}
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c54:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c57:	eb 06                	jmp    800c5f <strcmp+0x11>
		p++, q++;
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800c5f:	0f b6 01             	movzbl (%ecx),%eax
  800c62:	84 c0                	test   %al,%al
  800c64:	74 04                	je     800c6a <strcmp+0x1c>
  800c66:	3a 02                	cmp    (%edx),%al
  800c68:	74 ef                	je     800c59 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c6a:	0f b6 c0             	movzbl %al,%eax
  800c6d:	0f b6 12             	movzbl (%edx),%edx
  800c70:	29 d0                	sub    %edx,%eax
}
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	53                   	push   %ebx
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7e:	89 c3                	mov    %eax,%ebx
  800c80:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c83:	eb 06                	jmp    800c8b <strncmp+0x17>
		n--, p++, q++;
  800c85:	83 c0 01             	add    $0x1,%eax
  800c88:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c8b:	39 d8                	cmp    %ebx,%eax
  800c8d:	74 18                	je     800ca7 <strncmp+0x33>
  800c8f:	0f b6 08             	movzbl (%eax),%ecx
  800c92:	84 c9                	test   %cl,%cl
  800c94:	74 04                	je     800c9a <strncmp+0x26>
  800c96:	3a 0a                	cmp    (%edx),%cl
  800c98:	74 eb                	je     800c85 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c9a:	0f b6 00             	movzbl (%eax),%eax
  800c9d:	0f b6 12             	movzbl (%edx),%edx
  800ca0:	29 d0                	sub    %edx,%eax
}
  800ca2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    
		return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cac:	eb f4                	jmp    800ca2 <strncmp+0x2e>

00800cae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb8:	eb 03                	jmp    800cbd <strchr+0xf>
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	0f b6 10             	movzbl (%eax),%edx
  800cc0:	84 d2                	test   %dl,%dl
  800cc2:	74 06                	je     800cca <strchr+0x1c>
		if (*s == c)
  800cc4:	38 ca                	cmp    %cl,%dl
  800cc6:	75 f2                	jne    800cba <strchr+0xc>
  800cc8:	eb 05                	jmp    800ccf <strchr+0x21>
			return (char *) s;
	return 0;
  800cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cdb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cde:	38 ca                	cmp    %cl,%dl
  800ce0:	74 09                	je     800ceb <strfind+0x1a>
  800ce2:	84 d2                	test   %dl,%dl
  800ce4:	74 05                	je     800ceb <strfind+0x1a>
	for (; *s; s++)
  800ce6:	83 c0 01             	add    $0x1,%eax
  800ce9:	eb f0                	jmp    800cdb <strfind+0xa>
			break;
	return (char *) s;
}
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	57                   	push   %edi
  800cf1:	56                   	push   %esi
  800cf2:	53                   	push   %ebx
  800cf3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cf9:	85 c9                	test   %ecx,%ecx
  800cfb:	74 2f                	je     800d2c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cfd:	89 f8                	mov    %edi,%eax
  800cff:	09 c8                	or     %ecx,%eax
  800d01:	a8 03                	test   $0x3,%al
  800d03:	75 21                	jne    800d26 <memset+0x39>
		c &= 0xFF;
  800d05:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d09:	89 d0                	mov    %edx,%eax
  800d0b:	c1 e0 08             	shl    $0x8,%eax
  800d0e:	89 d3                	mov    %edx,%ebx
  800d10:	c1 e3 18             	shl    $0x18,%ebx
  800d13:	89 d6                	mov    %edx,%esi
  800d15:	c1 e6 10             	shl    $0x10,%esi
  800d18:	09 f3                	or     %esi,%ebx
  800d1a:	09 da                	or     %ebx,%edx
  800d1c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d1e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d21:	fc                   	cld    
  800d22:	f3 ab                	rep stos %eax,%es:(%edi)
  800d24:	eb 06                	jmp    800d2c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d29:	fc                   	cld    
  800d2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d2c:	89 f8                	mov    %edi,%eax
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d41:	39 c6                	cmp    %eax,%esi
  800d43:	73 32                	jae    800d77 <memmove+0x44>
  800d45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d48:	39 c2                	cmp    %eax,%edx
  800d4a:	76 2b                	jbe    800d77 <memmove+0x44>
		s += n;
		d += n;
  800d4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	09 fe                	or     %edi,%esi
  800d53:	09 ce                	or     %ecx,%esi
  800d55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d5b:	75 0e                	jne    800d6b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d5d:	83 ef 04             	sub    $0x4,%edi
  800d60:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d66:	fd                   	std    
  800d67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d69:	eb 09                	jmp    800d74 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d6b:	83 ef 01             	sub    $0x1,%edi
  800d6e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d71:	fd                   	std    
  800d72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d74:	fc                   	cld    
  800d75:	eb 1a                	jmp    800d91 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d77:	89 f2                	mov    %esi,%edx
  800d79:	09 c2                	or     %eax,%edx
  800d7b:	09 ca                	or     %ecx,%edx
  800d7d:	f6 c2 03             	test   $0x3,%dl
  800d80:	75 0a                	jne    800d8c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d85:	89 c7                	mov    %eax,%edi
  800d87:	fc                   	cld    
  800d88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d8a:	eb 05                	jmp    800d91 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d8c:	89 c7                	mov    %eax,%edi
  800d8e:	fc                   	cld    
  800d8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d9b:	ff 75 10             	push   0x10(%ebp)
  800d9e:	ff 75 0c             	push   0xc(%ebp)
  800da1:	ff 75 08             	push   0x8(%ebp)
  800da4:	e8 8a ff ff ff       	call   800d33 <memmove>
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db6:	89 c6                	mov    %eax,%esi
  800db8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbb:	eb 06                	jmp    800dc3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dbd:	83 c0 01             	add    $0x1,%eax
  800dc0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800dc3:	39 f0                	cmp    %esi,%eax
  800dc5:	74 14                	je     800ddb <memcmp+0x30>
		if (*s1 != *s2)
  800dc7:	0f b6 08             	movzbl (%eax),%ecx
  800dca:	0f b6 1a             	movzbl (%edx),%ebx
  800dcd:	38 d9                	cmp    %bl,%cl
  800dcf:	74 ec                	je     800dbd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800dd1:	0f b6 c1             	movzbl %cl,%eax
  800dd4:	0f b6 db             	movzbl %bl,%ebx
  800dd7:	29 d8                	sub    %ebx,%eax
  800dd9:	eb 05                	jmp    800de0 <memcmp+0x35>
	}

	return 0;
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ded:	89 c2                	mov    %eax,%edx
  800def:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df2:	eb 03                	jmp    800df7 <memfind+0x13>
  800df4:	83 c0 01             	add    $0x1,%eax
  800df7:	39 d0                	cmp    %edx,%eax
  800df9:	73 04                	jae    800dff <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dfb:	38 08                	cmp    %cl,(%eax)
  800dfd:	75 f5                	jne    800df4 <memfind+0x10>
			break;
	return (void *) s;
}
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0d:	eb 03                	jmp    800e12 <strtol+0x11>
		s++;
  800e0f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800e12:	0f b6 02             	movzbl (%edx),%eax
  800e15:	3c 20                	cmp    $0x20,%al
  800e17:	74 f6                	je     800e0f <strtol+0xe>
  800e19:	3c 09                	cmp    $0x9,%al
  800e1b:	74 f2                	je     800e0f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e1d:	3c 2b                	cmp    $0x2b,%al
  800e1f:	74 2a                	je     800e4b <strtol+0x4a>
	int neg = 0;
  800e21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e26:	3c 2d                	cmp    $0x2d,%al
  800e28:	74 2b                	je     800e55 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e30:	75 0f                	jne    800e41 <strtol+0x40>
  800e32:	80 3a 30             	cmpb   $0x30,(%edx)
  800e35:	74 28                	je     800e5f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e37:	85 db                	test   %ebx,%ebx
  800e39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e3e:	0f 44 d8             	cmove  %eax,%ebx
  800e41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e46:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e49:	eb 46                	jmp    800e91 <strtol+0x90>
		s++;
  800e4b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800e4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e53:	eb d5                	jmp    800e2a <strtol+0x29>
		s++, neg = 1;
  800e55:	83 c2 01             	add    $0x1,%edx
  800e58:	bf 01 00 00 00       	mov    $0x1,%edi
  800e5d:	eb cb                	jmp    800e2a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e63:	74 0e                	je     800e73 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e65:	85 db                	test   %ebx,%ebx
  800e67:	75 d8                	jne    800e41 <strtol+0x40>
		s++, base = 8;
  800e69:	83 c2 01             	add    $0x1,%edx
  800e6c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e71:	eb ce                	jmp    800e41 <strtol+0x40>
		s += 2, base = 16;
  800e73:	83 c2 02             	add    $0x2,%edx
  800e76:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e7b:	eb c4                	jmp    800e41 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e7d:	0f be c0             	movsbl %al,%eax
  800e80:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e83:	3b 45 10             	cmp    0x10(%ebp),%eax
  800e86:	7d 3a                	jge    800ec2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e88:	83 c2 01             	add    $0x1,%edx
  800e8b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800e8f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800e91:	0f b6 02             	movzbl (%edx),%eax
  800e94:	8d 70 d0             	lea    -0x30(%eax),%esi
  800e97:	89 f3                	mov    %esi,%ebx
  800e99:	80 fb 09             	cmp    $0x9,%bl
  800e9c:	76 df                	jbe    800e7d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800e9e:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ea1:	89 f3                	mov    %esi,%ebx
  800ea3:	80 fb 19             	cmp    $0x19,%bl
  800ea6:	77 08                	ja     800eb0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ea8:	0f be c0             	movsbl %al,%eax
  800eab:	83 e8 57             	sub    $0x57,%eax
  800eae:	eb d3                	jmp    800e83 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800eb0:	8d 70 bf             	lea    -0x41(%eax),%esi
  800eb3:	89 f3                	mov    %esi,%ebx
  800eb5:	80 fb 19             	cmp    $0x19,%bl
  800eb8:	77 08                	ja     800ec2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800eba:	0f be c0             	movsbl %al,%eax
  800ebd:	83 e8 37             	sub    $0x37,%eax
  800ec0:	eb c1                	jmp    800e83 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ec2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ec6:	74 05                	je     800ecd <strtol+0xcc>
		*endptr = (char *) s;
  800ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ecd:	89 c8                	mov    %ecx,%eax
  800ecf:	f7 d8                	neg    %eax
  800ed1:	85 ff                	test   %edi,%edi
  800ed3:	0f 45 c8             	cmovne %eax,%ecx
}
  800ed6:	89 c8                	mov    %ecx,%eax
  800ed8:	5b                   	pop    %ebx
  800ed9:	5e                   	pop    %esi
  800eda:	5f                   	pop    %edi
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	89 c3                	mov    %eax,%ebx
  800ef0:	89 c7                	mov    %eax,%edi
  800ef2:	89 c6                	mov    %eax,%esi
  800ef4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_cgetc>:

int
sys_cgetc(void)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f01:	ba 00 00 00 00       	mov    $0x0,%edx
  800f06:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0b:	89 d1                	mov    %edx,%ecx
  800f0d:	89 d3                	mov    %edx,%ebx
  800f0f:	89 d7                	mov    %edx,%edi
  800f11:	89 d6                	mov    %edx,%esi
  800f13:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	57                   	push   %edi
  800f1e:	56                   	push   %esi
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f23:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f28:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800f30:	89 cb                	mov    %ecx,%ebx
  800f32:	89 cf                	mov    %ecx,%edi
  800f34:	89 ce                	mov    %ecx,%esi
  800f36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	7f 08                	jg     800f44 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	50                   	push   %eax
  800f48:	6a 03                	push   $0x3
  800f4a:	68 ff 32 80 00       	push   $0x8032ff
  800f4f:	6a 2a                	push   $0x2a
  800f51:	68 1c 33 80 00       	push   $0x80331c
  800f56:	e8 8d f5 ff ff       	call   8004e8 <_panic>

00800f5b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f61:	ba 00 00 00 00       	mov    $0x0,%edx
  800f66:	b8 02 00 00 00       	mov    $0x2,%eax
  800f6b:	89 d1                	mov    %edx,%ecx
  800f6d:	89 d3                	mov    %edx,%ebx
  800f6f:	89 d7                	mov    %edx,%edi
  800f71:	89 d6                	mov    %edx,%esi
  800f73:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <sys_yield>:

void
sys_yield(void)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f80:	ba 00 00 00 00       	mov    $0x0,%edx
  800f85:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f8a:	89 d1                	mov    %edx,%ecx
  800f8c:	89 d3                	mov    %edx,%ebx
  800f8e:	89 d7                	mov    %edx,%edi
  800f90:	89 d6                	mov    %edx,%esi
  800f92:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f94:	5b                   	pop    %ebx
  800f95:	5e                   	pop    %esi
  800f96:	5f                   	pop    %edi
  800f97:	5d                   	pop    %ebp
  800f98:	c3                   	ret    

00800f99 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	57                   	push   %edi
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fa2:	be 00 00 00 00       	mov    $0x0,%esi
  800fa7:	8b 55 08             	mov    0x8(%ebp),%edx
  800faa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fad:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb5:	89 f7                	mov    %esi,%edi
  800fb7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	7f 08                	jg     800fc5 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	50                   	push   %eax
  800fc9:	6a 04                	push   $0x4
  800fcb:	68 ff 32 80 00       	push   $0x8032ff
  800fd0:	6a 2a                	push   $0x2a
  800fd2:	68 1c 33 80 00       	push   $0x80331c
  800fd7:	e8 0c f5 ff ff       	call   8004e8 <_panic>

00800fdc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	57                   	push   %edi
  800fe0:	56                   	push   %esi
  800fe1:	53                   	push   %ebx
  800fe2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fe5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800feb:	b8 05 00 00 00       	mov    $0x5,%eax
  800ff0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff6:	8b 75 18             	mov    0x18(%ebp),%esi
  800ff9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	7f 08                	jg     801007 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	50                   	push   %eax
  80100b:	6a 05                	push   $0x5
  80100d:	68 ff 32 80 00       	push   $0x8032ff
  801012:	6a 2a                	push   $0x2a
  801014:	68 1c 33 80 00       	push   $0x80331c
  801019:	e8 ca f4 ff ff       	call   8004e8 <_panic>

0080101e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801027:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801032:	b8 06 00 00 00       	mov    $0x6,%eax
  801037:	89 df                	mov    %ebx,%edi
  801039:	89 de                	mov    %ebx,%esi
  80103b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80103d:	85 c0                	test   %eax,%eax
  80103f:	7f 08                	jg     801049 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801041:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	50                   	push   %eax
  80104d:	6a 06                	push   $0x6
  80104f:	68 ff 32 80 00       	push   $0x8032ff
  801054:	6a 2a                	push   $0x2a
  801056:	68 1c 33 80 00       	push   $0x80331c
  80105b:	e8 88 f4 ff ff       	call   8004e8 <_panic>

00801060 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	53                   	push   %ebx
  801066:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801069:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801074:	b8 08 00 00 00       	mov    $0x8,%eax
  801079:	89 df                	mov    %ebx,%edi
  80107b:	89 de                	mov    %ebx,%esi
  80107d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80107f:	85 c0                	test   %eax,%eax
  801081:	7f 08                	jg     80108b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801083:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801086:	5b                   	pop    %ebx
  801087:	5e                   	pop    %esi
  801088:	5f                   	pop    %edi
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	50                   	push   %eax
  80108f:	6a 08                	push   $0x8
  801091:	68 ff 32 80 00       	push   $0x8032ff
  801096:	6a 2a                	push   $0x2a
  801098:	68 1c 33 80 00       	push   $0x80331c
  80109d:	e8 46 f4 ff ff       	call   8004e8 <_panic>

008010a2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b6:	b8 09 00 00 00       	mov    $0x9,%eax
  8010bb:	89 df                	mov    %ebx,%edi
  8010bd:	89 de                	mov    %ebx,%esi
  8010bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	7f 08                	jg     8010cd <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010cd:	83 ec 0c             	sub    $0xc,%esp
  8010d0:	50                   	push   %eax
  8010d1:	6a 09                	push   $0x9
  8010d3:	68 ff 32 80 00       	push   $0x8032ff
  8010d8:	6a 2a                	push   $0x2a
  8010da:	68 1c 33 80 00       	push   $0x80331c
  8010df:	e8 04 f4 ff ff       	call   8004e8 <_panic>

008010e4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010fd:	89 df                	mov    %ebx,%edi
  8010ff:	89 de                	mov    %ebx,%esi
  801101:	cd 30                	int    $0x30
	if(check && ret > 0)
  801103:	85 c0                	test   %eax,%eax
  801105:	7f 08                	jg     80110f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80110a:	5b                   	pop    %ebx
  80110b:	5e                   	pop    %esi
  80110c:	5f                   	pop    %edi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80110f:	83 ec 0c             	sub    $0xc,%esp
  801112:	50                   	push   %eax
  801113:	6a 0a                	push   $0xa
  801115:	68 ff 32 80 00       	push   $0x8032ff
  80111a:	6a 2a                	push   $0x2a
  80111c:	68 1c 33 80 00       	push   $0x80331c
  801121:	e8 c2 f3 ff ff       	call   8004e8 <_panic>

00801126 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80112c:	8b 55 08             	mov    0x8(%ebp),%edx
  80112f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801132:	b8 0c 00 00 00       	mov    $0xc,%eax
  801137:	be 00 00 00 00       	mov    $0x0,%esi
  80113c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80113f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801142:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801152:	b9 00 00 00 00       	mov    $0x0,%ecx
  801157:	8b 55 08             	mov    0x8(%ebp),%edx
  80115a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80115f:	89 cb                	mov    %ecx,%ebx
  801161:	89 cf                	mov    %ecx,%edi
  801163:	89 ce                	mov    %ecx,%esi
  801165:	cd 30                	int    $0x30
	if(check && ret > 0)
  801167:	85 c0                	test   %eax,%eax
  801169:	7f 08                	jg     801173 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	50                   	push   %eax
  801177:	6a 0d                	push   $0xd
  801179:	68 ff 32 80 00       	push   $0x8032ff
  80117e:	6a 2a                	push   $0x2a
  801180:	68 1c 33 80 00       	push   $0x80331c
  801185:	e8 5e f3 ff ff       	call   8004e8 <_panic>

0080118a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80118a:	55                   	push   %ebp
  80118b:	89 e5                	mov    %esp,%ebp
  80118d:	57                   	push   %edi
  80118e:	56                   	push   %esi
  80118f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801190:	ba 00 00 00 00       	mov    $0x0,%edx
  801195:	b8 0e 00 00 00       	mov    $0xe,%eax
  80119a:	89 d1                	mov    %edx,%ecx
  80119c:	89 d3                	mov    %edx,%ebx
  80119e:	89 d7                	mov    %edx,%edi
  8011a0:	89 d6                	mov    %edx,%esi
  8011a2:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011a4:	5b                   	pop    %ebx
  8011a5:	5e                   	pop    %esi
  8011a6:	5f                   	pop    %edi
  8011a7:	5d                   	pop    %ebp
  8011a8:	c3                   	ret    

008011a9 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  8011a9:	55                   	push   %ebp
  8011aa:	89 e5                	mov    %esp,%ebp
  8011ac:	57                   	push   %edi
  8011ad:	56                   	push   %esi
  8011ae:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ba:	b8 0f 00 00 00       	mov    $0xf,%eax
  8011bf:	89 df                	mov    %ebx,%edi
  8011c1:	89 de                	mov    %ebx,%esi
  8011c3:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8011c5:	5b                   	pop    %ebx
  8011c6:	5e                   	pop    %esi
  8011c7:	5f                   	pop    %edi
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011db:	b8 10 00 00 00       	mov    $0x10,%eax
  8011e0:	89 df                	mov    %ebx,%edi
  8011e2:	89 de                	mov    %ebx,%esi
  8011e4:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8011f3:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  8011f5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8011f9:	0f 84 8e 00 00 00    	je     80128d <pgfault+0xa2>
  8011ff:	89 f0                	mov    %esi,%eax
  801201:	c1 e8 0c             	shr    $0xc,%eax
  801204:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80120b:	f6 c4 08             	test   $0x8,%ah
  80120e:	74 7d                	je     80128d <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  801210:	e8 46 fd ff ff       	call   800f5b <sys_getenvid>
  801215:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801217:	83 ec 04             	sub    $0x4,%esp
  80121a:	6a 07                	push   $0x7
  80121c:	68 00 f0 7f 00       	push   $0x7ff000
  801221:	50                   	push   %eax
  801222:	e8 72 fd ff ff       	call   800f99 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801227:	83 c4 10             	add    $0x10,%esp
  80122a:	85 c0                	test   %eax,%eax
  80122c:	78 73                	js     8012a1 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  80122e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	68 00 10 00 00       	push   $0x1000
  80123c:	56                   	push   %esi
  80123d:	68 00 f0 7f 00       	push   $0x7ff000
  801242:	e8 ec fa ff ff       	call   800d33 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801247:	83 c4 08             	add    $0x8,%esp
  80124a:	56                   	push   %esi
  80124b:	53                   	push   %ebx
  80124c:	e8 cd fd ff ff       	call   80101e <sys_page_unmap>
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	85 c0                	test   %eax,%eax
  801256:	78 5b                	js     8012b3 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801258:	83 ec 0c             	sub    $0xc,%esp
  80125b:	6a 07                	push   $0x7
  80125d:	56                   	push   %esi
  80125e:	53                   	push   %ebx
  80125f:	68 00 f0 7f 00       	push   $0x7ff000
  801264:	53                   	push   %ebx
  801265:	e8 72 fd ff ff       	call   800fdc <sys_page_map>
  80126a:	83 c4 20             	add    $0x20,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 54                	js     8012c5 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	68 00 f0 7f 00       	push   $0x7ff000
  801279:	53                   	push   %ebx
  80127a:	e8 9f fd ff ff       	call   80101e <sys_page_unmap>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 51                	js     8012d7 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  801286:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80128d:	83 ec 04             	sub    $0x4,%esp
  801290:	68 2c 33 80 00       	push   $0x80332c
  801295:	6a 1d                	push   $0x1d
  801297:	68 a8 33 80 00       	push   $0x8033a8
  80129c:	e8 47 f2 ff ff       	call   8004e8 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8012a1:	50                   	push   %eax
  8012a2:	68 64 33 80 00       	push   $0x803364
  8012a7:	6a 29                	push   $0x29
  8012a9:	68 a8 33 80 00       	push   $0x8033a8
  8012ae:	e8 35 f2 ff ff       	call   8004e8 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8012b3:	50                   	push   %eax
  8012b4:	68 88 33 80 00       	push   $0x803388
  8012b9:	6a 2e                	push   $0x2e
  8012bb:	68 a8 33 80 00       	push   $0x8033a8
  8012c0:	e8 23 f2 ff ff       	call   8004e8 <_panic>
		panic("pgfault: page map failed (%e)", r);
  8012c5:	50                   	push   %eax
  8012c6:	68 b3 33 80 00       	push   $0x8033b3
  8012cb:	6a 30                	push   $0x30
  8012cd:	68 a8 33 80 00       	push   $0x8033a8
  8012d2:	e8 11 f2 ff ff       	call   8004e8 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8012d7:	50                   	push   %eax
  8012d8:	68 88 33 80 00       	push   $0x803388
  8012dd:	6a 32                	push   $0x32
  8012df:	68 a8 33 80 00       	push   $0x8033a8
  8012e4:	e8 ff f1 ff ff       	call   8004e8 <_panic>

008012e9 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	57                   	push   %edi
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
  8012ef:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  8012f2:	68 eb 11 80 00       	push   $0x8011eb
  8012f7:	e8 71 17 00 00       	call   802a6d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012fc:	b8 07 00 00 00       	mov    $0x7,%eax
  801301:	cd 30                	int    $0x30
  801303:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	85 c0                	test   %eax,%eax
  80130b:	78 30                	js     80133d <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80130d:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801312:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801316:	75 76                	jne    80138e <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  801318:	e8 3e fc ff ff       	call   800f5b <sys_getenvid>
  80131d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801322:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801328:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80132d:	a3 00 50 80 00       	mov    %eax,0x805000
		return 0;
  801332:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801335:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801338:	5b                   	pop    %ebx
  801339:	5e                   	pop    %esi
  80133a:	5f                   	pop    %edi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80133d:	50                   	push   %eax
  80133e:	68 d1 33 80 00       	push   $0x8033d1
  801343:	6a 78                	push   $0x78
  801345:	68 a8 33 80 00       	push   $0x8033a8
  80134a:	e8 99 f1 ff ff       	call   8004e8 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80134f:	83 ec 0c             	sub    $0xc,%esp
  801352:	ff 75 e4             	push   -0x1c(%ebp)
  801355:	57                   	push   %edi
  801356:	ff 75 dc             	push   -0x24(%ebp)
  801359:	57                   	push   %edi
  80135a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80135d:	56                   	push   %esi
  80135e:	e8 79 fc ff ff       	call   800fdc <sys_page_map>
	if(r<0) return r;
  801363:	83 c4 20             	add    $0x20,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 cb                	js     801335 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	ff 75 e4             	push   -0x1c(%ebp)
  801370:	57                   	push   %edi
  801371:	56                   	push   %esi
  801372:	57                   	push   %edi
  801373:	56                   	push   %esi
  801374:	e8 63 fc ff ff       	call   800fdc <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801379:	83 c4 20             	add    $0x20,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 76                	js     8013f6 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801380:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801386:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80138c:	74 75                	je     801403 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  80138e:	89 d8                	mov    %ebx,%eax
  801390:	c1 e8 16             	shr    $0x16,%eax
  801393:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80139a:	a8 01                	test   $0x1,%al
  80139c:	74 e2                	je     801380 <fork+0x97>
  80139e:	89 de                	mov    %ebx,%esi
  8013a0:	c1 ee 0c             	shr    $0xc,%esi
  8013a3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8013aa:	a8 01                	test   $0x1,%al
  8013ac:	74 d2                	je     801380 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  8013ae:	e8 a8 fb ff ff       	call   800f5b <sys_getenvid>
  8013b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8013b6:	89 f7                	mov    %esi,%edi
  8013b8:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8013bb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8013c2:	89 c1                	mov    %eax,%ecx
  8013c4:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8013ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8013cd:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8013d4:	f6 c6 04             	test   $0x4,%dh
  8013d7:	0f 85 72 ff ff ff    	jne    80134f <fork+0x66>
		perm &= ~PTE_W;
  8013dd:	25 05 0e 00 00       	and    $0xe05,%eax
  8013e2:	80 cc 08             	or     $0x8,%ah
  8013e5:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8013eb:	0f 44 c1             	cmove  %ecx,%eax
  8013ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013f1:	e9 59 ff ff ff       	jmp    80134f <fork+0x66>
  8013f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fb:	0f 4f c2             	cmovg  %edx,%eax
  8013fe:	e9 32 ff ff ff       	jmp    801335 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801403:	83 ec 04             	sub    $0x4,%esp
  801406:	6a 07                	push   $0x7
  801408:	68 00 f0 bf ee       	push   $0xeebff000
  80140d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801410:	57                   	push   %edi
  801411:	e8 83 fb ff ff       	call   800f99 <sys_page_alloc>
	if(r<0) return r;
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	85 c0                	test   %eax,%eax
  80141b:	0f 88 14 ff ff ff    	js     801335 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	68 e3 2a 80 00       	push   $0x802ae3
  801429:	57                   	push   %edi
  80142a:	e8 b5 fc ff ff       	call   8010e4 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	0f 88 fb fe ff ff    	js     801335 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	6a 02                	push   $0x2
  80143f:	57                   	push   %edi
  801440:	e8 1b fc ff ff       	call   801060 <sys_env_set_status>
	if(r<0) return r;
  801445:	83 c4 10             	add    $0x10,%esp
	return envid;
  801448:	85 c0                	test   %eax,%eax
  80144a:	0f 49 c7             	cmovns %edi,%eax
  80144d:	e9 e3 fe ff ff       	jmp    801335 <fork+0x4c>

00801452 <sfork>:

// Challenge!
int
sfork(void)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801458:	68 e1 33 80 00       	push   $0x8033e1
  80145d:	68 a1 00 00 00       	push   $0xa1
  801462:	68 a8 33 80 00       	push   $0x8033a8
  801467:	e8 7c f0 ff ff       	call   8004e8 <_panic>

0080146c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80146f:	8b 45 08             	mov    0x8(%ebp),%eax
  801472:	05 00 00 00 30       	add    $0x30000000,%eax
  801477:	c1 e8 0c             	shr    $0xc,%eax
}
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80147f:	8b 45 08             	mov    0x8(%ebp),%eax
  801482:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801487:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80148c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801491:	5d                   	pop    %ebp
  801492:	c3                   	ret    

00801493 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80149b:	89 c2                	mov    %eax,%edx
  80149d:	c1 ea 16             	shr    $0x16,%edx
  8014a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014a7:	f6 c2 01             	test   $0x1,%dl
  8014aa:	74 29                	je     8014d5 <fd_alloc+0x42>
  8014ac:	89 c2                	mov    %eax,%edx
  8014ae:	c1 ea 0c             	shr    $0xc,%edx
  8014b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b8:	f6 c2 01             	test   $0x1,%dl
  8014bb:	74 18                	je     8014d5 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8014bd:	05 00 10 00 00       	add    $0x1000,%eax
  8014c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014c7:	75 d2                	jne    80149b <fd_alloc+0x8>
  8014c9:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8014ce:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8014d3:	eb 05                	jmp    8014da <fd_alloc+0x47>
			return 0;
  8014d5:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8014da:	8b 55 08             	mov    0x8(%ebp),%edx
  8014dd:	89 02                	mov    %eax,(%edx)
}
  8014df:	89 c8                	mov    %ecx,%eax
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014e9:	83 f8 1f             	cmp    $0x1f,%eax
  8014ec:	77 30                	ja     80151e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014ee:	c1 e0 0c             	shl    $0xc,%eax
  8014f1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014f6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014fc:	f6 c2 01             	test   $0x1,%dl
  8014ff:	74 24                	je     801525 <fd_lookup+0x42>
  801501:	89 c2                	mov    %eax,%edx
  801503:	c1 ea 0c             	shr    $0xc,%edx
  801506:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150d:	f6 c2 01             	test   $0x1,%dl
  801510:	74 1a                	je     80152c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801512:	8b 55 0c             	mov    0xc(%ebp),%edx
  801515:	89 02                	mov    %eax,(%edx)
	return 0;
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    
		return -E_INVAL;
  80151e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801523:	eb f7                	jmp    80151c <fd_lookup+0x39>
		return -E_INVAL;
  801525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80152a:	eb f0                	jmp    80151c <fd_lookup+0x39>
  80152c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801531:	eb e9                	jmp    80151c <fd_lookup+0x39>

00801533 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 04             	sub    $0x4,%esp
  80153a:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
  801542:	bb 20 40 80 00       	mov    $0x804020,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801547:	39 13                	cmp    %edx,(%ebx)
  801549:	74 37                	je     801582 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80154b:	83 c0 01             	add    $0x1,%eax
  80154e:	8b 1c 85 74 34 80 00 	mov    0x803474(,%eax,4),%ebx
  801555:	85 db                	test   %ebx,%ebx
  801557:	75 ee                	jne    801547 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801559:	a1 00 50 80 00       	mov    0x805000,%eax
  80155e:	8b 40 58             	mov    0x58(%eax),%eax
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	52                   	push   %edx
  801565:	50                   	push   %eax
  801566:	68 f8 33 80 00       	push   $0x8033f8
  80156b:	e8 53 f0 ff ff       	call   8005c3 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801578:	8b 55 0c             	mov    0xc(%ebp),%edx
  80157b:	89 1a                	mov    %ebx,(%edx)
}
  80157d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801580:	c9                   	leave  
  801581:	c3                   	ret    
			return 0;
  801582:	b8 00 00 00 00       	mov    $0x0,%eax
  801587:	eb ef                	jmp    801578 <dev_lookup+0x45>

00801589 <fd_close>:
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	57                   	push   %edi
  80158d:	56                   	push   %esi
  80158e:	53                   	push   %ebx
  80158f:	83 ec 24             	sub    $0x24,%esp
  801592:	8b 75 08             	mov    0x8(%ebp),%esi
  801595:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801598:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80159b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80159c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015a2:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015a5:	50                   	push   %eax
  8015a6:	e8 38 ff ff ff       	call   8014e3 <fd_lookup>
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 05                	js     8015b9 <fd_close+0x30>
	    || fd != fd2)
  8015b4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8015b7:	74 16                	je     8015cf <fd_close+0x46>
		return (must_exist ? r : 0);
  8015b9:	89 f8                	mov    %edi,%eax
  8015bb:	84 c0                	test   %al,%al
  8015bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8015c2:	0f 44 d8             	cmove  %eax,%ebx
}
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015d5:	50                   	push   %eax
  8015d6:	ff 36                	push   (%esi)
  8015d8:	e8 56 ff ff ff       	call   801533 <dev_lookup>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 1a                	js     801600 <fd_close+0x77>
		if (dev->dev_close)
  8015e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015e9:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	74 0b                	je     801600 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	56                   	push   %esi
  8015f9:	ff d0                	call   *%eax
  8015fb:	89 c3                	mov    %eax,%ebx
  8015fd:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	56                   	push   %esi
  801604:	6a 00                	push   $0x0
  801606:	e8 13 fa ff ff       	call   80101e <sys_page_unmap>
	return r;
  80160b:	83 c4 10             	add    $0x10,%esp
  80160e:	eb b5                	jmp    8015c5 <fd_close+0x3c>

00801610 <close>:

int
close(int fdnum)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801616:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801619:	50                   	push   %eax
  80161a:	ff 75 08             	push   0x8(%ebp)
  80161d:	e8 c1 fe ff ff       	call   8014e3 <fd_lookup>
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	85 c0                	test   %eax,%eax
  801627:	79 02                	jns    80162b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801629:	c9                   	leave  
  80162a:	c3                   	ret    
		return fd_close(fd, 1);
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	6a 01                	push   $0x1
  801630:	ff 75 f4             	push   -0xc(%ebp)
  801633:	e8 51 ff ff ff       	call   801589 <fd_close>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	eb ec                	jmp    801629 <close+0x19>

0080163d <close_all>:

void
close_all(void)
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801644:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801649:	83 ec 0c             	sub    $0xc,%esp
  80164c:	53                   	push   %ebx
  80164d:	e8 be ff ff ff       	call   801610 <close>
	for (i = 0; i < MAXFD; i++)
  801652:	83 c3 01             	add    $0x1,%ebx
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	83 fb 20             	cmp    $0x20,%ebx
  80165b:	75 ec                	jne    801649 <close_all+0xc>
}
  80165d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	57                   	push   %edi
  801666:	56                   	push   %esi
  801667:	53                   	push   %ebx
  801668:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80166b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	ff 75 08             	push   0x8(%ebp)
  801672:	e8 6c fe ff ff       	call   8014e3 <fd_lookup>
  801677:	89 c3                	mov    %eax,%ebx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	78 7f                	js     8016ff <dup+0x9d>
		return r;
	close(newfdnum);
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	ff 75 0c             	push   0xc(%ebp)
  801686:	e8 85 ff ff ff       	call   801610 <close>

	newfd = INDEX2FD(newfdnum);
  80168b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80168e:	c1 e6 0c             	shl    $0xc,%esi
  801691:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80169a:	89 3c 24             	mov    %edi,(%esp)
  80169d:	e8 da fd ff ff       	call   80147c <fd2data>
  8016a2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016a4:	89 34 24             	mov    %esi,(%esp)
  8016a7:	e8 d0 fd ff ff       	call   80147c <fd2data>
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016b2:	89 d8                	mov    %ebx,%eax
  8016b4:	c1 e8 16             	shr    $0x16,%eax
  8016b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016be:	a8 01                	test   $0x1,%al
  8016c0:	74 11                	je     8016d3 <dup+0x71>
  8016c2:	89 d8                	mov    %ebx,%eax
  8016c4:	c1 e8 0c             	shr    $0xc,%eax
  8016c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ce:	f6 c2 01             	test   $0x1,%dl
  8016d1:	75 36                	jne    801709 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d3:	89 f8                	mov    %edi,%eax
  8016d5:	c1 e8 0c             	shr    $0xc,%eax
  8016d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016df:	83 ec 0c             	sub    $0xc,%esp
  8016e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016e7:	50                   	push   %eax
  8016e8:	56                   	push   %esi
  8016e9:	6a 00                	push   $0x0
  8016eb:	57                   	push   %edi
  8016ec:	6a 00                	push   $0x0
  8016ee:	e8 e9 f8 ff ff       	call   800fdc <sys_page_map>
  8016f3:	89 c3                	mov    %eax,%ebx
  8016f5:	83 c4 20             	add    $0x20,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 33                	js     80172f <dup+0xcd>
		goto err;

	return newfdnum;
  8016fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016ff:	89 d8                	mov    %ebx,%eax
  801701:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801704:	5b                   	pop    %ebx
  801705:	5e                   	pop    %esi
  801706:	5f                   	pop    %edi
  801707:	5d                   	pop    %ebp
  801708:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801709:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801710:	83 ec 0c             	sub    $0xc,%esp
  801713:	25 07 0e 00 00       	and    $0xe07,%eax
  801718:	50                   	push   %eax
  801719:	ff 75 d4             	push   -0x2c(%ebp)
  80171c:	6a 00                	push   $0x0
  80171e:	53                   	push   %ebx
  80171f:	6a 00                	push   $0x0
  801721:	e8 b6 f8 ff ff       	call   800fdc <sys_page_map>
  801726:	89 c3                	mov    %eax,%ebx
  801728:	83 c4 20             	add    $0x20,%esp
  80172b:	85 c0                	test   %eax,%eax
  80172d:	79 a4                	jns    8016d3 <dup+0x71>
	sys_page_unmap(0, newfd);
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	56                   	push   %esi
  801733:	6a 00                	push   $0x0
  801735:	e8 e4 f8 ff ff       	call   80101e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80173a:	83 c4 08             	add    $0x8,%esp
  80173d:	ff 75 d4             	push   -0x2c(%ebp)
  801740:	6a 00                	push   $0x0
  801742:	e8 d7 f8 ff ff       	call   80101e <sys_page_unmap>
	return r;
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	eb b3                	jmp    8016ff <dup+0x9d>

0080174c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	56                   	push   %esi
  801750:	53                   	push   %ebx
  801751:	83 ec 18             	sub    $0x18,%esp
  801754:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801757:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	56                   	push   %esi
  80175c:	e8 82 fd ff ff       	call   8014e3 <fd_lookup>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 3c                	js     8017a4 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801768:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80176b:	83 ec 08             	sub    $0x8,%esp
  80176e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801771:	50                   	push   %eax
  801772:	ff 33                	push   (%ebx)
  801774:	e8 ba fd ff ff       	call   801533 <dev_lookup>
  801779:	83 c4 10             	add    $0x10,%esp
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 24                	js     8017a4 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801780:	8b 43 08             	mov    0x8(%ebx),%eax
  801783:	83 e0 03             	and    $0x3,%eax
  801786:	83 f8 01             	cmp    $0x1,%eax
  801789:	74 20                	je     8017ab <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80178b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178e:	8b 40 08             	mov    0x8(%eax),%eax
  801791:	85 c0                	test   %eax,%eax
  801793:	74 37                	je     8017cc <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801795:	83 ec 04             	sub    $0x4,%esp
  801798:	ff 75 10             	push   0x10(%ebp)
  80179b:	ff 75 0c             	push   0xc(%ebp)
  80179e:	53                   	push   %ebx
  80179f:	ff d0                	call   *%eax
  8017a1:	83 c4 10             	add    $0x10,%esp
}
  8017a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a7:	5b                   	pop    %ebx
  8017a8:	5e                   	pop    %esi
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ab:	a1 00 50 80 00       	mov    0x805000,%eax
  8017b0:	8b 40 58             	mov    0x58(%eax),%eax
  8017b3:	83 ec 04             	sub    $0x4,%esp
  8017b6:	56                   	push   %esi
  8017b7:	50                   	push   %eax
  8017b8:	68 39 34 80 00       	push   $0x803439
  8017bd:	e8 01 ee ff ff       	call   8005c3 <cprintf>
		return -E_INVAL;
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ca:	eb d8                	jmp    8017a4 <read+0x58>
		return -E_NOT_SUPP;
  8017cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d1:	eb d1                	jmp    8017a4 <read+0x58>

008017d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	57                   	push   %edi
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 0c             	sub    $0xc,%esp
  8017dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e7:	eb 02                	jmp    8017eb <readn+0x18>
  8017e9:	01 c3                	add    %eax,%ebx
  8017eb:	39 f3                	cmp    %esi,%ebx
  8017ed:	73 21                	jae    801810 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017ef:	83 ec 04             	sub    $0x4,%esp
  8017f2:	89 f0                	mov    %esi,%eax
  8017f4:	29 d8                	sub    %ebx,%eax
  8017f6:	50                   	push   %eax
  8017f7:	89 d8                	mov    %ebx,%eax
  8017f9:	03 45 0c             	add    0xc(%ebp),%eax
  8017fc:	50                   	push   %eax
  8017fd:	57                   	push   %edi
  8017fe:	e8 49 ff ff ff       	call   80174c <read>
		if (m < 0)
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	85 c0                	test   %eax,%eax
  801808:	78 04                	js     80180e <readn+0x3b>
			return m;
		if (m == 0)
  80180a:	75 dd                	jne    8017e9 <readn+0x16>
  80180c:	eb 02                	jmp    801810 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80180e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801810:	89 d8                	mov    %ebx,%eax
  801812:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801815:	5b                   	pop    %ebx
  801816:	5e                   	pop    %esi
  801817:	5f                   	pop    %edi
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	56                   	push   %esi
  80181e:	53                   	push   %ebx
  80181f:	83 ec 18             	sub    $0x18,%esp
  801822:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801828:	50                   	push   %eax
  801829:	53                   	push   %ebx
  80182a:	e8 b4 fc ff ff       	call   8014e3 <fd_lookup>
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	85 c0                	test   %eax,%eax
  801834:	78 37                	js     80186d <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801836:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	ff 36                	push   (%esi)
  801842:	e8 ec fc ff ff       	call   801533 <dev_lookup>
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 1f                	js     80186d <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80184e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801852:	74 20                	je     801874 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801857:	8b 40 0c             	mov    0xc(%eax),%eax
  80185a:	85 c0                	test   %eax,%eax
  80185c:	74 37                	je     801895 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	ff 75 10             	push   0x10(%ebp)
  801864:	ff 75 0c             	push   0xc(%ebp)
  801867:	56                   	push   %esi
  801868:	ff d0                	call   *%eax
  80186a:	83 c4 10             	add    $0x10,%esp
}
  80186d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801870:	5b                   	pop    %ebx
  801871:	5e                   	pop    %esi
  801872:	5d                   	pop    %ebp
  801873:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801874:	a1 00 50 80 00       	mov    0x805000,%eax
  801879:	8b 40 58             	mov    0x58(%eax),%eax
  80187c:	83 ec 04             	sub    $0x4,%esp
  80187f:	53                   	push   %ebx
  801880:	50                   	push   %eax
  801881:	68 55 34 80 00       	push   $0x803455
  801886:	e8 38 ed ff ff       	call   8005c3 <cprintf>
		return -E_INVAL;
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801893:	eb d8                	jmp    80186d <write+0x53>
		return -E_NOT_SUPP;
  801895:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80189a:	eb d1                	jmp    80186d <write+0x53>

0080189c <seek>:

int
seek(int fdnum, off_t offset)
{
  80189c:	55                   	push   %ebp
  80189d:	89 e5                	mov    %esp,%ebp
  80189f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a5:	50                   	push   %eax
  8018a6:	ff 75 08             	push   0x8(%ebp)
  8018a9:	e8 35 fc ff ff       	call   8014e3 <fd_lookup>
  8018ae:	83 c4 10             	add    $0x10,%esp
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 0e                	js     8018c3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	83 ec 18             	sub    $0x18,%esp
  8018cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	53                   	push   %ebx
  8018d5:	e8 09 fc ff ff       	call   8014e3 <fd_lookup>
  8018da:	83 c4 10             	add    $0x10,%esp
  8018dd:	85 c0                	test   %eax,%eax
  8018df:	78 34                	js     801915 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ea:	50                   	push   %eax
  8018eb:	ff 36                	push   (%esi)
  8018ed:	e8 41 fc ff ff       	call   801533 <dev_lookup>
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	85 c0                	test   %eax,%eax
  8018f7:	78 1c                	js     801915 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018f9:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8018fd:	74 1d                	je     80191c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801902:	8b 40 18             	mov    0x18(%eax),%eax
  801905:	85 c0                	test   %eax,%eax
  801907:	74 34                	je     80193d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	ff 75 0c             	push   0xc(%ebp)
  80190f:	56                   	push   %esi
  801910:	ff d0                	call   *%eax
  801912:	83 c4 10             	add    $0x10,%esp
}
  801915:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80191c:	a1 00 50 80 00       	mov    0x805000,%eax
  801921:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801924:	83 ec 04             	sub    $0x4,%esp
  801927:	53                   	push   %ebx
  801928:	50                   	push   %eax
  801929:	68 18 34 80 00       	push   $0x803418
  80192e:	e8 90 ec ff ff       	call   8005c3 <cprintf>
		return -E_INVAL;
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80193b:	eb d8                	jmp    801915 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80193d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801942:	eb d1                	jmp    801915 <ftruncate+0x50>

00801944 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	56                   	push   %esi
  801948:	53                   	push   %ebx
  801949:	83 ec 18             	sub    $0x18,%esp
  80194c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80194f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801952:	50                   	push   %eax
  801953:	ff 75 08             	push   0x8(%ebp)
  801956:	e8 88 fb ff ff       	call   8014e3 <fd_lookup>
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 49                	js     8019ab <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801962:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801965:	83 ec 08             	sub    $0x8,%esp
  801968:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196b:	50                   	push   %eax
  80196c:	ff 36                	push   (%esi)
  80196e:	e8 c0 fb ff ff       	call   801533 <dev_lookup>
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	85 c0                	test   %eax,%eax
  801978:	78 31                	js     8019ab <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80197a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801981:	74 2f                	je     8019b2 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801983:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801986:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80198d:	00 00 00 
	stat->st_isdir = 0;
  801990:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801997:	00 00 00 
	stat->st_dev = dev;
  80199a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019a0:	83 ec 08             	sub    $0x8,%esp
  8019a3:	53                   	push   %ebx
  8019a4:	56                   	push   %esi
  8019a5:	ff 50 14             	call   *0x14(%eax)
  8019a8:	83 c4 10             	add    $0x10,%esp
}
  8019ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ae:	5b                   	pop    %ebx
  8019af:	5e                   	pop    %esi
  8019b0:	5d                   	pop    %ebp
  8019b1:	c3                   	ret    
		return -E_NOT_SUPP;
  8019b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b7:	eb f2                	jmp    8019ab <fstat+0x67>

008019b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	56                   	push   %esi
  8019bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019be:	83 ec 08             	sub    $0x8,%esp
  8019c1:	6a 00                	push   $0x0
  8019c3:	ff 75 08             	push   0x8(%ebp)
  8019c6:	e8 e4 01 00 00       	call   801baf <open>
  8019cb:	89 c3                	mov    %eax,%ebx
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 1b                	js     8019ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8019d4:	83 ec 08             	sub    $0x8,%esp
  8019d7:	ff 75 0c             	push   0xc(%ebp)
  8019da:	50                   	push   %eax
  8019db:	e8 64 ff ff ff       	call   801944 <fstat>
  8019e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8019e2:	89 1c 24             	mov    %ebx,(%esp)
  8019e5:	e8 26 fc ff ff       	call   801610 <close>
	return r;
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	89 f3                	mov    %esi,%ebx
}
  8019ef:	89 d8                	mov    %ebx,%eax
  8019f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5d                   	pop    %ebp
  8019f7:	c3                   	ret    

008019f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	56                   	push   %esi
  8019fc:	53                   	push   %ebx
  8019fd:	89 c6                	mov    %eax,%esi
  8019ff:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a01:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801a08:	74 27                	je     801a31 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a0a:	6a 07                	push   $0x7
  801a0c:	68 00 60 80 00       	push   $0x806000
  801a11:	56                   	push   %esi
  801a12:	ff 35 00 70 80 00    	push   0x807000
  801a18:	e8 5c 11 00 00       	call   802b79 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a1d:	83 c4 0c             	add    $0xc,%esp
  801a20:	6a 00                	push   $0x0
  801a22:	53                   	push   %ebx
  801a23:	6a 00                	push   $0x0
  801a25:	e8 df 10 00 00       	call   802b09 <ipc_recv>
}
  801a2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	6a 01                	push   $0x1
  801a36:	e8 92 11 00 00       	call   802bcd <ipc_find_env>
  801a3b:	a3 00 70 80 00       	mov    %eax,0x807000
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	eb c5                	jmp    801a0a <fsipc+0x12>

00801a45 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a51:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a59:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a63:	b8 02 00 00 00       	mov    $0x2,%eax
  801a68:	e8 8b ff ff ff       	call   8019f8 <fsipc>
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <devfile_flush>:
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a75:	8b 45 08             	mov    0x8(%ebp),%eax
  801a78:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a80:	ba 00 00 00 00       	mov    $0x0,%edx
  801a85:	b8 06 00 00 00       	mov    $0x6,%eax
  801a8a:	e8 69 ff ff ff       	call   8019f8 <fsipc>
}
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <devfile_stat>:
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	53                   	push   %ebx
  801a95:	83 ec 04             	sub    $0x4,%esp
  801a98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa1:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aa6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aab:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab0:	e8 43 ff ff ff       	call   8019f8 <fsipc>
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 2c                	js     801ae5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ab9:	83 ec 08             	sub    $0x8,%esp
  801abc:	68 00 60 80 00       	push   $0x806000
  801ac1:	53                   	push   %ebx
  801ac2:	e8 d6 f0 ff ff       	call   800b9d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ac7:	a1 80 60 80 00       	mov    0x806080,%eax
  801acc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ad2:	a1 84 60 80 00       	mov    0x806084,%eax
  801ad7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae8:	c9                   	leave  
  801ae9:	c3                   	ret    

00801aea <devfile_write>:
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	83 ec 0c             	sub    $0xc,%esp
  801af0:	8b 45 10             	mov    0x10(%ebp),%eax
  801af3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af8:	39 d0                	cmp    %edx,%eax
  801afa:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801afd:	8b 55 08             	mov    0x8(%ebp),%edx
  801b00:	8b 52 0c             	mov    0xc(%edx),%edx
  801b03:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b09:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b0e:	50                   	push   %eax
  801b0f:	ff 75 0c             	push   0xc(%ebp)
  801b12:	68 08 60 80 00       	push   $0x806008
  801b17:	e8 17 f2 ff ff       	call   800d33 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801b1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b21:	b8 04 00 00 00       	mov    $0x4,%eax
  801b26:	e8 cd fe ff ff       	call   8019f8 <fsipc>
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <devfile_read>:
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	8b 40 0c             	mov    0xc(%eax),%eax
  801b3b:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b40:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b46:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4b:	b8 03 00 00 00       	mov    $0x3,%eax
  801b50:	e8 a3 fe ff ff       	call   8019f8 <fsipc>
  801b55:	89 c3                	mov    %eax,%ebx
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 1f                	js     801b7a <devfile_read+0x4d>
	assert(r <= n);
  801b5b:	39 f0                	cmp    %esi,%eax
  801b5d:	77 24                	ja     801b83 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801b5f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b64:	7f 33                	jg     801b99 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b66:	83 ec 04             	sub    $0x4,%esp
  801b69:	50                   	push   %eax
  801b6a:	68 00 60 80 00       	push   $0x806000
  801b6f:	ff 75 0c             	push   0xc(%ebp)
  801b72:	e8 bc f1 ff ff       	call   800d33 <memmove>
	return r;
  801b77:	83 c4 10             	add    $0x10,%esp
}
  801b7a:	89 d8                	mov    %ebx,%eax
  801b7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    
	assert(r <= n);
  801b83:	68 88 34 80 00       	push   $0x803488
  801b88:	68 8f 34 80 00       	push   $0x80348f
  801b8d:	6a 7c                	push   $0x7c
  801b8f:	68 a4 34 80 00       	push   $0x8034a4
  801b94:	e8 4f e9 ff ff       	call   8004e8 <_panic>
	assert(r <= PGSIZE);
  801b99:	68 af 34 80 00       	push   $0x8034af
  801b9e:	68 8f 34 80 00       	push   $0x80348f
  801ba3:	6a 7d                	push   $0x7d
  801ba5:	68 a4 34 80 00       	push   $0x8034a4
  801baa:	e8 39 e9 ff ff       	call   8004e8 <_panic>

00801baf <open>:
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bba:	56                   	push   %esi
  801bbb:	e8 a2 ef ff ff       	call   800b62 <strlen>
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bc8:	7f 6c                	jg     801c36 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801bca:	83 ec 0c             	sub    $0xc,%esp
  801bcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd0:	50                   	push   %eax
  801bd1:	e8 bd f8 ff ff       	call   801493 <fd_alloc>
  801bd6:	89 c3                	mov    %eax,%ebx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 3c                	js     801c1b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801bdf:	83 ec 08             	sub    $0x8,%esp
  801be2:	56                   	push   %esi
  801be3:	68 00 60 80 00       	push   $0x806000
  801be8:	e8 b0 ef ff ff       	call   800b9d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf0:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bf8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bfd:	e8 f6 fd ff ff       	call   8019f8 <fsipc>
  801c02:	89 c3                	mov    %eax,%ebx
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 19                	js     801c24 <open+0x75>
	return fd2num(fd);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	ff 75 f4             	push   -0xc(%ebp)
  801c11:	e8 56 f8 ff ff       	call   80146c <fd2num>
  801c16:	89 c3                	mov    %eax,%ebx
  801c18:	83 c4 10             	add    $0x10,%esp
}
  801c1b:	89 d8                	mov    %ebx,%eax
  801c1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    
		fd_close(fd, 0);
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	6a 00                	push   $0x0
  801c29:	ff 75 f4             	push   -0xc(%ebp)
  801c2c:	e8 58 f9 ff ff       	call   801589 <fd_close>
		return r;
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	eb e5                	jmp    801c1b <open+0x6c>
		return -E_BAD_PATH;
  801c36:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c3b:	eb de                	jmp    801c1b <open+0x6c>

00801c3d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c43:	ba 00 00 00 00       	mov    $0x0,%edx
  801c48:	b8 08 00 00 00       	mov    $0x8,%eax
  801c4d:	e8 a6 fd ff ff       	call   8019f8 <fsipc>
}
  801c52:	c9                   	leave  
  801c53:	c3                   	ret    

00801c54 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	57                   	push   %edi
  801c58:	56                   	push   %esi
  801c59:	53                   	push   %ebx
  801c5a:	81 ec 84 02 00 00    	sub    $0x284,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801c60:	6a 00                	push   $0x0
  801c62:	ff 75 08             	push   0x8(%ebp)
  801c65:	e8 45 ff ff ff       	call   801baf <open>
  801c6a:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	0f 88 ad 04 00 00    	js     802128 <spawn+0x4d4>
  801c7b:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801c7d:	83 ec 04             	sub    $0x4,%esp
  801c80:	68 00 02 00 00       	push   $0x200
  801c85:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801c8b:	50                   	push   %eax
  801c8c:	57                   	push   %edi
  801c8d:	e8 41 fb ff ff       	call   8017d3 <readn>
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	3d 00 02 00 00       	cmp    $0x200,%eax
  801c9a:	75 5a                	jne    801cf6 <spawn+0xa2>
	    || elf->e_magic != ELF_MAGIC) {
  801c9c:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801ca3:	45 4c 46 
  801ca6:	75 4e                	jne    801cf6 <spawn+0xa2>
  801ca8:	b8 07 00 00 00       	mov    $0x7,%eax
  801cad:	cd 30                	int    $0x30
  801caf:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801cb5:	85 c0                	test   %eax,%eax
  801cb7:	0f 88 5f 04 00 00    	js     80211c <spawn+0x4c8>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801cbd:	25 ff 03 00 00       	and    $0x3ff,%eax
  801cc2:	69 f0 8c 00 00 00    	imul   $0x8c,%eax,%esi
  801cc8:	81 c6 10 00 c0 ee    	add    $0xeec00010,%esi
  801cce:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801cd4:	b9 11 00 00 00       	mov    $0x11,%ecx
  801cd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801cdb:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801ce1:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801ce7:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801cec:	be 00 00 00 00       	mov    $0x0,%esi
  801cf1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	for (argc = 0; argv[argc] != 0; argc++)
  801cf4:	eb 4b                	jmp    801d41 <spawn+0xed>
		close(fd);
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801cff:	e8 0c f9 ff ff       	call   801610 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d04:	83 c4 0c             	add    $0xc,%esp
  801d07:	68 7f 45 4c 46       	push   $0x464c457f
  801d0c:	ff b5 e8 fd ff ff    	push   -0x218(%ebp)
  801d12:	68 bb 34 80 00       	push   $0x8034bb
  801d17:	e8 a7 e8 ff ff       	call   8005c3 <cprintf>
		return -E_NOT_EXEC;
  801d1c:	83 c4 10             	add    $0x10,%esp
  801d1f:	c7 85 8c fd ff ff f2 	movl   $0xfffffff2,-0x274(%ebp)
  801d26:	ff ff ff 
  801d29:	e9 fa 03 00 00       	jmp    802128 <spawn+0x4d4>
		string_size += strlen(argv[argc]) + 1;
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	50                   	push   %eax
  801d32:	e8 2b ee ff ff       	call   800b62 <strlen>
  801d37:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801d3b:	83 c3 01             	add    $0x1,%ebx
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801d48:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801d4b:	85 c0                	test   %eax,%eax
  801d4d:	75 df                	jne    801d2e <spawn+0xda>
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801d4f:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801d55:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801d5b:	b8 00 10 40 00       	mov    $0x401000,%eax
  801d60:	29 f0                	sub    %esi,%eax
  801d62:	89 c7                	mov    %eax,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801d64:	89 c2                	mov    %eax,%edx
  801d66:	83 e2 fc             	and    $0xfffffffc,%edx
  801d69:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801d70:	29 c2                	sub    %eax,%edx
  801d72:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801d78:	8d 42 f8             	lea    -0x8(%edx),%eax
  801d7b:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801d80:	0f 86 14 04 00 00    	jbe    80219a <spawn+0x546>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801d86:	83 ec 04             	sub    $0x4,%esp
  801d89:	6a 07                	push   $0x7
  801d8b:	68 00 00 40 00       	push   $0x400000
  801d90:	6a 00                	push   $0x0
  801d92:	e8 02 f2 ff ff       	call   800f99 <sys_page_alloc>
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	85 c0                	test   %eax,%eax
  801d9c:	0f 88 fd 03 00 00    	js     80219f <spawn+0x54b>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801da2:	be 00 00 00 00       	mov    $0x0,%esi
  801da7:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801dad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801db0:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801db6:	7e 32                	jle    801dea <spawn+0x196>
		argv_store[i] = UTEMP2USTACK(string_store);
  801db8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801dbe:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801dc4:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801dc7:	83 ec 08             	sub    $0x8,%esp
  801dca:	ff 34 b3             	push   (%ebx,%esi,4)
  801dcd:	57                   	push   %edi
  801dce:	e8 ca ed ff ff       	call   800b9d <strcpy>
		string_store += strlen(argv[i]) + 1;
  801dd3:	83 c4 04             	add    $0x4,%esp
  801dd6:	ff 34 b3             	push   (%ebx,%esi,4)
  801dd9:	e8 84 ed ff ff       	call   800b62 <strlen>
  801dde:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801de2:	83 c6 01             	add    $0x1,%esi
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	eb c6                	jmp    801db0 <spawn+0x15c>
	}
	argv_store[argc] = 0;
  801dea:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801df0:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801df6:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801dfd:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e03:	0f 85 8c 00 00 00    	jne    801e95 <spawn+0x241>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e09:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801e0f:	8d 81 00 d0 7f ee    	lea    -0x11803000(%ecx),%eax
  801e15:	89 41 fc             	mov    %eax,-0x4(%ecx)
	argv_store[-2] = argc;
  801e18:	89 c8                	mov    %ecx,%eax
  801e1a:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
  801e20:	89 79 f8             	mov    %edi,-0x8(%ecx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e23:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801e28:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e2e:	83 ec 0c             	sub    $0xc,%esp
  801e31:	6a 07                	push   $0x7
  801e33:	68 00 d0 bf ee       	push   $0xeebfd000
  801e38:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801e3e:	68 00 00 40 00       	push   $0x400000
  801e43:	6a 00                	push   $0x0
  801e45:	e8 92 f1 ff ff       	call   800fdc <sys_page_map>
  801e4a:	89 c3                	mov    %eax,%ebx
  801e4c:	83 c4 20             	add    $0x20,%esp
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	0f 88 50 03 00 00    	js     8021a7 <spawn+0x553>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801e57:	83 ec 08             	sub    $0x8,%esp
  801e5a:	68 00 00 40 00       	push   $0x400000
  801e5f:	6a 00                	push   $0x0
  801e61:	e8 b8 f1 ff ff       	call   80101e <sys_page_unmap>
  801e66:	89 c3                	mov    %eax,%ebx
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	0f 88 34 03 00 00    	js     8021a7 <spawn+0x553>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801e73:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801e79:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801e80:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801e86:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801e8d:	00 00 00 
  801e90:	e9 4e 01 00 00       	jmp    801fe3 <spawn+0x38f>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e95:	68 48 35 80 00       	push   $0x803548
  801e9a:	68 8f 34 80 00       	push   $0x80348f
  801e9f:	68 f2 00 00 00       	push   $0xf2
  801ea4:	68 d5 34 80 00       	push   $0x8034d5
  801ea9:	e8 3a e6 ff ff       	call   8004e8 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801eae:	83 ec 04             	sub    $0x4,%esp
  801eb1:	6a 07                	push   $0x7
  801eb3:	68 00 00 40 00       	push   $0x400000
  801eb8:	6a 00                	push   $0x0
  801eba:	e8 da f0 ff ff       	call   800f99 <sys_page_alloc>
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	0f 88 6c 02 00 00    	js     802136 <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801ed3:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801ed9:	50                   	push   %eax
  801eda:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801ee0:	e8 b7 f9 ff ff       	call   80189c <seek>
  801ee5:	83 c4 10             	add    $0x10,%esp
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	0f 88 4d 02 00 00    	js     80213d <spawn+0x4e9>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ef0:	83 ec 04             	sub    $0x4,%esp
  801ef3:	89 f8                	mov    %edi,%eax
  801ef5:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801efb:	ba 00 10 00 00       	mov    $0x1000,%edx
  801f00:	39 d0                	cmp    %edx,%eax
  801f02:	0f 47 c2             	cmova  %edx,%eax
  801f05:	50                   	push   %eax
  801f06:	68 00 00 40 00       	push   $0x400000
  801f0b:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801f11:	e8 bd f8 ff ff       	call   8017d3 <readn>
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	0f 88 23 02 00 00    	js     802144 <spawn+0x4f0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f21:	83 ec 0c             	sub    $0xc,%esp
  801f24:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801f2a:	56                   	push   %esi
  801f2b:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f31:	68 00 00 40 00       	push   $0x400000
  801f36:	6a 00                	push   $0x0
  801f38:	e8 9f f0 ff ff       	call   800fdc <sys_page_map>
  801f3d:	83 c4 20             	add    $0x20,%esp
  801f40:	85 c0                	test   %eax,%eax
  801f42:	78 7c                	js     801fc0 <spawn+0x36c>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801f44:	83 ec 08             	sub    $0x8,%esp
  801f47:	68 00 00 40 00       	push   $0x400000
  801f4c:	6a 00                	push   $0x0
  801f4e:	e8 cb f0 ff ff       	call   80101e <sys_page_unmap>
  801f53:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801f56:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801f5c:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f62:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801f68:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801f6e:	76 65                	jbe    801fd5 <spawn+0x381>
		if (i >= filesz) {
  801f70:	39 df                	cmp    %ebx,%edi
  801f72:	0f 87 36 ff ff ff    	ja     801eae <spawn+0x25a>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801f78:	83 ec 04             	sub    $0x4,%esp
  801f7b:	ff b5 84 fd ff ff    	push   -0x27c(%ebp)
  801f81:	56                   	push   %esi
  801f82:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f88:	e8 0c f0 ff ff       	call   800f99 <sys_page_alloc>
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	85 c0                	test   %eax,%eax
  801f92:	79 c2                	jns    801f56 <spawn+0x302>
  801f94:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  801f9f:	e8 76 ef ff ff       	call   800f1a <sys_env_destroy>
	close(fd);
  801fa4:	83 c4 04             	add    $0x4,%esp
  801fa7:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  801fad:	e8 5e f6 ff ff       	call   801610 <close>
	return r;
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	89 bd 8c fd ff ff    	mov    %edi,-0x274(%ebp)
  801fbb:	e9 68 01 00 00       	jmp    802128 <spawn+0x4d4>
				panic("spawn: sys_page_map data: %e", r);
  801fc0:	50                   	push   %eax
  801fc1:	68 e1 34 80 00       	push   $0x8034e1
  801fc6:	68 25 01 00 00       	push   $0x125
  801fcb:	68 d5 34 80 00       	push   $0x8034d5
  801fd0:	e8 13 e5 ff ff       	call   8004e8 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801fd5:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801fdc:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801fe3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801fea:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801ff0:	7e 67                	jle    802059 <spawn+0x405>
		if (ph->p_type != ELF_PROG_LOAD)
  801ff2:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801ff8:	83 39 01             	cmpl   $0x1,(%ecx)
  801ffb:	75 d8                	jne    801fd5 <spawn+0x381>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ffd:	8b 41 18             	mov    0x18(%ecx),%eax
  802000:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802006:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802009:	83 f8 01             	cmp    $0x1,%eax
  80200c:	19 c0                	sbb    %eax,%eax
  80200e:	83 e0 fe             	and    $0xfffffffe,%eax
  802011:	83 c0 07             	add    $0x7,%eax
  802014:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80201a:	8b 51 04             	mov    0x4(%ecx),%edx
  80201d:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
  802023:	8b 79 10             	mov    0x10(%ecx),%edi
  802026:	8b 59 14             	mov    0x14(%ecx),%ebx
  802029:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80202f:	8b 71 08             	mov    0x8(%ecx),%esi
	if ((i = PGOFF(va))) {
  802032:	89 f0                	mov    %esi,%eax
  802034:	25 ff 0f 00 00       	and    $0xfff,%eax
  802039:	74 14                	je     80204f <spawn+0x3fb>
		va -= i;
  80203b:	29 c6                	sub    %eax,%esi
		memsz += i;
  80203d:	01 c3                	add    %eax,%ebx
  80203f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
		filesz += i;
  802045:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  802047:	29 c2                	sub    %eax,%edx
  802049:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  80204f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802054:	e9 09 ff ff ff       	jmp    801f62 <spawn+0x30e>
	close(fd);
  802059:	83 ec 0c             	sub    $0xc,%esp
  80205c:	ff b5 8c fd ff ff    	push   -0x274(%ebp)
  802062:	e8 a9 f5 ff ff       	call   801610 <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r;
	envid_t this_envid = sys_getenvid();//父进程号
  802067:	e8 ef ee ff ff       	call   800f5b <sys_getenvid>
  80206c:	89 c6                	mov    %eax,%esi
  80206e:	83 c4 10             	add    $0x10,%esp
	
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  802071:	bb 00 00 80 00       	mov    $0x800000,%ebx
  802076:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  80207c:	eb 12                	jmp    802090 <spawn+0x43c>
  80207e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802084:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80208a:	0f 84 bb 00 00 00    	je     80214b <spawn+0x4f7>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_SHARE ) ) {
  802090:	89 d8                	mov    %ebx,%eax
  802092:	c1 e8 16             	shr    $0x16,%eax
  802095:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80209c:	a8 01                	test   $0x1,%al
  80209e:	74 de                	je     80207e <spawn+0x42a>
  8020a0:	89 d8                	mov    %ebx,%eax
  8020a2:	c1 e8 0c             	shr    $0xc,%eax
  8020a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020ac:	f6 c2 01             	test   $0x1,%dl
  8020af:	74 cd                	je     80207e <spawn+0x42a>
  8020b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020b8:	f6 c6 04             	test   $0x4,%dh
  8020bb:	74 c1                	je     80207e <spawn+0x42a>
			//Copy the mappings
			if( (r=sys_page_map(this_envid , (void *)addr, child, (void *)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL ) )< 0 ) 
  8020bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020c4:	83 ec 0c             	sub    $0xc,%esp
  8020c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8020cc:	50                   	push   %eax
  8020cd:	53                   	push   %ebx
  8020ce:	57                   	push   %edi
  8020cf:	53                   	push   %ebx
  8020d0:	56                   	push   %esi
  8020d1:	e8 06 ef ff ff       	call   800fdc <sys_page_map>
  8020d6:	83 c4 20             	add    $0x20,%esp
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	79 a1                	jns    80207e <spawn+0x42a>
		panic("copy_shared_pages: %e", r);
  8020dd:	50                   	push   %eax
  8020de:	68 2f 35 80 00       	push   $0x80352f
  8020e3:	68 82 00 00 00       	push   $0x82
  8020e8:	68 d5 34 80 00       	push   $0x8034d5
  8020ed:	e8 f6 e3 ff ff       	call   8004e8 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  8020f2:	50                   	push   %eax
  8020f3:	68 fe 34 80 00       	push   $0x8034fe
  8020f8:	68 86 00 00 00       	push   $0x86
  8020fd:	68 d5 34 80 00       	push   $0x8034d5
  802102:	e8 e1 e3 ff ff       	call   8004e8 <_panic>
		panic("sys_env_set_status: %e", r);
  802107:	50                   	push   %eax
  802108:	68 18 35 80 00       	push   $0x803518
  80210d:	68 89 00 00 00       	push   $0x89
  802112:	68 d5 34 80 00       	push   $0x8034d5
  802117:	e8 cc e3 ff ff       	call   8004e8 <_panic>
		return r;
  80211c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802122:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
}
  802128:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  80212e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802131:	5b                   	pop    %ebx
  802132:	5e                   	pop    %esi
  802133:	5f                   	pop    %edi
  802134:	5d                   	pop    %ebp
  802135:	c3                   	ret    
  802136:	89 c7                	mov    %eax,%edi
  802138:	e9 59 fe ff ff       	jmp    801f96 <spawn+0x342>
  80213d:	89 c7                	mov    %eax,%edi
  80213f:	e9 52 fe ff ff       	jmp    801f96 <spawn+0x342>
  802144:	89 c7                	mov    %eax,%edi
  802146:	e9 4b fe ff ff       	jmp    801f96 <spawn+0x342>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  80214b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802152:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802155:	83 ec 08             	sub    $0x8,%esp
  802158:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  80215e:	50                   	push   %eax
  80215f:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  802165:	e8 38 ef ff ff       	call   8010a2 <sys_env_set_trapframe>
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 81                	js     8020f2 <spawn+0x49e>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802171:	83 ec 08             	sub    $0x8,%esp
  802174:	6a 02                	push   $0x2
  802176:	ff b5 88 fd ff ff    	push   -0x278(%ebp)
  80217c:	e8 df ee ff ff       	call   801060 <sys_env_set_status>
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	85 c0                	test   %eax,%eax
  802186:	0f 88 7b ff ff ff    	js     802107 <spawn+0x4b3>
	return child;
  80218c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802192:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802198:	eb 8e                	jmp    802128 <spawn+0x4d4>
		return -E_NO_MEM;
  80219a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  80219f:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8021a5:	eb 81                	jmp    802128 <spawn+0x4d4>
	sys_page_unmap(0, UTEMP);
  8021a7:	83 ec 08             	sub    $0x8,%esp
  8021aa:	68 00 00 40 00       	push   $0x400000
  8021af:	6a 00                	push   $0x0
  8021b1:	e8 68 ee ff ff       	call   80101e <sys_page_unmap>
  8021b6:	83 c4 10             	add    $0x10,%esp
  8021b9:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8021bf:	e9 64 ff ff ff       	jmp    802128 <spawn+0x4d4>

008021c4 <spawnl>:
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	56                   	push   %esi
  8021c8:	53                   	push   %ebx
	va_start(vl, arg0);
  8021c9:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  8021cc:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  8021d1:	eb 05                	jmp    8021d8 <spawnl+0x14>
		argc++;
  8021d3:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  8021d6:	89 ca                	mov    %ecx,%edx
  8021d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8021db:	83 3a 00             	cmpl   $0x0,(%edx)
  8021de:	75 f3                	jne    8021d3 <spawnl+0xf>
	const char *argv[argc+2];
  8021e0:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  8021e7:	89 d3                	mov    %edx,%ebx
  8021e9:	83 e3 f0             	and    $0xfffffff0,%ebx
  8021ec:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8021f2:	89 e1                	mov    %esp,%ecx
  8021f4:	29 d1                	sub    %edx,%ecx
  8021f6:	39 cc                	cmp    %ecx,%esp
  8021f8:	74 10                	je     80220a <spawnl+0x46>
  8021fa:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802200:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802207:	00 
  802208:	eb ec                	jmp    8021f6 <spawnl+0x32>
  80220a:	89 da                	mov    %ebx,%edx
  80220c:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802212:	29 d4                	sub    %edx,%esp
  802214:	85 d2                	test   %edx,%edx
  802216:	74 05                	je     80221d <spawnl+0x59>
  802218:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  80221d:	8d 5c 24 03          	lea    0x3(%esp),%ebx
  802221:	89 da                	mov    %ebx,%edx
  802223:	c1 ea 02             	shr    $0x2,%edx
  802226:	83 e3 fc             	and    $0xfffffffc,%ebx
	argv[0] = arg0;
  802229:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80222c:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802233:	c7 44 83 04 00 00 00 	movl   $0x0,0x4(%ebx,%eax,4)
  80223a:	00 
	va_start(vl, arg0);
  80223b:	8d 4d 10             	lea    0x10(%ebp),%ecx
  80223e:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802240:	b8 00 00 00 00       	mov    $0x0,%eax
  802245:	eb 0b                	jmp    802252 <spawnl+0x8e>
		argv[i+1] = va_arg(vl, const char *);
  802247:	83 c0 01             	add    $0x1,%eax
  80224a:	8b 31                	mov    (%ecx),%esi
  80224c:	89 34 83             	mov    %esi,(%ebx,%eax,4)
  80224f:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802252:	39 d0                	cmp    %edx,%eax
  802254:	75 f1                	jne    802247 <spawnl+0x83>
	return spawn(prog, argv);
  802256:	83 ec 08             	sub    $0x8,%esp
  802259:	53                   	push   %ebx
  80225a:	ff 75 08             	push   0x8(%ebp)
  80225d:	e8 f2 f9 ff ff       	call   801c54 <spawn>
}
  802262:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802265:	5b                   	pop    %ebx
  802266:	5e                   	pop    %esi
  802267:	5d                   	pop    %ebp
  802268:	c3                   	ret    

00802269 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80226f:	68 6e 35 80 00       	push   $0x80356e
  802274:	ff 75 0c             	push   0xc(%ebp)
  802277:	e8 21 e9 ff ff       	call   800b9d <strcpy>
	return 0;
}
  80227c:	b8 00 00 00 00       	mov    $0x0,%eax
  802281:	c9                   	leave  
  802282:	c3                   	ret    

00802283 <devsock_close>:
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	53                   	push   %ebx
  802287:	83 ec 10             	sub    $0x10,%esp
  80228a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80228d:	53                   	push   %ebx
  80228e:	e8 79 09 00 00       	call   802c0c <pageref>
  802293:	89 c2                	mov    %eax,%edx
  802295:	83 c4 10             	add    $0x10,%esp
		return 0;
  802298:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80229d:	83 fa 01             	cmp    $0x1,%edx
  8022a0:	74 05                	je     8022a7 <devsock_close+0x24>
}
  8022a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8022a5:	c9                   	leave  
  8022a6:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8022a7:	83 ec 0c             	sub    $0xc,%esp
  8022aa:	ff 73 0c             	push   0xc(%ebx)
  8022ad:	e8 b7 02 00 00       	call   802569 <nsipc_close>
  8022b2:	83 c4 10             	add    $0x10,%esp
  8022b5:	eb eb                	jmp    8022a2 <devsock_close+0x1f>

008022b7 <devsock_write>:
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8022bd:	6a 00                	push   $0x0
  8022bf:	ff 75 10             	push   0x10(%ebp)
  8022c2:	ff 75 0c             	push   0xc(%ebp)
  8022c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c8:	ff 70 0c             	push   0xc(%eax)
  8022cb:	e8 79 03 00 00       	call   802649 <nsipc_send>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <devsock_read>:
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8022d8:	6a 00                	push   $0x0
  8022da:	ff 75 10             	push   0x10(%ebp)
  8022dd:	ff 75 0c             	push   0xc(%ebp)
  8022e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e3:	ff 70 0c             	push   0xc(%eax)
  8022e6:	e8 ef 02 00 00       	call   8025da <nsipc_recv>
}
  8022eb:	c9                   	leave  
  8022ec:	c3                   	ret    

008022ed <fd2sockid>:
{
  8022ed:	55                   	push   %ebp
  8022ee:	89 e5                	mov    %esp,%ebp
  8022f0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8022f3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022f6:	52                   	push   %edx
  8022f7:	50                   	push   %eax
  8022f8:	e8 e6 f1 ff ff       	call   8014e3 <fd_lookup>
  8022fd:	83 c4 10             	add    $0x10,%esp
  802300:	85 c0                	test   %eax,%eax
  802302:	78 10                	js     802314 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  802304:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802307:	8b 0d 3c 40 80 00    	mov    0x80403c,%ecx
  80230d:	39 08                	cmp    %ecx,(%eax)
  80230f:	75 05                	jne    802316 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  802311:	8b 40 0c             	mov    0xc(%eax),%eax
}
  802314:	c9                   	leave  
  802315:	c3                   	ret    
		return -E_NOT_SUPP;
  802316:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80231b:	eb f7                	jmp    802314 <fd2sockid+0x27>

0080231d <alloc_sockfd>:
{
  80231d:	55                   	push   %ebp
  80231e:	89 e5                	mov    %esp,%ebp
  802320:	56                   	push   %esi
  802321:	53                   	push   %ebx
  802322:	83 ec 1c             	sub    $0x1c,%esp
  802325:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  802327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80232a:	50                   	push   %eax
  80232b:	e8 63 f1 ff ff       	call   801493 <fd_alloc>
  802330:	89 c3                	mov    %eax,%ebx
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	85 c0                	test   %eax,%eax
  802337:	78 43                	js     80237c <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802339:	83 ec 04             	sub    $0x4,%esp
  80233c:	68 07 04 00 00       	push   $0x407
  802341:	ff 75 f4             	push   -0xc(%ebp)
  802344:	6a 00                	push   $0x0
  802346:	e8 4e ec ff ff       	call   800f99 <sys_page_alloc>
  80234b:	89 c3                	mov    %eax,%ebx
  80234d:	83 c4 10             	add    $0x10,%esp
  802350:	85 c0                	test   %eax,%eax
  802352:	78 28                	js     80237c <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  802354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802357:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80235d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80235f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802362:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802369:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80236c:	83 ec 0c             	sub    $0xc,%esp
  80236f:	50                   	push   %eax
  802370:	e8 f7 f0 ff ff       	call   80146c <fd2num>
  802375:	89 c3                	mov    %eax,%ebx
  802377:	83 c4 10             	add    $0x10,%esp
  80237a:	eb 0c                	jmp    802388 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80237c:	83 ec 0c             	sub    $0xc,%esp
  80237f:	56                   	push   %esi
  802380:	e8 e4 01 00 00       	call   802569 <nsipc_close>
		return r;
  802385:	83 c4 10             	add    $0x10,%esp
}
  802388:	89 d8                	mov    %ebx,%eax
  80238a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5d                   	pop    %ebp
  802390:	c3                   	ret    

00802391 <accept>:
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802397:	8b 45 08             	mov    0x8(%ebp),%eax
  80239a:	e8 4e ff ff ff       	call   8022ed <fd2sockid>
  80239f:	85 c0                	test   %eax,%eax
  8023a1:	78 1b                	js     8023be <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023a3:	83 ec 04             	sub    $0x4,%esp
  8023a6:	ff 75 10             	push   0x10(%ebp)
  8023a9:	ff 75 0c             	push   0xc(%ebp)
  8023ac:	50                   	push   %eax
  8023ad:	e8 0e 01 00 00       	call   8024c0 <nsipc_accept>
  8023b2:	83 c4 10             	add    $0x10,%esp
  8023b5:	85 c0                	test   %eax,%eax
  8023b7:	78 05                	js     8023be <accept+0x2d>
	return alloc_sockfd(r);
  8023b9:	e8 5f ff ff ff       	call   80231d <alloc_sockfd>
}
  8023be:	c9                   	leave  
  8023bf:	c3                   	ret    

008023c0 <bind>:
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8023c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c9:	e8 1f ff ff ff       	call   8022ed <fd2sockid>
  8023ce:	85 c0                	test   %eax,%eax
  8023d0:	78 12                	js     8023e4 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8023d2:	83 ec 04             	sub    $0x4,%esp
  8023d5:	ff 75 10             	push   0x10(%ebp)
  8023d8:	ff 75 0c             	push   0xc(%ebp)
  8023db:	50                   	push   %eax
  8023dc:	e8 31 01 00 00       	call   802512 <nsipc_bind>
  8023e1:	83 c4 10             	add    $0x10,%esp
}
  8023e4:	c9                   	leave  
  8023e5:	c3                   	ret    

008023e6 <shutdown>:
{
  8023e6:	55                   	push   %ebp
  8023e7:	89 e5                	mov    %esp,%ebp
  8023e9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8023ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ef:	e8 f9 fe ff ff       	call   8022ed <fd2sockid>
  8023f4:	85 c0                	test   %eax,%eax
  8023f6:	78 0f                	js     802407 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8023f8:	83 ec 08             	sub    $0x8,%esp
  8023fb:	ff 75 0c             	push   0xc(%ebp)
  8023fe:	50                   	push   %eax
  8023ff:	e8 43 01 00 00       	call   802547 <nsipc_shutdown>
  802404:	83 c4 10             	add    $0x10,%esp
}
  802407:	c9                   	leave  
  802408:	c3                   	ret    

00802409 <connect>:
{
  802409:	55                   	push   %ebp
  80240a:	89 e5                	mov    %esp,%ebp
  80240c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80240f:	8b 45 08             	mov    0x8(%ebp),%eax
  802412:	e8 d6 fe ff ff       	call   8022ed <fd2sockid>
  802417:	85 c0                	test   %eax,%eax
  802419:	78 12                	js     80242d <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80241b:	83 ec 04             	sub    $0x4,%esp
  80241e:	ff 75 10             	push   0x10(%ebp)
  802421:	ff 75 0c             	push   0xc(%ebp)
  802424:	50                   	push   %eax
  802425:	e8 59 01 00 00       	call   802583 <nsipc_connect>
  80242a:	83 c4 10             	add    $0x10,%esp
}
  80242d:	c9                   	leave  
  80242e:	c3                   	ret    

0080242f <listen>:
{
  80242f:	55                   	push   %ebp
  802430:	89 e5                	mov    %esp,%ebp
  802432:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  802435:	8b 45 08             	mov    0x8(%ebp),%eax
  802438:	e8 b0 fe ff ff       	call   8022ed <fd2sockid>
  80243d:	85 c0                	test   %eax,%eax
  80243f:	78 0f                	js     802450 <listen+0x21>
	return nsipc_listen(r, backlog);
  802441:	83 ec 08             	sub    $0x8,%esp
  802444:	ff 75 0c             	push   0xc(%ebp)
  802447:	50                   	push   %eax
  802448:	e8 6b 01 00 00       	call   8025b8 <nsipc_listen>
  80244d:	83 c4 10             	add    $0x10,%esp
}
  802450:	c9                   	leave  
  802451:	c3                   	ret    

00802452 <socket>:

int
socket(int domain, int type, int protocol)
{
  802452:	55                   	push   %ebp
  802453:	89 e5                	mov    %esp,%ebp
  802455:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802458:	ff 75 10             	push   0x10(%ebp)
  80245b:	ff 75 0c             	push   0xc(%ebp)
  80245e:	ff 75 08             	push   0x8(%ebp)
  802461:	e8 41 02 00 00       	call   8026a7 <nsipc_socket>
  802466:	83 c4 10             	add    $0x10,%esp
  802469:	85 c0                	test   %eax,%eax
  80246b:	78 05                	js     802472 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80246d:	e8 ab fe ff ff       	call   80231d <alloc_sockfd>
}
  802472:	c9                   	leave  
  802473:	c3                   	ret    

00802474 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802474:	55                   	push   %ebp
  802475:	89 e5                	mov    %esp,%ebp
  802477:	53                   	push   %ebx
  802478:	83 ec 04             	sub    $0x4,%esp
  80247b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80247d:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802484:	74 26                	je     8024ac <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802486:	6a 07                	push   $0x7
  802488:	68 00 80 80 00       	push   $0x808000
  80248d:	53                   	push   %ebx
  80248e:	ff 35 00 90 80 00    	push   0x809000
  802494:	e8 e0 06 00 00       	call   802b79 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802499:	83 c4 0c             	add    $0xc,%esp
  80249c:	6a 00                	push   $0x0
  80249e:	6a 00                	push   $0x0
  8024a0:	6a 00                	push   $0x0
  8024a2:	e8 62 06 00 00       	call   802b09 <ipc_recv>
}
  8024a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024aa:	c9                   	leave  
  8024ab:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8024ac:	83 ec 0c             	sub    $0xc,%esp
  8024af:	6a 02                	push   $0x2
  8024b1:	e8 17 07 00 00       	call   802bcd <ipc_find_env>
  8024b6:	a3 00 90 80 00       	mov    %eax,0x809000
  8024bb:	83 c4 10             	add    $0x10,%esp
  8024be:	eb c6                	jmp    802486 <nsipc+0x12>

008024c0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	56                   	push   %esi
  8024c4:	53                   	push   %ebx
  8024c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8024c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cb:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8024d0:	8b 06                	mov    (%esi),%eax
  8024d2:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8024d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8024dc:	e8 93 ff ff ff       	call   802474 <nsipc>
  8024e1:	89 c3                	mov    %eax,%ebx
  8024e3:	85 c0                	test   %eax,%eax
  8024e5:	79 09                	jns    8024f0 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  8024e7:	89 d8                	mov    %ebx,%eax
  8024e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024ec:	5b                   	pop    %ebx
  8024ed:	5e                   	pop    %esi
  8024ee:	5d                   	pop    %ebp
  8024ef:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8024f0:	83 ec 04             	sub    $0x4,%esp
  8024f3:	ff 35 10 80 80 00    	push   0x808010
  8024f9:	68 00 80 80 00       	push   $0x808000
  8024fe:	ff 75 0c             	push   0xc(%ebp)
  802501:	e8 2d e8 ff ff       	call   800d33 <memmove>
		*addrlen = ret->ret_addrlen;
  802506:	a1 10 80 80 00       	mov    0x808010,%eax
  80250b:	89 06                	mov    %eax,(%esi)
  80250d:	83 c4 10             	add    $0x10,%esp
	return r;
  802510:	eb d5                	jmp    8024e7 <nsipc_accept+0x27>

00802512 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802512:	55                   	push   %ebp
  802513:	89 e5                	mov    %esp,%ebp
  802515:	53                   	push   %ebx
  802516:	83 ec 08             	sub    $0x8,%esp
  802519:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80251c:	8b 45 08             	mov    0x8(%ebp),%eax
  80251f:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802524:	53                   	push   %ebx
  802525:	ff 75 0c             	push   0xc(%ebp)
  802528:	68 04 80 80 00       	push   $0x808004
  80252d:	e8 01 e8 ff ff       	call   800d33 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802532:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  802538:	b8 02 00 00 00       	mov    $0x2,%eax
  80253d:	e8 32 ff ff ff       	call   802474 <nsipc>
}
  802542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802545:	c9                   	leave  
  802546:	c3                   	ret    

00802547 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802547:	55                   	push   %ebp
  802548:	89 e5                	mov    %esp,%ebp
  80254a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80254d:	8b 45 08             	mov    0x8(%ebp),%eax
  802550:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  802555:	8b 45 0c             	mov    0xc(%ebp),%eax
  802558:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  80255d:	b8 03 00 00 00       	mov    $0x3,%eax
  802562:	e8 0d ff ff ff       	call   802474 <nsipc>
}
  802567:	c9                   	leave  
  802568:	c3                   	ret    

00802569 <nsipc_close>:

int
nsipc_close(int s)
{
  802569:	55                   	push   %ebp
  80256a:	89 e5                	mov    %esp,%ebp
  80256c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80256f:	8b 45 08             	mov    0x8(%ebp),%eax
  802572:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  802577:	b8 04 00 00 00       	mov    $0x4,%eax
  80257c:	e8 f3 fe ff ff       	call   802474 <nsipc>
}
  802581:	c9                   	leave  
  802582:	c3                   	ret    

00802583 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802583:	55                   	push   %ebp
  802584:	89 e5                	mov    %esp,%ebp
  802586:	53                   	push   %ebx
  802587:	83 ec 08             	sub    $0x8,%esp
  80258a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80258d:	8b 45 08             	mov    0x8(%ebp),%eax
  802590:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802595:	53                   	push   %ebx
  802596:	ff 75 0c             	push   0xc(%ebp)
  802599:	68 04 80 80 00       	push   $0x808004
  80259e:	e8 90 e7 ff ff       	call   800d33 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8025a3:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  8025a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8025ae:	e8 c1 fe ff ff       	call   802474 <nsipc>
}
  8025b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8025b6:	c9                   	leave  
  8025b7:	c3                   	ret    

008025b8 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8025be:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c1:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  8025c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c9:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  8025ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8025d3:	e8 9c fe ff ff       	call   802474 <nsipc>
}
  8025d8:	c9                   	leave  
  8025d9:	c3                   	ret    

008025da <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8025da:	55                   	push   %ebp
  8025db:	89 e5                	mov    %esp,%ebp
  8025dd:	56                   	push   %esi
  8025de:	53                   	push   %ebx
  8025df:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8025e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e5:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  8025ea:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  8025f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8025f3:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025f8:	b8 07 00 00 00       	mov    $0x7,%eax
  8025fd:	e8 72 fe ff ff       	call   802474 <nsipc>
  802602:	89 c3                	mov    %eax,%ebx
  802604:	85 c0                	test   %eax,%eax
  802606:	78 22                	js     80262a <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  802608:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80260d:	39 c6                	cmp    %eax,%esi
  80260f:	0f 4e c6             	cmovle %esi,%eax
  802612:	39 c3                	cmp    %eax,%ebx
  802614:	7f 1d                	jg     802633 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802616:	83 ec 04             	sub    $0x4,%esp
  802619:	53                   	push   %ebx
  80261a:	68 00 80 80 00       	push   $0x808000
  80261f:	ff 75 0c             	push   0xc(%ebp)
  802622:	e8 0c e7 ff ff       	call   800d33 <memmove>
  802627:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80262a:	89 d8                	mov    %ebx,%eax
  80262c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80262f:	5b                   	pop    %ebx
  802630:	5e                   	pop    %esi
  802631:	5d                   	pop    %ebp
  802632:	c3                   	ret    
		assert(r < 1600 && r <= len);
  802633:	68 7a 35 80 00       	push   $0x80357a
  802638:	68 8f 34 80 00       	push   $0x80348f
  80263d:	6a 62                	push   $0x62
  80263f:	68 8f 35 80 00       	push   $0x80358f
  802644:	e8 9f de ff ff       	call   8004e8 <_panic>

00802649 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802649:	55                   	push   %ebp
  80264a:	89 e5                	mov    %esp,%ebp
  80264c:	53                   	push   %ebx
  80264d:	83 ec 04             	sub    $0x4,%esp
  802650:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802653:	8b 45 08             	mov    0x8(%ebp),%eax
  802656:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  80265b:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802661:	7f 2e                	jg     802691 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802663:	83 ec 04             	sub    $0x4,%esp
  802666:	53                   	push   %ebx
  802667:	ff 75 0c             	push   0xc(%ebp)
  80266a:	68 0c 80 80 00       	push   $0x80800c
  80266f:	e8 bf e6 ff ff       	call   800d33 <memmove>
	nsipcbuf.send.req_size = size;
  802674:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  80267a:	8b 45 14             	mov    0x14(%ebp),%eax
  80267d:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  802682:	b8 08 00 00 00       	mov    $0x8,%eax
  802687:	e8 e8 fd ff ff       	call   802474 <nsipc>
}
  80268c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80268f:	c9                   	leave  
  802690:	c3                   	ret    
	assert(size < 1600);
  802691:	68 9b 35 80 00       	push   $0x80359b
  802696:	68 8f 34 80 00       	push   $0x80348f
  80269b:	6a 6d                	push   $0x6d
  80269d:	68 8f 35 80 00       	push   $0x80358f
  8026a2:	e8 41 de ff ff       	call   8004e8 <_panic>

008026a7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8026a7:	55                   	push   %ebp
  8026a8:	89 e5                	mov    %esp,%ebp
  8026aa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8026ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b0:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8026b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026b8:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  8026bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8026c0:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  8026c5:	b8 09 00 00 00       	mov    $0x9,%eax
  8026ca:	e8 a5 fd ff ff       	call   802474 <nsipc>
}
  8026cf:	c9                   	leave  
  8026d0:	c3                   	ret    

008026d1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8026d1:	55                   	push   %ebp
  8026d2:	89 e5                	mov    %esp,%ebp
  8026d4:	56                   	push   %esi
  8026d5:	53                   	push   %ebx
  8026d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8026d9:	83 ec 0c             	sub    $0xc,%esp
  8026dc:	ff 75 08             	push   0x8(%ebp)
  8026df:	e8 98 ed ff ff       	call   80147c <fd2data>
  8026e4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8026e6:	83 c4 08             	add    $0x8,%esp
  8026e9:	68 a7 35 80 00       	push   $0x8035a7
  8026ee:	53                   	push   %ebx
  8026ef:	e8 a9 e4 ff ff       	call   800b9d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8026f4:	8b 46 04             	mov    0x4(%esi),%eax
  8026f7:	2b 06                	sub    (%esi),%eax
  8026f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8026ff:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802706:	00 00 00 
	stat->st_dev = &devpipe;
  802709:	c7 83 88 00 00 00 58 	movl   $0x804058,0x88(%ebx)
  802710:	40 80 00 
	return 0;
}
  802713:	b8 00 00 00 00       	mov    $0x0,%eax
  802718:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80271b:	5b                   	pop    %ebx
  80271c:	5e                   	pop    %esi
  80271d:	5d                   	pop    %ebp
  80271e:	c3                   	ret    

0080271f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80271f:	55                   	push   %ebp
  802720:	89 e5                	mov    %esp,%ebp
  802722:	53                   	push   %ebx
  802723:	83 ec 0c             	sub    $0xc,%esp
  802726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802729:	53                   	push   %ebx
  80272a:	6a 00                	push   $0x0
  80272c:	e8 ed e8 ff ff       	call   80101e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802731:	89 1c 24             	mov    %ebx,(%esp)
  802734:	e8 43 ed ff ff       	call   80147c <fd2data>
  802739:	83 c4 08             	add    $0x8,%esp
  80273c:	50                   	push   %eax
  80273d:	6a 00                	push   $0x0
  80273f:	e8 da e8 ff ff       	call   80101e <sys_page_unmap>
}
  802744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802747:	c9                   	leave  
  802748:	c3                   	ret    

00802749 <_pipeisclosed>:
{
  802749:	55                   	push   %ebp
  80274a:	89 e5                	mov    %esp,%ebp
  80274c:	57                   	push   %edi
  80274d:	56                   	push   %esi
  80274e:	53                   	push   %ebx
  80274f:	83 ec 1c             	sub    $0x1c,%esp
  802752:	89 c7                	mov    %eax,%edi
  802754:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802756:	a1 00 50 80 00       	mov    0x805000,%eax
  80275b:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80275e:	83 ec 0c             	sub    $0xc,%esp
  802761:	57                   	push   %edi
  802762:	e8 a5 04 00 00       	call   802c0c <pageref>
  802767:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80276a:	89 34 24             	mov    %esi,(%esp)
  80276d:	e8 9a 04 00 00       	call   802c0c <pageref>
		nn = thisenv->env_runs;
  802772:	8b 15 00 50 80 00    	mov    0x805000,%edx
  802778:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  80277b:	83 c4 10             	add    $0x10,%esp
  80277e:	39 cb                	cmp    %ecx,%ebx
  802780:	74 1b                	je     80279d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802782:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802785:	75 cf                	jne    802756 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802787:	8b 42 68             	mov    0x68(%edx),%eax
  80278a:	6a 01                	push   $0x1
  80278c:	50                   	push   %eax
  80278d:	53                   	push   %ebx
  80278e:	68 ae 35 80 00       	push   $0x8035ae
  802793:	e8 2b de ff ff       	call   8005c3 <cprintf>
  802798:	83 c4 10             	add    $0x10,%esp
  80279b:	eb b9                	jmp    802756 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80279d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8027a0:	0f 94 c0             	sete   %al
  8027a3:	0f b6 c0             	movzbl %al,%eax
}
  8027a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027a9:	5b                   	pop    %ebx
  8027aa:	5e                   	pop    %esi
  8027ab:	5f                   	pop    %edi
  8027ac:	5d                   	pop    %ebp
  8027ad:	c3                   	ret    

008027ae <devpipe_write>:
{
  8027ae:	55                   	push   %ebp
  8027af:	89 e5                	mov    %esp,%ebp
  8027b1:	57                   	push   %edi
  8027b2:	56                   	push   %esi
  8027b3:	53                   	push   %ebx
  8027b4:	83 ec 28             	sub    $0x28,%esp
  8027b7:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8027ba:	56                   	push   %esi
  8027bb:	e8 bc ec ff ff       	call   80147c <fd2data>
  8027c0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8027c2:	83 c4 10             	add    $0x10,%esp
  8027c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8027ca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8027cd:	75 09                	jne    8027d8 <devpipe_write+0x2a>
	return i;
  8027cf:	89 f8                	mov    %edi,%eax
  8027d1:	eb 23                	jmp    8027f6 <devpipe_write+0x48>
			sys_yield();
  8027d3:	e8 a2 e7 ff ff       	call   800f7a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8027d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8027db:	8b 0b                	mov    (%ebx),%ecx
  8027dd:	8d 51 20             	lea    0x20(%ecx),%edx
  8027e0:	39 d0                	cmp    %edx,%eax
  8027e2:	72 1a                	jb     8027fe <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8027e4:	89 da                	mov    %ebx,%edx
  8027e6:	89 f0                	mov    %esi,%eax
  8027e8:	e8 5c ff ff ff       	call   802749 <_pipeisclosed>
  8027ed:	85 c0                	test   %eax,%eax
  8027ef:	74 e2                	je     8027d3 <devpipe_write+0x25>
				return 0;
  8027f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027f9:	5b                   	pop    %ebx
  8027fa:	5e                   	pop    %esi
  8027fb:	5f                   	pop    %edi
  8027fc:	5d                   	pop    %ebp
  8027fd:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8027fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802801:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802805:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802808:	89 c2                	mov    %eax,%edx
  80280a:	c1 fa 1f             	sar    $0x1f,%edx
  80280d:	89 d1                	mov    %edx,%ecx
  80280f:	c1 e9 1b             	shr    $0x1b,%ecx
  802812:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802815:	83 e2 1f             	and    $0x1f,%edx
  802818:	29 ca                	sub    %ecx,%edx
  80281a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80281e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802822:	83 c0 01             	add    $0x1,%eax
  802825:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802828:	83 c7 01             	add    $0x1,%edi
  80282b:	eb 9d                	jmp    8027ca <devpipe_write+0x1c>

0080282d <devpipe_read>:
{
  80282d:	55                   	push   %ebp
  80282e:	89 e5                	mov    %esp,%ebp
  802830:	57                   	push   %edi
  802831:	56                   	push   %esi
  802832:	53                   	push   %ebx
  802833:	83 ec 18             	sub    $0x18,%esp
  802836:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802839:	57                   	push   %edi
  80283a:	e8 3d ec ff ff       	call   80147c <fd2data>
  80283f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802841:	83 c4 10             	add    $0x10,%esp
  802844:	be 00 00 00 00       	mov    $0x0,%esi
  802849:	3b 75 10             	cmp    0x10(%ebp),%esi
  80284c:	75 13                	jne    802861 <devpipe_read+0x34>
	return i;
  80284e:	89 f0                	mov    %esi,%eax
  802850:	eb 02                	jmp    802854 <devpipe_read+0x27>
				return i;
  802852:	89 f0                	mov    %esi,%eax
}
  802854:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802857:	5b                   	pop    %ebx
  802858:	5e                   	pop    %esi
  802859:	5f                   	pop    %edi
  80285a:	5d                   	pop    %ebp
  80285b:	c3                   	ret    
			sys_yield();
  80285c:	e8 19 e7 ff ff       	call   800f7a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802861:	8b 03                	mov    (%ebx),%eax
  802863:	3b 43 04             	cmp    0x4(%ebx),%eax
  802866:	75 18                	jne    802880 <devpipe_read+0x53>
			if (i > 0)
  802868:	85 f6                	test   %esi,%esi
  80286a:	75 e6                	jne    802852 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80286c:	89 da                	mov    %ebx,%edx
  80286e:	89 f8                	mov    %edi,%eax
  802870:	e8 d4 fe ff ff       	call   802749 <_pipeisclosed>
  802875:	85 c0                	test   %eax,%eax
  802877:	74 e3                	je     80285c <devpipe_read+0x2f>
				return 0;
  802879:	b8 00 00 00 00       	mov    $0x0,%eax
  80287e:	eb d4                	jmp    802854 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802880:	99                   	cltd   
  802881:	c1 ea 1b             	shr    $0x1b,%edx
  802884:	01 d0                	add    %edx,%eax
  802886:	83 e0 1f             	and    $0x1f,%eax
  802889:	29 d0                	sub    %edx,%eax
  80288b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802890:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802893:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802896:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802899:	83 c6 01             	add    $0x1,%esi
  80289c:	eb ab                	jmp    802849 <devpipe_read+0x1c>

0080289e <pipe>:
{
  80289e:	55                   	push   %ebp
  80289f:	89 e5                	mov    %esp,%ebp
  8028a1:	56                   	push   %esi
  8028a2:	53                   	push   %ebx
  8028a3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8028a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028a9:	50                   	push   %eax
  8028aa:	e8 e4 eb ff ff       	call   801493 <fd_alloc>
  8028af:	89 c3                	mov    %eax,%ebx
  8028b1:	83 c4 10             	add    $0x10,%esp
  8028b4:	85 c0                	test   %eax,%eax
  8028b6:	0f 88 23 01 00 00    	js     8029df <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028bc:	83 ec 04             	sub    $0x4,%esp
  8028bf:	68 07 04 00 00       	push   $0x407
  8028c4:	ff 75 f4             	push   -0xc(%ebp)
  8028c7:	6a 00                	push   $0x0
  8028c9:	e8 cb e6 ff ff       	call   800f99 <sys_page_alloc>
  8028ce:	89 c3                	mov    %eax,%ebx
  8028d0:	83 c4 10             	add    $0x10,%esp
  8028d3:	85 c0                	test   %eax,%eax
  8028d5:	0f 88 04 01 00 00    	js     8029df <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8028db:	83 ec 0c             	sub    $0xc,%esp
  8028de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028e1:	50                   	push   %eax
  8028e2:	e8 ac eb ff ff       	call   801493 <fd_alloc>
  8028e7:	89 c3                	mov    %eax,%ebx
  8028e9:	83 c4 10             	add    $0x10,%esp
  8028ec:	85 c0                	test   %eax,%eax
  8028ee:	0f 88 db 00 00 00    	js     8029cf <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028f4:	83 ec 04             	sub    $0x4,%esp
  8028f7:	68 07 04 00 00       	push   $0x407
  8028fc:	ff 75 f0             	push   -0x10(%ebp)
  8028ff:	6a 00                	push   $0x0
  802901:	e8 93 e6 ff ff       	call   800f99 <sys_page_alloc>
  802906:	89 c3                	mov    %eax,%ebx
  802908:	83 c4 10             	add    $0x10,%esp
  80290b:	85 c0                	test   %eax,%eax
  80290d:	0f 88 bc 00 00 00    	js     8029cf <pipe+0x131>
	va = fd2data(fd0);
  802913:	83 ec 0c             	sub    $0xc,%esp
  802916:	ff 75 f4             	push   -0xc(%ebp)
  802919:	e8 5e eb ff ff       	call   80147c <fd2data>
  80291e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802920:	83 c4 0c             	add    $0xc,%esp
  802923:	68 07 04 00 00       	push   $0x407
  802928:	50                   	push   %eax
  802929:	6a 00                	push   $0x0
  80292b:	e8 69 e6 ff ff       	call   800f99 <sys_page_alloc>
  802930:	89 c3                	mov    %eax,%ebx
  802932:	83 c4 10             	add    $0x10,%esp
  802935:	85 c0                	test   %eax,%eax
  802937:	0f 88 82 00 00 00    	js     8029bf <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80293d:	83 ec 0c             	sub    $0xc,%esp
  802940:	ff 75 f0             	push   -0x10(%ebp)
  802943:	e8 34 eb ff ff       	call   80147c <fd2data>
  802948:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80294f:	50                   	push   %eax
  802950:	6a 00                	push   $0x0
  802952:	56                   	push   %esi
  802953:	6a 00                	push   $0x0
  802955:	e8 82 e6 ff ff       	call   800fdc <sys_page_map>
  80295a:	89 c3                	mov    %eax,%ebx
  80295c:	83 c4 20             	add    $0x20,%esp
  80295f:	85 c0                	test   %eax,%eax
  802961:	78 4e                	js     8029b1 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802963:	a1 58 40 80 00       	mov    0x804058,%eax
  802968:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80296b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80296d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802970:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802977:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80297a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80297c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80297f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802986:	83 ec 0c             	sub    $0xc,%esp
  802989:	ff 75 f4             	push   -0xc(%ebp)
  80298c:	e8 db ea ff ff       	call   80146c <fd2num>
  802991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802994:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802996:	83 c4 04             	add    $0x4,%esp
  802999:	ff 75 f0             	push   -0x10(%ebp)
  80299c:	e8 cb ea ff ff       	call   80146c <fd2num>
  8029a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029a4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8029a7:	83 c4 10             	add    $0x10,%esp
  8029aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029af:	eb 2e                	jmp    8029df <pipe+0x141>
	sys_page_unmap(0, va);
  8029b1:	83 ec 08             	sub    $0x8,%esp
  8029b4:	56                   	push   %esi
  8029b5:	6a 00                	push   $0x0
  8029b7:	e8 62 e6 ff ff       	call   80101e <sys_page_unmap>
  8029bc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8029bf:	83 ec 08             	sub    $0x8,%esp
  8029c2:	ff 75 f0             	push   -0x10(%ebp)
  8029c5:	6a 00                	push   $0x0
  8029c7:	e8 52 e6 ff ff       	call   80101e <sys_page_unmap>
  8029cc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8029cf:	83 ec 08             	sub    $0x8,%esp
  8029d2:	ff 75 f4             	push   -0xc(%ebp)
  8029d5:	6a 00                	push   $0x0
  8029d7:	e8 42 e6 ff ff       	call   80101e <sys_page_unmap>
  8029dc:	83 c4 10             	add    $0x10,%esp
}
  8029df:	89 d8                	mov    %ebx,%eax
  8029e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8029e4:	5b                   	pop    %ebx
  8029e5:	5e                   	pop    %esi
  8029e6:	5d                   	pop    %ebp
  8029e7:	c3                   	ret    

008029e8 <pipeisclosed>:
{
  8029e8:	55                   	push   %ebp
  8029e9:	89 e5                	mov    %esp,%ebp
  8029eb:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8029ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029f1:	50                   	push   %eax
  8029f2:	ff 75 08             	push   0x8(%ebp)
  8029f5:	e8 e9 ea ff ff       	call   8014e3 <fd_lookup>
  8029fa:	83 c4 10             	add    $0x10,%esp
  8029fd:	85 c0                	test   %eax,%eax
  8029ff:	78 18                	js     802a19 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802a01:	83 ec 0c             	sub    $0xc,%esp
  802a04:	ff 75 f4             	push   -0xc(%ebp)
  802a07:	e8 70 ea ff ff       	call   80147c <fd2data>
  802a0c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a11:	e8 33 fd ff ff       	call   802749 <_pipeisclosed>
  802a16:	83 c4 10             	add    $0x10,%esp
}
  802a19:	c9                   	leave  
  802a1a:	c3                   	ret    

00802a1b <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802a1b:	55                   	push   %ebp
  802a1c:	89 e5                	mov    %esp,%ebp
  802a1e:	56                   	push   %esi
  802a1f:	53                   	push   %ebx
  802a20:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802a23:	85 f6                	test   %esi,%esi
  802a25:	74 16                	je     802a3d <wait+0x22>
	e = &envs[ENVX(envid)];
  802a27:	89 f3                	mov    %esi,%ebx
  802a29:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a2f:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
  802a35:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802a3b:	eb 1b                	jmp    802a58 <wait+0x3d>
	assert(envid != 0);
  802a3d:	68 c6 35 80 00       	push   $0x8035c6
  802a42:	68 8f 34 80 00       	push   $0x80348f
  802a47:	6a 09                	push   $0x9
  802a49:	68 d1 35 80 00       	push   $0x8035d1
  802a4e:	e8 95 da ff ff       	call   8004e8 <_panic>
		sys_yield();
  802a53:	e8 22 e5 ff ff       	call   800f7a <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802a58:	8b 43 58             	mov    0x58(%ebx),%eax
  802a5b:	39 f0                	cmp    %esi,%eax
  802a5d:	75 07                	jne    802a66 <wait+0x4b>
  802a5f:	8b 43 64             	mov    0x64(%ebx),%eax
  802a62:	85 c0                	test   %eax,%eax
  802a64:	75 ed                	jne    802a53 <wait+0x38>
}
  802a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a69:	5b                   	pop    %ebx
  802a6a:	5e                   	pop    %esi
  802a6b:	5d                   	pop    %ebp
  802a6c:	c3                   	ret    

00802a6d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802a6d:	55                   	push   %ebp
  802a6e:	89 e5                	mov    %esp,%ebp
  802a70:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802a73:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  802a7a:	74 0a                	je     802a86 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a7f:	a3 04 90 80 00       	mov    %eax,0x809004
}
  802a84:	c9                   	leave  
  802a85:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802a86:	e8 d0 e4 ff ff       	call   800f5b <sys_getenvid>
  802a8b:	83 ec 04             	sub    $0x4,%esp
  802a8e:	68 07 0e 00 00       	push   $0xe07
  802a93:	68 00 f0 bf ee       	push   $0xeebff000
  802a98:	50                   	push   %eax
  802a99:	e8 fb e4 ff ff       	call   800f99 <sys_page_alloc>
		if (r < 0) {
  802a9e:	83 c4 10             	add    $0x10,%esp
  802aa1:	85 c0                	test   %eax,%eax
  802aa3:	78 2c                	js     802ad1 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802aa5:	e8 b1 e4 ff ff       	call   800f5b <sys_getenvid>
  802aaa:	83 ec 08             	sub    $0x8,%esp
  802aad:	68 e3 2a 80 00       	push   $0x802ae3
  802ab2:	50                   	push   %eax
  802ab3:	e8 2c e6 ff ff       	call   8010e4 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802ab8:	83 c4 10             	add    $0x10,%esp
  802abb:	85 c0                	test   %eax,%eax
  802abd:	79 bd                	jns    802a7c <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802abf:	50                   	push   %eax
  802ac0:	68 1c 36 80 00       	push   $0x80361c
  802ac5:	6a 28                	push   $0x28
  802ac7:	68 52 36 80 00       	push   $0x803652
  802acc:	e8 17 da ff ff       	call   8004e8 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802ad1:	50                   	push   %eax
  802ad2:	68 dc 35 80 00       	push   $0x8035dc
  802ad7:	6a 23                	push   $0x23
  802ad9:	68 52 36 80 00       	push   $0x803652
  802ade:	e8 05 da ff ff       	call   8004e8 <_panic>

00802ae3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ae3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ae4:	a1 04 90 80 00       	mov    0x809004,%eax
	call *%eax
  802ae9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802aeb:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802aee:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802af2:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802af5:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802af9:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802afd:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802aff:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802b02:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802b03:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802b06:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802b07:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802b08:	c3                   	ret    

00802b09 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b09:	55                   	push   %ebp
  802b0a:	89 e5                	mov    %esp,%ebp
  802b0c:	56                   	push   %esi
  802b0d:	53                   	push   %ebx
  802b0e:	8b 75 08             	mov    0x8(%ebp),%esi
  802b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802b17:	85 c0                	test   %eax,%eax
  802b19:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802b1e:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802b21:	83 ec 0c             	sub    $0xc,%esp
  802b24:	50                   	push   %eax
  802b25:	e8 1f e6 ff ff       	call   801149 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802b2a:	83 c4 10             	add    $0x10,%esp
  802b2d:	85 f6                	test   %esi,%esi
  802b2f:	74 17                	je     802b48 <ipc_recv+0x3f>
  802b31:	ba 00 00 00 00       	mov    $0x0,%edx
  802b36:	85 c0                	test   %eax,%eax
  802b38:	78 0c                	js     802b46 <ipc_recv+0x3d>
  802b3a:	8b 15 00 50 80 00    	mov    0x805000,%edx
  802b40:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802b46:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802b48:	85 db                	test   %ebx,%ebx
  802b4a:	74 17                	je     802b63 <ipc_recv+0x5a>
  802b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  802b51:	85 c0                	test   %eax,%eax
  802b53:	78 0c                	js     802b61 <ipc_recv+0x58>
  802b55:	8b 15 00 50 80 00    	mov    0x805000,%edx
  802b5b:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802b61:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802b63:	85 c0                	test   %eax,%eax
  802b65:	78 0b                	js     802b72 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802b67:	a1 00 50 80 00       	mov    0x805000,%eax
  802b6c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802b72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802b75:	5b                   	pop    %ebx
  802b76:	5e                   	pop    %esi
  802b77:	5d                   	pop    %ebp
  802b78:	c3                   	ret    

00802b79 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802b79:	55                   	push   %ebp
  802b7a:	89 e5                	mov    %esp,%ebp
  802b7c:	57                   	push   %edi
  802b7d:	56                   	push   %esi
  802b7e:	53                   	push   %ebx
  802b7f:	83 ec 0c             	sub    $0xc,%esp
  802b82:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  802b88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802b8b:	85 db                	test   %ebx,%ebx
  802b8d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802b92:	0f 44 d8             	cmove  %eax,%ebx
  802b95:	eb 05                	jmp    802b9c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802b97:	e8 de e3 ff ff       	call   800f7a <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802b9c:	ff 75 14             	push   0x14(%ebp)
  802b9f:	53                   	push   %ebx
  802ba0:	56                   	push   %esi
  802ba1:	57                   	push   %edi
  802ba2:	e8 7f e5 ff ff       	call   801126 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802ba7:	83 c4 10             	add    $0x10,%esp
  802baa:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802bad:	74 e8                	je     802b97 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802baf:	85 c0                	test   %eax,%eax
  802bb1:	78 08                	js     802bbb <ipc_send+0x42>
	}while (r<0);

}
  802bb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bb6:	5b                   	pop    %ebx
  802bb7:	5e                   	pop    %esi
  802bb8:	5f                   	pop    %edi
  802bb9:	5d                   	pop    %ebp
  802bba:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802bbb:	50                   	push   %eax
  802bbc:	68 60 36 80 00       	push   $0x803660
  802bc1:	6a 3d                	push   $0x3d
  802bc3:	68 74 36 80 00       	push   $0x803674
  802bc8:	e8 1b d9 ff ff       	call   8004e8 <_panic>

00802bcd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802bcd:	55                   	push   %ebp
  802bce:	89 e5                	mov    %esp,%ebp
  802bd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802bd3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802bd8:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802bde:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802be4:	8b 52 60             	mov    0x60(%edx),%edx
  802be7:	39 ca                	cmp    %ecx,%edx
  802be9:	74 11                	je     802bfc <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802beb:	83 c0 01             	add    $0x1,%eax
  802bee:	3d 00 04 00 00       	cmp    $0x400,%eax
  802bf3:	75 e3                	jne    802bd8 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  802bfa:	eb 0e                	jmp    802c0a <ipc_find_env+0x3d>
			return envs[i].env_id;
  802bfc:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802c02:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802c07:	8b 40 58             	mov    0x58(%eax),%eax
}
  802c0a:	5d                   	pop    %ebp
  802c0b:	c3                   	ret    

00802c0c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802c0c:	55                   	push   %ebp
  802c0d:	89 e5                	mov    %esp,%ebp
  802c0f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802c12:	89 c2                	mov    %eax,%edx
  802c14:	c1 ea 16             	shr    $0x16,%edx
  802c17:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802c1e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802c23:	f6 c1 01             	test   $0x1,%cl
  802c26:	74 1c                	je     802c44 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802c28:	c1 e8 0c             	shr    $0xc,%eax
  802c2b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802c32:	a8 01                	test   $0x1,%al
  802c34:	74 0e                	je     802c44 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802c36:	c1 e8 0c             	shr    $0xc,%eax
  802c39:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802c40:	ef 
  802c41:	0f b7 d2             	movzwl %dx,%edx
}
  802c44:	89 d0                	mov    %edx,%eax
  802c46:	5d                   	pop    %ebp
  802c47:	c3                   	ret    
  802c48:	66 90                	xchg   %ax,%ax
  802c4a:	66 90                	xchg   %ax,%ax
  802c4c:	66 90                	xchg   %ax,%ax
  802c4e:	66 90                	xchg   %ax,%ax

00802c50 <__udivdi3>:
  802c50:	f3 0f 1e fb          	endbr32 
  802c54:	55                   	push   %ebp
  802c55:	57                   	push   %edi
  802c56:	56                   	push   %esi
  802c57:	53                   	push   %ebx
  802c58:	83 ec 1c             	sub    $0x1c,%esp
  802c5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802c5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802c63:	8b 74 24 34          	mov    0x34(%esp),%esi
  802c67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802c6b:	85 c0                	test   %eax,%eax
  802c6d:	75 19                	jne    802c88 <__udivdi3+0x38>
  802c6f:	39 f3                	cmp    %esi,%ebx
  802c71:	76 4d                	jbe    802cc0 <__udivdi3+0x70>
  802c73:	31 ff                	xor    %edi,%edi
  802c75:	89 e8                	mov    %ebp,%eax
  802c77:	89 f2                	mov    %esi,%edx
  802c79:	f7 f3                	div    %ebx
  802c7b:	89 fa                	mov    %edi,%edx
  802c7d:	83 c4 1c             	add    $0x1c,%esp
  802c80:	5b                   	pop    %ebx
  802c81:	5e                   	pop    %esi
  802c82:	5f                   	pop    %edi
  802c83:	5d                   	pop    %ebp
  802c84:	c3                   	ret    
  802c85:	8d 76 00             	lea    0x0(%esi),%esi
  802c88:	39 f0                	cmp    %esi,%eax
  802c8a:	76 14                	jbe    802ca0 <__udivdi3+0x50>
  802c8c:	31 ff                	xor    %edi,%edi
  802c8e:	31 c0                	xor    %eax,%eax
  802c90:	89 fa                	mov    %edi,%edx
  802c92:	83 c4 1c             	add    $0x1c,%esp
  802c95:	5b                   	pop    %ebx
  802c96:	5e                   	pop    %esi
  802c97:	5f                   	pop    %edi
  802c98:	5d                   	pop    %ebp
  802c99:	c3                   	ret    
  802c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ca0:	0f bd f8             	bsr    %eax,%edi
  802ca3:	83 f7 1f             	xor    $0x1f,%edi
  802ca6:	75 48                	jne    802cf0 <__udivdi3+0xa0>
  802ca8:	39 f0                	cmp    %esi,%eax
  802caa:	72 06                	jb     802cb2 <__udivdi3+0x62>
  802cac:	31 c0                	xor    %eax,%eax
  802cae:	39 eb                	cmp    %ebp,%ebx
  802cb0:	77 de                	ja     802c90 <__udivdi3+0x40>
  802cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  802cb7:	eb d7                	jmp    802c90 <__udivdi3+0x40>
  802cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cc0:	89 d9                	mov    %ebx,%ecx
  802cc2:	85 db                	test   %ebx,%ebx
  802cc4:	75 0b                	jne    802cd1 <__udivdi3+0x81>
  802cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  802ccb:	31 d2                	xor    %edx,%edx
  802ccd:	f7 f3                	div    %ebx
  802ccf:	89 c1                	mov    %eax,%ecx
  802cd1:	31 d2                	xor    %edx,%edx
  802cd3:	89 f0                	mov    %esi,%eax
  802cd5:	f7 f1                	div    %ecx
  802cd7:	89 c6                	mov    %eax,%esi
  802cd9:	89 e8                	mov    %ebp,%eax
  802cdb:	89 f7                	mov    %esi,%edi
  802cdd:	f7 f1                	div    %ecx
  802cdf:	89 fa                	mov    %edi,%edx
  802ce1:	83 c4 1c             	add    $0x1c,%esp
  802ce4:	5b                   	pop    %ebx
  802ce5:	5e                   	pop    %esi
  802ce6:	5f                   	pop    %edi
  802ce7:	5d                   	pop    %ebp
  802ce8:	c3                   	ret    
  802ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cf0:	89 f9                	mov    %edi,%ecx
  802cf2:	ba 20 00 00 00       	mov    $0x20,%edx
  802cf7:	29 fa                	sub    %edi,%edx
  802cf9:	d3 e0                	shl    %cl,%eax
  802cfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  802cff:	89 d1                	mov    %edx,%ecx
  802d01:	89 d8                	mov    %ebx,%eax
  802d03:	d3 e8                	shr    %cl,%eax
  802d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802d09:	09 c1                	or     %eax,%ecx
  802d0b:	89 f0                	mov    %esi,%eax
  802d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d11:	89 f9                	mov    %edi,%ecx
  802d13:	d3 e3                	shl    %cl,%ebx
  802d15:	89 d1                	mov    %edx,%ecx
  802d17:	d3 e8                	shr    %cl,%eax
  802d19:	89 f9                	mov    %edi,%ecx
  802d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802d1f:	89 eb                	mov    %ebp,%ebx
  802d21:	d3 e6                	shl    %cl,%esi
  802d23:	89 d1                	mov    %edx,%ecx
  802d25:	d3 eb                	shr    %cl,%ebx
  802d27:	09 f3                	or     %esi,%ebx
  802d29:	89 c6                	mov    %eax,%esi
  802d2b:	89 f2                	mov    %esi,%edx
  802d2d:	89 d8                	mov    %ebx,%eax
  802d2f:	f7 74 24 08          	divl   0x8(%esp)
  802d33:	89 d6                	mov    %edx,%esi
  802d35:	89 c3                	mov    %eax,%ebx
  802d37:	f7 64 24 0c          	mull   0xc(%esp)
  802d3b:	39 d6                	cmp    %edx,%esi
  802d3d:	72 19                	jb     802d58 <__udivdi3+0x108>
  802d3f:	89 f9                	mov    %edi,%ecx
  802d41:	d3 e5                	shl    %cl,%ebp
  802d43:	39 c5                	cmp    %eax,%ebp
  802d45:	73 04                	jae    802d4b <__udivdi3+0xfb>
  802d47:	39 d6                	cmp    %edx,%esi
  802d49:	74 0d                	je     802d58 <__udivdi3+0x108>
  802d4b:	89 d8                	mov    %ebx,%eax
  802d4d:	31 ff                	xor    %edi,%edi
  802d4f:	e9 3c ff ff ff       	jmp    802c90 <__udivdi3+0x40>
  802d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802d58:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802d5b:	31 ff                	xor    %edi,%edi
  802d5d:	e9 2e ff ff ff       	jmp    802c90 <__udivdi3+0x40>
  802d62:	66 90                	xchg   %ax,%ax
  802d64:	66 90                	xchg   %ax,%ax
  802d66:	66 90                	xchg   %ax,%ax
  802d68:	66 90                	xchg   %ax,%ax
  802d6a:	66 90                	xchg   %ax,%ax
  802d6c:	66 90                	xchg   %ax,%ax
  802d6e:	66 90                	xchg   %ax,%ax

00802d70 <__umoddi3>:
  802d70:	f3 0f 1e fb          	endbr32 
  802d74:	55                   	push   %ebp
  802d75:	57                   	push   %edi
  802d76:	56                   	push   %esi
  802d77:	53                   	push   %ebx
  802d78:	83 ec 1c             	sub    $0x1c,%esp
  802d7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  802d7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802d83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802d87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  802d8b:	89 f0                	mov    %esi,%eax
  802d8d:	89 da                	mov    %ebx,%edx
  802d8f:	85 ff                	test   %edi,%edi
  802d91:	75 15                	jne    802da8 <__umoddi3+0x38>
  802d93:	39 dd                	cmp    %ebx,%ebp
  802d95:	76 39                	jbe    802dd0 <__umoddi3+0x60>
  802d97:	f7 f5                	div    %ebp
  802d99:	89 d0                	mov    %edx,%eax
  802d9b:	31 d2                	xor    %edx,%edx
  802d9d:	83 c4 1c             	add    $0x1c,%esp
  802da0:	5b                   	pop    %ebx
  802da1:	5e                   	pop    %esi
  802da2:	5f                   	pop    %edi
  802da3:	5d                   	pop    %ebp
  802da4:	c3                   	ret    
  802da5:	8d 76 00             	lea    0x0(%esi),%esi
  802da8:	39 df                	cmp    %ebx,%edi
  802daa:	77 f1                	ja     802d9d <__umoddi3+0x2d>
  802dac:	0f bd cf             	bsr    %edi,%ecx
  802daf:	83 f1 1f             	xor    $0x1f,%ecx
  802db2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802db6:	75 40                	jne    802df8 <__umoddi3+0x88>
  802db8:	39 df                	cmp    %ebx,%edi
  802dba:	72 04                	jb     802dc0 <__umoddi3+0x50>
  802dbc:	39 f5                	cmp    %esi,%ebp
  802dbe:	77 dd                	ja     802d9d <__umoddi3+0x2d>
  802dc0:	89 da                	mov    %ebx,%edx
  802dc2:	89 f0                	mov    %esi,%eax
  802dc4:	29 e8                	sub    %ebp,%eax
  802dc6:	19 fa                	sbb    %edi,%edx
  802dc8:	eb d3                	jmp    802d9d <__umoddi3+0x2d>
  802dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802dd0:	89 e9                	mov    %ebp,%ecx
  802dd2:	85 ed                	test   %ebp,%ebp
  802dd4:	75 0b                	jne    802de1 <__umoddi3+0x71>
  802dd6:	b8 01 00 00 00       	mov    $0x1,%eax
  802ddb:	31 d2                	xor    %edx,%edx
  802ddd:	f7 f5                	div    %ebp
  802ddf:	89 c1                	mov    %eax,%ecx
  802de1:	89 d8                	mov    %ebx,%eax
  802de3:	31 d2                	xor    %edx,%edx
  802de5:	f7 f1                	div    %ecx
  802de7:	89 f0                	mov    %esi,%eax
  802de9:	f7 f1                	div    %ecx
  802deb:	89 d0                	mov    %edx,%eax
  802ded:	31 d2                	xor    %edx,%edx
  802def:	eb ac                	jmp    802d9d <__umoddi3+0x2d>
  802df1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802df8:	8b 44 24 04          	mov    0x4(%esp),%eax
  802dfc:	ba 20 00 00 00       	mov    $0x20,%edx
  802e01:	29 c2                	sub    %eax,%edx
  802e03:	89 c1                	mov    %eax,%ecx
  802e05:	89 e8                	mov    %ebp,%eax
  802e07:	d3 e7                	shl    %cl,%edi
  802e09:	89 d1                	mov    %edx,%ecx
  802e0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802e0f:	d3 e8                	shr    %cl,%eax
  802e11:	89 c1                	mov    %eax,%ecx
  802e13:	8b 44 24 04          	mov    0x4(%esp),%eax
  802e17:	09 f9                	or     %edi,%ecx
  802e19:	89 df                	mov    %ebx,%edi
  802e1b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802e1f:	89 c1                	mov    %eax,%ecx
  802e21:	d3 e5                	shl    %cl,%ebp
  802e23:	89 d1                	mov    %edx,%ecx
  802e25:	d3 ef                	shr    %cl,%edi
  802e27:	89 c1                	mov    %eax,%ecx
  802e29:	89 f0                	mov    %esi,%eax
  802e2b:	d3 e3                	shl    %cl,%ebx
  802e2d:	89 d1                	mov    %edx,%ecx
  802e2f:	89 fa                	mov    %edi,%edx
  802e31:	d3 e8                	shr    %cl,%eax
  802e33:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802e38:	09 d8                	or     %ebx,%eax
  802e3a:	f7 74 24 08          	divl   0x8(%esp)
  802e3e:	89 d3                	mov    %edx,%ebx
  802e40:	d3 e6                	shl    %cl,%esi
  802e42:	f7 e5                	mul    %ebp
  802e44:	89 c7                	mov    %eax,%edi
  802e46:	89 d1                	mov    %edx,%ecx
  802e48:	39 d3                	cmp    %edx,%ebx
  802e4a:	72 06                	jb     802e52 <__umoddi3+0xe2>
  802e4c:	75 0e                	jne    802e5c <__umoddi3+0xec>
  802e4e:	39 c6                	cmp    %eax,%esi
  802e50:	73 0a                	jae    802e5c <__umoddi3+0xec>
  802e52:	29 e8                	sub    %ebp,%eax
  802e54:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802e58:	89 d1                	mov    %edx,%ecx
  802e5a:	89 c7                	mov    %eax,%edi
  802e5c:	89 f5                	mov    %esi,%ebp
  802e5e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802e62:	29 fd                	sub    %edi,%ebp
  802e64:	19 cb                	sbb    %ecx,%ebx
  802e66:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802e6b:	89 d8                	mov    %ebx,%eax
  802e6d:	d3 e0                	shl    %cl,%eax
  802e6f:	89 f1                	mov    %esi,%ecx
  802e71:	d3 ed                	shr    %cl,%ebp
  802e73:	d3 eb                	shr    %cl,%ebx
  802e75:	09 e8                	or     %ebp,%eax
  802e77:	89 da                	mov    %ebx,%edx
  802e79:	83 c4 1c             	add    $0x1c,%esp
  802e7c:	5b                   	pop    %ebx
  802e7d:	5e                   	pop    %esi
  802e7e:	5f                   	pop    %edi
  802e7f:	5d                   	pop    %ebp
  802e80:	c3                   	ret    
