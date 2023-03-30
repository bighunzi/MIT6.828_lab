
obj/user/ls.debug：     文件格式 elf32-i386


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
  80002c:	e8 95 02 00 00       	call   8002c6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	push   0x10(%ebp)
  80005a:	68 22 27 80 00       	push   $0x802722
  80005f:	e8 f9 19 00 00       	call   801a5d <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 1c                	je     800087 <ls1+0x54>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 88 27 80 00       	mov    $0x802788,%eax
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	75 4b                	jne    8000c0 <ls1+0x8d>
		printf("%s%s", prefix, sep);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	50                   	push   %eax
  800079:	53                   	push   %ebx
  80007a:	68 2b 27 80 00       	push   $0x80272b
  80007f:	e8 d9 19 00 00       	call   801a5d <printf>
  800084:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	ff 75 14             	push   0x14(%ebp)
  80008d:	68 b5 2b 80 00       	push   $0x802bb5
  800092:	e8 c6 19 00 00       	call   801a5d <printf>
	if(flag['F'] && isdir)
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	83 3d 18 41 80 00 00 	cmpl   $0x0,0x804118
  8000a1:	74 06                	je     8000a9 <ls1+0x76>
  8000a3:	89 f0                	mov    %esi,%eax
  8000a5:	84 c0                	test   %al,%al
  8000a7:	75 37                	jne    8000e0 <ls1+0xad>
		printf("/");
	printf("\n");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 87 27 80 00       	push   $0x802787
  8000b1:	e8 a7 19 00 00       	call   801a5d <printf>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	53                   	push   %ebx
  8000c4:	e8 d7 08 00 00       	call   8009a0 <strlen>
  8000c9:	83 c4 10             	add    $0x10,%esp
			sep = "";
  8000cc:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  8000d1:	b8 20 27 80 00       	mov    $0x802720,%eax
  8000d6:	ba 88 27 80 00       	mov    $0x802788,%edx
  8000db:	0f 44 c2             	cmove  %edx,%eax
  8000de:	eb 95                	jmp    800075 <ls1+0x42>
		printf("/");
  8000e0:	83 ec 0c             	sub    $0xc,%esp
  8000e3:	68 20 27 80 00       	push   $0x802720
  8000e8:	e8 70 19 00 00       	call   801a5d <printf>
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	eb b7                	jmp    8000a9 <ls1+0x76>

008000f2 <lsdir>:
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000fe:	8b 7d 08             	mov    0x8(%ebp),%edi
	if ((fd = open(path, O_RDONLY)) < 0)
  800101:	6a 00                	push   $0x0
  800103:	57                   	push   %edi
  800104:	e8 b2 17 00 00       	call   8018bb <open>
  800109:	89 c3                	mov    %eax,%ebx
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	85 c0                	test   %eax,%eax
  800110:	78 4a                	js     80015c <lsdir+0x6a>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  800112:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800118:	83 ec 04             	sub    $0x4,%esp
  80011b:	68 00 01 00 00       	push   $0x100
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
  800122:	e8 b8 13 00 00       	call   8014df <readn>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	3d 00 01 00 00       	cmp    $0x100,%eax
  80012f:	75 41                	jne    800172 <lsdir+0x80>
		if (f.f_name[0])
  800131:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800138:	74 de                	je     800118 <lsdir+0x26>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80013a:	56                   	push   %esi
  80013b:	ff b5 68 ff ff ff    	push   -0x98(%ebp)
  800141:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  800148:	0f 94 c0             	sete   %al
  80014b:	0f b6 c0             	movzbl %al,%eax
  80014e:	50                   	push   %eax
  80014f:	ff 75 0c             	push   0xc(%ebp)
  800152:	e8 dc fe ff ff       	call   800033 <ls1>
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb bc                	jmp    800118 <lsdir+0x26>
		panic("open %s: %e", path, fd);
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	50                   	push   %eax
  800160:	57                   	push   %edi
  800161:	68 30 27 80 00       	push   $0x802730
  800166:	6a 1d                	push   $0x1d
  800168:	68 3c 27 80 00       	push   $0x80273c
  80016d:	e8 b4 01 00 00       	call   800326 <_panic>
	if (n > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7f 0a                	jg     800180 <lsdir+0x8e>
	if (n < 0)
  800176:	78 1a                	js     800192 <lsdir+0xa0>
}
  800178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    
		panic("short read in directory %s", path);
  800180:	57                   	push   %edi
  800181:	68 46 27 80 00       	push   $0x802746
  800186:	6a 22                	push   $0x22
  800188:	68 3c 27 80 00       	push   $0x80273c
  80018d:	e8 94 01 00 00       	call   800326 <_panic>
		panic("error reading directory %s: %e", path, n);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	57                   	push   %edi
  800197:	68 8c 27 80 00       	push   $0x80278c
  80019c:	6a 24                	push   $0x24
  80019e:	68 3c 27 80 00       	push   $0x80273c
  8001a3:	e8 7e 01 00 00       	call   800326 <_panic>

008001a8 <ls>:
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = stat(path, &st)) < 0)
  8001b5:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001bb:	50                   	push   %eax
  8001bc:	53                   	push   %ebx
  8001bd:	e8 03 15 00 00       	call   8016c5 <stat>
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	78 2c                	js     8001f5 <ls+0x4d>
	if (st.st_isdir && !flag['d'])
  8001c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	74 09                	je     8001d9 <ls+0x31>
  8001d0:	83 3d 90 41 80 00 00 	cmpl   $0x0,0x804190
  8001d7:	74 32                	je     80020b <ls+0x63>
		ls1(0, st.st_isdir, st.st_size, path);
  8001d9:	53                   	push   %ebx
  8001da:	ff 75 ec             	push   -0x14(%ebp)
  8001dd:	85 c0                	test   %eax,%eax
  8001df:	0f 95 c0             	setne  %al
  8001e2:	0f b6 c0             	movzbl %al,%eax
  8001e5:	50                   	push   %eax
  8001e6:	6a 00                	push   $0x0
  8001e8:	e8 46 fe ff ff       	call   800033 <ls1>
  8001ed:	83 c4 10             	add    $0x10,%esp
}
  8001f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f3:	c9                   	leave  
  8001f4:	c3                   	ret    
		panic("stat %s: %e", path, r);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	53                   	push   %ebx
  8001fa:	68 61 27 80 00       	push   $0x802761
  8001ff:	6a 0f                	push   $0xf
  800201:	68 3c 27 80 00       	push   $0x80273c
  800206:	e8 1b 01 00 00       	call   800326 <_panic>
		lsdir(path, prefix);
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	ff 75 0c             	push   0xc(%ebp)
  800211:	53                   	push   %ebx
  800212:	e8 db fe ff ff       	call   8000f2 <lsdir>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb d4                	jmp    8001f0 <ls+0x48>

0080021c <usage>:

void
usage(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800222:	68 6d 27 80 00       	push   $0x80276d
  800227:	e8 31 18 00 00       	call   801a5d <printf>
	exit();
  80022c:	e8 db 00 00 00       	call   80030c <exit>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <umain>:

void
umain(int argc, char **argv)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
  80023b:	83 ec 14             	sub    $0x14,%esp
  80023e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800241:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800244:	50                   	push   %eax
  800245:	56                   	push   %esi
  800246:	8d 45 08             	lea    0x8(%ebp),%eax
  800249:	50                   	push   %eax
  80024a:	e8 da 0d 00 00       	call   801029 <argstart>
	while ((i = argnext(&args)) >= 0)
  80024f:	83 c4 10             	add    $0x10,%esp
  800252:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800255:	eb 08                	jmp    80025f <umain+0x29>
		switch (i) {
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800257:	83 04 85 00 40 80 00 	addl   $0x1,0x804000(,%eax,4)
  80025e:	01 
	while ((i = argnext(&args)) >= 0)
  80025f:	83 ec 0c             	sub    $0xc,%esp
  800262:	53                   	push   %ebx
  800263:	e8 f1 0d 00 00       	call   801059 <argnext>
  800268:	83 c4 10             	add    $0x10,%esp
  80026b:	85 c0                	test   %eax,%eax
  80026d:	78 16                	js     800285 <umain+0x4f>
		switch (i) {
  80026f:	89 c2                	mov    %eax,%edx
  800271:	83 e2 f7             	and    $0xfffffff7,%edx
  800274:	83 fa 64             	cmp    $0x64,%edx
  800277:	74 de                	je     800257 <umain+0x21>
  800279:	83 f8 46             	cmp    $0x46,%eax
  80027c:	74 d9                	je     800257 <umain+0x21>
			break;
		default:
			usage();
  80027e:	e8 99 ff ff ff       	call   80021c <usage>
  800283:	eb da                	jmp    80025f <umain+0x29>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800285:	bb 01 00 00 00       	mov    $0x1,%ebx
	if (argc == 1)
  80028a:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028e:	75 2a                	jne    8002ba <umain+0x84>
		ls("/", "");
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	68 88 27 80 00       	push   $0x802788
  800298:	68 20 27 80 00       	push   $0x802720
  80029d:	e8 06 ff ff ff       	call   8001a8 <ls>
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	eb 18                	jmp    8002bf <umain+0x89>
			ls(argv[i], argv[i]);
  8002a7:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	50                   	push   %eax
  8002ae:	50                   	push   %eax
  8002af:	e8 f4 fe ff ff       	call   8001a8 <ls>
		for (i = 1; i < argc; i++)
  8002b4:	83 c3 01             	add    $0x1,%ebx
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  8002bd:	7f e8                	jg     8002a7 <umain+0x71>
	}
}
  8002bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5e                   	pop    %esi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8002d1:	e8 c3 0a 00 00       	call   800d99 <sys_getenvid>
  8002d6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002db:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002de:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e3:	a3 00 44 80 00       	mov    %eax,0x804400

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e8:	85 db                	test   %ebx,%ebx
  8002ea:	7e 07                	jle    8002f3 <libmain+0x2d>
		binaryname = argv[0];
  8002ec:	8b 06                	mov    (%esi),%eax
  8002ee:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	e8 39 ff ff ff       	call   800236 <umain>

	// exit gracefully
	exit();
  8002fd:	e8 0a 00 00 00       	call   80030c <exit>
}
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800312:	e8 32 10 00 00       	call   801349 <close_all>
	sys_env_destroy(0);
  800317:	83 ec 0c             	sub    $0xc,%esp
  80031a:	6a 00                	push   $0x0
  80031c:	e8 37 0a 00 00       	call   800d58 <sys_env_destroy>
}
  800321:	83 c4 10             	add    $0x10,%esp
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800334:	e8 60 0a 00 00       	call   800d99 <sys_getenvid>
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	ff 75 0c             	push   0xc(%ebp)
  80033f:	ff 75 08             	push   0x8(%ebp)
  800342:	56                   	push   %esi
  800343:	50                   	push   %eax
  800344:	68 b8 27 80 00       	push   $0x8027b8
  800349:	e8 b3 00 00 00       	call   800401 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034e:	83 c4 18             	add    $0x18,%esp
  800351:	53                   	push   %ebx
  800352:	ff 75 10             	push   0x10(%ebp)
  800355:	e8 56 00 00 00       	call   8003b0 <vcprintf>
	cprintf("\n");
  80035a:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  800361:	e8 9b 00 00 00       	call   800401 <cprintf>
  800366:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800369:	cc                   	int3   
  80036a:	eb fd                	jmp    800369 <_panic+0x43>

0080036c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	53                   	push   %ebx
  800370:	83 ec 04             	sub    $0x4,%esp
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800376:	8b 13                	mov    (%ebx),%edx
  800378:	8d 42 01             	lea    0x1(%edx),%eax
  80037b:	89 03                	mov    %eax,(%ebx)
  80037d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800380:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800384:	3d ff 00 00 00       	cmp    $0xff,%eax
  800389:	74 09                	je     800394 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80038b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80038f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800392:	c9                   	leave  
  800393:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800394:	83 ec 08             	sub    $0x8,%esp
  800397:	68 ff 00 00 00       	push   $0xff
  80039c:	8d 43 08             	lea    0x8(%ebx),%eax
  80039f:	50                   	push   %eax
  8003a0:	e8 76 09 00 00       	call   800d1b <sys_cputs>
		b->idx = 0;
  8003a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ab:	83 c4 10             	add    $0x10,%esp
  8003ae:	eb db                	jmp    80038b <putch+0x1f>

008003b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c0:	00 00 00 
	b.cnt = 0;
  8003c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cd:	ff 75 0c             	push   0xc(%ebp)
  8003d0:	ff 75 08             	push   0x8(%ebp)
  8003d3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d9:	50                   	push   %eax
  8003da:	68 6c 03 80 00       	push   $0x80036c
  8003df:	e8 14 01 00 00       	call   8004f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e4:	83 c4 08             	add    $0x8,%esp
  8003e7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003ed:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f3:	50                   	push   %eax
  8003f4:	e8 22 09 00 00       	call   800d1b <sys_cputs>

	return b.cnt;
}
  8003f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800407:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040a:	50                   	push   %eax
  80040b:	ff 75 08             	push   0x8(%ebp)
  80040e:	e8 9d ff ff ff       	call   8003b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800413:	c9                   	leave  
  800414:	c3                   	ret    

00800415 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	57                   	push   %edi
  800419:	56                   	push   %esi
  80041a:	53                   	push   %ebx
  80041b:	83 ec 1c             	sub    $0x1c,%esp
  80041e:	89 c7                	mov    %eax,%edi
  800420:	89 d6                	mov    %edx,%esi
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 d1                	mov    %edx,%ecx
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800432:	8b 45 10             	mov    0x10(%ebp),%eax
  800435:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800442:	39 c2                	cmp    %eax,%edx
  800444:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800447:	72 3e                	jb     800487 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800449:	83 ec 0c             	sub    $0xc,%esp
  80044c:	ff 75 18             	push   0x18(%ebp)
  80044f:	83 eb 01             	sub    $0x1,%ebx
  800452:	53                   	push   %ebx
  800453:	50                   	push   %eax
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	ff 75 e4             	push   -0x1c(%ebp)
  80045a:	ff 75 e0             	push   -0x20(%ebp)
  80045d:	ff 75 dc             	push   -0x24(%ebp)
  800460:	ff 75 d8             	push   -0x28(%ebp)
  800463:	e8 68 20 00 00       	call   8024d0 <__udivdi3>
  800468:	83 c4 18             	add    $0x18,%esp
  80046b:	52                   	push   %edx
  80046c:	50                   	push   %eax
  80046d:	89 f2                	mov    %esi,%edx
  80046f:	89 f8                	mov    %edi,%eax
  800471:	e8 9f ff ff ff       	call   800415 <printnum>
  800476:	83 c4 20             	add    $0x20,%esp
  800479:	eb 13                	jmp    80048e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	56                   	push   %esi
  80047f:	ff 75 18             	push   0x18(%ebp)
  800482:	ff d7                	call   *%edi
  800484:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800487:	83 eb 01             	sub    $0x1,%ebx
  80048a:	85 db                	test   %ebx,%ebx
  80048c:	7f ed                	jg     80047b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048e:	83 ec 08             	sub    $0x8,%esp
  800491:	56                   	push   %esi
  800492:	83 ec 04             	sub    $0x4,%esp
  800495:	ff 75 e4             	push   -0x1c(%ebp)
  800498:	ff 75 e0             	push   -0x20(%ebp)
  80049b:	ff 75 dc             	push   -0x24(%ebp)
  80049e:	ff 75 d8             	push   -0x28(%ebp)
  8004a1:	e8 4a 21 00 00       	call   8025f0 <__umoddi3>
  8004a6:	83 c4 14             	add    $0x14,%esp
  8004a9:	0f be 80 db 27 80 00 	movsbl 0x8027db(%eax),%eax
  8004b0:	50                   	push   %eax
  8004b1:	ff d7                	call   *%edi
}
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    

008004be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c8:	8b 10                	mov    (%eax),%edx
  8004ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8004cd:	73 0a                	jae    8004d9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d2:	89 08                	mov    %ecx,(%eax)
  8004d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d7:	88 02                	mov    %al,(%edx)
}
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <printfmt>:
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e4:	50                   	push   %eax
  8004e5:	ff 75 10             	push   0x10(%ebp)
  8004e8:	ff 75 0c             	push   0xc(%ebp)
  8004eb:	ff 75 08             	push   0x8(%ebp)
  8004ee:	e8 05 00 00 00       	call   8004f8 <vprintfmt>
}
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	c9                   	leave  
  8004f7:	c3                   	ret    

