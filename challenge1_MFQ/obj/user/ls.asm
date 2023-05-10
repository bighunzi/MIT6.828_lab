
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
  80005f:	e8 fc 19 00 00       	call   801a60 <printf>
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
  80007f:	e8 dc 19 00 00       	call   801a60 <printf>
  800084:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	ff 75 14             	push   0x14(%ebp)
  80008d:	68 b5 2b 80 00       	push   $0x802bb5
  800092:	e8 c9 19 00 00       	call   801a60 <printf>
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
  8000b1:	e8 aa 19 00 00       	call   801a60 <printf>
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
  8000c4:	e8 da 08 00 00       	call   8009a3 <strlen>
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
  8000e8:	e8 73 19 00 00       	call   801a60 <printf>
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
  800104:	e8 b5 17 00 00       	call   8018be <open>
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
  800122:	e8 bb 13 00 00       	call   8014e2 <readn>
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
  80016d:	e8 b7 01 00 00       	call   800329 <_panic>
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
  80018d:	e8 97 01 00 00       	call   800329 <_panic>
		panic("error reading directory %s: %e", path, n);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	57                   	push   %edi
  800197:	68 8c 27 80 00       	push   $0x80278c
  80019c:	6a 24                	push   $0x24
  80019e:	68 3c 27 80 00       	push   $0x80273c
  8001a3:	e8 81 01 00 00       	call   800329 <_panic>

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
  8001bd:	e8 06 15 00 00       	call   8016c8 <stat>
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
  800206:	e8 1e 01 00 00       	call   800329 <_panic>
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
  800227:	e8 34 18 00 00       	call   801a60 <printf>
	exit();
  80022c:	e8 de 00 00 00       	call   80030f <exit>
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
  80024a:	e8 dd 0d 00 00       	call   80102c <argstart>
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
  800263:	e8 f4 0d 00 00       	call   80105c <argnext>
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
  8002d1:	e8 c6 0a 00 00       	call   800d9c <sys_getenvid>
  8002d6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002db:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8002e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e6:	a3 00 44 80 00       	mov    %eax,0x804400

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	7e 07                	jle    8002f6 <libmain+0x30>
		binaryname = argv[0];
  8002ef:	8b 06                	mov    (%esi),%eax
  8002f1:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	e8 36 ff ff ff       	call   800236 <umain>

	// exit gracefully
	exit();
  800300:	e8 0a 00 00 00       	call   80030f <exit>
}
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80030b:	5b                   	pop    %ebx
  80030c:	5e                   	pop    %esi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800315:	e8 32 10 00 00       	call   80134c <close_all>
	sys_env_destroy(0);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	6a 00                	push   $0x0
  80031f:	e8 37 0a 00 00       	call   800d5b <sys_env_destroy>
}
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800331:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800337:	e8 60 0a 00 00       	call   800d9c <sys_getenvid>
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	ff 75 0c             	push   0xc(%ebp)
  800342:	ff 75 08             	push   0x8(%ebp)
  800345:	56                   	push   %esi
  800346:	50                   	push   %eax
  800347:	68 b8 27 80 00       	push   $0x8027b8
  80034c:	e8 b3 00 00 00       	call   800404 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800351:	83 c4 18             	add    $0x18,%esp
  800354:	53                   	push   %ebx
  800355:	ff 75 10             	push   0x10(%ebp)
  800358:	e8 56 00 00 00       	call   8003b3 <vcprintf>
	cprintf("\n");
  80035d:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  800364:	e8 9b 00 00 00       	call   800404 <cprintf>
  800369:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036c:	cc                   	int3   
  80036d:	eb fd                	jmp    80036c <_panic+0x43>

0080036f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	53                   	push   %ebx
  800373:	83 ec 04             	sub    $0x4,%esp
  800376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800379:	8b 13                	mov    (%ebx),%edx
  80037b:	8d 42 01             	lea    0x1(%edx),%eax
  80037e:	89 03                	mov    %eax,(%ebx)
  800380:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800383:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800387:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038c:	74 09                	je     800397 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80038e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800395:	c9                   	leave  
  800396:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	68 ff 00 00 00       	push   $0xff
  80039f:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a2:	50                   	push   %eax
  8003a3:	e8 76 09 00 00       	call   800d1e <sys_cputs>
		b->idx = 0;
  8003a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ae:	83 c4 10             	add    $0x10,%esp
  8003b1:	eb db                	jmp    80038e <putch+0x1f>

008003b3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c3:	00 00 00 
	b.cnt = 0;
  8003c6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003cd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d0:	ff 75 0c             	push   0xc(%ebp)
  8003d3:	ff 75 08             	push   0x8(%ebp)
  8003d6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	68 6f 03 80 00       	push   $0x80036f
  8003e2:	e8 14 01 00 00       	call   8004fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e7:	83 c4 08             	add    $0x8,%esp
  8003ea:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003f0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f6:	50                   	push   %eax
  8003f7:	e8 22 09 00 00       	call   800d1e <sys_cputs>

	return b.cnt;
}
  8003fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040d:	50                   	push   %eax
  80040e:	ff 75 08             	push   0x8(%ebp)
  800411:	e8 9d ff ff ff       	call   8003b3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	57                   	push   %edi
  80041c:	56                   	push   %esi
  80041d:	53                   	push   %ebx
  80041e:	83 ec 1c             	sub    $0x1c,%esp
  800421:	89 c7                	mov    %eax,%edi
  800423:	89 d6                	mov    %edx,%esi
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
  800428:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042b:	89 d1                	mov    %edx,%ecx
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800432:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800435:	8b 45 10             	mov    0x10(%ebp),%eax
  800438:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800445:	39 c2                	cmp    %eax,%edx
  800447:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80044a:	72 3e                	jb     80048a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044c:	83 ec 0c             	sub    $0xc,%esp
  80044f:	ff 75 18             	push   0x18(%ebp)
  800452:	83 eb 01             	sub    $0x1,%ebx
  800455:	53                   	push   %ebx
  800456:	50                   	push   %eax
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 e4             	push   -0x1c(%ebp)
  80045d:	ff 75 e0             	push   -0x20(%ebp)
  800460:	ff 75 dc             	push   -0x24(%ebp)
  800463:	ff 75 d8             	push   -0x28(%ebp)
  800466:	e8 75 20 00 00       	call   8024e0 <__udivdi3>
  80046b:	83 c4 18             	add    $0x18,%esp
  80046e:	52                   	push   %edx
  80046f:	50                   	push   %eax
  800470:	89 f2                	mov    %esi,%edx
  800472:	89 f8                	mov    %edi,%eax
  800474:	e8 9f ff ff ff       	call   800418 <printnum>
  800479:	83 c4 20             	add    $0x20,%esp
  80047c:	eb 13                	jmp    800491 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	ff 75 18             	push   0x18(%ebp)
  800485:	ff d7                	call   *%edi
  800487:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80048a:	83 eb 01             	sub    $0x1,%ebx
  80048d:	85 db                	test   %ebx,%ebx
  80048f:	7f ed                	jg     80047e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	56                   	push   %esi
  800495:	83 ec 04             	sub    $0x4,%esp
  800498:	ff 75 e4             	push   -0x1c(%ebp)
  80049b:	ff 75 e0             	push   -0x20(%ebp)
  80049e:	ff 75 dc             	push   -0x24(%ebp)
  8004a1:	ff 75 d8             	push   -0x28(%ebp)
  8004a4:	e8 57 21 00 00       	call   802600 <__umoddi3>
  8004a9:	83 c4 14             	add    $0x14,%esp
  8004ac:	0f be 80 db 27 80 00 	movsbl 0x8027db(%eax),%eax
  8004b3:	50                   	push   %eax
  8004b4:	ff d7                	call   *%edi
}
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bc:	5b                   	pop    %ebx
  8004bd:	5e                   	pop    %esi
  8004be:	5f                   	pop    %edi
  8004bf:	5d                   	pop    %ebp
  8004c0:	c3                   	ret    

008004c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d0:	73 0a                	jae    8004dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004da:	88 02                	mov    %al,(%edx)
}
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <printfmt>:
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e7:	50                   	push   %eax
  8004e8:	ff 75 10             	push   0x10(%ebp)
  8004eb:	ff 75 0c             	push   0xc(%ebp)
  8004ee:	ff 75 08             	push   0x8(%ebp)
  8004f1:	e8 05 00 00 00       	call   8004fb <vprintfmt>
}
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	c9                   	leave  
  8004fa:	c3                   	ret    

008004fb <vprintfmt>:
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 3c             	sub    $0x3c,%esp
  800504:	8b 75 08             	mov    0x8(%ebp),%esi
  800507:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80050d:	eb 0a                	jmp    800519 <vprintfmt+0x1e>
			putch(ch, putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	53                   	push   %ebx
  800513:	50                   	push   %eax
  800514:	ff d6                	call   *%esi
  800516:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800519:	83 c7 01             	add    $0x1,%edi
  80051c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800520:	83 f8 25             	cmp    $0x25,%eax
  800523:	74 0c                	je     800531 <vprintfmt+0x36>
			if (ch == '\0')
  800525:	85 c0                	test   %eax,%eax
  800527:	75 e6                	jne    80050f <vprintfmt+0x14>
}
  800529:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80052c:	5b                   	pop    %ebx
  80052d:	5e                   	pop    %esi
  80052e:	5f                   	pop    %edi
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    
		padc = ' ';
  800531:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800535:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80053c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800543:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80054a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80054f:	8d 47 01             	lea    0x1(%edi),%eax
  800552:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800555:	0f b6 17             	movzbl (%edi),%edx
  800558:	8d 42 dd             	lea    -0x23(%edx),%eax
  80055b:	3c 55                	cmp    $0x55,%al
  80055d:	0f 87 bb 03 00 00    	ja     80091e <vprintfmt+0x423>
  800563:	0f b6 c0             	movzbl %al,%eax
  800566:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800570:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800574:	eb d9                	jmp    80054f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800579:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80057d:	eb d0                	jmp    80054f <vprintfmt+0x54>
  80057f:	0f b6 d2             	movzbl %dl,%edx
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800585:	b8 00 00 00 00       	mov    $0x0,%eax
  80058a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80058d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800590:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800594:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800597:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80059a:	83 f9 09             	cmp    $0x9,%ecx
  80059d:	77 55                	ja     8005f4 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80059f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005a2:	eb e9                	jmp    80058d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 40 04             	lea    0x4(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bc:	79 91                	jns    80054f <vprintfmt+0x54>
				width = precision, precision = -1;
  8005be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005cb:	eb 82                	jmp    80054f <vprintfmt+0x54>
  8005cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d0:	85 d2                	test   %edx,%edx
  8005d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d7:	0f 49 c2             	cmovns %edx,%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e0:	e9 6a ff ff ff       	jmp    80054f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005e8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005ef:	e9 5b ff ff ff       	jmp    80054f <vprintfmt+0x54>
  8005f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	eb bc                	jmp    8005b8 <vprintfmt+0xbd>
			lflag++;
  8005fc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800602:	e9 48 ff ff ff       	jmp    80054f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 78 04             	lea    0x4(%eax),%edi
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	ff 30                	push   (%eax)
  800613:	ff d6                	call   *%esi
			break;
  800615:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800618:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80061b:	e9 9d 02 00 00       	jmp    8008bd <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 78 04             	lea    0x4(%eax),%edi
  800626:	8b 10                	mov    (%eax),%edx
  800628:	89 d0                	mov    %edx,%eax
  80062a:	f7 d8                	neg    %eax
  80062c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062f:	83 f8 0f             	cmp    $0xf,%eax
  800632:	7f 23                	jg     800657 <vprintfmt+0x15c>
  800634:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  80063b:	85 d2                	test   %edx,%edx
  80063d:	74 18                	je     800657 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80063f:	52                   	push   %edx
  800640:	68 b5 2b 80 00       	push   $0x802bb5
  800645:	53                   	push   %ebx
  800646:	56                   	push   %esi
  800647:	e8 92 fe ff ff       	call   8004de <printfmt>
  80064c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80064f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800652:	e9 66 02 00 00       	jmp    8008bd <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800657:	50                   	push   %eax
  800658:	68 f3 27 80 00       	push   $0x8027f3
  80065d:	53                   	push   %ebx
  80065e:	56                   	push   %esi
  80065f:	e8 7a fe ff ff       	call   8004de <printfmt>
  800664:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800667:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80066a:	e9 4e 02 00 00       	jmp    8008bd <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	83 c0 04             	add    $0x4,%eax
  800675:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80067d:	85 d2                	test   %edx,%edx
  80067f:	b8 ec 27 80 00       	mov    $0x8027ec,%eax
  800684:	0f 45 c2             	cmovne %edx,%eax
  800687:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80068a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068e:	7e 06                	jle    800696 <vprintfmt+0x19b>
  800690:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800694:	75 0d                	jne    8006a3 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800696:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800699:	89 c7                	mov    %eax,%edi
  80069b:	03 45 e0             	add    -0x20(%ebp),%eax
  80069e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a1:	eb 55                	jmp    8006f8 <vprintfmt+0x1fd>
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	ff 75 d8             	push   -0x28(%ebp)
  8006a9:	ff 75 cc             	push   -0x34(%ebp)
  8006ac:	e8 0a 03 00 00       	call   8009bb <strnlen>
  8006b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b4:	29 c1                	sub    %eax,%ecx
  8006b6:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006be:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	eb 0f                	jmp    8006d6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	ff 75 e0             	push   -0x20(%ebp)
  8006ce:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	83 ef 01             	sub    $0x1,%edi
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	85 ff                	test   %edi,%edi
  8006d8:	7f ed                	jg     8006c7 <vprintfmt+0x1cc>
  8006da:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e4:	0f 49 c2             	cmovns %edx,%eax
  8006e7:	29 c2                	sub    %eax,%edx
  8006e9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006ec:	eb a8                	jmp    800696 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	52                   	push   %edx
  8006f3:	ff d6                	call   *%esi
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fd:	83 c7 01             	add    $0x1,%edi
  800700:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800704:	0f be d0             	movsbl %al,%edx
  800707:	85 d2                	test   %edx,%edx
  800709:	74 4b                	je     800756 <vprintfmt+0x25b>
  80070b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070f:	78 06                	js     800717 <vprintfmt+0x21c>
  800711:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800715:	78 1e                	js     800735 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800717:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071b:	74 d1                	je     8006ee <vprintfmt+0x1f3>
  80071d:	0f be c0             	movsbl %al,%eax
  800720:	83 e8 20             	sub    $0x20,%eax
  800723:	83 f8 5e             	cmp    $0x5e,%eax
  800726:	76 c6                	jbe    8006ee <vprintfmt+0x1f3>
					putch('?', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 3f                	push   $0x3f
  80072e:	ff d6                	call   *%esi
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb c3                	jmp    8006f8 <vprintfmt+0x1fd>
  800735:	89 cf                	mov    %ecx,%edi
  800737:	eb 0e                	jmp    800747 <vprintfmt+0x24c>
				putch(' ', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	6a 20                	push   $0x20
  80073f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800741:	83 ef 01             	sub    $0x1,%edi
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	85 ff                	test   %edi,%edi
  800749:	7f ee                	jg     800739 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80074b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
  800751:	e9 67 01 00 00       	jmp    8008bd <vprintfmt+0x3c2>
  800756:	89 cf                	mov    %ecx,%edi
  800758:	eb ed                	jmp    800747 <vprintfmt+0x24c>
	if (lflag >= 2)
  80075a:	83 f9 01             	cmp    $0x1,%ecx
  80075d:	7f 1b                	jg     80077a <vprintfmt+0x27f>
	else if (lflag)
  80075f:	85 c9                	test   %ecx,%ecx
  800761:	74 63                	je     8007c6 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8b 00                	mov    (%eax),%eax
  800768:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076b:	99                   	cltd   
  80076c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8d 40 04             	lea    0x4(%eax),%eax
  800775:	89 45 14             	mov    %eax,0x14(%ebp)
  800778:	eb 17                	jmp    800791 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 50 04             	mov    0x4(%eax),%edx
  800780:	8b 00                	mov    (%eax),%eax
  800782:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800785:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 40 08             	lea    0x8(%eax),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800791:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800794:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800797:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	0f 89 ff 00 00 00    	jns    8008a3 <vprintfmt+0x3a8>
				putch('-', putdat);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	53                   	push   %ebx
  8007a8:	6a 2d                	push   $0x2d
  8007aa:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007af:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007b2:	f7 da                	neg    %edx
  8007b4:	83 d1 00             	adc    $0x0,%ecx
  8007b7:	f7 d9                	neg    %ecx
  8007b9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007bc:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007c1:	e9 dd 00 00 00       	jmp    8008a3 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	99                   	cltd   
  8007cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 40 04             	lea    0x4(%eax),%eax
  8007d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007db:	eb b4                	jmp    800791 <vprintfmt+0x296>
	if (lflag >= 2)
  8007dd:	83 f9 01             	cmp    $0x1,%ecx
  8007e0:	7f 1e                	jg     800800 <vprintfmt+0x305>
	else if (lflag)
  8007e2:	85 c9                	test   %ecx,%ecx
  8007e4:	74 32                	je     800818 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8b 10                	mov    (%eax),%edx
  8007eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f0:	8d 40 04             	lea    0x4(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007fb:	e9 a3 00 00 00       	jmp    8008a3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8b 10                	mov    (%eax),%edx
  800805:	8b 48 04             	mov    0x4(%eax),%ecx
  800808:	8d 40 08             	lea    0x8(%eax),%eax
  80080b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800813:	e9 8b 00 00 00       	jmp    8008a3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800818:	8b 45 14             	mov    0x14(%ebp),%eax
  80081b:	8b 10                	mov    (%eax),%edx
  80081d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800822:	8d 40 04             	lea    0x4(%eax),%eax
  800825:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800828:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80082d:	eb 74                	jmp    8008a3 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80082f:	83 f9 01             	cmp    $0x1,%ecx
  800832:	7f 1b                	jg     80084f <vprintfmt+0x354>
	else if (lflag)
  800834:	85 c9                	test   %ecx,%ecx
  800836:	74 2c                	je     800864 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800842:	8d 40 04             	lea    0x4(%eax),%eax
  800845:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800848:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80084d:	eb 54                	jmp    8008a3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80084f:	8b 45 14             	mov    0x14(%ebp),%eax
  800852:	8b 10                	mov    (%eax),%edx
  800854:	8b 48 04             	mov    0x4(%eax),%ecx
  800857:	8d 40 08             	lea    0x8(%eax),%eax
  80085a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80085d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800862:	eb 3f                	jmp    8008a3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8b 10                	mov    (%eax),%edx
  800869:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086e:	8d 40 04             	lea    0x4(%eax),%eax
  800871:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800874:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800879:	eb 28                	jmp    8008a3 <vprintfmt+0x3a8>
			putch('0', putdat);
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	53                   	push   %ebx
  80087f:	6a 30                	push   $0x30
  800881:	ff d6                	call   *%esi
			putch('x', putdat);
  800883:	83 c4 08             	add    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 78                	push   $0x78
  800889:	ff d6                	call   *%esi
			num = (unsigned long long)
  80088b:	8b 45 14             	mov    0x14(%ebp),%eax
  80088e:	8b 10                	mov    (%eax),%edx
  800890:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800895:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800898:	8d 40 04             	lea    0x4(%eax),%eax
  80089b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089e:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8008a3:	83 ec 0c             	sub    $0xc,%esp
  8008a6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	ff 75 e0             	push   -0x20(%ebp)
  8008ae:	57                   	push   %edi
  8008af:	51                   	push   %ecx
  8008b0:	52                   	push   %edx
  8008b1:	89 da                	mov    %ebx,%edx
  8008b3:	89 f0                	mov    %esi,%eax
  8008b5:	e8 5e fb ff ff       	call   800418 <printnum>
			break;
  8008ba:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c0:	e9 54 fc ff ff       	jmp    800519 <vprintfmt+0x1e>
	if (lflag >= 2)
  8008c5:	83 f9 01             	cmp    $0x1,%ecx
  8008c8:	7f 1b                	jg     8008e5 <vprintfmt+0x3ea>
	else if (lflag)
  8008ca:	85 c9                	test   %ecx,%ecx
  8008cc:	74 2c                	je     8008fa <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d1:	8b 10                	mov    (%eax),%edx
  8008d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d8:	8d 40 04             	lea    0x4(%eax),%eax
  8008db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008de:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008e3:	eb be                	jmp    8008a3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8b 10                	mov    (%eax),%edx
  8008ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ed:	8d 40 08             	lea    0x8(%eax),%eax
  8008f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008f8:	eb a9                	jmp    8008a3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	8b 10                	mov    (%eax),%edx
  8008ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800904:	8d 40 04             	lea    0x4(%eax),%eax
  800907:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80090f:	eb 92                	jmp    8008a3 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	53                   	push   %ebx
  800915:	6a 25                	push   $0x25
  800917:	ff d6                	call   *%esi
			break;
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	eb 9f                	jmp    8008bd <vprintfmt+0x3c2>
			putch('%', putdat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	53                   	push   %ebx
  800922:	6a 25                	push   $0x25
  800924:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	89 f8                	mov    %edi,%eax
  80092b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80092f:	74 05                	je     800936 <vprintfmt+0x43b>
  800931:	83 e8 01             	sub    $0x1,%eax
  800934:	eb f5                	jmp    80092b <vprintfmt+0x430>
  800936:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800939:	eb 82                	jmp    8008bd <vprintfmt+0x3c2>

0080093b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	83 ec 18             	sub    $0x18,%esp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800947:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80094a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800958:	85 c0                	test   %eax,%eax
  80095a:	74 26                	je     800982 <vsnprintf+0x47>
  80095c:	85 d2                	test   %edx,%edx
  80095e:	7e 22                	jle    800982 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800960:	ff 75 14             	push   0x14(%ebp)
  800963:	ff 75 10             	push   0x10(%ebp)
  800966:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800969:	50                   	push   %eax
  80096a:	68 c1 04 80 00       	push   $0x8004c1
  80096f:	e8 87 fb ff ff       	call   8004fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800974:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800977:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80097a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097d:	83 c4 10             	add    $0x10,%esp
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    
		return -E_INVAL;
  800982:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800987:	eb f7                	jmp    800980 <vsnprintf+0x45>

00800989 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800992:	50                   	push   %eax
  800993:	ff 75 10             	push   0x10(%ebp)
  800996:	ff 75 0c             	push   0xc(%ebp)
  800999:	ff 75 08             	push   0x8(%ebp)
  80099c:	e8 9a ff ff ff       	call   80093b <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ae:	eb 03                	jmp    8009b3 <strlen+0x10>
		n++;
  8009b0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b7:	75 f7                	jne    8009b0 <strlen+0xd>
	return n;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c9:	eb 03                	jmp    8009ce <strnlen+0x13>
		n++;
  8009cb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ce:	39 d0                	cmp    %edx,%eax
  8009d0:	74 08                	je     8009da <strnlen+0x1f>
  8009d2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d6:	75 f3                	jne    8009cb <strnlen+0x10>
  8009d8:	89 c2                	mov    %eax,%edx
	return n;
}
  8009da:	89 d0                	mov    %edx,%eax
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	53                   	push   %ebx
  8009e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ed:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009f1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	84 d2                	test   %dl,%dl
  8009f9:	75 f2                	jne    8009ed <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009fb:	89 c8                	mov    %ecx,%eax
  8009fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	53                   	push   %ebx
  800a06:	83 ec 10             	sub    $0x10,%esp
  800a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a0c:	53                   	push   %ebx
  800a0d:	e8 91 ff ff ff       	call   8009a3 <strlen>
  800a12:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a15:	ff 75 0c             	push   0xc(%ebp)
  800a18:	01 d8                	add    %ebx,%eax
  800a1a:	50                   	push   %eax
  800a1b:	e8 be ff ff ff       	call   8009de <strcpy>
	return dst;
}
  800a20:	89 d8                	mov    %ebx,%eax
  800a22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a32:	89 f3                	mov    %esi,%ebx
  800a34:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a37:	89 f0                	mov    %esi,%eax
  800a39:	eb 0f                	jmp    800a4a <strncpy+0x23>
		*dst++ = *src;
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	0f b6 0a             	movzbl (%edx),%ecx
  800a41:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a44:	80 f9 01             	cmp    $0x1,%cl
  800a47:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a4a:	39 d8                	cmp    %ebx,%eax
  800a4c:	75 ed                	jne    800a3b <strncpy+0x14>
	}
	return ret;
}
  800a4e:	89 f0                	mov    %esi,%eax
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5f:	8b 55 10             	mov    0x10(%ebp),%edx
  800a62:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a64:	85 d2                	test   %edx,%edx
  800a66:	74 21                	je     800a89 <strlcpy+0x35>
  800a68:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a6c:	89 f2                	mov    %esi,%edx
  800a6e:	eb 09                	jmp    800a79 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	83 c2 01             	add    $0x1,%edx
  800a76:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a79:	39 c2                	cmp    %eax,%edx
  800a7b:	74 09                	je     800a86 <strlcpy+0x32>
  800a7d:	0f b6 19             	movzbl (%ecx),%ebx
  800a80:	84 db                	test   %bl,%bl
  800a82:	75 ec                	jne    800a70 <strlcpy+0x1c>
  800a84:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a86:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a89:	29 f0                	sub    %esi,%eax
}
  800a8b:	5b                   	pop    %ebx
  800a8c:	5e                   	pop    %esi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a95:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a98:	eb 06                	jmp    800aa0 <strcmp+0x11>
		p++, q++;
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aa0:	0f b6 01             	movzbl (%ecx),%eax
  800aa3:	84 c0                	test   %al,%al
  800aa5:	74 04                	je     800aab <strcmp+0x1c>
  800aa7:	3a 02                	cmp    (%edx),%al
  800aa9:	74 ef                	je     800a9a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aab:	0f b6 c0             	movzbl %al,%eax
  800aae:	0f b6 12             	movzbl (%edx),%edx
  800ab1:	29 d0                	sub    %edx,%eax
}
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	53                   	push   %ebx
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abf:	89 c3                	mov    %eax,%ebx
  800ac1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac4:	eb 06                	jmp    800acc <strncmp+0x17>
		n--, p++, q++;
  800ac6:	83 c0 01             	add    $0x1,%eax
  800ac9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800acc:	39 d8                	cmp    %ebx,%eax
  800ace:	74 18                	je     800ae8 <strncmp+0x33>
  800ad0:	0f b6 08             	movzbl (%eax),%ecx
  800ad3:	84 c9                	test   %cl,%cl
  800ad5:	74 04                	je     800adb <strncmp+0x26>
  800ad7:	3a 0a                	cmp    (%edx),%cl
  800ad9:	74 eb                	je     800ac6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800adb:	0f b6 00             	movzbl (%eax),%eax
  800ade:	0f b6 12             	movzbl (%edx),%edx
  800ae1:	29 d0                	sub    %edx,%eax
}
  800ae3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    
		return 0;
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	eb f4                	jmp    800ae3 <strncmp+0x2e>