008004f8 <vprintfmt>:
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	57                   	push   %edi
  8004fc:	56                   	push   %esi
  8004fd:	53                   	push   %ebx
  8004fe:	83 ec 3c             	sub    $0x3c,%esp
  800501:	8b 75 08             	mov    0x8(%ebp),%esi
  800504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800507:	8b 7d 10             	mov    0x10(%ebp),%edi
  80050a:	eb 0a                	jmp    800516 <vprintfmt+0x1e>
			putch(ch, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	50                   	push   %eax
  800511:	ff d6                	call   *%esi
  800513:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051d:	83 f8 25             	cmp    $0x25,%eax
  800520:	74 0c                	je     80052e <vprintfmt+0x36>
			if (ch == '\0')
  800522:	85 c0                	test   %eax,%eax
  800524:	75 e6                	jne    80050c <vprintfmt+0x14>
}
  800526:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800529:	5b                   	pop    %ebx
  80052a:	5e                   	pop    %esi
  80052b:	5f                   	pop    %edi
  80052c:	5d                   	pop    %ebp
  80052d:	c3                   	ret    
		padc = ' ';
  80052e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800532:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800539:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800540:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800547:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80054c:	8d 47 01             	lea    0x1(%edi),%eax
  80054f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800552:	0f b6 17             	movzbl (%edi),%edx
  800555:	8d 42 dd             	lea    -0x23(%edx),%eax
  800558:	3c 55                	cmp    $0x55,%al
  80055a:	0f 87 bb 03 00 00    	ja     80091b <vprintfmt+0x423>
  800560:	0f b6 c0             	movzbl %al,%eax
  800563:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80056d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800571:	eb d9                	jmp    80054c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800576:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80057a:	eb d0                	jmp    80054c <vprintfmt+0x54>
  80057c:	0f b6 d2             	movzbl %dl,%edx
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800582:	b8 00 00 00 00       	mov    $0x0,%eax
  800587:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80058a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800591:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800594:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800597:	83 f9 09             	cmp    $0x9,%ecx
  80059a:	77 55                	ja     8005f1 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80059c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80059f:	eb e9                	jmp    80058a <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b9:	79 91                	jns    80054c <vprintfmt+0x54>
				width = precision, precision = -1;
  8005bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005c8:	eb 82                	jmp    80054c <vprintfmt+0x54>
  8005ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005cd:	85 d2                	test   %edx,%edx
  8005cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d4:	0f 49 c2             	cmovns %edx,%eax
  8005d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005dd:	e9 6a ff ff ff       	jmp    80054c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005e5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005ec:	e9 5b ff ff ff       	jmp    80054c <vprintfmt+0x54>
  8005f1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	eb bc                	jmp    8005b5 <vprintfmt+0xbd>
			lflag++;
  8005f9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ff:	e9 48 ff ff ff       	jmp    80054c <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 78 04             	lea    0x4(%eax),%edi
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	ff 30                	push   (%eax)
  800610:	ff d6                	call   *%esi
			break;
  800612:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800615:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800618:	e9 9d 02 00 00       	jmp    8008ba <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 78 04             	lea    0x4(%eax),%edi
  800623:	8b 10                	mov    (%eax),%edx
  800625:	89 d0                	mov    %edx,%eax
  800627:	f7 d8                	neg    %eax
  800629:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062c:	83 f8 0f             	cmp    $0xf,%eax
  80062f:	7f 23                	jg     800654 <vprintfmt+0x15c>
  800631:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  800638:	85 d2                	test   %edx,%edx
  80063a:	74 18                	je     800654 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80063c:	52                   	push   %edx
  80063d:	68 b5 2b 80 00       	push   $0x802bb5
  800642:	53                   	push   %ebx
  800643:	56                   	push   %esi
  800644:	e8 92 fe ff ff       	call   8004db <printfmt>
  800649:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80064c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80064f:	e9 66 02 00 00       	jmp    8008ba <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800654:	50                   	push   %eax
  800655:	68 f3 27 80 00       	push   $0x8027f3
  80065a:	53                   	push   %ebx
  80065b:	56                   	push   %esi
  80065c:	e8 7a fe ff ff       	call   8004db <printfmt>
  800661:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800664:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800667:	e9 4e 02 00 00       	jmp    8008ba <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	83 c0 04             	add    $0x4,%eax
  800672:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80067a:	85 d2                	test   %edx,%edx
  80067c:	b8 ec 27 80 00       	mov    $0x8027ec,%eax
  800681:	0f 45 c2             	cmovne %edx,%eax
  800684:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800687:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068b:	7e 06                	jle    800693 <vprintfmt+0x19b>
  80068d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800691:	75 0d                	jne    8006a0 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800693:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800696:	89 c7                	mov    %eax,%edi
  800698:	03 45 e0             	add    -0x20(%ebp),%eax
  80069b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80069e:	eb 55                	jmp    8006f5 <vprintfmt+0x1fd>
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	ff 75 d8             	push   -0x28(%ebp)
  8006a6:	ff 75 cc             	push   -0x34(%ebp)
  8006a9:	e8 0a 03 00 00       	call   8009b8 <strnlen>
  8006ae:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b1:	29 c1                	sub    %eax,%ecx
  8006b3:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006bb:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c2:	eb 0f                	jmp    8006d3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	ff 75 e0             	push   -0x20(%ebp)
  8006cb:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	83 ef 01             	sub    $0x1,%edi
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	85 ff                	test   %edi,%edi
  8006d5:	7f ed                	jg     8006c4 <vprintfmt+0x1cc>
  8006d7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006da:	85 d2                	test   %edx,%edx
  8006dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e1:	0f 49 c2             	cmovns %edx,%eax
  8006e4:	29 c2                	sub    %eax,%edx
  8006e6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006e9:	eb a8                	jmp    800693 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	52                   	push   %edx
  8006f0:	ff d6                	call   *%esi
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fa:	83 c7 01             	add    $0x1,%edi
  8006fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800701:	0f be d0             	movsbl %al,%edx
  800704:	85 d2                	test   %edx,%edx
  800706:	74 4b                	je     800753 <vprintfmt+0x25b>
  800708:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070c:	78 06                	js     800714 <vprintfmt+0x21c>
  80070e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800712:	78 1e                	js     800732 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800714:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800718:	74 d1                	je     8006eb <vprintfmt+0x1f3>
  80071a:	0f be c0             	movsbl %al,%eax
  80071d:	83 e8 20             	sub    $0x20,%eax
  800720:	83 f8 5e             	cmp    $0x5e,%eax
  800723:	76 c6                	jbe    8006eb <vprintfmt+0x1f3>
					putch('?', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	6a 3f                	push   $0x3f
  80072b:	ff d6                	call   *%esi
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb c3                	jmp    8006f5 <vprintfmt+0x1fd>
  800732:	89 cf                	mov    %ecx,%edi
  800734:	eb 0e                	jmp    800744 <vprintfmt+0x24c>
				putch(' ', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 20                	push   $0x20
  80073c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80073e:	83 ef 01             	sub    $0x1,%edi
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	85 ff                	test   %edi,%edi
  800746:	7f ee                	jg     800736 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800748:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80074b:	89 45 14             	mov    %eax,0x14(%ebp)
  80074e:	e9 67 01 00 00       	jmp    8008ba <vprintfmt+0x3c2>
  800753:	89 cf                	mov    %ecx,%edi
  800755:	eb ed                	jmp    800744 <vprintfmt+0x24c>
	if (lflag >= 2)
  800757:	83 f9 01             	cmp    $0x1,%ecx
  80075a:	7f 1b                	jg     800777 <vprintfmt+0x27f>
	else if (lflag)
  80075c:	85 c9                	test   %ecx,%ecx
  80075e:	74 63                	je     8007c3 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8b 00                	mov    (%eax),%eax
  800765:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800768:	99                   	cltd   
  800769:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
  800775:	eb 17                	jmp    80078e <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8b 50 04             	mov    0x4(%eax),%edx
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800782:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 40 08             	lea    0x8(%eax),%eax
  80078b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80078e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800791:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800794:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800799:	85 c9                	test   %ecx,%ecx
  80079b:	0f 89 ff 00 00 00    	jns    8008a0 <vprintfmt+0x3a8>
				putch('-', putdat);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	53                   	push   %ebx
  8007a5:	6a 2d                	push   $0x2d
  8007a7:	ff d6                	call   *%esi
				num = -(long long) num;
  8007a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007af:	f7 da                	neg    %edx
  8007b1:	83 d1 00             	adc    $0x0,%ecx
  8007b4:	f7 d9                	neg    %ecx
  8007b6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007b9:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007be:	e9 dd 00 00 00       	jmp    8008a0 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cb:	99                   	cltd   
  8007cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d8:	eb b4                	jmp    80078e <vprintfmt+0x296>
	if (lflag >= 2)
  8007da:	83 f9 01             	cmp    $0x1,%ecx
  8007dd:	7f 1e                	jg     8007fd <vprintfmt+0x305>
	else if (lflag)
  8007df:	85 c9                	test   %ecx,%ecx
  8007e1:	74 32                	je     800815 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8b 10                	mov    (%eax),%edx
  8007e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ed:	8d 40 04             	lea    0x4(%eax),%eax
  8007f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007f8:	e9 a3 00 00 00       	jmp    8008a0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 10                	mov    (%eax),%edx
  800802:	8b 48 04             	mov    0x4(%eax),%ecx
  800805:	8d 40 08             	lea    0x8(%eax),%eax
  800808:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800810:	e9 8b 00 00 00       	jmp    8008a0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081f:	8d 40 04             	lea    0x4(%eax),%eax
  800822:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800825:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80082a:	eb 74                	jmp    8008a0 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80082c:	83 f9 01             	cmp    $0x1,%ecx
  80082f:	7f 1b                	jg     80084c <vprintfmt+0x354>
	else if (lflag)
  800831:	85 c9                	test   %ecx,%ecx
  800833:	74 2c                	je     800861 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800845:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80084a:	eb 54                	jmp    8008a0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	8b 48 04             	mov    0x4(%eax),%ecx
  800854:	8d 40 08             	lea    0x8(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80085a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80085f:	eb 3f                	jmp    8008a0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086b:	8d 40 04             	lea    0x4(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800871:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800876:	eb 28                	jmp    8008a0 <vprintfmt+0x3a8>
			putch('0', putdat);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	6a 30                	push   $0x30
  80087e:	ff d6                	call   *%esi
			putch('x', putdat);
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	6a 78                	push   $0x78
  800886:	ff d6                	call   *%esi
			num = (unsigned long long)
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8b 10                	mov    (%eax),%edx
  80088d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800892:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800895:	8d 40 04             	lea    0x4(%eax),%eax
  800898:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089b:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8008a0:	83 ec 0c             	sub    $0xc,%esp
  8008a3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008a7:	50                   	push   %eax
  8008a8:	ff 75 e0             	push   -0x20(%ebp)
  8008ab:	57                   	push   %edi
  8008ac:	51                   	push   %ecx
  8008ad:	52                   	push   %edx
  8008ae:	89 da                	mov    %ebx,%edx
  8008b0:	89 f0                	mov    %esi,%eax
  8008b2:	e8 5e fb ff ff       	call   800415 <printnum>
			break;
  8008b7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008bd:	e9 54 fc ff ff       	jmp    800516 <vprintfmt+0x1e>
	if (lflag >= 2)
  8008c2:	83 f9 01             	cmp    $0x1,%ecx
  8008c5:	7f 1b                	jg     8008e2 <vprintfmt+0x3ea>
	else if (lflag)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 2c                	je     8008f7 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 10                	mov    (%eax),%edx
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d5:	8d 40 04             	lea    0x4(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008db:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008e0:	eb be                	jmp    8008a0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ea:	8d 40 08             	lea    0x8(%eax),%eax
  8008ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008f5:	eb a9                	jmp    8008a0 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8b 10                	mov    (%eax),%edx
  8008fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800901:	8d 40 04             	lea    0x4(%eax),%eax
  800904:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800907:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80090c:	eb 92                	jmp    8008a0 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	6a 25                	push   $0x25
  800914:	ff d6                	call   *%esi
			break;
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb 9f                	jmp    8008ba <vprintfmt+0x3c2>
			putch('%', putdat);
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	53                   	push   %ebx
  80091f:	6a 25                	push   $0x25
  800921:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	89 f8                	mov    %edi,%eax
  800928:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80092c:	74 05                	je     800933 <vprintfmt+0x43b>
  80092e:	83 e8 01             	sub    $0x1,%eax
  800931:	eb f5                	jmp    800928 <vprintfmt+0x430>
  800933:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800936:	eb 82                	jmp    8008ba <vprintfmt+0x3c2>

00800938 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	83 ec 18             	sub    $0x18,%esp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800944:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800947:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80094e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800955:	85 c0                	test   %eax,%eax
  800957:	74 26                	je     80097f <vsnprintf+0x47>
  800959:	85 d2                	test   %edx,%edx
  80095b:	7e 22                	jle    80097f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095d:	ff 75 14             	push   0x14(%ebp)
  800960:	ff 75 10             	push   0x10(%ebp)
  800963:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800966:	50                   	push   %eax
  800967:	68 be 04 80 00       	push   $0x8004be
  80096c:	e8 87 fb ff ff       	call   8004f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800971:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800974:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800977:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097a:	83 c4 10             	add    $0x10,%esp
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    
		return -E_INVAL;
  80097f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800984:	eb f7                	jmp    80097d <vsnprintf+0x45>

00800986 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098f:	50                   	push   %eax
  800990:	ff 75 10             	push   0x10(%ebp)
  800993:	ff 75 0c             	push   0xc(%ebp)
  800996:	ff 75 08             	push   0x8(%ebp)
  800999:	e8 9a ff ff ff       	call   800938 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	eb 03                	jmp    8009b0 <strlen+0x10>
		n++;
  8009ad:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b4:	75 f7                	jne    8009ad <strlen+0xd>
	return n;
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c6:	eb 03                	jmp    8009cb <strnlen+0x13>
		n++;
  8009c8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cb:	39 d0                	cmp    %edx,%eax
  8009cd:	74 08                	je     8009d7 <strnlen+0x1f>
  8009cf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d3:	75 f3                	jne    8009c8 <strnlen+0x10>
  8009d5:	89 c2                	mov    %eax,%edx
	return n;
}
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009ee:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	75 f2                	jne    8009ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f8:	89 c8                	mov    %ecx,%eax
  8009fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	53                   	push   %ebx
  800a03:	83 ec 10             	sub    $0x10,%esp
  800a06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a09:	53                   	push   %ebx
  800a0a:	e8 91 ff ff ff       	call   8009a0 <strlen>
  800a0f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a12:	ff 75 0c             	push   0xc(%ebp)
  800a15:	01 d8                	add    %ebx,%eax
  800a17:	50                   	push   %eax
  800a18:	e8 be ff ff ff       	call   8009db <strcpy>
	return dst;
}
  800a1d:	89 d8                	mov    %ebx,%eax
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2f:	89 f3                	mov    %esi,%ebx
  800a31:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a34:	89 f0                	mov    %esi,%eax
  800a36:	eb 0f                	jmp    800a47 <strncpy+0x23>
		*dst++ = *src;
  800a38:	83 c0 01             	add    $0x1,%eax
  800a3b:	0f b6 0a             	movzbl (%edx),%ecx
  800a3e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a41:	80 f9 01             	cmp    $0x1,%cl
  800a44:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a47:	39 d8                	cmp    %ebx,%eax
  800a49:	75 ed                	jne    800a38 <strncpy+0x14>
	}
	return ret;
}
  800a4b:	89 f0                	mov    %esi,%eax
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 75 08             	mov    0x8(%ebp),%esi
  800a59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a5f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a61:	85 d2                	test   %edx,%edx
  800a63:	74 21                	je     800a86 <strlcpy+0x35>
  800a65:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	eb 09                	jmp    800a76 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a6d:	83 c1 01             	add    $0x1,%ecx
  800a70:	83 c2 01             	add    $0x1,%edx
  800a73:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a76:	39 c2                	cmp    %eax,%edx
  800a78:	74 09                	je     800a83 <strlcpy+0x32>
  800a7a:	0f b6 19             	movzbl (%ecx),%ebx
  800a7d:	84 db                	test   %bl,%bl
  800a7f:	75 ec                	jne    800a6d <strlcpy+0x1c>
  800a81:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a83:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a86:	29 f0                	sub    %esi,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a95:	eb 06                	jmp    800a9d <strcmp+0x11>
		p++, q++;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a9d:	0f b6 01             	movzbl (%ecx),%eax
  800aa0:	84 c0                	test   %al,%al
  800aa2:	74 04                	je     800aa8 <strcmp+0x1c>
  800aa4:	3a 02                	cmp    (%edx),%al
  800aa6:	74 ef                	je     800a97 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	0f b6 c0             	movzbl %al,%eax
  800aab:	0f b6 12             	movzbl (%edx),%edx
  800aae:	29 d0                	sub    %edx,%eax
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	53                   	push   %ebx
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac1:	eb 06                	jmp    800ac9 <strncmp+0x17>
		n--, p++, q++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ac9:	39 d8                	cmp    %ebx,%eax
  800acb:	74 18                	je     800ae5 <strncmp+0x33>
  800acd:	0f b6 08             	movzbl (%eax),%ecx
  800ad0:	84 c9                	test   %cl,%cl
  800ad2:	74 04                	je     800ad8 <strncmp+0x26>
  800ad4:	3a 0a                	cmp    (%edx),%cl
  800ad6:	74 eb                	je     800ac3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad8:	0f b6 00             	movzbl (%eax),%eax
  800adb:	0f b6 12             	movzbl (%edx),%edx
  800ade:	29 d0                	sub    %edx,%eax
}
  800ae0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    
		return 0;
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	eb f4                	jmp    800ae0 <strncmp+0x2e>