00800aef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af9:	eb 03                	jmp    800afe <strchr+0xf>
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	0f b6 10             	movzbl (%eax),%edx
  800b01:	84 d2                	test   %dl,%dl
  800b03:	74 06                	je     800b0b <strchr+0x1c>
		if (*s == c)
  800b05:	38 ca                	cmp    %cl,%dl
  800b07:	75 f2                	jne    800afb <strchr+0xc>
  800b09:	eb 05                	jmp    800b10 <strchr+0x21>
			return (char *) s;
	return 0;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b1c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b1f:	38 ca                	cmp    %cl,%dl
  800b21:	74 09                	je     800b2c <strfind+0x1a>
  800b23:	84 d2                	test   %dl,%dl
  800b25:	74 05                	je     800b2c <strfind+0x1a>
	for (; *s; s++)
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	eb f0                	jmp    800b1c <strfind+0xa>
			break;
	return (char *) s;
}
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b3a:	85 c9                	test   %ecx,%ecx
  800b3c:	74 2f                	je     800b6d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3e:	89 f8                	mov    %edi,%eax
  800b40:	09 c8                	or     %ecx,%eax
  800b42:	a8 03                	test   $0x3,%al
  800b44:	75 21                	jne    800b67 <memset+0x39>
		c &= 0xFF;
  800b46:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b4a:	89 d0                	mov    %edx,%eax
  800b4c:	c1 e0 08             	shl    $0x8,%eax
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	c1 e3 18             	shl    $0x18,%ebx
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	c1 e6 10             	shl    $0x10,%esi
  800b59:	09 f3                	or     %esi,%ebx
  800b5b:	09 da                	or     %ebx,%edx
  800b5d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b5f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b62:	fc                   	cld    
  800b63:	f3 ab                	rep stos %eax,%es:(%edi)
  800b65:	eb 06                	jmp    800b6d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6a:	fc                   	cld    
  800b6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6d:	89 f8                	mov    %edi,%eax
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b82:	39 c6                	cmp    %eax,%esi
  800b84:	73 32                	jae    800bb8 <memmove+0x44>
  800b86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b89:	39 c2                	cmp    %eax,%edx
  800b8b:	76 2b                	jbe    800bb8 <memmove+0x44>
		s += n;
		d += n;
  800b8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	09 fe                	or     %edi,%esi
  800b94:	09 ce                	or     %ecx,%esi
  800b96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9c:	75 0e                	jne    800bac <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b9e:	83 ef 04             	sub    $0x4,%edi
  800ba1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ba7:	fd                   	std    
  800ba8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800baa:	eb 09                	jmp    800bb5 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bac:	83 ef 01             	sub    $0x1,%edi
  800baf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bb2:	fd                   	std    
  800bb3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb5:	fc                   	cld    
  800bb6:	eb 1a                	jmp    800bd2 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb8:	89 f2                	mov    %esi,%edx
  800bba:	09 c2                	or     %eax,%edx
  800bbc:	09 ca                	or     %ecx,%edx
  800bbe:	f6 c2 03             	test   $0x3,%dl
  800bc1:	75 0a                	jne    800bcd <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bc6:	89 c7                	mov    %eax,%edi
  800bc8:	fc                   	cld    
  800bc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bcb:	eb 05                	jmp    800bd2 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bcd:	89 c7                	mov    %eax,%edi
  800bcf:	fc                   	cld    
  800bd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bdc:	ff 75 10             	push   0x10(%ebp)
  800bdf:	ff 75 0c             	push   0xc(%ebp)
  800be2:	ff 75 08             	push   0x8(%ebp)
  800be5:	e8 8a ff ff ff       	call   800b74 <memmove>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf7:	89 c6                	mov    %eax,%esi
  800bf9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfc:	eb 06                	jmp    800c04 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bfe:	83 c0 01             	add    $0x1,%eax
  800c01:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c04:	39 f0                	cmp    %esi,%eax
  800c06:	74 14                	je     800c1c <memcmp+0x30>
		if (*s1 != *s2)
  800c08:	0f b6 08             	movzbl (%eax),%ecx
  800c0b:	0f b6 1a             	movzbl (%edx),%ebx
  800c0e:	38 d9                	cmp    %bl,%cl
  800c10:	74 ec                	je     800bfe <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c12:	0f b6 c1             	movzbl %cl,%eax
  800c15:	0f b6 db             	movzbl %bl,%ebx
  800c18:	29 d8                	sub    %ebx,%eax
  800c1a:	eb 05                	jmp    800c21 <memcmp+0x35>
	}

	return 0;
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c2e:	89 c2                	mov    %eax,%edx
  800c30:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c33:	eb 03                	jmp    800c38 <memfind+0x13>
  800c35:	83 c0 01             	add    $0x1,%eax
  800c38:	39 d0                	cmp    %edx,%eax
  800c3a:	73 04                	jae    800c40 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3c:	38 08                	cmp    %cl,(%eax)
  800c3e:	75 f5                	jne    800c35 <memfind+0x10>
			break;
	return (void *) s;
}
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4e:	eb 03                	jmp    800c53 <strtol+0x11>
		s++;
  800c50:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c53:	0f b6 02             	movzbl (%edx),%eax
  800c56:	3c 20                	cmp    $0x20,%al
  800c58:	74 f6                	je     800c50 <strtol+0xe>
  800c5a:	3c 09                	cmp    $0x9,%al
  800c5c:	74 f2                	je     800c50 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c5e:	3c 2b                	cmp    $0x2b,%al
  800c60:	74 2a                	je     800c8c <strtol+0x4a>
	int neg = 0;
  800c62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c67:	3c 2d                	cmp    $0x2d,%al
  800c69:	74 2b                	je     800c96 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c71:	75 0f                	jne    800c82 <strtol+0x40>
  800c73:	80 3a 30             	cmpb   $0x30,(%edx)
  800c76:	74 28                	je     800ca0 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c78:	85 db                	test   %ebx,%ebx
  800c7a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7f:	0f 44 d8             	cmove  %eax,%ebx
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c8a:	eb 46                	jmp    800cd2 <strtol+0x90>
		s++;
  800c8c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c94:	eb d5                	jmp    800c6b <strtol+0x29>
		s++, neg = 1;
  800c96:	83 c2 01             	add    $0x1,%edx
  800c99:	bf 01 00 00 00       	mov    $0x1,%edi
  800c9e:	eb cb                	jmp    800c6b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca4:	74 0e                	je     800cb4 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ca6:	85 db                	test   %ebx,%ebx
  800ca8:	75 d8                	jne    800c82 <strtol+0x40>
		s++, base = 8;
  800caa:	83 c2 01             	add    $0x1,%edx
  800cad:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cb2:	eb ce                	jmp    800c82 <strtol+0x40>
		s += 2, base = 16;
  800cb4:	83 c2 02             	add    $0x2,%edx
  800cb7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cbc:	eb c4                	jmp    800c82 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cbe:	0f be c0             	movsbl %al,%eax
  800cc1:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cc7:	7d 3a                	jge    800d03 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cc9:	83 c2 01             	add    $0x1,%edx
  800ccc:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800cd0:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cd2:	0f b6 02             	movzbl (%edx),%eax
  800cd5:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cd8:	89 f3                	mov    %esi,%ebx
  800cda:	80 fb 09             	cmp    $0x9,%bl
  800cdd:	76 df                	jbe    800cbe <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cdf:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ce2:	89 f3                	mov    %esi,%ebx
  800ce4:	80 fb 19             	cmp    $0x19,%bl
  800ce7:	77 08                	ja     800cf1 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ce9:	0f be c0             	movsbl %al,%eax
  800cec:	83 e8 57             	sub    $0x57,%eax
  800cef:	eb d3                	jmp    800cc4 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cf1:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cf4:	89 f3                	mov    %esi,%ebx
  800cf6:	80 fb 19             	cmp    $0x19,%bl
  800cf9:	77 08                	ja     800d03 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cfb:	0f be c0             	movsbl %al,%eax
  800cfe:	83 e8 37             	sub    $0x37,%eax
  800d01:	eb c1                	jmp    800cc4 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d07:	74 05                	je     800d0e <strtol+0xcc>
		*endptr = (char *) s;
  800d09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d0e:	89 c8                	mov    %ecx,%eax
  800d10:	f7 d8                	neg    %eax
  800d12:	85 ff                	test   %edi,%edi
  800d14:	0f 45 c8             	cmovne %eax,%ecx
}
  800d17:	89 c8                	mov    %ecx,%eax
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d24:	b8 00 00 00 00       	mov    $0x0,%eax
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	89 c3                	mov    %eax,%ebx
  800d31:	89 c7                	mov    %eax,%edi
  800d33:	89 c6                	mov    %eax,%esi
  800d35:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_cgetc>:

int
sys_cgetc(void)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4c:	89 d1                	mov    %edx,%ecx
  800d4e:	89 d3                	mov    %edx,%ebx
  800d50:	89 d7                	mov    %edx,%edi
  800d52:	89 d6                	mov    %edx,%esi
  800d54:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	b8 03 00 00 00       	mov    $0x3,%eax
  800d71:	89 cb                	mov    %ecx,%ebx
  800d73:	89 cf                	mov    %ecx,%edi
  800d75:	89 ce                	mov    %ecx,%esi
  800d77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7f 08                	jg     800d85 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	50                   	push   %eax
  800d89:	6a 03                	push   $0x3
  800d8b:	68 df 2a 80 00       	push   $0x802adf
  800d90:	6a 2a                	push   $0x2a
  800d92:	68 fc 2a 80 00       	push   $0x802afc
  800d97:	e8 8d f5 ff ff       	call   800329 <_panic>

00800d9c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da2:	ba 00 00 00 00       	mov    $0x0,%edx
  800da7:	b8 02 00 00 00       	mov    $0x2,%eax
  800dac:	89 d1                	mov    %edx,%ecx
  800dae:	89 d3                	mov    %edx,%ebx
  800db0:	89 d7                	mov    %edx,%edi
  800db2:	89 d6                	mov    %edx,%esi
  800db4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_yield>:

void
sys_yield(void)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dcb:	89 d1                	mov    %edx,%ecx
  800dcd:	89 d3                	mov    %edx,%ebx
  800dcf:	89 d7                	mov    %edx,%edi
  800dd1:	89 d6                	mov    %edx,%esi
  800dd3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de3:	be 00 00 00 00       	mov    $0x0,%esi
  800de8:	8b 55 08             	mov    0x8(%ebp),%edx
  800deb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dee:	b8 04 00 00 00       	mov    $0x4,%eax
  800df3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df6:	89 f7                	mov    %esi,%edi
  800df8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	7f 08                	jg     800e06 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e06:	83 ec 0c             	sub    $0xc,%esp
  800e09:	50                   	push   %eax
  800e0a:	6a 04                	push   $0x4
  800e0c:	68 df 2a 80 00       	push   $0x802adf
  800e11:	6a 2a                	push   $0x2a
  800e13:	68 fc 2a 80 00       	push   $0x802afc
  800e18:	e8 0c f5 ff ff       	call   800329 <_panic>

00800e1d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e1d:	55                   	push   %ebp
  800e1e:	89 e5                	mov    %esp,%ebp
  800e20:	57                   	push   %edi
  800e21:	56                   	push   %esi
  800e22:	53                   	push   %ebx
  800e23:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	b8 05 00 00 00       	mov    $0x5,%eax
  800e31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e34:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e37:	8b 75 18             	mov    0x18(%ebp),%esi
  800e3a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	7f 08                	jg     800e48 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	50                   	push   %eax
  800e4c:	6a 05                	push   $0x5
  800e4e:	68 df 2a 80 00       	push   $0x802adf
  800e53:	6a 2a                	push   $0x2a
  800e55:	68 fc 2a 80 00       	push   $0x802afc
  800e5a:	e8 ca f4 ff ff       	call   800329 <_panic>

00800e5f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e5f:	55                   	push   %ebp
  800e60:	89 e5                	mov    %esp,%ebp
  800e62:	57                   	push   %edi
  800e63:	56                   	push   %esi
  800e64:	53                   	push   %ebx
  800e65:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e73:	b8 06 00 00 00       	mov    $0x6,%eax
  800e78:	89 df                	mov    %ebx,%edi
  800e7a:	89 de                	mov    %ebx,%esi
  800e7c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	7f 08                	jg     800e8a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	50                   	push   %eax
  800e8e:	6a 06                	push   $0x6
  800e90:	68 df 2a 80 00       	push   $0x802adf
  800e95:	6a 2a                	push   $0x2a
  800e97:	68 fc 2a 80 00       	push   $0x802afc
  800e9c:	e8 88 f4 ff ff       	call   800329 <_panic>

00800ea1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	b8 08 00 00 00       	mov    $0x8,%eax
  800eba:	89 df                	mov    %ebx,%edi
  800ebc:	89 de                	mov    %ebx,%esi
  800ebe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	7f 08                	jg     800ecc <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecc:	83 ec 0c             	sub    $0xc,%esp
  800ecf:	50                   	push   %eax
  800ed0:	6a 08                	push   $0x8
  800ed2:	68 df 2a 80 00       	push   $0x802adf
  800ed7:	6a 2a                	push   $0x2a
  800ed9:	68 fc 2a 80 00       	push   $0x802afc
  800ede:	e8 46 f4 ff ff       	call   800329 <_panic>

00800ee3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	57                   	push   %edi
  800ee7:	56                   	push   %esi
  800ee8:	53                   	push   %ebx
  800ee9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	b8 09 00 00 00       	mov    $0x9,%eax
  800efc:	89 df                	mov    %ebx,%edi
  800efe:	89 de                	mov    %ebx,%esi
  800f00:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	7f 08                	jg     800f0e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0e:	83 ec 0c             	sub    $0xc,%esp
  800f11:	50                   	push   %eax
  800f12:	6a 09                	push   $0x9
  800f14:	68 df 2a 80 00       	push   $0x802adf
  800f19:	6a 2a                	push   $0x2a
  800f1b:	68 fc 2a 80 00       	push   $0x802afc
  800f20:	e8 04 f4 ff ff       	call   800329 <_panic>

00800f25 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3e:	89 df                	mov    %ebx,%edi
  800f40:	89 de                	mov    %ebx,%esi
  800f42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f44:	85 c0                	test   %eax,%eax
  800f46:	7f 08                	jg     800f50 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4b:	5b                   	pop    %ebx
  800f4c:	5e                   	pop    %esi
  800f4d:	5f                   	pop    %edi
  800f4e:	5d                   	pop    %ebp
  800f4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f50:	83 ec 0c             	sub    $0xc,%esp
  800f53:	50                   	push   %eax
  800f54:	6a 0a                	push   $0xa
  800f56:	68 df 2a 80 00       	push   $0x802adf
  800f5b:	6a 2a                	push   $0x2a
  800f5d:	68 fc 2a 80 00       	push   $0x802afc
  800f62:	e8 c2 f3 ff ff       	call   800329 <_panic>

00800f67 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f78:	be 00 00 00 00       	mov    $0x0,%esi
  800f7d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f80:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f83:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	57                   	push   %edi
  800f8e:	56                   	push   %esi
  800f8f:	53                   	push   %ebx
  800f90:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f98:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fa0:	89 cb                	mov    %ecx,%ebx
  800fa2:	89 cf                	mov    %ecx,%edi
  800fa4:	89 ce                	mov    %ecx,%esi
  800fa6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	7f 08                	jg     800fb4 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	50                   	push   %eax
  800fb8:	6a 0d                	push   $0xd
  800fba:	68 df 2a 80 00       	push   $0x802adf
  800fbf:	6a 2a                	push   $0x2a
  800fc1:	68 fc 2a 80 00       	push   $0x802afc
  800fc6:	e8 5e f3 ff ff       	call   800329 <_panic>

00800fcb <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd6:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fdb:	89 d1                	mov    %edx,%ecx
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	89 d6                	mov    %edx,%esi
  800fe3:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	57                   	push   %edi
  800fee:	56                   	push   %esi
  800fef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ff0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ff5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ffb:	b8 0f 00 00 00       	mov    $0xf,%eax
  801000:	89 df                	mov    %ebx,%edi
  801002:	89 de                	mov    %ebx,%esi
  801004:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
	asm volatile("int %1\n"
  801011:	bb 00 00 00 00       	mov    $0x0,%ebx
  801016:	8b 55 08             	mov    0x8(%ebp),%edx
  801019:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101c:	b8 10 00 00 00       	mov    $0x10,%eax
  801021:	89 df                	mov    %ebx,%edi
  801023:	89 de                	mov    %ebx,%esi
  801025:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	8b 55 08             	mov    0x8(%ebp),%edx
  801032:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801035:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801038:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  80103a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  80103d:	83 3a 01             	cmpl   $0x1,(%edx)
  801040:	7e 09                	jle    80104b <argstart+0x1f>
  801042:	ba 88 27 80 00       	mov    $0x802788,%edx
  801047:	85 c9                	test   %ecx,%ecx
  801049:	75 05                	jne    801050 <argstart+0x24>
  80104b:	ba 00 00 00 00       	mov    $0x0,%edx
  801050:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801053:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  80105a:	5d                   	pop    %ebp
  80105b:	c3                   	ret    

0080105c <argnext>:

int
argnext(struct Argstate *args)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	53                   	push   %ebx
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801066:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  80106d:	8b 43 08             	mov    0x8(%ebx),%eax
  801070:	85 c0                	test   %eax,%eax
  801072:	74 74                	je     8010e8 <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  801074:	80 38 00             	cmpb   $0x0,(%eax)
  801077:	75 48                	jne    8010c1 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801079:	8b 0b                	mov    (%ebx),%ecx
  80107b:	83 39 01             	cmpl   $0x1,(%ecx)
  80107e:	74 5a                	je     8010da <argnext+0x7e>
		    || args->argv[1][0] != '-'
  801080:	8b 53 04             	mov    0x4(%ebx),%edx
  801083:	8b 42 04             	mov    0x4(%edx),%eax
  801086:	80 38 2d             	cmpb   $0x2d,(%eax)
  801089:	75 4f                	jne    8010da <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  80108b:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80108f:	74 49                	je     8010da <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801091:	83 c0 01             	add    $0x1,%eax
  801094:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	8b 01                	mov    (%ecx),%eax
  80109c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8010a3:	50                   	push   %eax
  8010a4:	8d 42 08             	lea    0x8(%edx),%eax
  8010a7:	50                   	push   %eax
  8010a8:	83 c2 04             	add    $0x4,%edx
  8010ab:	52                   	push   %edx
  8010ac:	e8 c3 fa ff ff       	call   800b74 <memmove>
		(*args->argc)--;
  8010b1:	8b 03                	mov    (%ebx),%eax
  8010b3:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010b6:	8b 43 08             	mov    0x8(%ebx),%eax
  8010b9:	83 c4 10             	add    $0x10,%esp
  8010bc:	80 38 2d             	cmpb   $0x2d,(%eax)
  8010bf:	74 13                	je     8010d4 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  8010c1:	8b 43 08             	mov    0x8(%ebx),%eax
  8010c4:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  8010c7:	83 c0 01             	add    $0x1,%eax
  8010ca:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8010cd:	89 d0                	mov    %edx,%eax
  8010cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  8010d4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  8010d8:	75 e7                	jne    8010c1 <argnext+0x65>
	args->curarg = 0;
  8010da:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8010e1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010e6:	eb e5                	jmp    8010cd <argnext+0x71>
		return -1;
  8010e8:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010ed:	eb de                	jmp    8010cd <argnext+0x71>

008010ef <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8010f9:	8b 43 08             	mov    0x8(%ebx),%eax
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	74 12                	je     801112 <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  801100:	80 38 00             	cmpb   $0x0,(%eax)
  801103:	74 12                	je     801117 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801105:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801108:	c7 43 08 88 27 80 00 	movl   $0x802788,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  80110f:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801115:	c9                   	leave  
  801116:	c3                   	ret    
	} else if (*args->argc > 1) {
  801117:	8b 13                	mov    (%ebx),%edx
  801119:	83 3a 01             	cmpl   $0x1,(%edx)
  80111c:	7f 10                	jg     80112e <argnextvalue+0x3f>
		args->argvalue = 0;
  80111e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801125:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  80112c:	eb e1                	jmp    80110f <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  80112e:	8b 43 04             	mov    0x4(%ebx),%eax
  801131:	8b 48 04             	mov    0x4(%eax),%ecx
  801134:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801137:	83 ec 04             	sub    $0x4,%esp
  80113a:	8b 12                	mov    (%edx),%edx
  80113c:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801143:	52                   	push   %edx
  801144:	8d 50 08             	lea    0x8(%eax),%edx
  801147:	52                   	push   %edx
  801148:	83 c0 04             	add    $0x4,%eax
  80114b:	50                   	push   %eax
  80114c:	e8 23 fa ff ff       	call   800b74 <memmove>
		(*args->argc)--;
  801151:	8b 03                	mov    (%ebx),%eax
  801153:	83 28 01             	subl   $0x1,(%eax)
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	eb b4                	jmp    80110f <argnextvalue+0x20>

0080115b <argvalue>:
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801164:	8b 42 0c             	mov    0xc(%edx),%eax
  801167:	85 c0                	test   %eax,%eax
  801169:	74 02                	je     80116d <argvalue+0x12>
}
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	52                   	push   %edx
  801171:	e8 79 ff ff ff       	call   8010ef <argnextvalue>
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	eb f0                	jmp    80116b <argvalue+0x10>