00800aec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af6:	eb 03                	jmp    800afb <strchr+0xf>
  800af8:	83 c0 01             	add    $0x1,%eax
  800afb:	0f b6 10             	movzbl (%eax),%edx
  800afe:	84 d2                	test   %dl,%dl
  800b00:	74 06                	je     800b08 <strchr+0x1c>
		if (*s == c)
  800b02:	38 ca                	cmp    %cl,%dl
  800b04:	75 f2                	jne    800af8 <strchr+0xc>
  800b06:	eb 05                	jmp    800b0d <strchr+0x21>
			return (char *) s;
	return 0;
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b19:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b1c:	38 ca                	cmp    %cl,%dl
  800b1e:	74 09                	je     800b29 <strfind+0x1a>
  800b20:	84 d2                	test   %dl,%dl
  800b22:	74 05                	je     800b29 <strfind+0x1a>
	for (; *s; s++)
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	eb f0                	jmp    800b19 <strfind+0xa>
			break;
	return (char *) s;
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	57                   	push   %edi
  800b2f:	56                   	push   %esi
  800b30:	53                   	push   %ebx
  800b31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b37:	85 c9                	test   %ecx,%ecx
  800b39:	74 2f                	je     800b6a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3b:	89 f8                	mov    %edi,%eax
  800b3d:	09 c8                	or     %ecx,%eax
  800b3f:	a8 03                	test   $0x3,%al
  800b41:	75 21                	jne    800b64 <memset+0x39>
		c &= 0xFF;
  800b43:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b47:	89 d0                	mov    %edx,%eax
  800b49:	c1 e0 08             	shl    $0x8,%eax
  800b4c:	89 d3                	mov    %edx,%ebx
  800b4e:	c1 e3 18             	shl    $0x18,%ebx
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	c1 e6 10             	shl    $0x10,%esi
  800b56:	09 f3                	or     %esi,%ebx
  800b58:	09 da                	or     %ebx,%edx
  800b5a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b5f:	fc                   	cld    
  800b60:	f3 ab                	rep stos %eax,%es:(%edi)
  800b62:	eb 06                	jmp    800b6a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b67:	fc                   	cld    
  800b68:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6a:	89 f8                	mov    %edi,%eax
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
  800b79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b7f:	39 c6                	cmp    %eax,%esi
  800b81:	73 32                	jae    800bb5 <memmove+0x44>
  800b83:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b86:	39 c2                	cmp    %eax,%edx
  800b88:	76 2b                	jbe    800bb5 <memmove+0x44>
		s += n;
		d += n;
  800b8a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	09 fe                	or     %edi,%esi
  800b91:	09 ce                	or     %ecx,%esi
  800b93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b99:	75 0e                	jne    800ba9 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b9b:	83 ef 04             	sub    $0x4,%edi
  800b9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ba4:	fd                   	std    
  800ba5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba7:	eb 09                	jmp    800bb2 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ba9:	83 ef 01             	sub    $0x1,%edi
  800bac:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800baf:	fd                   	std    
  800bb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb2:	fc                   	cld    
  800bb3:	eb 1a                	jmp    800bcf <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb5:	89 f2                	mov    %esi,%edx
  800bb7:	09 c2                	or     %eax,%edx
  800bb9:	09 ca                	or     %ecx,%edx
  800bbb:	f6 c2 03             	test   $0x3,%dl
  800bbe:	75 0a                	jne    800bca <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bc3:	89 c7                	mov    %eax,%edi
  800bc5:	fc                   	cld    
  800bc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc8:	eb 05                	jmp    800bcf <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bca:	89 c7                	mov    %eax,%edi
  800bcc:	fc                   	cld    
  800bcd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bd9:	ff 75 10             	push   0x10(%ebp)
  800bdc:	ff 75 0c             	push   0xc(%ebp)
  800bdf:	ff 75 08             	push   0x8(%ebp)
  800be2:	e8 8a ff ff ff       	call   800b71 <memmove>
}
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf4:	89 c6                	mov    %eax,%esi
  800bf6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf9:	eb 06                	jmp    800c01 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bfb:	83 c0 01             	add    $0x1,%eax
  800bfe:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c01:	39 f0                	cmp    %esi,%eax
  800c03:	74 14                	je     800c19 <memcmp+0x30>
		if (*s1 != *s2)
  800c05:	0f b6 08             	movzbl (%eax),%ecx
  800c08:	0f b6 1a             	movzbl (%edx),%ebx
  800c0b:	38 d9                	cmp    %bl,%cl
  800c0d:	74 ec                	je     800bfb <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c0f:	0f b6 c1             	movzbl %cl,%eax
  800c12:	0f b6 db             	movzbl %bl,%ebx
  800c15:	29 d8                	sub    %ebx,%eax
  800c17:	eb 05                	jmp    800c1e <memcmp+0x35>
	}

	return 0;
  800c19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	8b 45 08             	mov    0x8(%ebp),%eax
  800c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c30:	eb 03                	jmp    800c35 <memfind+0x13>
  800c32:	83 c0 01             	add    $0x1,%eax
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	73 04                	jae    800c3d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c39:	38 08                	cmp    %cl,(%eax)
  800c3b:	75 f5                	jne    800c32 <memfind+0x10>
			break;
	return (void *) s;
}
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4b:	eb 03                	jmp    800c50 <strtol+0x11>
		s++;
  800c4d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c50:	0f b6 02             	movzbl (%edx),%eax
  800c53:	3c 20                	cmp    $0x20,%al
  800c55:	74 f6                	je     800c4d <strtol+0xe>
  800c57:	3c 09                	cmp    $0x9,%al
  800c59:	74 f2                	je     800c4d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c5b:	3c 2b                	cmp    $0x2b,%al
  800c5d:	74 2a                	je     800c89 <strtol+0x4a>
	int neg = 0;
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c64:	3c 2d                	cmp    $0x2d,%al
  800c66:	74 2b                	je     800c93 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c6e:	75 0f                	jne    800c7f <strtol+0x40>
  800c70:	80 3a 30             	cmpb   $0x30,(%edx)
  800c73:	74 28                	je     800c9d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c75:	85 db                	test   %ebx,%ebx
  800c77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7c:	0f 44 d8             	cmove  %eax,%ebx
  800c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c84:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c87:	eb 46                	jmp    800ccf <strtol+0x90>
		s++;
  800c89:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c91:	eb d5                	jmp    800c68 <strtol+0x29>
		s++, neg = 1;
  800c93:	83 c2 01             	add    $0x1,%edx
  800c96:	bf 01 00 00 00       	mov    $0x1,%edi
  800c9b:	eb cb                	jmp    800c68 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca1:	74 0e                	je     800cb1 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	75 d8                	jne    800c7f <strtol+0x40>
		s++, base = 8;
  800ca7:	83 c2 01             	add    $0x1,%edx
  800caa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800caf:	eb ce                	jmp    800c7f <strtol+0x40>
		s += 2, base = 16;
  800cb1:	83 c2 02             	add    $0x2,%edx
  800cb4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cb9:	eb c4                	jmp    800c7f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cbb:	0f be c0             	movsbl %al,%eax
  800cbe:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc1:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cc4:	7d 3a                	jge    800d00 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cc6:	83 c2 01             	add    $0x1,%edx
  800cc9:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ccd:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ccf:	0f b6 02             	movzbl (%edx),%eax
  800cd2:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 09             	cmp    $0x9,%bl
  800cda:	76 df                	jbe    800cbb <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cdc:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cdf:	89 f3                	mov    %esi,%ebx
  800ce1:	80 fb 19             	cmp    $0x19,%bl
  800ce4:	77 08                	ja     800cee <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ce6:	0f be c0             	movsbl %al,%eax
  800ce9:	83 e8 57             	sub    $0x57,%eax
  800cec:	eb d3                	jmp    800cc1 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cee:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cf1:	89 f3                	mov    %esi,%ebx
  800cf3:	80 fb 19             	cmp    $0x19,%bl
  800cf6:	77 08                	ja     800d00 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cf8:	0f be c0             	movsbl %al,%eax
  800cfb:	83 e8 37             	sub    $0x37,%eax
  800cfe:	eb c1                	jmp    800cc1 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d04:	74 05                	je     800d0b <strtol+0xcc>
		*endptr = (char *) s;
  800d06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d09:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d0b:	89 c8                	mov    %ecx,%eax
  800d0d:	f7 d8                	neg    %eax
  800d0f:	85 ff                	test   %edi,%edi
  800d11:	0f 45 c8             	cmovne %eax,%ecx
}
  800d14:	89 c8                	mov    %ecx,%eax
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d21:	b8 00 00 00 00       	mov    $0x0,%eax
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	89 c3                	mov    %eax,%ebx
  800d2e:	89 c7                	mov    %eax,%edi
  800d30:	89 c6                	mov    %eax,%esi
  800d32:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d44:	b8 01 00 00 00       	mov    $0x1,%eax
  800d49:	89 d1                	mov    %edx,%ecx
  800d4b:	89 d3                	mov    %edx,%ebx
  800d4d:	89 d7                	mov    %edx,%edi
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	b8 03 00 00 00       	mov    $0x3,%eax
  800d6e:	89 cb                	mov    %ecx,%ebx
  800d70:	89 cf                	mov    %ecx,%edi
  800d72:	89 ce                	mov    %ecx,%esi
  800d74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7f 08                	jg     800d82 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 03                	push   $0x3
  800d88:	68 df 2a 80 00       	push   $0x802adf
  800d8d:	6a 2a                	push   $0x2a
  800d8f:	68 fc 2a 80 00       	push   $0x802afc
  800d94:	e8 8d f5 ff ff       	call   800326 <_panic>

00800d99 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	57                   	push   %edi
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800da4:	b8 02 00 00 00       	mov    $0x2,%eax
  800da9:	89 d1                	mov    %edx,%ecx
  800dab:	89 d3                	mov    %edx,%ebx
  800dad:	89 d7                	mov    %edx,%edi
  800daf:	89 d6                	mov    %edx,%esi
  800db1:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_yield>:

void
sys_yield(void)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc8:	89 d1                	mov    %edx,%ecx
  800dca:	89 d3                	mov    %edx,%ebx
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	89 d6                	mov    %edx,%esi
  800dd0:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dd2:	5b                   	pop    %ebx
  800dd3:	5e                   	pop    %esi
  800dd4:	5f                   	pop    %edi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de0:	be 00 00 00 00       	mov    $0x0,%esi
  800de5:	8b 55 08             	mov    0x8(%ebp),%edx
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	b8 04 00 00 00       	mov    $0x4,%eax
  800df0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df3:	89 f7                	mov    %esi,%edi
  800df5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df7:	85 c0                	test   %eax,%eax
  800df9:	7f 08                	jg     800e03 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e03:	83 ec 0c             	sub    $0xc,%esp
  800e06:	50                   	push   %eax
  800e07:	6a 04                	push   $0x4
  800e09:	68 df 2a 80 00       	push   $0x802adf
  800e0e:	6a 2a                	push   $0x2a
  800e10:	68 fc 2a 80 00       	push   $0x802afc
  800e15:	e8 0c f5 ff ff       	call   800326 <_panic>

00800e1a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e29:	b8 05 00 00 00       	mov    $0x5,%eax
  800e2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e31:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e34:	8b 75 18             	mov    0x18(%ebp),%esi
  800e37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7f 08                	jg     800e45 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	50                   	push   %eax
  800e49:	6a 05                	push   $0x5
  800e4b:	68 df 2a 80 00       	push   $0x802adf
  800e50:	6a 2a                	push   $0x2a
  800e52:	68 fc 2a 80 00       	push   $0x802afc
  800e57:	e8 ca f4 ff ff       	call   800326 <_panic>

00800e5c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	b8 06 00 00 00       	mov    $0x6,%eax
  800e75:	89 df                	mov    %ebx,%edi
  800e77:	89 de                	mov    %ebx,%esi
  800e79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	7f 08                	jg     800e87 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e82:	5b                   	pop    %ebx
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	50                   	push   %eax
  800e8b:	6a 06                	push   $0x6
  800e8d:	68 df 2a 80 00       	push   $0x802adf
  800e92:	6a 2a                	push   $0x2a
  800e94:	68 fc 2a 80 00       	push   $0x802afc
  800e99:	e8 88 f4 ff ff       	call   800326 <_panic>

00800e9e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb2:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb7:	89 df                	mov    %ebx,%edi
  800eb9:	89 de                	mov    %ebx,%esi
  800ebb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	7f 08                	jg     800ec9 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	50                   	push   %eax
  800ecd:	6a 08                	push   $0x8
  800ecf:	68 df 2a 80 00       	push   $0x802adf
  800ed4:	6a 2a                	push   $0x2a
  800ed6:	68 fc 2a 80 00       	push   $0x802afc
  800edb:	e8 46 f4 ff ff       	call   800326 <_panic>

00800ee0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ef9:	89 df                	mov    %ebx,%edi
  800efb:	89 de                	mov    %ebx,%esi
  800efd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	7f 08                	jg     800f0b <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	50                   	push   %eax
  800f0f:	6a 09                	push   $0x9
  800f11:	68 df 2a 80 00       	push   $0x802adf
  800f16:	6a 2a                	push   $0x2a
  800f18:	68 fc 2a 80 00       	push   $0x802afc
  800f1d:	e8 04 f4 ff ff       	call   800326 <_panic>

00800f22 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3b:	89 df                	mov    %ebx,%edi
  800f3d:	89 de                	mov    %ebx,%esi
  800f3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7f 08                	jg     800f4d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	50                   	push   %eax
  800f51:	6a 0a                	push   $0xa
  800f53:	68 df 2a 80 00       	push   $0x802adf
  800f58:	6a 2a                	push   $0x2a
  800f5a:	68 fc 2a 80 00       	push   $0x802afc
  800f5f:	e8 c2 f3 ff ff       	call   800326 <_panic>

00800f64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f70:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f75:	be 00 00 00 00       	mov    $0x0,%esi
  800f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f80:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f95:	8b 55 08             	mov    0x8(%ebp),%edx
  800f98:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f9d:	89 cb                	mov    %ecx,%ebx
  800f9f:	89 cf                	mov    %ecx,%edi
  800fa1:	89 ce                	mov    %ecx,%esi
  800fa3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	7f 08                	jg     800fb1 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	50                   	push   %eax
  800fb5:	6a 0d                	push   $0xd
  800fb7:	68 df 2a 80 00       	push   $0x802adf
  800fbc:	6a 2a                	push   $0x2a
  800fbe:	68 fc 2a 80 00       	push   $0x802afc
  800fc3:	e8 5e f3 ff ff       	call   800326 <_panic>