0080117b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80117e:	8b 45 08             	mov    0x8(%ebp),%eax
  801181:	05 00 00 00 30       	add    $0x30000000,%eax
  801186:	c1 e8 0c             	shr    $0xc,%eax
}
  801189:	5d                   	pop    %ebp
  80118a:	c3                   	ret    

0080118b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80118e:	8b 45 08             	mov    0x8(%ebp),%eax
  801191:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	c1 ea 16             	shr    $0x16,%edx
  8011af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b6:	f6 c2 01             	test   $0x1,%dl
  8011b9:	74 29                	je     8011e4 <fd_alloc+0x42>
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	c1 ea 0c             	shr    $0xc,%edx
  8011c0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c7:	f6 c2 01             	test   $0x1,%dl
  8011ca:	74 18                	je     8011e4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011cc:	05 00 10 00 00       	add    $0x1000,%eax
  8011d1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011d6:	75 d2                	jne    8011aa <fd_alloc+0x8>
  8011d8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011dd:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011e2:	eb 05                	jmp    8011e9 <fd_alloc+0x47>
			return 0;
  8011e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8011e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ec:	89 02                	mov    %eax,(%edx)
}
  8011ee:	89 c8                	mov    %ecx,%eax
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f8:	83 f8 1f             	cmp    $0x1f,%eax
  8011fb:	77 30                	ja     80122d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fd:	c1 e0 0c             	shl    $0xc,%eax
  801200:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801205:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80120b:	f6 c2 01             	test   $0x1,%dl
  80120e:	74 24                	je     801234 <fd_lookup+0x42>
  801210:	89 c2                	mov    %eax,%edx
  801212:	c1 ea 0c             	shr    $0xc,%edx
  801215:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121c:	f6 c2 01             	test   $0x1,%dl
  80121f:	74 1a                	je     80123b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801221:	8b 55 0c             	mov    0xc(%ebp),%edx
  801224:	89 02                	mov    %eax,(%edx)
	return 0;
  801226:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    
		return -E_INVAL;
  80122d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801232:	eb f7                	jmp    80122b <fd_lookup+0x39>
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb f0                	jmp    80122b <fd_lookup+0x39>
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801240:	eb e9                	jmp    80122b <fd_lookup+0x39>

00801242 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
  801251:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801256:	39 13                	cmp    %edx,(%ebx)
  801258:	74 37                	je     801291 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80125a:	83 c0 01             	add    $0x1,%eax
  80125d:	8b 1c 85 88 2b 80 00 	mov    0x802b88(,%eax,4),%ebx
  801264:	85 db                	test   %ebx,%ebx
  801266:	75 ee                	jne    801256 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801268:	a1 00 44 80 00       	mov    0x804400,%eax
  80126d:	8b 40 58             	mov    0x58(%eax),%eax
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	52                   	push   %edx
  801274:	50                   	push   %eax
  801275:	68 0c 2b 80 00       	push   $0x802b0c
  80127a:	e8 85 f1 ff ff       	call   800404 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801287:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128a:	89 1a                	mov    %ebx,(%edx)
}
  80128c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80128f:	c9                   	leave  
  801290:	c3                   	ret    
			return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb ef                	jmp    801287 <dev_lookup+0x45>

00801298 <fd_close>:
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 24             	sub    $0x24,%esp
  8012a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012aa:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012b4:	50                   	push   %eax
  8012b5:	e8 38 ff ff ff       	call   8011f2 <fd_lookup>
  8012ba:	89 c3                	mov    %eax,%ebx
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 05                	js     8012c8 <fd_close+0x30>
	    || fd != fd2)
  8012c3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012c6:	74 16                	je     8012de <fd_close+0x46>
		return (must_exist ? r : 0);
  8012c8:	89 f8                	mov    %edi,%eax
  8012ca:	84 c0                	test   %al,%al
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d1:	0f 44 d8             	cmove  %eax,%ebx
}
  8012d4:	89 d8                	mov    %ebx,%eax
  8012d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d9:	5b                   	pop    %ebx
  8012da:	5e                   	pop    %esi
  8012db:	5f                   	pop    %edi
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	ff 36                	push   (%esi)
  8012e7:	e8 56 ff ff ff       	call   801242 <dev_lookup>
  8012ec:	89 c3                	mov    %eax,%ebx
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	85 c0                	test   %eax,%eax
  8012f3:	78 1a                	js     80130f <fd_close+0x77>
		if (dev->dev_close)
  8012f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f8:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801300:	85 c0                	test   %eax,%eax
  801302:	74 0b                	je     80130f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	56                   	push   %esi
  801308:	ff d0                	call   *%eax
  80130a:	89 c3                	mov    %eax,%ebx
  80130c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80130f:	83 ec 08             	sub    $0x8,%esp
  801312:	56                   	push   %esi
  801313:	6a 00                	push   $0x0
  801315:	e8 45 fb ff ff       	call   800e5f <sys_page_unmap>
	return r;
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	eb b5                	jmp    8012d4 <fd_close+0x3c>

0080131f <close>:

int
close(int fdnum)
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	ff 75 08             	push   0x8(%ebp)
  80132c:	e8 c1 fe ff ff       	call   8011f2 <fd_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	79 02                	jns    80133a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    
		return fd_close(fd, 1);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	6a 01                	push   $0x1
  80133f:	ff 75 f4             	push   -0xc(%ebp)
  801342:	e8 51 ff ff ff       	call   801298 <fd_close>
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	eb ec                	jmp    801338 <close+0x19>

0080134c <close_all>:

void
close_all(void)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	53                   	push   %ebx
  801350:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801353:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	53                   	push   %ebx
  80135c:	e8 be ff ff ff       	call   80131f <close>
	for (i = 0; i < MAXFD; i++)
  801361:	83 c3 01             	add    $0x1,%ebx
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	83 fb 20             	cmp    $0x20,%ebx
  80136a:	75 ec                	jne    801358 <close_all+0xc>
}
  80136c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	push   0x8(%ebp)
  801381:	e8 6c fe ff ff       	call   8011f2 <fd_lookup>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 7f                	js     80140e <dup+0x9d>
		return r;
	close(newfdnum);
  80138f:	83 ec 0c             	sub    $0xc,%esp
  801392:	ff 75 0c             	push   0xc(%ebp)
  801395:	e8 85 ff ff ff       	call   80131f <close>

	newfd = INDEX2FD(newfdnum);
  80139a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80139d:	c1 e6 0c             	shl    $0xc,%esi
  8013a0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a9:	89 3c 24             	mov    %edi,(%esp)
  8013ac:	e8 da fd ff ff       	call   80118b <fd2data>
  8013b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013b3:	89 34 24             	mov    %esi,(%esp)
  8013b6:	e8 d0 fd ff ff       	call   80118b <fd2data>
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c1:	89 d8                	mov    %ebx,%eax
  8013c3:	c1 e8 16             	shr    $0x16,%eax
  8013c6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cd:	a8 01                	test   $0x1,%al
  8013cf:	74 11                	je     8013e2 <dup+0x71>
  8013d1:	89 d8                	mov    %ebx,%eax
  8013d3:	c1 e8 0c             	shr    $0xc,%eax
  8013d6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013dd:	f6 c2 01             	test   $0x1,%dl
  8013e0:	75 36                	jne    801418 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e2:	89 f8                	mov    %edi,%eax
  8013e4:	c1 e8 0c             	shr    $0xc,%eax
  8013e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ee:	83 ec 0c             	sub    $0xc,%esp
  8013f1:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f6:	50                   	push   %eax
  8013f7:	56                   	push   %esi
  8013f8:	6a 00                	push   $0x0
  8013fa:	57                   	push   %edi
  8013fb:	6a 00                	push   $0x0
  8013fd:	e8 1b fa ff ff       	call   800e1d <sys_page_map>
  801402:	89 c3                	mov    %eax,%ebx
  801404:	83 c4 20             	add    $0x20,%esp
  801407:	85 c0                	test   %eax,%eax
  801409:	78 33                	js     80143e <dup+0xcd>
		goto err;

	return newfdnum;
  80140b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80140e:	89 d8                	mov    %ebx,%eax
  801410:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801413:	5b                   	pop    %ebx
  801414:	5e                   	pop    %esi
  801415:	5f                   	pop    %edi
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801418:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141f:	83 ec 0c             	sub    $0xc,%esp
  801422:	25 07 0e 00 00       	and    $0xe07,%eax
  801427:	50                   	push   %eax
  801428:	ff 75 d4             	push   -0x2c(%ebp)
  80142b:	6a 00                	push   $0x0
  80142d:	53                   	push   %ebx
  80142e:	6a 00                	push   $0x0
  801430:	e8 e8 f9 ff ff       	call   800e1d <sys_page_map>
  801435:	89 c3                	mov    %eax,%ebx
  801437:	83 c4 20             	add    $0x20,%esp
  80143a:	85 c0                	test   %eax,%eax
  80143c:	79 a4                	jns    8013e2 <dup+0x71>
	sys_page_unmap(0, newfd);
  80143e:	83 ec 08             	sub    $0x8,%esp
  801441:	56                   	push   %esi
  801442:	6a 00                	push   $0x0
  801444:	e8 16 fa ff ff       	call   800e5f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	ff 75 d4             	push   -0x2c(%ebp)
  80144f:	6a 00                	push   $0x0
  801451:	e8 09 fa ff ff       	call   800e5f <sys_page_unmap>
	return r;
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb b3                	jmp    80140e <dup+0x9d>

0080145b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
  801460:	83 ec 18             	sub    $0x18,%esp
  801463:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801466:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	56                   	push   %esi
  80146b:	e8 82 fd ff ff       	call   8011f2 <fd_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 3c                	js     8014b3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	ff 33                	push   (%ebx)
  801483:	e8 ba fd ff ff       	call   801242 <dev_lookup>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 24                	js     8014b3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148f:	8b 43 08             	mov    0x8(%ebx),%eax
  801492:	83 e0 03             	and    $0x3,%eax
  801495:	83 f8 01             	cmp    $0x1,%eax
  801498:	74 20                	je     8014ba <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149d:	8b 40 08             	mov    0x8(%eax),%eax
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	74 37                	je     8014db <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	ff 75 10             	push   0x10(%ebp)
  8014aa:	ff 75 0c             	push   0xc(%ebp)
  8014ad:	53                   	push   %ebx
  8014ae:	ff d0                	call   *%eax
  8014b0:	83 c4 10             	add    $0x10,%esp
}
  8014b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ba:	a1 00 44 80 00       	mov    0x804400,%eax
  8014bf:	8b 40 58             	mov    0x58(%eax),%eax
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	56                   	push   %esi
  8014c6:	50                   	push   %eax
  8014c7:	68 4d 2b 80 00       	push   $0x802b4d
  8014cc:	e8 33 ef ff ff       	call   800404 <cprintf>
		return -E_INVAL;
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d9:	eb d8                	jmp    8014b3 <read+0x58>
		return -E_NOT_SUPP;
  8014db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014e0:	eb d1                	jmp    8014b3 <read+0x58>

008014e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f6:	eb 02                	jmp    8014fa <readn+0x18>
  8014f8:	01 c3                	add    %eax,%ebx
  8014fa:	39 f3                	cmp    %esi,%ebx
  8014fc:	73 21                	jae    80151f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	89 f0                	mov    %esi,%eax
  801503:	29 d8                	sub    %ebx,%eax
  801505:	50                   	push   %eax
  801506:	89 d8                	mov    %ebx,%eax
  801508:	03 45 0c             	add    0xc(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	57                   	push   %edi
  80150d:	e8 49 ff ff ff       	call   80145b <read>
		if (m < 0)
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	85 c0                	test   %eax,%eax
  801517:	78 04                	js     80151d <readn+0x3b>
			return m;
		if (m == 0)
  801519:	75 dd                	jne    8014f8 <readn+0x16>
  80151b:	eb 02                	jmp    80151f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80151d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80151f:	89 d8                	mov    %ebx,%eax
  801521:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801524:	5b                   	pop    %ebx
  801525:	5e                   	pop    %esi
  801526:	5f                   	pop    %edi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    

00801529 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	56                   	push   %esi
  80152d:	53                   	push   %ebx
  80152e:	83 ec 18             	sub    $0x18,%esp
  801531:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801534:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	53                   	push   %ebx
  801539:	e8 b4 fc ff ff       	call   8011f2 <fd_lookup>
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 37                	js     80157c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801545:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801548:	83 ec 08             	sub    $0x8,%esp
  80154b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	ff 36                	push   (%esi)
  801551:	e8 ec fc ff ff       	call   801242 <dev_lookup>
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 1f                	js     80157c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80155d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801561:	74 20                	je     801583 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801566:	8b 40 0c             	mov    0xc(%eax),%eax
  801569:	85 c0                	test   %eax,%eax
  80156b:	74 37                	je     8015a4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80156d:	83 ec 04             	sub    $0x4,%esp
  801570:	ff 75 10             	push   0x10(%ebp)
  801573:	ff 75 0c             	push   0xc(%ebp)
  801576:	56                   	push   %esi
  801577:	ff d0                	call   *%eax
  801579:	83 c4 10             	add    $0x10,%esp
}
  80157c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80157f:	5b                   	pop    %ebx
  801580:	5e                   	pop    %esi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801583:	a1 00 44 80 00       	mov    0x804400,%eax
  801588:	8b 40 58             	mov    0x58(%eax),%eax
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	53                   	push   %ebx
  80158f:	50                   	push   %eax
  801590:	68 69 2b 80 00       	push   $0x802b69
  801595:	e8 6a ee ff ff       	call   800404 <cprintf>
		return -E_INVAL;
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015a2:	eb d8                	jmp    80157c <write+0x53>
		return -E_NOT_SUPP;
  8015a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a9:	eb d1                	jmp    80157c <write+0x53>

008015ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	ff 75 08             	push   0x8(%ebp)
  8015b8:	e8 35 fc ff ff       	call   8011f2 <fd_lookup>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 0e                	js     8015d2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 18             	sub    $0x18,%esp
  8015dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	53                   	push   %ebx
  8015e4:	e8 09 fc ff ff       	call   8011f2 <fd_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 34                	js     801624 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	ff 36                	push   (%esi)
  8015fc:	e8 41 fc ff ff       	call   801242 <dev_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 1c                	js     801624 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801608:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80160c:	74 1d                	je     80162b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80160e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801611:	8b 40 18             	mov    0x18(%eax),%eax
  801614:	85 c0                	test   %eax,%eax
  801616:	74 34                	je     80164c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	ff 75 0c             	push   0xc(%ebp)
  80161e:	56                   	push   %esi
  80161f:	ff d0                	call   *%eax
  801621:	83 c4 10             	add    $0x10,%esp
}
  801624:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801627:	5b                   	pop    %ebx
  801628:	5e                   	pop    %esi
  801629:	5d                   	pop    %ebp
  80162a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80162b:	a1 00 44 80 00       	mov    0x804400,%eax
  801630:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801633:	83 ec 04             	sub    $0x4,%esp
  801636:	53                   	push   %ebx
  801637:	50                   	push   %eax
  801638:	68 2c 2b 80 00       	push   $0x802b2c
  80163d:	e8 c2 ed ff ff       	call   800404 <cprintf>
		return -E_INVAL;
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164a:	eb d8                	jmp    801624 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80164c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801651:	eb d1                	jmp    801624 <ftruncate+0x50>

00801653 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801653:	55                   	push   %ebp
  801654:	89 e5                	mov    %esp,%ebp
  801656:	56                   	push   %esi
  801657:	53                   	push   %ebx
  801658:	83 ec 18             	sub    $0x18,%esp
  80165b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	ff 75 08             	push   0x8(%ebp)
  801665:	e8 88 fb ff ff       	call   8011f2 <fd_lookup>
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 49                	js     8016ba <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801671:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	ff 36                	push   (%esi)
  80167d:	e8 c0 fb ff ff       	call   801242 <dev_lookup>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	85 c0                	test   %eax,%eax
  801687:	78 31                	js     8016ba <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801690:	74 2f                	je     8016c1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801692:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801695:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169c:	00 00 00 
	stat->st_isdir = 0;
  80169f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a6:	00 00 00 
	stat->st_dev = dev;
  8016a9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	53                   	push   %ebx
  8016b3:	56                   	push   %esi
  8016b4:	ff 50 14             	call   *0x14(%eax)
  8016b7:	83 c4 10             	add    $0x10,%esp
}
  8016ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    
		return -E_NOT_SUPP;
  8016c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016c6:	eb f2                	jmp    8016ba <fstat+0x67>

008016c8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016cd:	83 ec 08             	sub    $0x8,%esp
  8016d0:	6a 00                	push   $0x0
  8016d2:	ff 75 08             	push   0x8(%ebp)
  8016d5:	e8 e4 01 00 00       	call   8018be <open>
  8016da:	89 c3                	mov    %eax,%ebx
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	78 1b                	js     8016fe <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	ff 75 0c             	push   0xc(%ebp)
  8016e9:	50                   	push   %eax
  8016ea:	e8 64 ff ff ff       	call   801653 <fstat>
  8016ef:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f1:	89 1c 24             	mov    %ebx,(%esp)
  8016f4:	e8 26 fc ff ff       	call   80131f <close>
	return r;
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	89 f3                	mov    %esi,%ebx
}
  8016fe:	89 d8                	mov    %ebx,%eax
  801700:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801703:	5b                   	pop    %ebx
  801704:	5e                   	pop    %esi
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	56                   	push   %esi
  80170b:	53                   	push   %ebx
  80170c:	89 c6                	mov    %eax,%esi
  80170e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801710:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801717:	74 27                	je     801740 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801719:	6a 07                	push   $0x7
  80171b:	68 00 50 80 00       	push   $0x805000
  801720:	56                   	push   %esi
  801721:	ff 35 00 60 80 00    	push   0x806000
  801727:	e8 e0 0c 00 00       	call   80240c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80172c:	83 c4 0c             	add    $0xc,%esp
  80172f:	6a 00                	push   $0x0
  801731:	53                   	push   %ebx
  801732:	6a 00                	push   $0x0
  801734:	e8 63 0c 00 00       	call   80239c <ipc_recv>
}
  801739:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801740:	83 ec 0c             	sub    $0xc,%esp
  801743:	6a 01                	push   $0x1
  801745:	e8 16 0d 00 00       	call   802460 <ipc_find_env>
  80174a:	a3 00 60 80 00       	mov    %eax,0x806000
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	eb c5                	jmp    801719 <fsipc+0x12>

00801754 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80175a:	8b 45 08             	mov    0x8(%ebp),%eax
  80175d:	8b 40 0c             	mov    0xc(%eax),%eax
  801760:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801765:	8b 45 0c             	mov    0xc(%ebp),%eax
  801768:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 02 00 00 00       	mov    $0x2,%eax
  801777:	e8 8b ff ff ff       	call   801707 <fsipc>
}
  80177c:	c9                   	leave  
  80177d:	c3                   	ret    

0080177e <devfile_flush>:
{
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	8b 40 0c             	mov    0xc(%eax),%eax
  80178a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	b8 06 00 00 00       	mov    $0x6,%eax
  801799:	e8 69 ff ff ff       	call   801707 <fsipc>
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_stat>:
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8017bf:	e8 43 ff ff ff       	call   801707 <fsipc>
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 2c                	js     8017f4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	68 00 50 80 00       	push   $0x805000
  8017d0:	53                   	push   %ebx
  8017d1:	e8 08 f2 ff ff       	call   8009de <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017d6:	a1 80 50 80 00       	mov    0x805080,%eax
  8017db:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e1:	a1 84 50 80 00       	mov    0x805084,%eax
  8017e6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017ec:	83 c4 10             	add    $0x10,%esp
  8017ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <devfile_write>:
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 0c             	sub    $0xc,%esp
  8017ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801802:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801807:	39 d0                	cmp    %edx,%eax
  801809:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80180c:	8b 55 08             	mov    0x8(%ebp),%edx
  80180f:	8b 52 0c             	mov    0xc(%edx),%edx
  801812:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801818:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80181d:	50                   	push   %eax
  80181e:	ff 75 0c             	push   0xc(%ebp)
  801821:	68 08 50 80 00       	push   $0x805008
  801826:	e8 49 f3 ff ff       	call   800b74 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80182b:	ba 00 00 00 00       	mov    $0x0,%edx
  801830:	b8 04 00 00 00       	mov    $0x4,%eax
  801835:	e8 cd fe ff ff       	call   801707 <fsipc>
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <devfile_read>:
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	56                   	push   %esi
  801840:	53                   	push   %ebx
  801841:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80184f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801855:	ba 00 00 00 00       	mov    $0x0,%edx
  80185a:	b8 03 00 00 00       	mov    $0x3,%eax
  80185f:	e8 a3 fe ff ff       	call   801707 <fsipc>
  801864:	89 c3                	mov    %eax,%ebx
  801866:	85 c0                	test   %eax,%eax
  801868:	78 1f                	js     801889 <devfile_read+0x4d>
	assert(r <= n);
  80186a:	39 f0                	cmp    %esi,%eax
  80186c:	77 24                	ja     801892 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80186e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801873:	7f 33                	jg     8018a8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801875:	83 ec 04             	sub    $0x4,%esp
  801878:	50                   	push   %eax
  801879:	68 00 50 80 00       	push   $0x805000
  80187e:	ff 75 0c             	push   0xc(%ebp)
  801881:	e8 ee f2 ff ff       	call   800b74 <memmove>
	return r;
  801886:	83 c4 10             	add    $0x10,%esp
}
  801889:	89 d8                	mov    %ebx,%eax
  80188b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188e:	5b                   	pop    %ebx
  80188f:	5e                   	pop    %esi
  801890:	5d                   	pop    %ebp
  801891:	c3                   	ret    
	assert(r <= n);
  801892:	68 9c 2b 80 00       	push   $0x802b9c
  801897:	68 a3 2b 80 00       	push   $0x802ba3
  80189c:	6a 7c                	push   $0x7c
  80189e:	68 b8 2b 80 00       	push   $0x802bb8
  8018a3:	e8 81 ea ff ff       	call   800329 <_panic>
	assert(r <= PGSIZE);
  8018a8:	68 c3 2b 80 00       	push   $0x802bc3
  8018ad:	68 a3 2b 80 00       	push   $0x802ba3
  8018b2:	6a 7d                	push   $0x7d
  8018b4:	68 b8 2b 80 00       	push   $0x802bb8
  8018b9:	e8 6b ea ff ff       	call   800329 <_panic>

008018be <open>:
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	56                   	push   %esi
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 1c             	sub    $0x1c,%esp
  8018c6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018c9:	56                   	push   %esi
  8018ca:	e8 d4 f0 ff ff       	call   8009a3 <strlen>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018d7:	7f 6c                	jg     801945 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	e8 bd f8 ff ff       	call   8011a2 <fd_alloc>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 3c                	js     80192a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	56                   	push   %esi
  8018f2:	68 00 50 80 00       	push   $0x805000
  8018f7:	e8 e2 f0 ff ff       	call   8009de <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ff:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801904:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801907:	b8 01 00 00 00       	mov    $0x1,%eax
  80190c:	e8 f6 fd ff ff       	call   801707 <fsipc>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 19                	js     801933 <open+0x75>
	return fd2num(fd);
  80191a:	83 ec 0c             	sub    $0xc,%esp
  80191d:	ff 75 f4             	push   -0xc(%ebp)
  801920:	e8 56 f8 ff ff       	call   80117b <fd2num>
  801925:	89 c3                	mov    %eax,%ebx
  801927:	83 c4 10             	add    $0x10,%esp
}
  80192a:	89 d8                	mov    %ebx,%eax
  80192c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192f:	5b                   	pop    %ebx
  801930:	5e                   	pop    %esi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    
		fd_close(fd, 0);
  801933:	83 ec 08             	sub    $0x8,%esp
  801936:	6a 00                	push   $0x0
  801938:	ff 75 f4             	push   -0xc(%ebp)
  80193b:	e8 58 f9 ff ff       	call   801298 <fd_close>
		return r;
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	eb e5                	jmp    80192a <open+0x6c>
		return -E_BAD_PATH;
  801945:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80194a:	eb de                	jmp    80192a <open+0x6c>

0080194c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801952:	ba 00 00 00 00       	mov    $0x0,%edx
  801957:	b8 08 00 00 00       	mov    $0x8,%eax
  80195c:	e8 a6 fd ff ff       	call   801707 <fsipc>
}
  801961:	c9                   	leave  
  801962:	c3                   	ret    

00801963 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801963:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801967:	7f 01                	jg     80196a <writebuf+0x7>
  801969:	c3                   	ret    
{
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	53                   	push   %ebx
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801973:	ff 70 04             	push   0x4(%eax)
  801976:	8d 40 10             	lea    0x10(%eax),%eax
  801979:	50                   	push   %eax
  80197a:	ff 33                	push   (%ebx)
  80197c:	e8 a8 fb ff ff       	call   801529 <write>
		if (result > 0)
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	7e 03                	jle    80198b <writebuf+0x28>
			b->result += result;
  801988:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80198b:	39 43 04             	cmp    %eax,0x4(%ebx)
  80198e:	74 0d                	je     80199d <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801990:	85 c0                	test   %eax,%eax
  801992:	ba 00 00 00 00       	mov    $0x0,%edx
  801997:	0f 4f c2             	cmovg  %edx,%eax
  80199a:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80199d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <putch>:

static void
putch(int ch, void *thunk)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8019ac:	8b 53 04             	mov    0x4(%ebx),%edx
  8019af:	8d 42 01             	lea    0x1(%edx),%eax
  8019b2:	89 43 04             	mov    %eax,0x4(%ebx)
  8019b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019b8:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8019bc:	3d 00 01 00 00       	cmp    $0x100,%eax
  8019c1:	74 05                	je     8019c8 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    
		writebuf(b);
  8019c8:	89 d8                	mov    %ebx,%eax
  8019ca:	e8 94 ff ff ff       	call   801963 <writebuf>
		b->idx = 0;
  8019cf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8019d6:	eb eb                	jmp    8019c3 <putch+0x21>

008019d8 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8019e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e4:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8019ea:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8019f1:	00 00 00 
	b.result = 0;
  8019f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8019fb:	00 00 00 
	b.error = 1;
  8019fe:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801a05:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801a08:	ff 75 10             	push   0x10(%ebp)
  801a0b:	ff 75 0c             	push   0xc(%ebp)
  801a0e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a14:	50                   	push   %eax
  801a15:	68 a2 19 80 00       	push   $0x8019a2
  801a1a:	e8 dc ea ff ff       	call   8004fb <vprintfmt>
	if (b.idx > 0)
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801a29:	7f 11                	jg     801a3c <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801a2b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801a31:	85 c0                	test   %eax,%eax
  801a33:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    
		writebuf(&b);
  801a3c:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801a42:	e8 1c ff ff ff       	call   801963 <writebuf>
  801a47:	eb e2                	jmp    801a2b <vfprintf+0x53>

00801a49 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a4f:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801a52:	50                   	push   %eax
  801a53:	ff 75 0c             	push   0xc(%ebp)
  801a56:	ff 75 08             	push   0x8(%ebp)
  801a59:	e8 7a ff ff ff       	call   8019d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <printf>:

int
printf(const char *fmt, ...)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a66:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a69:	50                   	push   %eax
  801a6a:	ff 75 08             	push   0x8(%ebp)
  801a6d:	6a 01                	push   $0x1
  801a6f:	e8 64 ff ff ff       	call   8019d8 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a7c:	68 cf 2b 80 00       	push   $0x802bcf
  801a81:	ff 75 0c             	push   0xc(%ebp)
  801a84:	e8 55 ef ff ff       	call   8009de <strcpy>
	return 0;
}
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8e:	c9                   	leave  
  801a8f:	c3                   	ret    

00801a90 <devsock_close>:
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	53                   	push   %ebx
  801a94:	83 ec 10             	sub    $0x10,%esp
  801a97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a9a:	53                   	push   %ebx
  801a9b:	e8 ff 09 00 00       	call   80249f <pageref>
  801aa0:	89 c2                	mov    %eax,%edx
  801aa2:	83 c4 10             	add    $0x10,%esp
		return 0;
  801aa5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801aaa:	83 fa 01             	cmp    $0x1,%edx
  801aad:	74 05                	je     801ab4 <devsock_close+0x24>
}
  801aaf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801ab4:	83 ec 0c             	sub    $0xc,%esp
  801ab7:	ff 73 0c             	push   0xc(%ebx)
  801aba:	e8 b7 02 00 00       	call   801d76 <nsipc_close>
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	eb eb                	jmp    801aaf <devsock_close+0x1f>

00801ac4 <devsock_write>:
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aca:	6a 00                	push   $0x0
  801acc:	ff 75 10             	push   0x10(%ebp)
  801acf:	ff 75 0c             	push   0xc(%ebp)
  801ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad5:	ff 70 0c             	push   0xc(%eax)
  801ad8:	e8 79 03 00 00       	call   801e56 <nsipc_send>
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <devsock_read>:
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ae5:	6a 00                	push   $0x0
  801ae7:	ff 75 10             	push   0x10(%ebp)
  801aea:	ff 75 0c             	push   0xc(%ebp)
  801aed:	8b 45 08             	mov    0x8(%ebp),%eax
  801af0:	ff 70 0c             	push   0xc(%eax)
  801af3:	e8 ef 02 00 00       	call   801de7 <nsipc_recv>
}
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <fd2sockid>:
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b00:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b03:	52                   	push   %edx
  801b04:	50                   	push   %eax
  801b05:	e8 e8 f6 ff ff       	call   8011f2 <fd_lookup>
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	78 10                	js     801b21 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b14:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b1a:	39 08                	cmp    %ecx,(%eax)
  801b1c:	75 05                	jne    801b23 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b1e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    
		return -E_NOT_SUPP;
  801b23:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b28:	eb f7                	jmp    801b21 <fd2sockid+0x27>