00800fc8 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	57                   	push   %edi
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fce:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fd8:	89 d1                	mov    %edx,%ecx
  800fda:	89 d3                	mov    %edx,%ebx
  800fdc:	89 d7                	mov    %edx,%edi
  800fde:	89 d6                	mov    %edx,%esi
  800fe0:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff8:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ffd:	89 df                	mov    %ebx,%edi
  800fff:	89 de                	mov    %ebx,%esi
  801001:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5f                   	pop    %edi
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	57                   	push   %edi
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80100e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801013:	8b 55 08             	mov    0x8(%ebp),%edx
  801016:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801019:	b8 10 00 00 00       	mov    $0x10,%eax
  80101e:	89 df                	mov    %ebx,%edi
  801020:	89 de                	mov    %ebx,%esi
  801022:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5f                   	pop    %edi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	8b 55 08             	mov    0x8(%ebp),%edx
  80102f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801032:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801035:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801037:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80103a:	83 3a 01             	cmpl   $0x1,(%edx)
  80103d:	7e 09                	jle    801048 <argstart+0x1f>
  80103f:	ba 88 27 80 00       	mov    $0x802788,%edx
  801044:	85 c9                	test   %ecx,%ecx
  801046:	75 05                	jne    80104d <argstart+0x24>
  801048:	ba 00 00 00 00       	mov    $0x0,%edx
  80104d:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801050:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801057:	5d                   	pop    %ebp
  801058:	c3                   	ret    

00801059 <argnext>:

int
argnext(struct Argstate *args)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	53                   	push   %ebx
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801063:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80106a:	8b 43 08             	mov    0x8(%ebx),%eax
  80106d:	85 c0                	test   %eax,%eax
  80106f:	74 74                	je     8010e5 <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  801071:	80 38 00             	cmpb   $0x0,(%eax)
  801074:	75 48                	jne    8010be <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801076:	8b 0b                	mov    (%ebx),%ecx
  801078:	83 39 01             	cmpl   $0x1,(%ecx)
  80107b:	74 5a                	je     8010d7 <argnext+0x7e>
		    || args->argv[1][0] != '-'
  80107d:	8b 53 04             	mov    0x4(%ebx),%edx
  801080:	8b 42 04             	mov    0x4(%edx),%eax
  801083:	80 38 2d             	cmpb   $0x2d,(%eax)
  801086:	75 4f                	jne    8010d7 <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  801088:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80108c:	74 49                	je     8010d7 <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80108e:	83 c0 01             	add    $0x1,%eax
  801091:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	8b 01                	mov    (%ecx),%eax
  801099:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8010a0:	50                   	push   %eax
  8010a1:	8d 42 08             	lea    0x8(%edx),%eax
  8010a4:	50                   	push   %eax
  8010a5:	83 c2 04             	add    $0x4,%edx
  8010a8:	52                   	push   %edx
  8010a9:	e8 c3 fa ff ff       	call   800b71 <memmove>
		(*args->argc)--;
  8010ae:	8b 03                	mov    (%ebx),%eax
  8010b0:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010b3:	8b 43 08             	mov    0x8(%ebx),%eax
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010bc:	74 13                	je     8010d1 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010be:	8b 43 08             	mov    0x8(%ebx),%eax
  8010c1:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  8010c4:	83 c0 01             	add    $0x1,%eax
  8010c7:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010d1:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010d5:	75 e7                	jne    8010be <argnext+0x65>
	args->curarg = 0;
  8010d7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010de:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010e3:	eb e5                	jmp    8010ca <argnext+0x71>
		return -1;
  8010e5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010ea:	eb de                	jmp    8010ca <argnext+0x71>

008010ec <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 04             	sub    $0x4,%esp
  8010f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010f6:	8b 43 08             	mov    0x8(%ebx),%eax
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	74 12                	je     80110f <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  8010fd:	80 38 00             	cmpb   $0x0,(%eax)
  801100:	74 12                	je     801114 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801102:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801105:	c7 43 08 88 27 80 00 	movl   $0x802788,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  80110c:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  80110f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801112:	c9                   	leave  
  801113:	c3                   	ret    
	} else if (*args->argc > 1) {
  801114:	8b 13                	mov    (%ebx),%edx
  801116:	83 3a 01             	cmpl   $0x1,(%edx)
  801119:	7f 10                	jg     80112b <argnextvalue+0x3f>
		args->argvalue = 0;
  80111b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801122:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801129:	eb e1                	jmp    80110c <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  80112b:	8b 43 04             	mov    0x4(%ebx),%eax
  80112e:	8b 48 04             	mov    0x4(%eax),%ecx
  801131:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	8b 12                	mov    (%edx),%edx
  801139:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801140:	52                   	push   %edx
  801141:	8d 50 08             	lea    0x8(%eax),%edx
  801144:	52                   	push   %edx
  801145:	83 c0 04             	add    $0x4,%eax
  801148:	50                   	push   %eax
  801149:	e8 23 fa ff ff       	call   800b71 <memmove>
		(*args->argc)--;
  80114e:	8b 03                	mov    (%ebx),%eax
  801150:	83 28 01             	subl   $0x1,(%eax)
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	eb b4                	jmp    80110c <argnextvalue+0x20>

00801158 <argvalue>:
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801161:	8b 42 0c             	mov    0xc(%edx),%eax
  801164:	85 c0                	test   %eax,%eax
  801166:	74 02                	je     80116a <argvalue+0x12>
}
  801168:	c9                   	leave  
  801169:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80116a:	83 ec 0c             	sub    $0xc,%esp
  80116d:	52                   	push   %edx
  80116e:	e8 79 ff ff ff       	call   8010ec <argnextvalue>
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	eb f0                	jmp    801168 <argvalue+0x10>

00801178 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	05 00 00 00 30       	add    $0x30000000,%eax
  801183:	c1 e8 0c             	shr    $0xc,%eax
}
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    

00801188 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118b:	8b 45 08             	mov    0x8(%ebp),%eax
  80118e:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801193:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801198:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	c1 ea 16             	shr    $0x16,%edx
  8011ac:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b3:	f6 c2 01             	test   $0x1,%dl
  8011b6:	74 29                	je     8011e1 <fd_alloc+0x42>
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	c1 ea 0c             	shr    $0xc,%edx
  8011bd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c4:	f6 c2 01             	test   $0x1,%dl
  8011c7:	74 18                	je     8011e1 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011c9:	05 00 10 00 00       	add    $0x1000,%eax
  8011ce:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d3:	75 d2                	jne    8011a7 <fd_alloc+0x8>
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011da:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011df:	eb 05                	jmp    8011e6 <fd_alloc+0x47>
			return 0;
  8011e1:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e9:	89 02                	mov    %eax,(%edx)
}
  8011eb:	89 c8                	mov    %ecx,%eax
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f5:	83 f8 1f             	cmp    $0x1f,%eax
  8011f8:	77 30                	ja     80122a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fa:	c1 e0 0c             	shl    $0xc,%eax
  8011fd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801202:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801208:	f6 c2 01             	test   $0x1,%dl
  80120b:	74 24                	je     801231 <fd_lookup+0x42>
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 ea 0c             	shr    $0xc,%edx
  801212:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801219:	f6 c2 01             	test   $0x1,%dl
  80121c:	74 1a                	je     801238 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801221:	89 02                	mov    %eax,(%edx)
	return 0;
  801223:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    
		return -E_INVAL;
  80122a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80122f:	eb f7                	jmp    801228 <fd_lookup+0x39>
		return -E_INVAL;
  801231:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801236:	eb f0                	jmp    801228 <fd_lookup+0x39>
  801238:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80123d:	eb e9                	jmp    801228 <fd_lookup+0x39>

0080123f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	53                   	push   %ebx
  801243:	83 ec 04             	sub    $0x4,%esp
  801246:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
  80124e:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801253:	39 13                	cmp    %edx,(%ebx)
  801255:	74 37                	je     80128e <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801257:	83 c0 01             	add    $0x1,%eax
  80125a:	8b 1c 85 88 2b 80 00 	mov    0x802b88(,%eax,4),%ebx
  801261:	85 db                	test   %ebx,%ebx
  801263:	75 ee                	jne    801253 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801265:	a1 00 44 80 00       	mov    0x804400,%eax
  80126a:	8b 40 48             	mov    0x48(%eax),%eax
  80126d:	83 ec 04             	sub    $0x4,%esp
  801270:	52                   	push   %edx
  801271:	50                   	push   %eax
  801272:	68 0c 2b 80 00       	push   $0x802b0c
  801277:	e8 85 f1 ff ff       	call   800401 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801284:	8b 55 0c             	mov    0xc(%ebp),%edx
  801287:	89 1a                	mov    %ebx,(%edx)
}
  801289:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128c:	c9                   	leave  
  80128d:	c3                   	ret    
			return 0;
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
  801293:	eb ef                	jmp    801284 <dev_lookup+0x45>

00801295 <fd_close>:
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	57                   	push   %edi
  801299:	56                   	push   %esi
  80129a:	53                   	push   %ebx
  80129b:	83 ec 24             	sub    $0x24,%esp
  80129e:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012a7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012a8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012ae:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b1:	50                   	push   %eax
  8012b2:	e8 38 ff ff ff       	call   8011ef <fd_lookup>
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 05                	js     8012c5 <fd_close+0x30>
	    || fd != fd2)
  8012c0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012c3:	74 16                	je     8012db <fd_close+0x46>
		return (must_exist ? r : 0);
  8012c5:	89 f8                	mov    %edi,%eax
  8012c7:	84 c0                	test   %al,%al
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ce:	0f 44 d8             	cmove  %eax,%ebx
}
  8012d1:	89 d8                	mov    %ebx,%eax
  8012d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d6:	5b                   	pop    %ebx
  8012d7:	5e                   	pop    %esi
  8012d8:	5f                   	pop    %edi
  8012d9:	5d                   	pop    %ebp
  8012da:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 36                	push   (%esi)
  8012e4:	e8 56 ff ff ff       	call   80123f <dev_lookup>
  8012e9:	89 c3                	mov    %eax,%ebx
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 1a                	js     80130c <fd_close+0x77>
		if (dev->dev_close)
  8012f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f5:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	74 0b                	je     80130c <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801301:	83 ec 0c             	sub    $0xc,%esp
  801304:	56                   	push   %esi
  801305:	ff d0                	call   *%eax
  801307:	89 c3                	mov    %eax,%ebx
  801309:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	56                   	push   %esi
  801310:	6a 00                	push   $0x0
  801312:	e8 45 fb ff ff       	call   800e5c <sys_page_unmap>
	return r;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	eb b5                	jmp    8012d1 <fd_close+0x3c>

0080131c <close>:

int
close(int fdnum)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	ff 75 08             	push   0x8(%ebp)
  801329:	e8 c1 fe ff ff       	call   8011ef <fd_lookup>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	79 02                	jns    801337 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    
		return fd_close(fd, 1);
  801337:	83 ec 08             	sub    $0x8,%esp
  80133a:	6a 01                	push   $0x1
  80133c:	ff 75 f4             	push   -0xc(%ebp)
  80133f:	e8 51 ff ff ff       	call   801295 <fd_close>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	eb ec                	jmp    801335 <close+0x19>

00801349 <close_all>:

void
close_all(void)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	53                   	push   %ebx
  80134d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801350:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	53                   	push   %ebx
  801359:	e8 be ff ff ff       	call   80131c <close>
	for (i = 0; i < MAXFD; i++)
  80135e:	83 c3 01             	add    $0x1,%ebx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	83 fb 20             	cmp    $0x20,%ebx
  801367:	75 ec                	jne    801355 <close_all+0xc>
}
  801369:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    

0080136e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801377:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137a:	50                   	push   %eax
  80137b:	ff 75 08             	push   0x8(%ebp)
  80137e:	e8 6c fe ff ff       	call   8011ef <fd_lookup>
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 7f                	js     80140b <dup+0x9d>
		return r;
	close(newfdnum);
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	ff 75 0c             	push   0xc(%ebp)
  801392:	e8 85 ff ff ff       	call   80131c <close>

	newfd = INDEX2FD(newfdnum);
  801397:	8b 75 0c             	mov    0xc(%ebp),%esi
  80139a:	c1 e6 0c             	shl    $0xc,%esi
  80139d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a6:	89 3c 24             	mov    %edi,(%esp)
  8013a9:	e8 da fd ff ff       	call   801188 <fd2data>
  8013ae:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013b0:	89 34 24             	mov    %esi,(%esp)
  8013b3:	e8 d0 fd ff ff       	call   801188 <fd2data>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013be:	89 d8                	mov    %ebx,%eax
  8013c0:	c1 e8 16             	shr    $0x16,%eax
  8013c3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ca:	a8 01                	test   $0x1,%al
  8013cc:	74 11                	je     8013df <dup+0x71>
  8013ce:	89 d8                	mov    %ebx,%eax
  8013d0:	c1 e8 0c             	shr    $0xc,%eax
  8013d3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013da:	f6 c2 01             	test   $0x1,%dl
  8013dd:	75 36                	jne    801415 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013df:	89 f8                	mov    %edi,%eax
  8013e1:	c1 e8 0c             	shr    $0xc,%eax
  8013e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f3:	50                   	push   %eax
  8013f4:	56                   	push   %esi
  8013f5:	6a 00                	push   $0x0
  8013f7:	57                   	push   %edi
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 1b fa ff ff       	call   800e1a <sys_page_map>
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	83 c4 20             	add    $0x20,%esp
  801404:	85 c0                	test   %eax,%eax
  801406:	78 33                	js     80143b <dup+0xcd>
		goto err;

	return newfdnum;
  801408:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80140b:	89 d8                	mov    %ebx,%eax
  80140d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801415:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141c:	83 ec 0c             	sub    $0xc,%esp
  80141f:	25 07 0e 00 00       	and    $0xe07,%eax
  801424:	50                   	push   %eax
  801425:	ff 75 d4             	push   -0x2c(%ebp)
  801428:	6a 00                	push   $0x0
  80142a:	53                   	push   %ebx
  80142b:	6a 00                	push   $0x0
  80142d:	e8 e8 f9 ff ff       	call   800e1a <sys_page_map>
  801432:	89 c3                	mov    %eax,%ebx
  801434:	83 c4 20             	add    $0x20,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	79 a4                	jns    8013df <dup+0x71>
	sys_page_unmap(0, newfd);
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	56                   	push   %esi
  80143f:	6a 00                	push   $0x0
  801441:	e8 16 fa ff ff       	call   800e5c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801446:	83 c4 08             	add    $0x8,%esp
  801449:	ff 75 d4             	push   -0x2c(%ebp)
  80144c:	6a 00                	push   $0x0
  80144e:	e8 09 fa ff ff       	call   800e5c <sys_page_unmap>
	return r;
  801453:	83 c4 10             	add    $0x10,%esp
  801456:	eb b3                	jmp    80140b <dup+0x9d>

00801458 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	83 ec 18             	sub    $0x18,%esp
  801460:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801463:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	56                   	push   %esi
  801468:	e8 82 fd ff ff       	call   8011ef <fd_lookup>
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	85 c0                	test   %eax,%eax
  801472:	78 3c                	js     8014b0 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801474:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	ff 33                	push   (%ebx)
  801480:	e8 ba fd ff ff       	call   80123f <dev_lookup>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	85 c0                	test   %eax,%eax
  80148a:	78 24                	js     8014b0 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148c:	8b 43 08             	mov    0x8(%ebx),%eax
  80148f:	83 e0 03             	and    $0x3,%eax
  801492:	83 f8 01             	cmp    $0x1,%eax
  801495:	74 20                	je     8014b7 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801497:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149a:	8b 40 08             	mov    0x8(%eax),%eax
  80149d:	85 c0                	test   %eax,%eax
  80149f:	74 37                	je     8014d8 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a1:	83 ec 04             	sub    $0x4,%esp
  8014a4:	ff 75 10             	push   0x10(%ebp)
  8014a7:	ff 75 0c             	push   0xc(%ebp)
  8014aa:	53                   	push   %ebx
  8014ab:	ff d0                	call   *%eax
  8014ad:	83 c4 10             	add    $0x10,%esp
}
  8014b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b7:	a1 00 44 80 00       	mov    0x804400,%eax
  8014bc:	8b 40 48             	mov    0x48(%eax),%eax
  8014bf:	83 ec 04             	sub    $0x4,%esp
  8014c2:	56                   	push   %esi
  8014c3:	50                   	push   %eax
  8014c4:	68 4d 2b 80 00       	push   $0x802b4d
  8014c9:	e8 33 ef ff ff       	call   800401 <cprintf>
		return -E_INVAL;
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d6:	eb d8                	jmp    8014b0 <read+0x58>
		return -E_NOT_SUPP;
  8014d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014dd:	eb d1                	jmp    8014b0 <read+0x58>