00801b2a <alloc_sockfd>:
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	56                   	push   %esi
  801b2e:	53                   	push   %ebx
  801b2f:	83 ec 1c             	sub    $0x1c,%esp
  801b32:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b37:	50                   	push   %eax
  801b38:	e8 65 f6 ff ff       	call   8011a2 <fd_alloc>
  801b3d:	89 c3                	mov    %eax,%ebx
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 43                	js     801b89 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b46:	83 ec 04             	sub    $0x4,%esp
  801b49:	68 07 04 00 00       	push   $0x407
  801b4e:	ff 75 f4             	push   -0xc(%ebp)
  801b51:	6a 00                	push   $0x0
  801b53:	e8 82 f2 ff ff       	call   800dda <sys_page_alloc>
  801b58:	89 c3                	mov    %eax,%ebx
  801b5a:	83 c4 10             	add    $0x10,%esp
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	78 28                	js     801b89 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b64:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b6a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b76:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b79:	83 ec 0c             	sub    $0xc,%esp
  801b7c:	50                   	push   %eax
  801b7d:	e8 f9 f5 ff ff       	call   80117b <fd2num>
  801b82:	89 c3                	mov    %eax,%ebx
  801b84:	83 c4 10             	add    $0x10,%esp
  801b87:	eb 0c                	jmp    801b95 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b89:	83 ec 0c             	sub    $0xc,%esp
  801b8c:	56                   	push   %esi
  801b8d:	e8 e4 01 00 00       	call   801d76 <nsipc_close>
		return r;
  801b92:	83 c4 10             	add    $0x10,%esp
}
  801b95:	89 d8                	mov    %ebx,%eax
  801b97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9a:	5b                   	pop    %ebx
  801b9b:	5e                   	pop    %esi
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <accept>:
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba7:	e8 4e ff ff ff       	call   801afa <fd2sockid>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 1b                	js     801bcb <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bb0:	83 ec 04             	sub    $0x4,%esp
  801bb3:	ff 75 10             	push   0x10(%ebp)
  801bb6:	ff 75 0c             	push   0xc(%ebp)
  801bb9:	50                   	push   %eax
  801bba:	e8 0e 01 00 00       	call   801ccd <nsipc_accept>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 05                	js     801bcb <accept+0x2d>
	return alloc_sockfd(r);
  801bc6:	e8 5f ff ff ff       	call   801b2a <alloc_sockfd>
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <bind>:
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd6:	e8 1f ff ff ff       	call   801afa <fd2sockid>
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 12                	js     801bf1 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801bdf:	83 ec 04             	sub    $0x4,%esp
  801be2:	ff 75 10             	push   0x10(%ebp)
  801be5:	ff 75 0c             	push   0xc(%ebp)
  801be8:	50                   	push   %eax
  801be9:	e8 31 01 00 00       	call   801d1f <nsipc_bind>
  801bee:	83 c4 10             	add    $0x10,%esp
}
  801bf1:	c9                   	leave  
  801bf2:	c3                   	ret    

00801bf3 <shutdown>:
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	e8 f9 fe ff ff       	call   801afa <fd2sockid>
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 0f                	js     801c14 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801c05:	83 ec 08             	sub    $0x8,%esp
  801c08:	ff 75 0c             	push   0xc(%ebp)
  801c0b:	50                   	push   %eax
  801c0c:	e8 43 01 00 00       	call   801d54 <nsipc_shutdown>
  801c11:	83 c4 10             	add    $0x10,%esp
}
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <connect>:
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	e8 d6 fe ff ff       	call   801afa <fd2sockid>
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 12                	js     801c3a <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801c28:	83 ec 04             	sub    $0x4,%esp
  801c2b:	ff 75 10             	push   0x10(%ebp)
  801c2e:	ff 75 0c             	push   0xc(%ebp)
  801c31:	50                   	push   %eax
  801c32:	e8 59 01 00 00       	call   801d90 <nsipc_connect>
  801c37:	83 c4 10             	add    $0x10,%esp
}
  801c3a:	c9                   	leave  
  801c3b:	c3                   	ret    

00801c3c <listen>:
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	e8 b0 fe ff ff       	call   801afa <fd2sockid>
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 0f                	js     801c5d <listen+0x21>
	return nsipc_listen(r, backlog);
  801c4e:	83 ec 08             	sub    $0x8,%esp
  801c51:	ff 75 0c             	push   0xc(%ebp)
  801c54:	50                   	push   %eax
  801c55:	e8 6b 01 00 00       	call   801dc5 <nsipc_listen>
  801c5a:	83 c4 10             	add    $0x10,%esp
}
  801c5d:	c9                   	leave  
  801c5e:	c3                   	ret    

00801c5f <socket>:

int
socket(int domain, int type, int protocol)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c65:	ff 75 10             	push   0x10(%ebp)
  801c68:	ff 75 0c             	push   0xc(%ebp)
  801c6b:	ff 75 08             	push   0x8(%ebp)
  801c6e:	e8 41 02 00 00       	call   801eb4 <nsipc_socket>
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	78 05                	js     801c7f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c7a:	e8 ab fe ff ff       	call   801b2a <alloc_sockfd>
}
  801c7f:	c9                   	leave  
  801c80:	c3                   	ret    

00801c81 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	53                   	push   %ebx
  801c85:	83 ec 04             	sub    $0x4,%esp
  801c88:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c8a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c91:	74 26                	je     801cb9 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c93:	6a 07                	push   $0x7
  801c95:	68 00 70 80 00       	push   $0x807000
  801c9a:	53                   	push   %ebx
  801c9b:	ff 35 00 80 80 00    	push   0x808000
  801ca1:	e8 66 07 00 00       	call   80240c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ca6:	83 c4 0c             	add    $0xc,%esp
  801ca9:	6a 00                	push   $0x0
  801cab:	6a 00                	push   $0x0
  801cad:	6a 00                	push   $0x0
  801caf:	e8 e8 06 00 00       	call   80239c <ipc_recv>
}
  801cb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb7:	c9                   	leave  
  801cb8:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cb9:	83 ec 0c             	sub    $0xc,%esp
  801cbc:	6a 02                	push   $0x2
  801cbe:	e8 9d 07 00 00       	call   802460 <ipc_find_env>
  801cc3:	a3 00 80 80 00       	mov    %eax,0x808000
  801cc8:	83 c4 10             	add    $0x10,%esp
  801ccb:	eb c6                	jmp    801c93 <nsipc+0x12>

00801ccd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cdd:	8b 06                	mov    (%esi),%eax
  801cdf:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ce4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce9:	e8 93 ff ff ff       	call   801c81 <nsipc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	79 09                	jns    801cfd <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801cf4:	89 d8                	mov    %ebx,%eax
  801cf6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf9:	5b                   	pop    %ebx
  801cfa:	5e                   	pop    %esi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	ff 35 10 70 80 00    	push   0x807010
  801d06:	68 00 70 80 00       	push   $0x807000
  801d0b:	ff 75 0c             	push   0xc(%ebp)
  801d0e:	e8 61 ee ff ff       	call   800b74 <memmove>
		*addrlen = ret->ret_addrlen;
  801d13:	a1 10 70 80 00       	mov    0x807010,%eax
  801d18:	89 06                	mov    %eax,(%esi)
  801d1a:	83 c4 10             	add    $0x10,%esp
	return r;
  801d1d:	eb d5                	jmp    801cf4 <nsipc_accept+0x27>

00801d1f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	53                   	push   %ebx
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d29:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d31:	53                   	push   %ebx
  801d32:	ff 75 0c             	push   0xc(%ebp)
  801d35:	68 04 70 80 00       	push   $0x807004
  801d3a:	e8 35 ee ff ff       	call   800b74 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d3f:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d45:	b8 02 00 00 00       	mov    $0x2,%eax
  801d4a:	e8 32 ff ff ff       	call   801c81 <nsipc>
}
  801d4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d65:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d6a:	b8 03 00 00 00       	mov    $0x3,%eax
  801d6f:	e8 0d ff ff ff       	call   801c81 <nsipc>
}
  801d74:	c9                   	leave  
  801d75:	c3                   	ret    

00801d76 <nsipc_close>:

int
nsipc_close(int s)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801d84:	b8 04 00 00 00       	mov    $0x4,%eax
  801d89:	e8 f3 fe ff ff       	call   801c81 <nsipc>
}
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	53                   	push   %ebx
  801d94:	83 ec 08             	sub    $0x8,%esp
  801d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801da2:	53                   	push   %ebx
  801da3:	ff 75 0c             	push   0xc(%ebp)
  801da6:	68 04 70 80 00       	push   $0x807004
  801dab:	e8 c4 ed ff ff       	call   800b74 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801db0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801db6:	b8 05 00 00 00       	mov    $0x5,%eax
  801dbb:	e8 c1 fe ff ff       	call   801c81 <nsipc>
}
  801dc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd6:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801ddb:	b8 06 00 00 00       	mov    $0x6,%eax
  801de0:	e8 9c fe ff ff       	call   801c81 <nsipc>
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
  801dec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801def:	8b 45 08             	mov    0x8(%ebp),%eax
  801df2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801df7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801dfd:	8b 45 14             	mov    0x14(%ebp),%eax
  801e00:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e05:	b8 07 00 00 00       	mov    $0x7,%eax
  801e0a:	e8 72 fe ff ff       	call   801c81 <nsipc>
  801e0f:	89 c3                	mov    %eax,%ebx
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 22                	js     801e37 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801e15:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e1a:	39 c6                	cmp    %eax,%esi
  801e1c:	0f 4e c6             	cmovle %esi,%eax
  801e1f:	39 c3                	cmp    %eax,%ebx
  801e21:	7f 1d                	jg     801e40 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e23:	83 ec 04             	sub    $0x4,%esp
  801e26:	53                   	push   %ebx
  801e27:	68 00 70 80 00       	push   $0x807000
  801e2c:	ff 75 0c             	push   0xc(%ebp)
  801e2f:	e8 40 ed ff ff       	call   800b74 <memmove>
  801e34:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e37:	89 d8                	mov    %ebx,%eax
  801e39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5e                   	pop    %esi
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e40:	68 db 2b 80 00       	push   $0x802bdb
  801e45:	68 a3 2b 80 00       	push   $0x802ba3
  801e4a:	6a 62                	push   $0x62
  801e4c:	68 f0 2b 80 00       	push   $0x802bf0
  801e51:	e8 d3 e4 ff ff       	call   800329 <_panic>

00801e56 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 04             	sub    $0x4,%esp
  801e5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e60:	8b 45 08             	mov    0x8(%ebp),%eax
  801e63:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e68:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e6e:	7f 2e                	jg     801e9e <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e70:	83 ec 04             	sub    $0x4,%esp
  801e73:	53                   	push   %ebx
  801e74:	ff 75 0c             	push   0xc(%ebp)
  801e77:	68 0c 70 80 00       	push   $0x80700c
  801e7c:	e8 f3 ec ff ff       	call   800b74 <memmove>
	nsipcbuf.send.req_size = size;
  801e81:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801e87:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e8f:	b8 08 00 00 00       	mov    $0x8,%eax
  801e94:	e8 e8 fd ff ff       	call   801c81 <nsipc>
}
  801e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e9c:	c9                   	leave  
  801e9d:	c3                   	ret    
	assert(size < 1600);
  801e9e:	68 fc 2b 80 00       	push   $0x802bfc
  801ea3:	68 a3 2b 80 00       	push   $0x802ba3
  801ea8:	6a 6d                	push   $0x6d
  801eaa:	68 f0 2b 80 00       	push   $0x802bf0
  801eaf:	e8 75 e4 ff ff       	call   800329 <_panic>

00801eb4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eba:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801eca:	8b 45 10             	mov    0x10(%ebp),%eax
  801ecd:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801ed2:	b8 09 00 00 00       	mov    $0x9,%eax
  801ed7:	e8 a5 fd ff ff       	call   801c81 <nsipc>
}
  801edc:	c9                   	leave  
  801edd:	c3                   	ret    

00801ede <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	56                   	push   %esi
  801ee2:	53                   	push   %ebx
  801ee3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ee6:	83 ec 0c             	sub    $0xc,%esp
  801ee9:	ff 75 08             	push   0x8(%ebp)
  801eec:	e8 9a f2 ff ff       	call   80118b <fd2data>
  801ef1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ef3:	83 c4 08             	add    $0x8,%esp
  801ef6:	68 08 2c 80 00       	push   $0x802c08
  801efb:	53                   	push   %ebx
  801efc:	e8 dd ea ff ff       	call   8009de <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f01:	8b 46 04             	mov    0x4(%esi),%eax
  801f04:	2b 06                	sub    (%esi),%eax
  801f06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f0c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f13:	00 00 00 
	stat->st_dev = &devpipe;
  801f16:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f1d:	30 80 00 
	return 0;
}
  801f20:	b8 00 00 00 00       	mov    $0x0,%eax
  801f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f28:	5b                   	pop    %ebx
  801f29:	5e                   	pop    %esi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f36:	53                   	push   %ebx
  801f37:	6a 00                	push   $0x0
  801f39:	e8 21 ef ff ff       	call   800e5f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f3e:	89 1c 24             	mov    %ebx,(%esp)
  801f41:	e8 45 f2 ff ff       	call   80118b <fd2data>
  801f46:	83 c4 08             	add    $0x8,%esp
  801f49:	50                   	push   %eax
  801f4a:	6a 00                	push   $0x0
  801f4c:	e8 0e ef ff ff       	call   800e5f <sys_page_unmap>
}
  801f51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    

00801f56 <_pipeisclosed>:
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	57                   	push   %edi
  801f5a:	56                   	push   %esi
  801f5b:	53                   	push   %ebx
  801f5c:	83 ec 1c             	sub    $0x1c,%esp
  801f5f:	89 c7                	mov    %eax,%edi
  801f61:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f63:	a1 00 44 80 00       	mov    0x804400,%eax
  801f68:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f6b:	83 ec 0c             	sub    $0xc,%esp
  801f6e:	57                   	push   %edi
  801f6f:	e8 2b 05 00 00       	call   80249f <pageref>
  801f74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f77:	89 34 24             	mov    %esi,(%esp)
  801f7a:	e8 20 05 00 00       	call   80249f <pageref>
		nn = thisenv->env_runs;
  801f7f:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801f85:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	39 cb                	cmp    %ecx,%ebx
  801f8d:	74 1b                	je     801faa <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f8f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f92:	75 cf                	jne    801f63 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f94:	8b 42 68             	mov    0x68(%edx),%eax
  801f97:	6a 01                	push   $0x1
  801f99:	50                   	push   %eax
  801f9a:	53                   	push   %ebx
  801f9b:	68 0f 2c 80 00       	push   $0x802c0f
  801fa0:	e8 5f e4 ff ff       	call   800404 <cprintf>
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	eb b9                	jmp    801f63 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801faa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fad:	0f 94 c0             	sete   %al
  801fb0:	0f b6 c0             	movzbl %al,%eax
}
  801fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb6:	5b                   	pop    %ebx
  801fb7:	5e                   	pop    %esi
  801fb8:	5f                   	pop    %edi
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    