008014df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	57                   	push   %edi
  8014e3:	56                   	push   %esi
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f3:	eb 02                	jmp    8014f7 <readn+0x18>
  8014f5:	01 c3                	add    %eax,%ebx
  8014f7:	39 f3                	cmp    %esi,%ebx
  8014f9:	73 21                	jae    80151c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	89 f0                	mov    %esi,%eax
  801500:	29 d8                	sub    %ebx,%eax
  801502:	50                   	push   %eax
  801503:	89 d8                	mov    %ebx,%eax
  801505:	03 45 0c             	add    0xc(%ebp),%eax
  801508:	50                   	push   %eax
  801509:	57                   	push   %edi
  80150a:	e8 49 ff ff ff       	call   801458 <read>
		if (m < 0)
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 04                	js     80151a <readn+0x3b>
			return m;
		if (m == 0)
  801516:	75 dd                	jne    8014f5 <readn+0x16>
  801518:	eb 02                	jmp    80151c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80151c:	89 d8                	mov    %ebx,%eax
  80151e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801521:	5b                   	pop    %ebx
  801522:	5e                   	pop    %esi
  801523:	5f                   	pop    %edi
  801524:	5d                   	pop    %ebp
  801525:	c3                   	ret    

00801526 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801526:	55                   	push   %ebp
  801527:	89 e5                	mov    %esp,%ebp
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	83 ec 18             	sub    $0x18,%esp
  80152e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801531:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801534:	50                   	push   %eax
  801535:	53                   	push   %ebx
  801536:	e8 b4 fc ff ff       	call   8011ef <fd_lookup>
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 37                	js     801579 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801542:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801545:	83 ec 08             	sub    $0x8,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	ff 36                	push   (%esi)
  80154e:	e8 ec fc ff ff       	call   80123f <dev_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 1f                	js     801579 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80155e:	74 20                	je     801580 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801560:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801563:	8b 40 0c             	mov    0xc(%eax),%eax
  801566:	85 c0                	test   %eax,%eax
  801568:	74 37                	je     8015a1 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156a:	83 ec 04             	sub    $0x4,%esp
  80156d:	ff 75 10             	push   0x10(%ebp)
  801570:	ff 75 0c             	push   0xc(%ebp)
  801573:	56                   	push   %esi
  801574:	ff d0                	call   *%eax
  801576:	83 c4 10             	add    $0x10,%esp
}
  801579:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157c:	5b                   	pop    %ebx
  80157d:	5e                   	pop    %esi
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801580:	a1 00 44 80 00       	mov    0x804400,%eax
  801585:	8b 40 48             	mov    0x48(%eax),%eax
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	53                   	push   %ebx
  80158c:	50                   	push   %eax
  80158d:	68 69 2b 80 00       	push   $0x802b69
  801592:	e8 6a ee ff ff       	call   800401 <cprintf>
		return -E_INVAL;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80159f:	eb d8                	jmp    801579 <write+0x53>
		return -E_NOT_SUPP;
  8015a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a6:	eb d1                	jmp    801579 <write+0x53>

008015a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	ff 75 08             	push   0x8(%ebp)
  8015b5:	e8 35 fc ff ff       	call   8011ef <fd_lookup>
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 0e                	js     8015cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 18             	sub    $0x18,%esp
  8015d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015df:	50                   	push   %eax
  8015e0:	53                   	push   %ebx
  8015e1:	e8 09 fc ff ff       	call   8011ef <fd_lookup>
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 34                	js     801621 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015f0:	83 ec 08             	sub    $0x8,%esp
  8015f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f6:	50                   	push   %eax
  8015f7:	ff 36                	push   (%esi)
  8015f9:	e8 41 fc ff ff       	call   80123f <dev_lookup>
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	85 c0                	test   %eax,%eax
  801603:	78 1c                	js     801621 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801605:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801609:	74 1d                	je     801628 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80160b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160e:	8b 40 18             	mov    0x18(%eax),%eax
  801611:	85 c0                	test   %eax,%eax
  801613:	74 34                	je     801649 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	ff 75 0c             	push   0xc(%ebp)
  80161b:	56                   	push   %esi
  80161c:	ff d0                	call   *%eax
  80161e:	83 c4 10             	add    $0x10,%esp
}
  801621:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    
			thisenv->env_id, fdnum);
  801628:	a1 00 44 80 00       	mov    0x804400,%eax
  80162d:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801630:	83 ec 04             	sub    $0x4,%esp
  801633:	53                   	push   %ebx
  801634:	50                   	push   %eax
  801635:	68 2c 2b 80 00       	push   $0x802b2c
  80163a:	e8 c2 ed ff ff       	call   800401 <cprintf>
		return -E_INVAL;
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801647:	eb d8                	jmp    801621 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801649:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80164e:	eb d1                	jmp    801621 <ftruncate+0x50>

00801650 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	56                   	push   %esi
  801654:	53                   	push   %ebx
  801655:	83 ec 18             	sub    $0x18,%esp
  801658:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165e:	50                   	push   %eax
  80165f:	ff 75 08             	push   0x8(%ebp)
  801662:	e8 88 fb ff ff       	call   8011ef <fd_lookup>
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 49                	js     8016b7 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	ff 36                	push   (%esi)
  80167a:	e8 c0 fb ff ff       	call   80123f <dev_lookup>
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	85 c0                	test   %eax,%eax
  801684:	78 31                	js     8016b7 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801686:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801689:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80168d:	74 2f                	je     8016be <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80168f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801692:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801699:	00 00 00 
	stat->st_isdir = 0;
  80169c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a3:	00 00 00 
	stat->st_dev = dev;
  8016a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	53                   	push   %ebx
  8016b0:	56                   	push   %esi
  8016b1:	ff 50 14             	call   *0x14(%eax)
  8016b4:	83 c4 10             	add    $0x10,%esp
}
  8016b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ba:	5b                   	pop    %ebx
  8016bb:	5e                   	pop    %esi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    
		return -E_NOT_SUPP;
  8016be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c3:	eb f2                	jmp    8016b7 <fstat+0x67>

008016c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	56                   	push   %esi
  8016c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	6a 00                	push   $0x0
  8016cf:	ff 75 08             	push   0x8(%ebp)
  8016d2:	e8 e4 01 00 00       	call   8018bb <open>
  8016d7:	89 c3                	mov    %eax,%ebx
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 1b                	js     8016fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e0:	83 ec 08             	sub    $0x8,%esp
  8016e3:	ff 75 0c             	push   0xc(%ebp)
  8016e6:	50                   	push   %eax
  8016e7:	e8 64 ff ff ff       	call   801650 <fstat>
  8016ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8016ee:	89 1c 24             	mov    %ebx,(%esp)
  8016f1:	e8 26 fc ff ff       	call   80131c <close>
	return r;
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	89 f3                	mov    %esi,%ebx
}
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801700:	5b                   	pop    %ebx
  801701:	5e                   	pop    %esi
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	56                   	push   %esi
  801708:	53                   	push   %ebx
  801709:	89 c6                	mov    %eax,%esi
  80170b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80170d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801714:	74 27                	je     80173d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801716:	6a 07                	push   $0x7
  801718:	68 00 50 80 00       	push   $0x805000
  80171d:	56                   	push   %esi
  80171e:	ff 35 00 60 80 00    	push   0x806000
  801724:	e8 d7 0c 00 00       	call   802400 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801729:	83 c4 0c             	add    $0xc,%esp
  80172c:	6a 00                	push   $0x0
  80172e:	53                   	push   %ebx
  80172f:	6a 00                	push   $0x0
  801731:	e8 63 0c 00 00       	call   802399 <ipc_recv>
}
  801736:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801739:	5b                   	pop    %ebx
  80173a:	5e                   	pop    %esi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	6a 01                	push   $0x1
  801742:	e8 0d 0d 00 00       	call   802454 <ipc_find_env>
  801747:	a3 00 60 80 00       	mov    %eax,0x806000
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	eb c5                	jmp    801716 <fsipc+0x12>

00801751 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801757:	8b 45 08             	mov    0x8(%ebp),%eax
  80175a:	8b 40 0c             	mov    0xc(%eax),%eax
  80175d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801762:	8b 45 0c             	mov    0xc(%ebp),%eax
  801765:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80176a:	ba 00 00 00 00       	mov    $0x0,%edx
  80176f:	b8 02 00 00 00       	mov    $0x2,%eax
  801774:	e8 8b ff ff ff       	call   801704 <fsipc>
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <devfile_flush>:
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801781:	8b 45 08             	mov    0x8(%ebp),%eax
  801784:	8b 40 0c             	mov    0xc(%eax),%eax
  801787:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80178c:	ba 00 00 00 00       	mov    $0x0,%edx
  801791:	b8 06 00 00 00       	mov    $0x6,%eax
  801796:	e8 69 ff ff ff       	call   801704 <fsipc>
}
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devfile_stat>:
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	53                   	push   %ebx
  8017a1:	83 ec 04             	sub    $0x4,%esp
  8017a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8017bc:	e8 43 ff ff ff       	call   801704 <fsipc>
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 2c                	js     8017f1 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	68 00 50 80 00       	push   $0x805000
  8017cd:	53                   	push   %ebx
  8017ce:	e8 08 f2 ff ff       	call   8009db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8017d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017de:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_write>:
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ff:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801804:	39 d0                	cmp    %edx,%eax
  801806:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801809:	8b 55 08             	mov    0x8(%ebp),%edx
  80180c:	8b 52 0c             	mov    0xc(%edx),%edx
  80180f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801815:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80181a:	50                   	push   %eax
  80181b:	ff 75 0c             	push   0xc(%ebp)
  80181e:	68 08 50 80 00       	push   $0x805008
  801823:	e8 49 f3 ff ff       	call   800b71 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801828:	ba 00 00 00 00       	mov    $0x0,%edx
  80182d:	b8 04 00 00 00       	mov    $0x4,%eax
  801832:	e8 cd fe ff ff       	call   801704 <fsipc>
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <devfile_read>:
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	8b 40 0c             	mov    0xc(%eax),%eax
  801847:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80184c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
  801857:	b8 03 00 00 00       	mov    $0x3,%eax
  80185c:	e8 a3 fe ff ff       	call   801704 <fsipc>
  801861:	89 c3                	mov    %eax,%ebx
  801863:	85 c0                	test   %eax,%eax
  801865:	78 1f                	js     801886 <devfile_read+0x4d>
	assert(r <= n);
  801867:	39 f0                	cmp    %esi,%eax
  801869:	77 24                	ja     80188f <devfile_read+0x56>
	assert(r <= PGSIZE);
  80186b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801870:	7f 33                	jg     8018a5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801872:	83 ec 04             	sub    $0x4,%esp
  801875:	50                   	push   %eax
  801876:	68 00 50 80 00       	push   $0x805000
  80187b:	ff 75 0c             	push   0xc(%ebp)
  80187e:	e8 ee f2 ff ff       	call   800b71 <memmove>
	return r;
  801883:	83 c4 10             	add    $0x10,%esp
}
  801886:	89 d8                	mov    %ebx,%eax
  801888:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    
	assert(r <= n);
  80188f:	68 9c 2b 80 00       	push   $0x802b9c
  801894:	68 a3 2b 80 00       	push   $0x802ba3
  801899:	6a 7c                	push   $0x7c
  80189b:	68 b8 2b 80 00       	push   $0x802bb8
  8018a0:	e8 81 ea ff ff       	call   800326 <_panic>
	assert(r <= PGSIZE);
  8018a5:	68 c3 2b 80 00       	push   $0x802bc3
  8018aa:	68 a3 2b 80 00       	push   $0x802ba3
  8018af:	6a 7d                	push   $0x7d
  8018b1:	68 b8 2b 80 00       	push   $0x802bb8
  8018b6:	e8 6b ea ff ff       	call   800326 <_panic>

008018bb <open>:
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 1c             	sub    $0x1c,%esp
  8018c3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018c6:	56                   	push   %esi
  8018c7:	e8 d4 f0 ff ff       	call   8009a0 <strlen>
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d4:	7f 6c                	jg     801942 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018dc:	50                   	push   %eax
  8018dd:	e8 bd f8 ff ff       	call   80119f <fd_alloc>
  8018e2:	89 c3                	mov    %eax,%ebx
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	78 3c                	js     801927 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	56                   	push   %esi
  8018ef:	68 00 50 80 00       	push   $0x805000
  8018f4:	e8 e2 f0 ff ff       	call   8009db <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fc:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801901:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801904:	b8 01 00 00 00       	mov    $0x1,%eax
  801909:	e8 f6 fd ff ff       	call   801704 <fsipc>
  80190e:	89 c3                	mov    %eax,%ebx
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	78 19                	js     801930 <open+0x75>
	return fd2num(fd);
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	ff 75 f4             	push   -0xc(%ebp)
  80191d:	e8 56 f8 ff ff       	call   801178 <fd2num>
  801922:	89 c3                	mov    %eax,%ebx
  801924:	83 c4 10             	add    $0x10,%esp
}
  801927:	89 d8                	mov    %ebx,%eax
  801929:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    
		fd_close(fd, 0);
  801930:	83 ec 08             	sub    $0x8,%esp
  801933:	6a 00                	push   $0x0
  801935:	ff 75 f4             	push   -0xc(%ebp)
  801938:	e8 58 f9 ff ff       	call   801295 <fd_close>
		return r;
  80193d:	83 c4 10             	add    $0x10,%esp
  801940:	eb e5                	jmp    801927 <open+0x6c>
		return -E_BAD_PATH;
  801942:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801947:	eb de                	jmp    801927 <open+0x6c>

00801949 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801949:	55                   	push   %ebp
  80194a:	89 e5                	mov    %esp,%ebp
  80194c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 08 00 00 00       	mov    $0x8,%eax
  801959:	e8 a6 fd ff ff       	call   801704 <fsipc>
}
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801960:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801964:	7f 01                	jg     801967 <writebuf+0x7>
  801966:	c3                   	ret    
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	53                   	push   %ebx
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801970:	ff 70 04             	push   0x4(%eax)
  801973:	8d 40 10             	lea    0x10(%eax),%eax
  801976:	50                   	push   %eax
  801977:	ff 33                	push   (%ebx)
  801979:	e8 a8 fb ff ff       	call   801526 <write>
		if (result > 0)
  80197e:	83 c4 10             	add    $0x10,%esp
  801981:	85 c0                	test   %eax,%eax
  801983:	7e 03                	jle    801988 <writebuf+0x28>
			b->result += result;
  801985:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801988:	39 43 04             	cmp    %eax,0x4(%ebx)
  80198b:	74 0d                	je     80199a <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80198d:	85 c0                	test   %eax,%eax
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	0f 4f c2             	cmovg  %edx,%eax
  801997:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80199a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <putch>:

static void
putch(int ch, void *thunk)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 04             	sub    $0x4,%esp
  8019a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019a9:	8b 53 04             	mov    0x4(%ebx),%edx
  8019ac:	8d 42 01             	lea    0x1(%edx),%eax
  8019af:	89 43 04             	mov    %eax,0x4(%ebx)
  8019b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019b5:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019b9:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019be:	74 05                	je     8019c5 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8019c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    
		writebuf(b);
  8019c5:	89 d8                	mov    %ebx,%eax
  8019c7:	e8 94 ff ff ff       	call   801960 <writebuf>
		b->idx = 0;
  8019cc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8019d3:	eb eb                	jmp    8019c0 <putch+0x21>

008019d5 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019e7:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019ee:	00 00 00 
	b.result = 0;
  8019f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019f8:	00 00 00 
	b.error = 1;
  8019fb:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a02:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a05:	ff 75 10             	push   0x10(%ebp)
  801a08:	ff 75 0c             	push   0xc(%ebp)
  801a0b:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	68 9f 19 80 00       	push   $0x80199f
  801a17:	e8 dc ea ff ff       	call   8004f8 <vprintfmt>
	if (b.idx > 0)
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a26:	7f 11                	jg     801a39 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801a28:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    
		writebuf(&b);
  801a39:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a3f:	e8 1c ff ff ff       	call   801960 <writebuf>
  801a44:	eb e2                	jmp    801a28 <vfprintf+0x53>

00801a46 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a4c:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a4f:	50                   	push   %eax
  801a50:	ff 75 0c             	push   0xc(%ebp)
  801a53:	ff 75 08             	push   0x8(%ebp)
  801a56:	e8 7a ff ff ff       	call   8019d5 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a5b:	c9                   	leave  
  801a5c:	c3                   	ret    

00801a5d <printf>:

int
printf(const char *fmt, ...)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a63:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a66:	50                   	push   %eax
  801a67:	ff 75 08             	push   0x8(%ebp)
  801a6a:	6a 01                	push   $0x1
  801a6c:	e8 64 ff ff ff       	call   8019d5 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a79:	68 cf 2b 80 00       	push   $0x802bcf
  801a7e:	ff 75 0c             	push   0xc(%ebp)
  801a81:	e8 55 ef ff ff       	call   8009db <strcpy>
	return 0;
}
  801a86:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <devsock_close>:
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	53                   	push   %ebx
  801a91:	83 ec 10             	sub    $0x10,%esp
  801a94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a97:	53                   	push   %ebx
  801a98:	e8 f0 09 00 00       	call   80248d <pageref>
  801a9d:	89 c2                	mov    %eax,%edx
  801a9f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801aa7:	83 fa 01             	cmp    $0x1,%edx
  801aaa:	74 05                	je     801ab1 <devsock_close+0x24>
}
  801aac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aaf:	c9                   	leave  
  801ab0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	ff 73 0c             	push   0xc(%ebx)
  801ab7:	e8 b7 02 00 00       	call   801d73 <nsipc_close>
  801abc:	83 c4 10             	add    $0x10,%esp
  801abf:	eb eb                	jmp    801aac <devsock_close+0x1f>

00801ac1 <devsock_write>:
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ac7:	6a 00                	push   $0x0
  801ac9:	ff 75 10             	push   0x10(%ebp)
  801acc:	ff 75 0c             	push   0xc(%ebp)
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad2:	ff 70 0c             	push   0xc(%eax)
  801ad5:	e8 79 03 00 00       	call   801e53 <nsipc_send>
}
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <devsock_read>:
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ae2:	6a 00                	push   $0x0
  801ae4:	ff 75 10             	push   0x10(%ebp)
  801ae7:	ff 75 0c             	push   0xc(%ebp)
  801aea:	8b 45 08             	mov    0x8(%ebp),%eax
  801aed:	ff 70 0c             	push   0xc(%eax)
  801af0:	e8 ef 02 00 00       	call   801de4 <nsipc_recv>
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <fd2sockid>:
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801afd:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b00:	52                   	push   %edx
  801b01:	50                   	push   %eax
  801b02:	e8 e8 f6 ff ff       	call   8011ef <fd_lookup>
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 10                	js     801b1e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b17:	39 08                	cmp    %ecx,(%eax)
  801b19:	75 05                	jne    801b20 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b1b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    
		return -E_NOT_SUPP;
  801b20:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b25:	eb f7                	jmp    801b1e <fd2sockid+0x27>

00801b27 <alloc_sockfd>:
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	56                   	push   %esi
  801b2b:	53                   	push   %ebx
  801b2c:	83 ec 1c             	sub    $0x1c,%esp
  801b2f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b34:	50                   	push   %eax
  801b35:	e8 65 f6 ff ff       	call   80119f <fd_alloc>
  801b3a:	89 c3                	mov    %eax,%ebx
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 43                	js     801b86 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b43:	83 ec 04             	sub    $0x4,%esp
  801b46:	68 07 04 00 00       	push   $0x407
  801b4b:	ff 75 f4             	push   -0xc(%ebp)
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 82 f2 ff ff       	call   800dd7 <sys_page_alloc>
  801b55:	89 c3                	mov    %eax,%ebx
  801b57:	83 c4 10             	add    $0x10,%esp
  801b5a:	85 c0                	test   %eax,%eax
  801b5c:	78 28                	js     801b86 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b61:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b67:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b73:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b76:	83 ec 0c             	sub    $0xc,%esp
  801b79:	50                   	push   %eax
  801b7a:	e8 f9 f5 ff ff       	call   801178 <fd2num>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	eb 0c                	jmp    801b92 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	56                   	push   %esi
  801b8a:	e8 e4 01 00 00       	call   801d73 <nsipc_close>
		return r;
  801b8f:	83 c4 10             	add    $0x10,%esp
}
  801b92:	89 d8                	mov    %ebx,%eax
  801b94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5e                   	pop    %esi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <accept>:
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba4:	e8 4e ff ff ff       	call   801af7 <fd2sockid>
  801ba9:	85 c0                	test   %eax,%eax
  801bab:	78 1b                	js     801bc8 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bad:	83 ec 04             	sub    $0x4,%esp
  801bb0:	ff 75 10             	push   0x10(%ebp)
  801bb3:	ff 75 0c             	push   0xc(%ebp)
  801bb6:	50                   	push   %eax
  801bb7:	e8 0e 01 00 00       	call   801cca <nsipc_accept>
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 05                	js     801bc8 <accept+0x2d>
	return alloc_sockfd(r);
  801bc3:	e8 5f ff ff ff       	call   801b27 <alloc_sockfd>
}
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <bind>:
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd3:	e8 1f ff ff ff       	call   801af7 <fd2sockid>
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	78 12                	js     801bee <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801bdc:	83 ec 04             	sub    $0x4,%esp
  801bdf:	ff 75 10             	push   0x10(%ebp)
  801be2:	ff 75 0c             	push   0xc(%ebp)
  801be5:	50                   	push   %eax
  801be6:	e8 31 01 00 00       	call   801d1c <nsipc_bind>
  801beb:	83 c4 10             	add    $0x10,%esp
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <shutdown>:
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	e8 f9 fe ff ff       	call   801af7 <fd2sockid>
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 0f                	js     801c11 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801c02:	83 ec 08             	sub    $0x8,%esp
  801c05:	ff 75 0c             	push   0xc(%ebp)
  801c08:	50                   	push   %eax
  801c09:	e8 43 01 00 00       	call   801d51 <nsipc_shutdown>
  801c0e:	83 c4 10             	add    $0x10,%esp
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <connect>:
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c19:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1c:	e8 d6 fe ff ff       	call   801af7 <fd2sockid>
  801c21:	85 c0                	test   %eax,%eax
  801c23:	78 12                	js     801c37 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801c25:	83 ec 04             	sub    $0x4,%esp
  801c28:	ff 75 10             	push   0x10(%ebp)
  801c2b:	ff 75 0c             	push   0xc(%ebp)
  801c2e:	50                   	push   %eax
  801c2f:	e8 59 01 00 00       	call   801d8d <nsipc_connect>
  801c34:	83 c4 10             	add    $0x10,%esp
}
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    

00801c39 <listen>:
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c42:	e8 b0 fe ff ff       	call   801af7 <fd2sockid>
  801c47:	85 c0                	test   %eax,%eax
  801c49:	78 0f                	js     801c5a <listen+0x21>
	return nsipc_listen(r, backlog);
  801c4b:	83 ec 08             	sub    $0x8,%esp
  801c4e:	ff 75 0c             	push   0xc(%ebp)
  801c51:	50                   	push   %eax
  801c52:	e8 6b 01 00 00       	call   801dc2 <nsipc_listen>
  801c57:	83 c4 10             	add    $0x10,%esp
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <socket>:

int
socket(int domain, int type, int protocol)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c62:	ff 75 10             	push   0x10(%ebp)
  801c65:	ff 75 0c             	push   0xc(%ebp)
  801c68:	ff 75 08             	push   0x8(%ebp)
  801c6b:	e8 41 02 00 00       	call   801eb1 <nsipc_socket>
  801c70:	83 c4 10             	add    $0x10,%esp
  801c73:	85 c0                	test   %eax,%eax
  801c75:	78 05                	js     801c7c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c77:	e8 ab fe ff ff       	call   801b27 <alloc_sockfd>
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	53                   	push   %ebx
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c87:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c8e:	74 26                	je     801cb6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c90:	6a 07                	push   $0x7
  801c92:	68 00 70 80 00       	push   $0x807000
  801c97:	53                   	push   %ebx
  801c98:	ff 35 00 80 80 00    	push   0x808000
  801c9e:	e8 5d 07 00 00       	call   802400 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ca3:	83 c4 0c             	add    $0xc,%esp
  801ca6:	6a 00                	push   $0x0
  801ca8:	6a 00                	push   $0x0
  801caa:	6a 00                	push   $0x0
  801cac:	e8 e8 06 00 00       	call   802399 <ipc_recv>
}
  801cb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	6a 02                	push   $0x2
  801cbb:	e8 94 07 00 00       	call   802454 <ipc_find_env>
  801cc0:	a3 00 80 80 00       	mov    %eax,0x808000
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	eb c6                	jmp    801c90 <nsipc+0x12>

00801cca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	56                   	push   %esi
  801cce:	53                   	push   %ebx
  801ccf:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cda:	8b 06                	mov    (%esi),%eax
  801cdc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce6:	e8 93 ff ff ff       	call   801c7e <nsipc>
  801ceb:	89 c3                	mov    %eax,%ebx
  801ced:	85 c0                	test   %eax,%eax
  801cef:	79 09                	jns    801cfa <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801cf1:	89 d8                	mov    %ebx,%eax
  801cf3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cfa:	83 ec 04             	sub    $0x4,%esp
  801cfd:	ff 35 10 70 80 00    	push   0x807010
  801d03:	68 00 70 80 00       	push   $0x807000
  801d08:	ff 75 0c             	push   0xc(%ebp)
  801d0b:	e8 61 ee ff ff       	call   800b71 <memmove>
		*addrlen = ret->ret_addrlen;
  801d10:	a1 10 70 80 00       	mov    0x807010,%eax
  801d15:	89 06                	mov    %eax,(%esi)
  801d17:	83 c4 10             	add    $0x10,%esp
	return r;
  801d1a:	eb d5                	jmp    801cf1 <nsipc_accept+0x27>

00801d1c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	53                   	push   %ebx
  801d20:	83 ec 08             	sub    $0x8,%esp
  801d23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d26:	8b 45 08             	mov    0x8(%ebp),%eax
  801d29:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d2e:	53                   	push   %ebx
  801d2f:	ff 75 0c             	push   0xc(%ebp)
  801d32:	68 04 70 80 00       	push   $0x807004
  801d37:	e8 35 ee ff ff       	call   800b71 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d3c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d42:	b8 02 00 00 00       	mov    $0x2,%eax
  801d47:	e8 32 ff ff ff       	call   801c7e <nsipc>
}
  801d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d62:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d67:	b8 03 00 00 00       	mov    $0x3,%eax
  801d6c:	e8 0d ff ff ff       	call   801c7e <nsipc>
}
  801d71:	c9                   	leave  
  801d72:	c3                   	ret    

00801d73 <nsipc_close>:

int
nsipc_close(int s)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801d81:	b8 04 00 00 00       	mov    $0x4,%eax
  801d86:	e8 f3 fe ff ff       	call   801c7e <nsipc>
}
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    

00801d8d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	53                   	push   %ebx
  801d91:	83 ec 08             	sub    $0x8,%esp
  801d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d97:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d9f:	53                   	push   %ebx
  801da0:	ff 75 0c             	push   0xc(%ebp)
  801da3:	68 04 70 80 00       	push   $0x807004
  801da8:	e8 c4 ed ff ff       	call   800b71 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dad:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801db3:	b8 05 00 00 00       	mov    $0x5,%eax
  801db8:	e8 c1 fe ff ff       	call   801c7e <nsipc>
}
  801dbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    

00801dc2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801dd8:	b8 06 00 00 00       	mov    $0x6,%eax
  801ddd:	e8 9c fe ff ff       	call   801c7e <nsipc>
}
  801de2:	c9                   	leave  
  801de3:	c3                   	ret    

00801de4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	56                   	push   %esi
  801de8:	53                   	push   %ebx
  801de9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801df4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801dfa:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e02:	b8 07 00 00 00       	mov    $0x7,%eax
  801e07:	e8 72 fe ff ff       	call   801c7e <nsipc>
  801e0c:	89 c3                	mov    %eax,%ebx
  801e0e:	85 c0                	test   %eax,%eax
  801e10:	78 22                	js     801e34 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801e12:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e17:	39 c6                	cmp    %eax,%esi
  801e19:	0f 4e c6             	cmovle %esi,%eax
  801e1c:	39 c3                	cmp    %eax,%ebx
  801e1e:	7f 1d                	jg     801e3d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e20:	83 ec 04             	sub    $0x4,%esp
  801e23:	53                   	push   %ebx
  801e24:	68 00 70 80 00       	push   $0x807000
  801e29:	ff 75 0c             	push   0xc(%ebp)
  801e2c:	e8 40 ed ff ff       	call   800b71 <memmove>
  801e31:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e34:	89 d8                	mov    %ebx,%eax
  801e36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e39:	5b                   	pop    %ebx
  801e3a:	5e                   	pop    %esi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e3d:	68 db 2b 80 00       	push   $0x802bdb
  801e42:	68 a3 2b 80 00       	push   $0x802ba3
  801e47:	6a 62                	push   $0x62
  801e49:	68 f0 2b 80 00       	push   $0x802bf0
  801e4e:	e8 d3 e4 ff ff       	call   800326 <_panic>

00801e53 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	53                   	push   %ebx
  801e57:	83 ec 04             	sub    $0x4,%esp
  801e5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e60:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e65:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e6b:	7f 2e                	jg     801e9b <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e6d:	83 ec 04             	sub    $0x4,%esp
  801e70:	53                   	push   %ebx
  801e71:	ff 75 0c             	push   0xc(%ebp)
  801e74:	68 0c 70 80 00       	push   $0x80700c
  801e79:	e8 f3 ec ff ff       	call   800b71 <memmove>
	nsipcbuf.send.req_size = size;
  801e7e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801e84:	8b 45 14             	mov    0x14(%ebp),%eax
  801e87:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e8c:	b8 08 00 00 00       	mov    $0x8,%eax
  801e91:	e8 e8 fd ff ff       	call   801c7e <nsipc>
}
  801e96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    
	assert(size < 1600);
  801e9b:	68 fc 2b 80 00       	push   $0x802bfc
  801ea0:	68 a3 2b 80 00       	push   $0x802ba3
  801ea5:	6a 6d                	push   $0x6d
  801ea7:	68 f0 2b 80 00       	push   $0x802bf0
  801eac:	e8 75 e4 ff ff       	call   800326 <_panic>

00801eb1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec2:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801ec7:	8b 45 10             	mov    0x10(%ebp),%eax
  801eca:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801ecf:	b8 09 00 00 00       	mov    $0x9,%eax
  801ed4:	e8 a5 fd ff ff       	call   801c7e <nsipc>
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
  801ee0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ee3:	83 ec 0c             	sub    $0xc,%esp
  801ee6:	ff 75 08             	push   0x8(%ebp)
  801ee9:	e8 9a f2 ff ff       	call   801188 <fd2data>
  801eee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ef0:	83 c4 08             	add    $0x8,%esp
  801ef3:	68 08 2c 80 00       	push   $0x802c08
  801ef8:	53                   	push   %ebx
  801ef9:	e8 dd ea ff ff       	call   8009db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801efe:	8b 46 04             	mov    0x4(%esi),%eax
  801f01:	2b 06                	sub    (%esi),%eax
  801f03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f09:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f10:	00 00 00 
	stat->st_dev = &devpipe;
  801f13:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f1a:	30 80 00 
	return 0;
}
  801f1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    