00801fbb <devpipe_write>:
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	57                   	push   %edi
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	83 ec 28             	sub    $0x28,%esp
  801fc4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fc7:	56                   	push   %esi
  801fc8:	e8 be f1 ff ff       	call   80118b <fd2data>
  801fcd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	bf 00 00 00 00       	mov    $0x0,%edi
  801fd7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fda:	75 09                	jne    801fe5 <devpipe_write+0x2a>
	return i;
  801fdc:	89 f8                	mov    %edi,%eax
  801fde:	eb 23                	jmp    802003 <devpipe_write+0x48>
			sys_yield();
  801fe0:	e8 d6 ed ff ff       	call   800dbb <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fe5:	8b 43 04             	mov    0x4(%ebx),%eax
  801fe8:	8b 0b                	mov    (%ebx),%ecx
  801fea:	8d 51 20             	lea    0x20(%ecx),%edx
  801fed:	39 d0                	cmp    %edx,%eax
  801fef:	72 1a                	jb     80200b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ff1:	89 da                	mov    %ebx,%edx
  801ff3:	89 f0                	mov    %esi,%eax
  801ff5:	e8 5c ff ff ff       	call   801f56 <_pipeisclosed>
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	74 e2                	je     801fe0 <devpipe_write+0x25>
				return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80200b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80200e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802012:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802015:	89 c2                	mov    %eax,%edx
  802017:	c1 fa 1f             	sar    $0x1f,%edx
  80201a:	89 d1                	mov    %edx,%ecx
  80201c:	c1 e9 1b             	shr    $0x1b,%ecx
  80201f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802022:	83 e2 1f             	and    $0x1f,%edx
  802025:	29 ca                	sub    %ecx,%edx
  802027:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80202b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80202f:	83 c0 01             	add    $0x1,%eax
  802032:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802035:	83 c7 01             	add    $0x1,%edi
  802038:	eb 9d                	jmp    801fd7 <devpipe_write+0x1c>

0080203a <devpipe_read>:
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	57                   	push   %edi
  80203e:	56                   	push   %esi
  80203f:	53                   	push   %ebx
  802040:	83 ec 18             	sub    $0x18,%esp
  802043:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802046:	57                   	push   %edi
  802047:	e8 3f f1 ff ff       	call   80118b <fd2data>
  80204c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80204e:	83 c4 10             	add    $0x10,%esp
  802051:	be 00 00 00 00       	mov    $0x0,%esi
  802056:	3b 75 10             	cmp    0x10(%ebp),%esi
  802059:	75 13                	jne    80206e <devpipe_read+0x34>
	return i;
  80205b:	89 f0                	mov    %esi,%eax
  80205d:	eb 02                	jmp    802061 <devpipe_read+0x27>
				return i;
  80205f:	89 f0                	mov    %esi,%eax
}
  802061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    
			sys_yield();
  802069:	e8 4d ed ff ff       	call   800dbb <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80206e:	8b 03                	mov    (%ebx),%eax
  802070:	3b 43 04             	cmp    0x4(%ebx),%eax
  802073:	75 18                	jne    80208d <devpipe_read+0x53>
			if (i > 0)
  802075:	85 f6                	test   %esi,%esi
  802077:	75 e6                	jne    80205f <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802079:	89 da                	mov    %ebx,%edx
  80207b:	89 f8                	mov    %edi,%eax
  80207d:	e8 d4 fe ff ff       	call   801f56 <_pipeisclosed>
  802082:	85 c0                	test   %eax,%eax
  802084:	74 e3                	je     802069 <devpipe_read+0x2f>
				return 0;
  802086:	b8 00 00 00 00       	mov    $0x0,%eax
  80208b:	eb d4                	jmp    802061 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80208d:	99                   	cltd   
  80208e:	c1 ea 1b             	shr    $0x1b,%edx
  802091:	01 d0                	add    %edx,%eax
  802093:	83 e0 1f             	and    $0x1f,%eax
  802096:	29 d0                	sub    %edx,%eax
  802098:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80209d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020a3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020a6:	83 c6 01             	add    $0x1,%esi
  8020a9:	eb ab                	jmp    802056 <devpipe_read+0x1c>

008020ab <pipe>:
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	56                   	push   %esi
  8020af:	53                   	push   %ebx
  8020b0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020b6:	50                   	push   %eax
  8020b7:	e8 e6 f0 ff ff       	call   8011a2 <fd_alloc>
  8020bc:	89 c3                	mov    %eax,%ebx
  8020be:	83 c4 10             	add    $0x10,%esp
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	0f 88 23 01 00 00    	js     8021ec <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020c9:	83 ec 04             	sub    $0x4,%esp
  8020cc:	68 07 04 00 00       	push   $0x407
  8020d1:	ff 75 f4             	push   -0xc(%ebp)
  8020d4:	6a 00                	push   $0x0
  8020d6:	e8 ff ec ff ff       	call   800dda <sys_page_alloc>
  8020db:	89 c3                	mov    %eax,%ebx
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	0f 88 04 01 00 00    	js     8021ec <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8020e8:	83 ec 0c             	sub    $0xc,%esp
  8020eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020ee:	50                   	push   %eax
  8020ef:	e8 ae f0 ff ff       	call   8011a2 <fd_alloc>
  8020f4:	89 c3                	mov    %eax,%ebx
  8020f6:	83 c4 10             	add    $0x10,%esp
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	0f 88 db 00 00 00    	js     8021dc <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802101:	83 ec 04             	sub    $0x4,%esp
  802104:	68 07 04 00 00       	push   $0x407
  802109:	ff 75 f0             	push   -0x10(%ebp)
  80210c:	6a 00                	push   $0x0
  80210e:	e8 c7 ec ff ff       	call   800dda <sys_page_alloc>
  802113:	89 c3                	mov    %eax,%ebx
  802115:	83 c4 10             	add    $0x10,%esp
  802118:	85 c0                	test   %eax,%eax
  80211a:	0f 88 bc 00 00 00    	js     8021dc <pipe+0x131>
	va = fd2data(fd0);
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	ff 75 f4             	push   -0xc(%ebp)
  802126:	e8 60 f0 ff ff       	call   80118b <fd2data>
  80212b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212d:	83 c4 0c             	add    $0xc,%esp
  802130:	68 07 04 00 00       	push   $0x407
  802135:	50                   	push   %eax
  802136:	6a 00                	push   $0x0
  802138:	e8 9d ec ff ff       	call   800dda <sys_page_alloc>
  80213d:	89 c3                	mov    %eax,%ebx
  80213f:	83 c4 10             	add    $0x10,%esp
  802142:	85 c0                	test   %eax,%eax
  802144:	0f 88 82 00 00 00    	js     8021cc <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214a:	83 ec 0c             	sub    $0xc,%esp
  80214d:	ff 75 f0             	push   -0x10(%ebp)
  802150:	e8 36 f0 ff ff       	call   80118b <fd2data>
  802155:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80215c:	50                   	push   %eax
  80215d:	6a 00                	push   $0x0
  80215f:	56                   	push   %esi
  802160:	6a 00                	push   $0x0
  802162:	e8 b6 ec ff ff       	call   800e1d <sys_page_map>
  802167:	89 c3                	mov    %eax,%ebx
  802169:	83 c4 20             	add    $0x20,%esp
  80216c:	85 c0                	test   %eax,%eax
  80216e:	78 4e                	js     8021be <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802170:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802175:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802178:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80217a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80217d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802184:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802187:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80218c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802193:	83 ec 0c             	sub    $0xc,%esp
  802196:	ff 75 f4             	push   -0xc(%ebp)
  802199:	e8 dd ef ff ff       	call   80117b <fd2num>
  80219e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021a1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021a3:	83 c4 04             	add    $0x4,%esp
  8021a6:	ff 75 f0             	push   -0x10(%ebp)
  8021a9:	e8 cd ef ff ff       	call   80117b <fd2num>
  8021ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021b1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021b4:	83 c4 10             	add    $0x10,%esp
  8021b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021bc:	eb 2e                	jmp    8021ec <pipe+0x141>
	sys_page_unmap(0, va);
  8021be:	83 ec 08             	sub    $0x8,%esp
  8021c1:	56                   	push   %esi
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 96 ec ff ff       	call   800e5f <sys_page_unmap>
  8021c9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021cc:	83 ec 08             	sub    $0x8,%esp
  8021cf:	ff 75 f0             	push   -0x10(%ebp)
  8021d2:	6a 00                	push   $0x0
  8021d4:	e8 86 ec ff ff       	call   800e5f <sys_page_unmap>
  8021d9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8021dc:	83 ec 08             	sub    $0x8,%esp
  8021df:	ff 75 f4             	push   -0xc(%ebp)
  8021e2:	6a 00                	push   $0x0
  8021e4:	e8 76 ec ff ff       	call   800e5f <sys_page_unmap>
  8021e9:	83 c4 10             	add    $0x10,%esp
}
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021f1:	5b                   	pop    %ebx
  8021f2:	5e                   	pop    %esi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <pipeisclosed>:
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021fe:	50                   	push   %eax
  8021ff:	ff 75 08             	push   0x8(%ebp)
  802202:	e8 eb ef ff ff       	call   8011f2 <fd_lookup>
  802207:	83 c4 10             	add    $0x10,%esp
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 18                	js     802226 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80220e:	83 ec 0c             	sub    $0xc,%esp
  802211:	ff 75 f4             	push   -0xc(%ebp)
  802214:	e8 72 ef ff ff       	call   80118b <fd2data>
  802219:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80221b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221e:	e8 33 fd ff ff       	call   801f56 <_pipeisclosed>
  802223:	83 c4 10             	add    $0x10,%esp
}
  802226:	c9                   	leave  
  802227:	c3                   	ret    

00802228 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
  80222d:	c3                   	ret    

0080222e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80222e:	55                   	push   %ebp
  80222f:	89 e5                	mov    %esp,%ebp
  802231:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802234:	68 27 2c 80 00       	push   $0x802c27
  802239:	ff 75 0c             	push   0xc(%ebp)
  80223c:	e8 9d e7 ff ff       	call   8009de <strcpy>
	return 0;
}
  802241:	b8 00 00 00 00       	mov    $0x0,%eax
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <devcons_write>:
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	57                   	push   %edi
  80224c:	56                   	push   %esi
  80224d:	53                   	push   %ebx
  80224e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802254:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802259:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80225f:	eb 2e                	jmp    80228f <devcons_write+0x47>
		m = n - tot;
  802261:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802264:	29 f3                	sub    %esi,%ebx
  802266:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80226b:	39 c3                	cmp    %eax,%ebx
  80226d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802270:	83 ec 04             	sub    $0x4,%esp
  802273:	53                   	push   %ebx
  802274:	89 f0                	mov    %esi,%eax
  802276:	03 45 0c             	add    0xc(%ebp),%eax
  802279:	50                   	push   %eax
  80227a:	57                   	push   %edi
  80227b:	e8 f4 e8 ff ff       	call   800b74 <memmove>
		sys_cputs(buf, m);
  802280:	83 c4 08             	add    $0x8,%esp
  802283:	53                   	push   %ebx
  802284:	57                   	push   %edi
  802285:	e8 94 ea ff ff       	call   800d1e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80228a:	01 de                	add    %ebx,%esi
  80228c:	83 c4 10             	add    $0x10,%esp
  80228f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802292:	72 cd                	jb     802261 <devcons_write+0x19>
}
  802294:	89 f0                	mov    %esi,%eax
  802296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802299:	5b                   	pop    %ebx
  80229a:	5e                   	pop    %esi
  80229b:	5f                   	pop    %edi
  80229c:	5d                   	pop    %ebp
  80229d:	c3                   	ret    

0080229e <devcons_read>:
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	83 ec 08             	sub    $0x8,%esp
  8022a4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8022a9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ad:	75 07                	jne    8022b6 <devcons_read+0x18>
  8022af:	eb 1f                	jmp    8022d0 <devcons_read+0x32>
		sys_yield();
  8022b1:	e8 05 eb ff ff       	call   800dbb <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8022b6:	e8 81 ea ff ff       	call   800d3c <sys_cgetc>
  8022bb:	85 c0                	test   %eax,%eax
  8022bd:	74 f2                	je     8022b1 <devcons_read+0x13>
	if (c < 0)
  8022bf:	78 0f                	js     8022d0 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8022c1:	83 f8 04             	cmp    $0x4,%eax
  8022c4:	74 0c                	je     8022d2 <devcons_read+0x34>
	*(char*)vbuf = c;
  8022c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022c9:	88 02                	mov    %al,(%edx)
	return 1;
  8022cb:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    
		return 0;
  8022d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d7:	eb f7                	jmp    8022d0 <devcons_read+0x32>

008022d9 <cputchar>:
{
  8022d9:	55                   	push   %ebp
  8022da:	89 e5                	mov    %esp,%ebp
  8022dc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022df:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8022e5:	6a 01                	push   $0x1
  8022e7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022ea:	50                   	push   %eax
  8022eb:	e8 2e ea ff ff       	call   800d1e <sys_cputs>
}
  8022f0:	83 c4 10             	add    $0x10,%esp
  8022f3:	c9                   	leave  
  8022f4:	c3                   	ret    

008022f5 <getchar>:
{
  8022f5:	55                   	push   %ebp
  8022f6:	89 e5                	mov    %esp,%ebp
  8022f8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8022fb:	6a 01                	push   $0x1
  8022fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802300:	50                   	push   %eax
  802301:	6a 00                	push   $0x0
  802303:	e8 53 f1 ff ff       	call   80145b <read>
	if (r < 0)
  802308:	83 c4 10             	add    $0x10,%esp
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 06                	js     802315 <getchar+0x20>
	if (r < 1)
  80230f:	74 06                	je     802317 <getchar+0x22>
	return c;
  802311:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802315:	c9                   	leave  
  802316:	c3                   	ret    
		return -E_EOF;
  802317:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80231c:	eb f7                	jmp    802315 <getchar+0x20>

0080231e <iscons>:
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802324:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802327:	50                   	push   %eax
  802328:	ff 75 08             	push   0x8(%ebp)
  80232b:	e8 c2 ee ff ff       	call   8011f2 <fd_lookup>
  802330:	83 c4 10             	add    $0x10,%esp
  802333:	85 c0                	test   %eax,%eax
  802335:	78 11                	js     802348 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80233a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802340:	39 10                	cmp    %edx,(%eax)
  802342:	0f 94 c0             	sete   %al
  802345:	0f b6 c0             	movzbl %al,%eax
}
  802348:	c9                   	leave  
  802349:	c3                   	ret    

0080234a <opencons>:
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802353:	50                   	push   %eax
  802354:	e8 49 ee ff ff       	call   8011a2 <fd_alloc>
  802359:	83 c4 10             	add    $0x10,%esp
  80235c:	85 c0                	test   %eax,%eax
  80235e:	78 3a                	js     80239a <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802360:	83 ec 04             	sub    $0x4,%esp
  802363:	68 07 04 00 00       	push   $0x407
  802368:	ff 75 f4             	push   -0xc(%ebp)
  80236b:	6a 00                	push   $0x0
  80236d:	e8 68 ea ff ff       	call   800dda <sys_page_alloc>
  802372:	83 c4 10             	add    $0x10,%esp
  802375:	85 c0                	test   %eax,%eax
  802377:	78 21                	js     80239a <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802379:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80237c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802382:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802387:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80238e:	83 ec 0c             	sub    $0xc,%esp
  802391:	50                   	push   %eax
  802392:	e8 e4 ed ff ff       	call   80117b <fd2num>
  802397:	83 c4 10             	add    $0x10,%esp
}
  80239a:	c9                   	leave  
  80239b:	c3                   	ret    

0080239c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80239c:	55                   	push   %ebp
  80239d:	89 e5                	mov    %esp,%ebp
  80239f:	56                   	push   %esi
  8023a0:	53                   	push   %ebx
  8023a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8023a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023b1:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8023b4:	83 ec 0c             	sub    $0xc,%esp
  8023b7:	50                   	push   %eax
  8023b8:	e8 cd eb ff ff       	call   800f8a <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8023bd:	83 c4 10             	add    $0x10,%esp
  8023c0:	85 f6                	test   %esi,%esi
  8023c2:	74 17                	je     8023db <ipc_recv+0x3f>
  8023c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	78 0c                	js     8023d9 <ipc_recv+0x3d>
  8023cd:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023d3:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8023d9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8023db:	85 db                	test   %ebx,%ebx
  8023dd:	74 17                	je     8023f6 <ipc_recv+0x5a>
  8023df:	ba 00 00 00 00       	mov    $0x0,%edx
  8023e4:	85 c0                	test   %eax,%eax
  8023e6:	78 0c                	js     8023f4 <ipc_recv+0x58>
  8023e8:	8b 15 00 44 80 00    	mov    0x804400,%edx
  8023ee:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8023f4:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	78 0b                	js     802405 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8023fa:	a1 00 44 80 00       	mov    0x804400,%eax
  8023ff:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802405:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5d                   	pop    %ebp
  80240b:	c3                   	ret    

0080240c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80240c:	55                   	push   %ebp
  80240d:	89 e5                	mov    %esp,%ebp
  80240f:	57                   	push   %edi
  802410:	56                   	push   %esi
  802411:	53                   	push   %ebx
  802412:	83 ec 0c             	sub    $0xc,%esp
  802415:	8b 7d 08             	mov    0x8(%ebp),%edi
  802418:	8b 75 0c             	mov    0xc(%ebp),%esi
  80241b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80241e:	85 db                	test   %ebx,%ebx
  802420:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802425:	0f 44 d8             	cmove  %eax,%ebx
  802428:	eb 05                	jmp    80242f <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80242a:	e8 8c e9 ff ff       	call   800dbb <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80242f:	ff 75 14             	push   0x14(%ebp)
  802432:	53                   	push   %ebx
  802433:	56                   	push   %esi
  802434:	57                   	push   %edi
  802435:	e8 2d eb ff ff       	call   800f67 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80243a:	83 c4 10             	add    $0x10,%esp
  80243d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802440:	74 e8                	je     80242a <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802442:	85 c0                	test   %eax,%eax
  802444:	78 08                	js     80244e <ipc_send+0x42>
	}while (r<0);

}
  802446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802449:	5b                   	pop    %ebx
  80244a:	5e                   	pop    %esi
  80244b:	5f                   	pop    %edi
  80244c:	5d                   	pop    %ebp
  80244d:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80244e:	50                   	push   %eax
  80244f:	68 33 2c 80 00       	push   $0x802c33
  802454:	6a 3d                	push   $0x3d
  802456:	68 47 2c 80 00       	push   $0x802c47
  80245b:	e8 c9 de ff ff       	call   800329 <_panic>

00802460 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802466:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80246b:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802471:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802477:	8b 52 60             	mov    0x60(%edx),%edx
  80247a:	39 ca                	cmp    %ecx,%edx
  80247c:	74 11                	je     80248f <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80247e:	83 c0 01             	add    $0x1,%eax
  802481:	3d 00 04 00 00       	cmp    $0x400,%eax
  802486:	75 e3                	jne    80246b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802488:	b8 00 00 00 00       	mov    $0x0,%eax
  80248d:	eb 0e                	jmp    80249d <ipc_find_env+0x3d>
			return envs[i].env_id;
  80248f:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802495:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80249a:	8b 40 58             	mov    0x58(%eax),%eax
}
  80249d:	5d                   	pop    %ebp
  80249e:	c3                   	ret    

0080249f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80249f:	55                   	push   %ebp
  8024a0:	89 e5                	mov    %esp,%ebp
  8024a2:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024a5:	89 c2                	mov    %eax,%edx
  8024a7:	c1 ea 16             	shr    $0x16,%edx
  8024aa:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8024b1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024b6:	f6 c1 01             	test   $0x1,%cl
  8024b9:	74 1c                	je     8024d7 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8024bb:	c1 e8 0c             	shr    $0xc,%eax
  8024be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024c5:	a8 01                	test   $0x1,%al
  8024c7:	74 0e                	je     8024d7 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024c9:	c1 e8 0c             	shr    $0xc,%eax
  8024cc:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024d3:	ef 
  8024d4:	0f b7 d2             	movzwl %dx,%edx
}
  8024d7:	89 d0                	mov    %edx,%eax
  8024d9:	5d                   	pop    %ebp
  8024da:	c3                   	ret    
  8024db:	66 90                	xchg   %ax,%ax
  8024dd:	66 90                	xchg   %ax,%ax
  8024df:	90                   	nop

008024e0 <__udivdi3>:
  8024e0:	f3 0f 1e fb          	endbr32 
  8024e4:	55                   	push   %ebp
  8024e5:	57                   	push   %edi
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	83 ec 1c             	sub    $0x1c,%esp
  8024eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	75 19                	jne    802518 <__udivdi3+0x38>
  8024ff:	39 f3                	cmp    %esi,%ebx
  802501:	76 4d                	jbe    802550 <__udivdi3+0x70>
  802503:	31 ff                	xor    %edi,%edi
  802505:	89 e8                	mov    %ebp,%eax
  802507:	89 f2                	mov    %esi,%edx
  802509:	f7 f3                	div    %ebx
  80250b:	89 fa                	mov    %edi,%edx
  80250d:	83 c4 1c             	add    $0x1c,%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
  802515:	8d 76 00             	lea    0x0(%esi),%esi
  802518:	39 f0                	cmp    %esi,%eax
  80251a:	76 14                	jbe    802530 <__udivdi3+0x50>
  80251c:	31 ff                	xor    %edi,%edi
  80251e:	31 c0                	xor    %eax,%eax
  802520:	89 fa                	mov    %edi,%edx
  802522:	83 c4 1c             	add    $0x1c,%esp
  802525:	5b                   	pop    %ebx
  802526:	5e                   	pop    %esi
  802527:	5f                   	pop    %edi
  802528:	5d                   	pop    %ebp
  802529:	c3                   	ret    
  80252a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802530:	0f bd f8             	bsr    %eax,%edi
  802533:	83 f7 1f             	xor    $0x1f,%edi
  802536:	75 48                	jne    802580 <__udivdi3+0xa0>
  802538:	39 f0                	cmp    %esi,%eax
  80253a:	72 06                	jb     802542 <__udivdi3+0x62>
  80253c:	31 c0                	xor    %eax,%eax
  80253e:	39 eb                	cmp    %ebp,%ebx
  802540:	77 de                	ja     802520 <__udivdi3+0x40>
  802542:	b8 01 00 00 00       	mov    $0x1,%eax
  802547:	eb d7                	jmp    802520 <__udivdi3+0x40>
  802549:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802550:	89 d9                	mov    %ebx,%ecx
  802552:	85 db                	test   %ebx,%ebx
  802554:	75 0b                	jne    802561 <__udivdi3+0x81>
  802556:	b8 01 00 00 00       	mov    $0x1,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	f7 f3                	div    %ebx
  80255f:	89 c1                	mov    %eax,%ecx
  802561:	31 d2                	xor    %edx,%edx
  802563:	89 f0                	mov    %esi,%eax
  802565:	f7 f1                	div    %ecx
  802567:	89 c6                	mov    %eax,%esi
  802569:	89 e8                	mov    %ebp,%eax
  80256b:	89 f7                	mov    %esi,%edi
  80256d:	f7 f1                	div    %ecx
  80256f:	89 fa                	mov    %edi,%edx
  802571:	83 c4 1c             	add    $0x1c,%esp
  802574:	5b                   	pop    %ebx
  802575:	5e                   	pop    %esi
  802576:	5f                   	pop    %edi
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 f9                	mov    %edi,%ecx
  802582:	ba 20 00 00 00       	mov    $0x20,%edx
  802587:	29 fa                	sub    %edi,%edx
  802589:	d3 e0                	shl    %cl,%eax
  80258b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80258f:	89 d1                	mov    %edx,%ecx
  802591:	89 d8                	mov    %ebx,%eax
  802593:	d3 e8                	shr    %cl,%eax
  802595:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802599:	09 c1                	or     %eax,%ecx
  80259b:	89 f0                	mov    %esi,%eax
  80259d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025a1:	89 f9                	mov    %edi,%ecx
  8025a3:	d3 e3                	shl    %cl,%ebx
  8025a5:	89 d1                	mov    %edx,%ecx
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 f9                	mov    %edi,%ecx
  8025ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8025af:	89 eb                	mov    %ebp,%ebx
  8025b1:	d3 e6                	shl    %cl,%esi
  8025b3:	89 d1                	mov    %edx,%ecx
  8025b5:	d3 eb                	shr    %cl,%ebx
  8025b7:	09 f3                	or     %esi,%ebx
  8025b9:	89 c6                	mov    %eax,%esi
  8025bb:	89 f2                	mov    %esi,%edx
  8025bd:	89 d8                	mov    %ebx,%eax
  8025bf:	f7 74 24 08          	divl   0x8(%esp)
  8025c3:	89 d6                	mov    %edx,%esi
  8025c5:	89 c3                	mov    %eax,%ebx
  8025c7:	f7 64 24 0c          	mull   0xc(%esp)
  8025cb:	39 d6                	cmp    %edx,%esi
  8025cd:	72 19                	jb     8025e8 <__udivdi3+0x108>
  8025cf:	89 f9                	mov    %edi,%ecx
  8025d1:	d3 e5                	shl    %cl,%ebp
  8025d3:	39 c5                	cmp    %eax,%ebp
  8025d5:	73 04                	jae    8025db <__udivdi3+0xfb>
  8025d7:	39 d6                	cmp    %edx,%esi
  8025d9:	74 0d                	je     8025e8 <__udivdi3+0x108>
  8025db:	89 d8                	mov    %ebx,%eax
  8025dd:	31 ff                	xor    %edi,%edi
  8025df:	e9 3c ff ff ff       	jmp    802520 <__udivdi3+0x40>
  8025e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025eb:	31 ff                	xor    %edi,%edi
  8025ed:	e9 2e ff ff ff       	jmp    802520 <__udivdi3+0x40>
  8025f2:	66 90                	xchg   %ax,%ax
  8025f4:	66 90                	xchg   %ax,%ax
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	66 90                	xchg   %ax,%ax
  8025fa:	66 90                	xchg   %ax,%ax
  8025fc:	66 90                	xchg   %ax,%ax
  8025fe:	66 90                	xchg   %ax,%ax

00802600 <__umoddi3>:
  802600:	f3 0f 1e fb          	endbr32 
  802604:	55                   	push   %ebp
  802605:	57                   	push   %edi
  802606:	56                   	push   %esi
  802607:	53                   	push   %ebx
  802608:	83 ec 1c             	sub    $0x1c,%esp
  80260b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80260f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802613:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802617:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80261b:	89 f0                	mov    %esi,%eax
  80261d:	89 da                	mov    %ebx,%edx
  80261f:	85 ff                	test   %edi,%edi
  802621:	75 15                	jne    802638 <__umoddi3+0x38>
  802623:	39 dd                	cmp    %ebx,%ebp
  802625:	76 39                	jbe    802660 <__umoddi3+0x60>
  802627:	f7 f5                	div    %ebp
  802629:	89 d0                	mov    %edx,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	83 c4 1c             	add    $0x1c,%esp
  802630:	5b                   	pop    %ebx
  802631:	5e                   	pop    %esi
  802632:	5f                   	pop    %edi
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    
  802635:	8d 76 00             	lea    0x0(%esi),%esi
  802638:	39 df                	cmp    %ebx,%edi
  80263a:	77 f1                	ja     80262d <__umoddi3+0x2d>
  80263c:	0f bd cf             	bsr    %edi,%ecx
  80263f:	83 f1 1f             	xor    $0x1f,%ecx
  802642:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802646:	75 40                	jne    802688 <__umoddi3+0x88>
  802648:	39 df                	cmp    %ebx,%edi
  80264a:	72 04                	jb     802650 <__umoddi3+0x50>
  80264c:	39 f5                	cmp    %esi,%ebp
  80264e:	77 dd                	ja     80262d <__umoddi3+0x2d>
  802650:	89 da                	mov    %ebx,%edx
  802652:	89 f0                	mov    %esi,%eax
  802654:	29 e8                	sub    %ebp,%eax
  802656:	19 fa                	sbb    %edi,%edx
  802658:	eb d3                	jmp    80262d <__umoddi3+0x2d>
  80265a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802660:	89 e9                	mov    %ebp,%ecx
  802662:	85 ed                	test   %ebp,%ebp
  802664:	75 0b                	jne    802671 <__umoddi3+0x71>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f5                	div    %ebp
  80266f:	89 c1                	mov    %eax,%ecx
  802671:	89 d8                	mov    %ebx,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f1                	div    %ecx
  802677:	89 f0                	mov    %esi,%eax
  802679:	f7 f1                	div    %ecx
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	31 d2                	xor    %edx,%edx
  80267f:	eb ac                	jmp    80262d <__umoddi3+0x2d>
  802681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802688:	8b 44 24 04          	mov    0x4(%esp),%eax
  80268c:	ba 20 00 00 00       	mov    $0x20,%edx
  802691:	29 c2                	sub    %eax,%edx
  802693:	89 c1                	mov    %eax,%ecx
  802695:	89 e8                	mov    %ebp,%eax
  802697:	d3 e7                	shl    %cl,%edi
  802699:	89 d1                	mov    %edx,%ecx
  80269b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80269f:	d3 e8                	shr    %cl,%eax
  8026a1:	89 c1                	mov    %eax,%ecx
  8026a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026a7:	09 f9                	or     %edi,%ecx
  8026a9:	89 df                	mov    %ebx,%edi
  8026ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026af:	89 c1                	mov    %eax,%ecx
  8026b1:	d3 e5                	shl    %cl,%ebp
  8026b3:	89 d1                	mov    %edx,%ecx
  8026b5:	d3 ef                	shr    %cl,%edi
  8026b7:	89 c1                	mov    %eax,%ecx
  8026b9:	89 f0                	mov    %esi,%eax
  8026bb:	d3 e3                	shl    %cl,%ebx
  8026bd:	89 d1                	mov    %edx,%ecx
  8026bf:	89 fa                	mov    %edi,%edx
  8026c1:	d3 e8                	shr    %cl,%eax
  8026c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026c8:	09 d8                	or     %ebx,%eax
  8026ca:	f7 74 24 08          	divl   0x8(%esp)
  8026ce:	89 d3                	mov    %edx,%ebx
  8026d0:	d3 e6                	shl    %cl,%esi
  8026d2:	f7 e5                	mul    %ebp
  8026d4:	89 c7                	mov    %eax,%edi
  8026d6:	89 d1                	mov    %edx,%ecx
  8026d8:	39 d3                	cmp    %edx,%ebx
  8026da:	72 06                	jb     8026e2 <__umoddi3+0xe2>
  8026dc:	75 0e                	jne    8026ec <__umoddi3+0xec>
  8026de:	39 c6                	cmp    %eax,%esi
  8026e0:	73 0a                	jae    8026ec <__umoddi3+0xec>
  8026e2:	29 e8                	sub    %ebp,%eax
  8026e4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026e8:	89 d1                	mov    %edx,%ecx
  8026ea:	89 c7                	mov    %eax,%edi
  8026ec:	89 f5                	mov    %esi,%ebp
  8026ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026f2:	29 fd                	sub    %edi,%ebp
  8026f4:	19 cb                	sbb    %ecx,%ebx
  8026f6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026fb:	89 d8                	mov    %ebx,%eax
  8026fd:	d3 e0                	shl    %cl,%eax
  8026ff:	89 f1                	mov    %esi,%ecx
  802701:	d3 ed                	shr    %cl,%ebp
  802703:	d3 eb                	shr    %cl,%ebx
  802705:	09 e8                	or     %ebp,%eax
  802707:	89 da                	mov    %ebx,%edx
  802709:	83 c4 1c             	add    $0x1c,%esp
  80270c:	5b                   	pop    %ebx
  80270d:	5e                   	pop    %esi
  80270e:	5f                   	pop    %edi
  80270f:	5d                   	pop    %ebp
  802710:	c3                   	ret    