00801f29 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f29:	55                   	push   %ebp
  801f2a:	89 e5                	mov    %esp,%ebp
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 0c             	sub    $0xc,%esp
  801f30:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f33:	53                   	push   %ebx
  801f34:	6a 00                	push   $0x0
  801f36:	e8 21 ef ff ff       	call   800e5c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f3b:	89 1c 24             	mov    %ebx,(%esp)
  801f3e:	e8 45 f2 ff ff       	call   801188 <fd2data>
  801f43:	83 c4 08             	add    $0x8,%esp
  801f46:	50                   	push   %eax
  801f47:	6a 00                	push   $0x0
  801f49:	e8 0e ef ff ff       	call   800e5c <sys_page_unmap>
}
  801f4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <_pipeisclosed>:
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	57                   	push   %edi
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	83 ec 1c             	sub    $0x1c,%esp
  801f5c:	89 c7                	mov    %eax,%edi
  801f5e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f60:	a1 00 44 80 00       	mov    0x804400,%eax
  801f65:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f68:	83 ec 0c             	sub    $0xc,%esp
  801f6b:	57                   	push   %edi
  801f6c:	e8 1c 05 00 00       	call   80248d <pageref>
  801f71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f74:	89 34 24             	mov    %esi,(%esp)
  801f77:	e8 11 05 00 00       	call   80248d <pageref>
		nn = thisenv->env_runs;
  801f7c:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801f82:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	39 cb                	cmp    %ecx,%ebx
  801f8a:	74 1b                	je     801fa7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f8c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f8f:	75 cf                	jne    801f60 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f91:	8b 42 58             	mov    0x58(%edx),%eax
  801f94:	6a 01                	push   $0x1
  801f96:	50                   	push   %eax
  801f97:	53                   	push   %ebx
  801f98:	68 0f 2c 80 00       	push   $0x802c0f
  801f9d:	e8 5f e4 ff ff       	call   800401 <cprintf>
  801fa2:	83 c4 10             	add    $0x10,%esp
  801fa5:	eb b9                	jmp    801f60 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801fa7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801faa:	0f 94 c0             	sete   %al
  801fad:	0f b6 c0             	movzbl %al,%eax
}
  801fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <devpipe_write>:
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	57                   	push   %edi
  801fbc:	56                   	push   %esi
  801fbd:	53                   	push   %ebx
  801fbe:	83 ec 28             	sub    $0x28,%esp
  801fc1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fc4:	56                   	push   %esi
  801fc5:	e8 be f1 ff ff       	call   801188 <fd2data>
  801fca:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fcc:	83 c4 10             	add    $0x10,%esp
  801fcf:	bf 00 00 00 00       	mov    $0x0,%edi
  801fd4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fd7:	75 09                	jne    801fe2 <devpipe_write+0x2a>
	return i;
  801fd9:	89 f8                	mov    %edi,%eax
  801fdb:	eb 23                	jmp    802000 <devpipe_write+0x48>
			sys_yield();
  801fdd:	e8 d6 ed ff ff       	call   800db8 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fe2:	8b 43 04             	mov    0x4(%ebx),%eax
  801fe5:	8b 0b                	mov    (%ebx),%ecx
  801fe7:	8d 51 20             	lea    0x20(%ecx),%edx
  801fea:	39 d0                	cmp    %edx,%eax
  801fec:	72 1a                	jb     802008 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801fee:	89 da                	mov    %ebx,%edx
  801ff0:	89 f0                	mov    %esi,%eax
  801ff2:	e8 5c ff ff ff       	call   801f53 <_pipeisclosed>
  801ff7:	85 c0                	test   %eax,%eax
  801ff9:	74 e2                	je     801fdd <devpipe_write+0x25>
				return 0;
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802000:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802008:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80200b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80200f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802012:	89 c2                	mov    %eax,%edx
  802014:	c1 fa 1f             	sar    $0x1f,%edx
  802017:	89 d1                	mov    %edx,%ecx
  802019:	c1 e9 1b             	shr    $0x1b,%ecx
  80201c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80201f:	83 e2 1f             	and    $0x1f,%edx
  802022:	29 ca                	sub    %ecx,%edx
  802024:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802028:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80202c:	83 c0 01             	add    $0x1,%eax
  80202f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802032:	83 c7 01             	add    $0x1,%edi
  802035:	eb 9d                	jmp    801fd4 <devpipe_write+0x1c>

00802037 <devpipe_read>:
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	57                   	push   %edi
  80203b:	56                   	push   %esi
  80203c:	53                   	push   %ebx
  80203d:	83 ec 18             	sub    $0x18,%esp
  802040:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802043:	57                   	push   %edi
  802044:	e8 3f f1 ff ff       	call   801188 <fd2data>
  802049:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	be 00 00 00 00       	mov    $0x0,%esi
  802053:	3b 75 10             	cmp    0x10(%ebp),%esi
  802056:	75 13                	jne    80206b <devpipe_read+0x34>
	return i;
  802058:	89 f0                	mov    %esi,%eax
  80205a:	eb 02                	jmp    80205e <devpipe_read+0x27>
				return i;
  80205c:	89 f0                	mov    %esi,%eax
}
  80205e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
			sys_yield();
  802066:	e8 4d ed ff ff       	call   800db8 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80206b:	8b 03                	mov    (%ebx),%eax
  80206d:	3b 43 04             	cmp    0x4(%ebx),%eax
  802070:	75 18                	jne    80208a <devpipe_read+0x53>
			if (i > 0)
  802072:	85 f6                	test   %esi,%esi
  802074:	75 e6                	jne    80205c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802076:	89 da                	mov    %ebx,%edx
  802078:	89 f8                	mov    %edi,%eax
  80207a:	e8 d4 fe ff ff       	call   801f53 <_pipeisclosed>
  80207f:	85 c0                	test   %eax,%eax
  802081:	74 e3                	je     802066 <devpipe_read+0x2f>
				return 0;
  802083:	b8 00 00 00 00       	mov    $0x0,%eax
  802088:	eb d4                	jmp    80205e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80208a:	99                   	cltd   
  80208b:	c1 ea 1b             	shr    $0x1b,%edx
  80208e:	01 d0                	add    %edx,%eax
  802090:	83 e0 1f             	and    $0x1f,%eax
  802093:	29 d0                	sub    %edx,%eax
  802095:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80209a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020a0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020a3:	83 c6 01             	add    $0x1,%esi
  8020a6:	eb ab                	jmp    802053 <devpipe_read+0x1c>

008020a8 <pipe>:
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	56                   	push   %esi
  8020ac:	53                   	push   %ebx
  8020ad:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b3:	50                   	push   %eax
  8020b4:	e8 e6 f0 ff ff       	call   80119f <fd_alloc>
  8020b9:	89 c3                	mov    %eax,%ebx
  8020bb:	83 c4 10             	add    $0x10,%esp
  8020be:	85 c0                	test   %eax,%eax
  8020c0:	0f 88 23 01 00 00    	js     8021e9 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c6:	83 ec 04             	sub    $0x4,%esp
  8020c9:	68 07 04 00 00       	push   $0x407
  8020ce:	ff 75 f4             	push   -0xc(%ebp)
  8020d1:	6a 00                	push   $0x0
  8020d3:	e8 ff ec ff ff       	call   800dd7 <sys_page_alloc>
  8020d8:	89 c3                	mov    %eax,%ebx
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	0f 88 04 01 00 00    	js     8021e9 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8020e5:	83 ec 0c             	sub    $0xc,%esp
  8020e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020eb:	50                   	push   %eax
  8020ec:	e8 ae f0 ff ff       	call   80119f <fd_alloc>
  8020f1:	89 c3                	mov    %eax,%ebx
  8020f3:	83 c4 10             	add    $0x10,%esp
  8020f6:	85 c0                	test   %eax,%eax
  8020f8:	0f 88 db 00 00 00    	js     8021d9 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020fe:	83 ec 04             	sub    $0x4,%esp
  802101:	68 07 04 00 00       	push   $0x407
  802106:	ff 75 f0             	push   -0x10(%ebp)
  802109:	6a 00                	push   $0x0
  80210b:	e8 c7 ec ff ff       	call   800dd7 <sys_page_alloc>
  802110:	89 c3                	mov    %eax,%ebx
  802112:	83 c4 10             	add    $0x10,%esp
  802115:	85 c0                	test   %eax,%eax
  802117:	0f 88 bc 00 00 00    	js     8021d9 <pipe+0x131>
	va = fd2data(fd0);
  80211d:	83 ec 0c             	sub    $0xc,%esp
  802120:	ff 75 f4             	push   -0xc(%ebp)
  802123:	e8 60 f0 ff ff       	call   801188 <fd2data>
  802128:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212a:	83 c4 0c             	add    $0xc,%esp
  80212d:	68 07 04 00 00       	push   $0x407
  802132:	50                   	push   %eax
  802133:	6a 00                	push   $0x0
  802135:	e8 9d ec ff ff       	call   800dd7 <sys_page_alloc>
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 c0                	test   %eax,%eax
  802141:	0f 88 82 00 00 00    	js     8021c9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802147:	83 ec 0c             	sub    $0xc,%esp
  80214a:	ff 75 f0             	push   -0x10(%ebp)
  80214d:	e8 36 f0 ff ff       	call   801188 <fd2data>
  802152:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802159:	50                   	push   %eax
  80215a:	6a 00                	push   $0x0
  80215c:	56                   	push   %esi
  80215d:	6a 00                	push   $0x0
  80215f:	e8 b6 ec ff ff       	call   800e1a <sys_page_map>
  802164:	89 c3                	mov    %eax,%ebx
  802166:	83 c4 20             	add    $0x20,%esp
  802169:	85 c0                	test   %eax,%eax
  80216b:	78 4e                	js     8021bb <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80216d:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802172:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802175:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802177:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80217a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802181:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802184:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802186:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802189:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802190:	83 ec 0c             	sub    $0xc,%esp
  802193:	ff 75 f4             	push   -0xc(%ebp)
  802196:	e8 dd ef ff ff       	call   801178 <fd2num>
  80219b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021a0:	83 c4 04             	add    $0x4,%esp
  8021a3:	ff 75 f0             	push   -0x10(%ebp)
  8021a6:	e8 cd ef ff ff       	call   801178 <fd2num>
  8021ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ae:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021b9:	eb 2e                	jmp    8021e9 <pipe+0x141>
	sys_page_unmap(0, va);
  8021bb:	83 ec 08             	sub    $0x8,%esp
  8021be:	56                   	push   %esi
  8021bf:	6a 00                	push   $0x0
  8021c1:	e8 96 ec ff ff       	call   800e5c <sys_page_unmap>
  8021c6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021c9:	83 ec 08             	sub    $0x8,%esp
  8021cc:	ff 75 f0             	push   -0x10(%ebp)
  8021cf:	6a 00                	push   $0x0
  8021d1:	e8 86 ec ff ff       	call   800e5c <sys_page_unmap>
  8021d6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8021d9:	83 ec 08             	sub    $0x8,%esp
  8021dc:	ff 75 f4             	push   -0xc(%ebp)
  8021df:	6a 00                	push   $0x0
  8021e1:	e8 76 ec ff ff       	call   800e5c <sys_page_unmap>
  8021e6:	83 c4 10             	add    $0x10,%esp
}
  8021e9:	89 d8                	mov    %ebx,%eax
  8021eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ee:	5b                   	pop    %ebx
  8021ef:	5e                   	pop    %esi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    

008021f2 <pipeisclosed>:
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fb:	50                   	push   %eax
  8021fc:	ff 75 08             	push   0x8(%ebp)
  8021ff:	e8 eb ef ff ff       	call   8011ef <fd_lookup>
  802204:	83 c4 10             	add    $0x10,%esp
  802207:	85 c0                	test   %eax,%eax
  802209:	78 18                	js     802223 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80220b:	83 ec 0c             	sub    $0xc,%esp
  80220e:	ff 75 f4             	push   -0xc(%ebp)
  802211:	e8 72 ef ff ff       	call   801188 <fd2data>
  802216:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802218:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221b:	e8 33 fd ff ff       	call   801f53 <_pipeisclosed>
  802220:	83 c4 10             	add    $0x10,%esp
}
  802223:	c9                   	leave  
  802224:	c3                   	ret    

00802225 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802225:	b8 00 00 00 00       	mov    $0x0,%eax
  80222a:	c3                   	ret    

0080222b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802231:	68 27 2c 80 00       	push   $0x802c27
  802236:	ff 75 0c             	push   0xc(%ebp)
  802239:	e8 9d e7 ff ff       	call   8009db <strcpy>
	return 0;
}
  80223e:	b8 00 00 00 00       	mov    $0x0,%eax
  802243:	c9                   	leave  
  802244:	c3                   	ret    

00802245 <devcons_write>:
{
  802245:	55                   	push   %ebp
  802246:	89 e5                	mov    %esp,%ebp
  802248:	57                   	push   %edi
  802249:	56                   	push   %esi
  80224a:	53                   	push   %ebx
  80224b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802251:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802256:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80225c:	eb 2e                	jmp    80228c <devcons_write+0x47>
		m = n - tot;
  80225e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802261:	29 f3                	sub    %esi,%ebx
  802263:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802268:	39 c3                	cmp    %eax,%ebx
  80226a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80226d:	83 ec 04             	sub    $0x4,%esp
  802270:	53                   	push   %ebx
  802271:	89 f0                	mov    %esi,%eax
  802273:	03 45 0c             	add    0xc(%ebp),%eax
  802276:	50                   	push   %eax
  802277:	57                   	push   %edi
  802278:	e8 f4 e8 ff ff       	call   800b71 <memmove>
		sys_cputs(buf, m);
  80227d:	83 c4 08             	add    $0x8,%esp
  802280:	53                   	push   %ebx
  802281:	57                   	push   %edi
  802282:	e8 94 ea ff ff       	call   800d1b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802287:	01 de                	add    %ebx,%esi
  802289:	83 c4 10             	add    $0x10,%esp
  80228c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80228f:	72 cd                	jb     80225e <devcons_write+0x19>
}
  802291:	89 f0                	mov    %esi,%eax
  802293:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802296:	5b                   	pop    %ebx
  802297:	5e                   	pop    %esi
  802298:	5f                   	pop    %edi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    

0080229b <devcons_read>:
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 08             	sub    $0x8,%esp
  8022a1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8022a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022aa:	75 07                	jne    8022b3 <devcons_read+0x18>
  8022ac:	eb 1f                	jmp    8022cd <devcons_read+0x32>
		sys_yield();
  8022ae:	e8 05 eb ff ff       	call   800db8 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8022b3:	e8 81 ea ff ff       	call   800d39 <sys_cgetc>
  8022b8:	85 c0                	test   %eax,%eax
  8022ba:	74 f2                	je     8022ae <devcons_read+0x13>
	if (c < 0)
  8022bc:	78 0f                	js     8022cd <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8022be:	83 f8 04             	cmp    $0x4,%eax
  8022c1:	74 0c                	je     8022cf <devcons_read+0x34>
	*(char*)vbuf = c;
  8022c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022c6:	88 02                	mov    %al,(%edx)
	return 1;
  8022c8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8022cd:	c9                   	leave  
  8022ce:	c3                   	ret    
		return 0;
  8022cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d4:	eb f7                	jmp    8022cd <devcons_read+0x32>

008022d6 <cputchar>:
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022df:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8022e2:	6a 01                	push   $0x1
  8022e4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022e7:	50                   	push   %eax
  8022e8:	e8 2e ea ff ff       	call   800d1b <sys_cputs>
}
  8022ed:	83 c4 10             	add    $0x10,%esp
  8022f0:	c9                   	leave  
  8022f1:	c3                   	ret    

008022f2 <getchar>:
{
  8022f2:	55                   	push   %ebp
  8022f3:	89 e5                	mov    %esp,%ebp
  8022f5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8022f8:	6a 01                	push   $0x1
  8022fa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022fd:	50                   	push   %eax
  8022fe:	6a 00                	push   $0x0
  802300:	e8 53 f1 ff ff       	call   801458 <read>
	if (r < 0)
  802305:	83 c4 10             	add    $0x10,%esp
  802308:	85 c0                	test   %eax,%eax
  80230a:	78 06                	js     802312 <getchar+0x20>
	if (r < 1)
  80230c:	74 06                	je     802314 <getchar+0x22>
	return c;
  80230e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802312:	c9                   	leave  
  802313:	c3                   	ret    
		return -E_EOF;
  802314:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802319:	eb f7                	jmp    802312 <getchar+0x20>

0080231b <iscons>:
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802324:	50                   	push   %eax
  802325:	ff 75 08             	push   0x8(%ebp)
  802328:	e8 c2 ee ff ff       	call   8011ef <fd_lookup>
  80232d:	83 c4 10             	add    $0x10,%esp
  802330:	85 c0                	test   %eax,%eax
  802332:	78 11                	js     802345 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802337:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80233d:	39 10                	cmp    %edx,(%eax)
  80233f:	0f 94 c0             	sete   %al
  802342:	0f b6 c0             	movzbl %al,%eax
}
  802345:	c9                   	leave  
  802346:	c3                   	ret    

00802347 <opencons>:
{
  802347:	55                   	push   %ebp
  802348:	89 e5                	mov    %esp,%ebp
  80234a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80234d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802350:	50                   	push   %eax
  802351:	e8 49 ee ff ff       	call   80119f <fd_alloc>
  802356:	83 c4 10             	add    $0x10,%esp
  802359:	85 c0                	test   %eax,%eax
  80235b:	78 3a                	js     802397 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80235d:	83 ec 04             	sub    $0x4,%esp
  802360:	68 07 04 00 00       	push   $0x407
  802365:	ff 75 f4             	push   -0xc(%ebp)
  802368:	6a 00                	push   $0x0
  80236a:	e8 68 ea ff ff       	call   800dd7 <sys_page_alloc>
  80236f:	83 c4 10             	add    $0x10,%esp
  802372:	85 c0                	test   %eax,%eax
  802374:	78 21                	js     802397 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802379:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80237f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802381:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802384:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80238b:	83 ec 0c             	sub    $0xc,%esp
  80238e:	50                   	push   %eax
  80238f:	e8 e4 ed ff ff       	call   801178 <fd2num>
  802394:	83 c4 10             	add    $0x10,%esp
}
  802397:	c9                   	leave  
  802398:	c3                   	ret    

00802399 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802399:	55                   	push   %ebp
  80239a:	89 e5                	mov    %esp,%ebp
  80239c:	56                   	push   %esi
  80239d:	53                   	push   %ebx
  80239e:	8b 75 08             	mov    0x8(%ebp),%esi
  8023a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023ae:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8023b1:	83 ec 0c             	sub    $0xc,%esp
  8023b4:	50                   	push   %eax
  8023b5:	e8 cd eb ff ff       	call   800f87 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8023ba:	83 c4 10             	add    $0x10,%esp
  8023bd:	85 f6                	test   %esi,%esi
  8023bf:	74 14                	je     8023d5 <ipc_recv+0x3c>
  8023c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c6:	85 c0                	test   %eax,%eax
  8023c8:	78 09                	js     8023d3 <ipc_recv+0x3a>
  8023ca:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023d0:	8b 52 74             	mov    0x74(%edx),%edx
  8023d3:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8023d5:	85 db                	test   %ebx,%ebx
  8023d7:	74 14                	je     8023ed <ipc_recv+0x54>
  8023d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023de:	85 c0                	test   %eax,%eax
  8023e0:	78 09                	js     8023eb <ipc_recv+0x52>
  8023e2:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023e8:	8b 52 78             	mov    0x78(%edx),%edx
  8023eb:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	78 08                	js     8023f9 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8023f1:	a1 00 44 80 00       	mov    0x804400,%eax
  8023f6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023fc:	5b                   	pop    %ebx
  8023fd:	5e                   	pop    %esi
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    

00802400 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	57                   	push   %edi
  802404:	56                   	push   %esi
  802405:	53                   	push   %ebx
  802406:	83 ec 0c             	sub    $0xc,%esp
  802409:	8b 7d 08             	mov    0x8(%ebp),%edi
  80240c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80240f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802412:	85 db                	test   %ebx,%ebx
  802414:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802419:	0f 44 d8             	cmove  %eax,%ebx
  80241c:	eb 05                	jmp    802423 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80241e:	e8 95 e9 ff ff       	call   800db8 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802423:	ff 75 14             	push   0x14(%ebp)
  802426:	53                   	push   %ebx
  802427:	56                   	push   %esi
  802428:	57                   	push   %edi
  802429:	e8 36 eb ff ff       	call   800f64 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80242e:	83 c4 10             	add    $0x10,%esp
  802431:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802434:	74 e8                	je     80241e <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802436:	85 c0                	test   %eax,%eax
  802438:	78 08                	js     802442 <ipc_send+0x42>
	}while (r<0);

}
  80243a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5e                   	pop    %esi
  80243f:	5f                   	pop    %edi
  802440:	5d                   	pop    %ebp
  802441:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802442:	50                   	push   %eax
  802443:	68 33 2c 80 00       	push   $0x802c33
  802448:	6a 3d                	push   $0x3d
  80244a:	68 47 2c 80 00       	push   $0x802c47
  80244f:	e8 d2 de ff ff       	call   800326 <_panic>

00802454 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802454:	55                   	push   %ebp
  802455:	89 e5                	mov    %esp,%ebp
  802457:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80245a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80245f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802462:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802468:	8b 52 50             	mov    0x50(%edx),%edx
  80246b:	39 ca                	cmp    %ecx,%edx
  80246d:	74 11                	je     802480 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80246f:	83 c0 01             	add    $0x1,%eax
  802472:	3d 00 04 00 00       	cmp    $0x400,%eax
  802477:	75 e6                	jne    80245f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802479:	b8 00 00 00 00       	mov    $0x0,%eax
  80247e:	eb 0b                	jmp    80248b <ipc_find_env+0x37>
			return envs[i].env_id;
  802480:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802483:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802488:	8b 40 48             	mov    0x48(%eax),%eax
}
  80248b:	5d                   	pop    %ebp
  80248c:	c3                   	ret    

0080248d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80248d:	55                   	push   %ebp
  80248e:	89 e5                	mov    %esp,%ebp
  802490:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802493:	89 c2                	mov    %eax,%edx
  802495:	c1 ea 16             	shr    $0x16,%edx
  802498:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80249f:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024a4:	f6 c1 01             	test   $0x1,%cl
  8024a7:	74 1c                	je     8024c5 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8024a9:	c1 e8 0c             	shr    $0xc,%eax
  8024ac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024b3:	a8 01                	test   $0x1,%al
  8024b5:	74 0e                	je     8024c5 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024b7:	c1 e8 0c             	shr    $0xc,%eax
  8024ba:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024c1:	ef 
  8024c2:	0f b7 d2             	movzwl %dx,%edx
}
  8024c5:	89 d0                	mov    %edx,%eax
  8024c7:	5d                   	pop    %ebp
  8024c8:	c3                   	ret    
  8024c9:	66 90                	xchg   %ax,%ax
  8024cb:	66 90                	xchg   %ax,%ax
  8024cd:	66 90                	xchg   %ax,%ax
  8024cf:	90                   	nop

008024d0 <__udivdi3>:
  8024d0:	f3 0f 1e fb          	endbr32 
  8024d4:	55                   	push   %ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 1c             	sub    $0x1c,%esp
  8024db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024eb:	85 c0                	test   %eax,%eax
  8024ed:	75 19                	jne    802508 <__udivdi3+0x38>
  8024ef:	39 f3                	cmp    %esi,%ebx
  8024f1:	76 4d                	jbe    802540 <__udivdi3+0x70>
  8024f3:	31 ff                	xor    %edi,%edi
  8024f5:	89 e8                	mov    %ebp,%eax
  8024f7:	89 f2                	mov    %esi,%edx
  8024f9:	f7 f3                	div    %ebx
  8024fb:	89 fa                	mov    %edi,%edx
  8024fd:	83 c4 1c             	add    $0x1c,%esp
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi
  802508:	39 f0                	cmp    %esi,%eax
  80250a:	76 14                	jbe    802520 <__udivdi3+0x50>
  80250c:	31 ff                	xor    %edi,%edi
  80250e:	31 c0                	xor    %eax,%eax
  802510:	89 fa                	mov    %edi,%edx
  802512:	83 c4 1c             	add    $0x1c,%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	0f bd f8             	bsr    %eax,%edi
  802523:	83 f7 1f             	xor    $0x1f,%edi
  802526:	75 48                	jne    802570 <__udivdi3+0xa0>
  802528:	39 f0                	cmp    %esi,%eax
  80252a:	72 06                	jb     802532 <__udivdi3+0x62>
  80252c:	31 c0                	xor    %eax,%eax
  80252e:	39 eb                	cmp    %ebp,%ebx
  802530:	77 de                	ja     802510 <__udivdi3+0x40>
  802532:	b8 01 00 00 00       	mov    $0x1,%eax
  802537:	eb d7                	jmp    802510 <__udivdi3+0x40>
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d9                	mov    %ebx,%ecx
  802542:	85 db                	test   %ebx,%ebx
  802544:	75 0b                	jne    802551 <__udivdi3+0x81>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f3                	div    %ebx
  80254f:	89 c1                	mov    %eax,%ecx
  802551:	31 d2                	xor    %edx,%edx
  802553:	89 f0                	mov    %esi,%eax
  802555:	f7 f1                	div    %ecx
  802557:	89 c6                	mov    %eax,%esi
  802559:	89 e8                	mov    %ebp,%eax
  80255b:	89 f7                	mov    %esi,%edi
  80255d:	f7 f1                	div    %ecx
  80255f:	89 fa                	mov    %edi,%edx
  802561:	83 c4 1c             	add    $0x1c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	89 f9                	mov    %edi,%ecx
  802572:	ba 20 00 00 00       	mov    $0x20,%edx
  802577:	29 fa                	sub    %edi,%edx
  802579:	d3 e0                	shl    %cl,%eax
  80257b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80257f:	89 d1                	mov    %edx,%ecx
  802581:	89 d8                	mov    %ebx,%eax
  802583:	d3 e8                	shr    %cl,%eax
  802585:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802589:	09 c1                	or     %eax,%ecx
  80258b:	89 f0                	mov    %esi,%eax
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f9                	mov    %edi,%ecx
  802593:	d3 e3                	shl    %cl,%ebx
  802595:	89 d1                	mov    %edx,%ecx
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 f9                	mov    %edi,%ecx
  80259b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80259f:	89 eb                	mov    %ebp,%ebx
  8025a1:	d3 e6                	shl    %cl,%esi
  8025a3:	89 d1                	mov    %edx,%ecx
  8025a5:	d3 eb                	shr    %cl,%ebx
  8025a7:	09 f3                	or     %esi,%ebx
  8025a9:	89 c6                	mov    %eax,%esi
  8025ab:	89 f2                	mov    %esi,%edx
  8025ad:	89 d8                	mov    %ebx,%eax
  8025af:	f7 74 24 08          	divl   0x8(%esp)
  8025b3:	89 d6                	mov    %edx,%esi
  8025b5:	89 c3                	mov    %eax,%ebx
  8025b7:	f7 64 24 0c          	mull   0xc(%esp)
  8025bb:	39 d6                	cmp    %edx,%esi
  8025bd:	72 19                	jb     8025d8 <__udivdi3+0x108>
  8025bf:	89 f9                	mov    %edi,%ecx
  8025c1:	d3 e5                	shl    %cl,%ebp
  8025c3:	39 c5                	cmp    %eax,%ebp
  8025c5:	73 04                	jae    8025cb <__udivdi3+0xfb>
  8025c7:	39 d6                	cmp    %edx,%esi
  8025c9:	74 0d                	je     8025d8 <__udivdi3+0x108>
  8025cb:	89 d8                	mov    %ebx,%eax
  8025cd:	31 ff                	xor    %edi,%edi
  8025cf:	e9 3c ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025db:	31 ff                	xor    %edi,%edi
  8025dd:	e9 2e ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025e2:	66 90                	xchg   %ax,%ax
  8025e4:	66 90                	xchg   %ax,%ax
  8025e6:	66 90                	xchg   %ax,%ax
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__umoddi3>:
  8025f0:	f3 0f 1e fb          	endbr32 
  8025f4:	55                   	push   %ebp
  8025f5:	57                   	push   %edi
  8025f6:	56                   	push   %esi
  8025f7:	53                   	push   %ebx
  8025f8:	83 ec 1c             	sub    $0x1c,%esp
  8025fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802603:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802607:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80260b:	89 f0                	mov    %esi,%eax
  80260d:	89 da                	mov    %ebx,%edx
  80260f:	85 ff                	test   %edi,%edi
  802611:	75 15                	jne    802628 <__umoddi3+0x38>
  802613:	39 dd                	cmp    %ebx,%ebp
  802615:	76 39                	jbe    802650 <__umoddi3+0x60>
  802617:	f7 f5                	div    %ebp
  802619:	89 d0                	mov    %edx,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	83 c4 1c             	add    $0x1c,%esp
  802620:	5b                   	pop    %ebx
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	8d 76 00             	lea    0x0(%esi),%esi
  802628:	39 df                	cmp    %ebx,%edi
  80262a:	77 f1                	ja     80261d <__umoddi3+0x2d>
  80262c:	0f bd cf             	bsr    %edi,%ecx
  80262f:	83 f1 1f             	xor    $0x1f,%ecx
  802632:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802636:	75 40                	jne    802678 <__umoddi3+0x88>
  802638:	39 df                	cmp    %ebx,%edi
  80263a:	72 04                	jb     802640 <__umoddi3+0x50>
  80263c:	39 f5                	cmp    %esi,%ebp
  80263e:	77 dd                	ja     80261d <__umoddi3+0x2d>
  802640:	89 da                	mov    %ebx,%edx
  802642:	89 f0                	mov    %esi,%eax
  802644:	29 e8                	sub    %ebp,%eax
  802646:	19 fa                	sbb    %edi,%edx
  802648:	eb d3                	jmp    80261d <__umoddi3+0x2d>
  80264a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802650:	89 e9                	mov    %ebp,%ecx
  802652:	85 ed                	test   %ebp,%ebp
  802654:	75 0b                	jne    802661 <__umoddi3+0x71>
  802656:	b8 01 00 00 00       	mov    $0x1,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	f7 f5                	div    %ebp
  80265f:	89 c1                	mov    %eax,%ecx
  802661:	89 d8                	mov    %ebx,%eax
  802663:	31 d2                	xor    %edx,%edx
  802665:	f7 f1                	div    %ecx
  802667:	89 f0                	mov    %esi,%eax
  802669:	f7 f1                	div    %ecx
  80266b:	89 d0                	mov    %edx,%eax
  80266d:	31 d2                	xor    %edx,%edx
  80266f:	eb ac                	jmp    80261d <__umoddi3+0x2d>
  802671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802678:	8b 44 24 04          	mov    0x4(%esp),%eax
  80267c:	ba 20 00 00 00       	mov    $0x20,%edx
  802681:	29 c2                	sub    %eax,%edx
  802683:	89 c1                	mov    %eax,%ecx
  802685:	89 e8                	mov    %ebp,%eax
  802687:	d3 e7                	shl    %cl,%edi
  802689:	89 d1                	mov    %edx,%ecx
  80268b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80268f:	d3 e8                	shr    %cl,%eax
  802691:	89 c1                	mov    %eax,%ecx
  802693:	8b 44 24 04          	mov    0x4(%esp),%eax
  802697:	09 f9                	or     %edi,%ecx
  802699:	89 df                	mov    %ebx,%edi
  80269b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80269f:	89 c1                	mov    %eax,%ecx
  8026a1:	d3 e5                	shl    %cl,%ebp
  8026a3:	89 d1                	mov    %edx,%ecx
  8026a5:	d3 ef                	shr    %cl,%edi
  8026a7:	89 c1                	mov    %eax,%ecx
  8026a9:	89 f0                	mov    %esi,%eax
  8026ab:	d3 e3                	shl    %cl,%ebx
  8026ad:	89 d1                	mov    %edx,%ecx
  8026af:	89 fa                	mov    %edi,%edx
  8026b1:	d3 e8                	shr    %cl,%eax
  8026b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026b8:	09 d8                	or     %ebx,%eax
  8026ba:	f7 74 24 08          	divl   0x8(%esp)
  8026be:	89 d3                	mov    %edx,%ebx
  8026c0:	d3 e6                	shl    %cl,%esi
  8026c2:	f7 e5                	mul    %ebp
  8026c4:	89 c7                	mov    %eax,%edi
  8026c6:	89 d1                	mov    %edx,%ecx
  8026c8:	39 d3                	cmp    %edx,%ebx
  8026ca:	72 06                	jb     8026d2 <__umoddi3+0xe2>
  8026cc:	75 0e                	jne    8026dc <__umoddi3+0xec>
  8026ce:	39 c6                	cmp    %eax,%esi
  8026d0:	73 0a                	jae    8026dc <__umoddi3+0xec>
  8026d2:	29 e8                	sub    %ebp,%eax
  8026d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026d8:	89 d1                	mov    %edx,%ecx
  8026da:	89 c7                	mov    %eax,%edi
  8026dc:	89 f5                	mov    %esi,%ebp
  8026de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026e2:	29 fd                	sub    %edi,%ebp
  8026e4:	19 cb                	sbb    %ecx,%ebx
  8026e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026eb:	89 d8                	mov    %ebx,%eax
  8026ed:	d3 e0                	shl    %cl,%eax
  8026ef:	89 f1                	mov    %esi,%ecx
  8026f1:	d3 ed                	shr    %cl,%ebp
  8026f3:	d3 eb                	shr    %cl,%ebx
  8026f5:	09 e8                	or     %ebp,%eax
  8026f7:	89 da                	mov    %ebx,%edx
  8026f9:	83 c4 1c             	add    $0x1c,%esp
  8026fc:	5b                   	pop    %ebx
  8026fd:	5e                   	pop    %esi
  8026fe:	5f                   	pop    %edi
  8026ff:	5d                   	pop    %ebp
  802700:	c3                   	ret    
