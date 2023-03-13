
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
  80005a:	68 42 22 80 00       	push   $0x802242
  80005f:	e8 93 19 00 00       	call   8019f7 <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 1c                	je     800087 <ls1+0x54>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	b8 a8 22 80 00       	mov    $0x8022a8,%eax
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	75 4b                	jne    8000c0 <ls1+0x8d>
		printf("%s%s", prefix, sep);
  800075:	83 ec 04             	sub    $0x4,%esp
  800078:	50                   	push   %eax
  800079:	53                   	push   %ebx
  80007a:	68 4b 22 80 00       	push   $0x80224b
  80007f:	e8 73 19 00 00       	call   8019f7 <printf>
  800084:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	ff 75 14             	push   0x14(%ebp)
  80008d:	68 d1 26 80 00       	push   $0x8026d1
  800092:	e8 60 19 00 00       	call   8019f7 <printf>
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
  8000ac:	68 a7 22 80 00       	push   $0x8022a7
  8000b1:	e8 41 19 00 00       	call   8019f7 <printf>
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
  8000d1:	b8 40 22 80 00       	mov    $0x802240,%eax
  8000d6:	ba a8 22 80 00       	mov    $0x8022a8,%edx
  8000db:	0f 44 c2             	cmove  %edx,%eax
  8000de:	eb 95                	jmp    800075 <ls1+0x42>
		printf("/");
  8000e0:	83 ec 0c             	sub    $0xc,%esp
  8000e3:	68 40 22 80 00       	push   $0x802240
  8000e8:	e8 0a 19 00 00       	call   8019f7 <printf>
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
  800104:	e8 4c 17 00 00       	call   801855 <open>
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
  800122:	e8 52 13 00 00       	call   801479 <readn>
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
  800161:	68 50 22 80 00       	push   $0x802250
  800166:	6a 1d                	push   $0x1d
  800168:	68 5c 22 80 00       	push   $0x80225c
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
  800181:	68 66 22 80 00       	push   $0x802266
  800186:	6a 22                	push   $0x22
  800188:	68 5c 22 80 00       	push   $0x80225c
  80018d:	e8 94 01 00 00       	call   800326 <_panic>
		panic("error reading directory %s: %e", path, n);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	57                   	push   %edi
  800197:	68 ac 22 80 00       	push   $0x8022ac
  80019c:	6a 24                	push   $0x24
  80019e:	68 5c 22 80 00       	push   $0x80225c
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
  8001bd:	e8 9d 14 00 00       	call   80165f <stat>
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
  8001fa:	68 81 22 80 00       	push   $0x802281
  8001ff:	6a 0f                	push   $0xf
  800201:	68 5c 22 80 00       	push   $0x80225c
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
  800222:	68 8d 22 80 00       	push   $0x80228d
  800227:	e8 cb 17 00 00       	call   8019f7 <printf>
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
  80024a:	e8 79 0d 00 00       	call   800fc8 <argstart>
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
  800263:	e8 90 0d 00 00       	call   800ff8 <argnext>
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
  800293:	68 a8 22 80 00       	push   $0x8022a8
  800298:	68 40 22 80 00       	push   $0x802240
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
  800312:	e8 cc 0f 00 00       	call   8012e3 <close_all>
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
  800344:	68 d8 22 80 00       	push   $0x8022d8
  800349:	e8 b3 00 00 00       	call   800401 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034e:	83 c4 18             	add    $0x18,%esp
  800351:	53                   	push   %ebx
  800352:	ff 75 10             	push   0x10(%ebp)
  800355:	e8 56 00 00 00       	call   8003b0 <vcprintf>
	cprintf("\n");
  80035a:	c7 04 24 a7 22 80 00 	movl   $0x8022a7,(%esp)
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
  800463:	e8 98 1b 00 00       	call   802000 <__udivdi3>
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
  8004a1:	e8 7a 1c 00 00       	call   802120 <__umoddi3>
  8004a6:	83 c4 14             	add    $0x14,%esp
  8004a9:	0f be 80 fb 22 80 00 	movsbl 0x8022fb(%eax),%eax
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
  800563:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
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
  800631:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  800638:	85 d2                	test   %edx,%edx
  80063a:	74 18                	je     800654 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80063c:	52                   	push   %edx
  80063d:	68 d1 26 80 00       	push   $0x8026d1
  800642:	53                   	push   %ebx
  800643:	56                   	push   %esi
  800644:	e8 92 fe ff ff       	call   8004db <printfmt>
  800649:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80064c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80064f:	e9 66 02 00 00       	jmp    8008ba <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800654:	50                   	push   %eax
  800655:	68 13 23 80 00       	push   $0x802313
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
  80067c:	b8 0c 23 80 00       	mov    $0x80230c,%eax
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
  800d88:	68 ff 25 80 00       	push   $0x8025ff
  800d8d:	6a 2a                	push   $0x2a
  800d8f:	68 1c 26 80 00       	push   $0x80261c
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
  800e09:	68 ff 25 80 00       	push   $0x8025ff
  800e0e:	6a 2a                	push   $0x2a
  800e10:	68 1c 26 80 00       	push   $0x80261c
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
  800e4b:	68 ff 25 80 00       	push   $0x8025ff
  800e50:	6a 2a                	push   $0x2a
  800e52:	68 1c 26 80 00       	push   $0x80261c
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
  800e8d:	68 ff 25 80 00       	push   $0x8025ff
  800e92:	6a 2a                	push   $0x2a
  800e94:	68 1c 26 80 00       	push   $0x80261c
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
  800ecf:	68 ff 25 80 00       	push   $0x8025ff
  800ed4:	6a 2a                	push   $0x2a
  800ed6:	68 1c 26 80 00       	push   $0x80261c
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
  800f11:	68 ff 25 80 00       	push   $0x8025ff
  800f16:	6a 2a                	push   $0x2a
  800f18:	68 1c 26 80 00       	push   $0x80261c
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
  800f53:	68 ff 25 80 00       	push   $0x8025ff
  800f58:	6a 2a                	push   $0x2a
  800f5a:	68 1c 26 80 00       	push   $0x80261c
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
  800fb7:	68 ff 25 80 00       	push   $0x8025ff
  800fbc:	6a 2a                	push   $0x2a
  800fbe:	68 1c 26 80 00       	push   $0x80261c
  800fc3:	e8 5e f3 ff ff       	call   800326 <_panic>

00800fc8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd1:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fd4:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fd6:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fd9:	83 3a 01             	cmpl   $0x1,(%edx)
  800fdc:	7e 09                	jle    800fe7 <argstart+0x1f>
  800fde:	ba a8 22 80 00       	mov    $0x8022a8,%edx
  800fe3:	85 c9                	test   %ecx,%ecx
  800fe5:	75 05                	jne    800fec <argstart+0x24>
  800fe7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fec:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fef:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <argnext>:

int
argnext(struct Argstate *args)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801002:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801009:	8b 43 08             	mov    0x8(%ebx),%eax
  80100c:	85 c0                	test   %eax,%eax
  80100e:	74 74                	je     801084 <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  801010:	80 38 00             	cmpb   $0x0,(%eax)
  801013:	75 48                	jne    80105d <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801015:	8b 0b                	mov    (%ebx),%ecx
  801017:	83 39 01             	cmpl   $0x1,(%ecx)
  80101a:	74 5a                	je     801076 <argnext+0x7e>
		    || args->argv[1][0] != '-'
  80101c:	8b 53 04             	mov    0x4(%ebx),%edx
  80101f:	8b 42 04             	mov    0x4(%edx),%eax
  801022:	80 38 2d             	cmpb   $0x2d,(%eax)
  801025:	75 4f                	jne    801076 <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  801027:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  80102b:	74 49                	je     801076 <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  80102d:	83 c0 01             	add    $0x1,%eax
  801030:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	8b 01                	mov    (%ecx),%eax
  801038:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  80103f:	50                   	push   %eax
  801040:	8d 42 08             	lea    0x8(%edx),%eax
  801043:	50                   	push   %eax
  801044:	83 c2 04             	add    $0x4,%edx
  801047:	52                   	push   %edx
  801048:	e8 24 fb ff ff       	call   800b71 <memmove>
		(*args->argc)--;
  80104d:	8b 03                	mov    (%ebx),%eax
  80104f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801052:	8b 43 08             	mov    0x8(%ebx),%eax
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	80 38 2d             	cmpb   $0x2d,(%eax)
  80105b:	74 13                	je     801070 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80105d:	8b 43 08             	mov    0x8(%ebx),%eax
  801060:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801063:	83 c0 01             	add    $0x1,%eax
  801066:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801069:	89 d0                	mov    %edx,%eax
  80106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801070:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801074:	75 e7                	jne    80105d <argnext+0x65>
	args->curarg = 0;
  801076:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80107d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801082:	eb e5                	jmp    801069 <argnext+0x71>
		return -1;
  801084:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801089:	eb de                	jmp    801069 <argnext+0x71>

0080108b <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	53                   	push   %ebx
  80108f:	83 ec 04             	sub    $0x4,%esp
  801092:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801095:	8b 43 08             	mov    0x8(%ebx),%eax
  801098:	85 c0                	test   %eax,%eax
  80109a:	74 12                	je     8010ae <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  80109c:	80 38 00             	cmpb   $0x0,(%eax)
  80109f:	74 12                	je     8010b3 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  8010a1:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8010a4:	c7 43 08 a8 22 80 00 	movl   $0x8022a8,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  8010ab:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  8010ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    
	} else if (*args->argc > 1) {
  8010b3:	8b 13                	mov    (%ebx),%edx
  8010b5:	83 3a 01             	cmpl   $0x1,(%edx)
  8010b8:	7f 10                	jg     8010ca <argnextvalue+0x3f>
		args->argvalue = 0;
  8010ba:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010c1:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  8010c8:	eb e1                	jmp    8010ab <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  8010ca:	8b 43 04             	mov    0x4(%ebx),%eax
  8010cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8010d0:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	8b 12                	mov    (%edx),%edx
  8010d8:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  8010df:	52                   	push   %edx
  8010e0:	8d 50 08             	lea    0x8(%eax),%edx
  8010e3:	52                   	push   %edx
  8010e4:	83 c0 04             	add    $0x4,%eax
  8010e7:	50                   	push   %eax
  8010e8:	e8 84 fa ff ff       	call   800b71 <memmove>
		(*args->argc)--;
  8010ed:	8b 03                	mov    (%ebx),%eax
  8010ef:	83 28 01             	subl   $0x1,(%eax)
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	eb b4                	jmp    8010ab <argnextvalue+0x20>

008010f7 <argvalue>:
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	83 ec 08             	sub    $0x8,%esp
  8010fd:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801100:	8b 42 0c             	mov    0xc(%edx),%eax
  801103:	85 c0                	test   %eax,%eax
  801105:	74 02                	je     801109 <argvalue+0x12>
}
  801107:	c9                   	leave  
  801108:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	52                   	push   %edx
  80110d:	e8 79 ff ff ff       	call   80108b <argnextvalue>
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	eb f0                	jmp    801107 <argvalue+0x10>

00801117 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	05 00 00 00 30       	add    $0x30000000,%eax
  801122:	c1 e8 0c             	shr    $0xc,%eax
}
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    

00801127 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80112a:	8b 45 08             	mov    0x8(%ebp),%eax
  80112d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801132:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801137:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801146:	89 c2                	mov    %eax,%edx
  801148:	c1 ea 16             	shr    $0x16,%edx
  80114b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801152:	f6 c2 01             	test   $0x1,%dl
  801155:	74 29                	je     801180 <fd_alloc+0x42>
  801157:	89 c2                	mov    %eax,%edx
  801159:	c1 ea 0c             	shr    $0xc,%edx
  80115c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801163:	f6 c2 01             	test   $0x1,%dl
  801166:	74 18                	je     801180 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801168:	05 00 10 00 00       	add    $0x1000,%eax
  80116d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801172:	75 d2                	jne    801146 <fd_alloc+0x8>
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801179:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80117e:	eb 05                	jmp    801185 <fd_alloc+0x47>
			return 0;
  801180:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801185:	8b 55 08             	mov    0x8(%ebp),%edx
  801188:	89 02                	mov    %eax,(%edx)
}
  80118a:	89 c8                	mov    %ecx,%eax
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801194:	83 f8 1f             	cmp    $0x1f,%eax
  801197:	77 30                	ja     8011c9 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801199:	c1 e0 0c             	shl    $0xc,%eax
  80119c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	74 24                	je     8011d0 <fd_lookup+0x42>
  8011ac:	89 c2                	mov    %eax,%edx
  8011ae:	c1 ea 0c             	shr    $0xc,%edx
  8011b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011b8:	f6 c2 01             	test   $0x1,%dl
  8011bb:	74 1a                	je     8011d7 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c0:	89 02                	mov    %eax,(%edx)
	return 0;
  8011c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    
		return -E_INVAL;
  8011c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ce:	eb f7                	jmp    8011c7 <fd_lookup+0x39>
		return -E_INVAL;
  8011d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d5:	eb f0                	jmp    8011c7 <fd_lookup+0x39>
  8011d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dc:	eb e9                	jmp    8011c7 <fd_lookup+0x39>

008011de <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	53                   	push   %ebx
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e8:	b8 a8 26 80 00       	mov    $0x8026a8,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8011ed:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8011f2:	39 13                	cmp    %edx,(%ebx)
  8011f4:	74 32                	je     801228 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  8011f6:	83 c0 04             	add    $0x4,%eax
  8011f9:	8b 18                	mov    (%eax),%ebx
  8011fb:	85 db                	test   %ebx,%ebx
  8011fd:	75 f3                	jne    8011f2 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011ff:	a1 00 44 80 00       	mov    0x804400,%eax
  801204:	8b 40 48             	mov    0x48(%eax),%eax
  801207:	83 ec 04             	sub    $0x4,%esp
  80120a:	52                   	push   %edx
  80120b:	50                   	push   %eax
  80120c:	68 2c 26 80 00       	push   $0x80262c
  801211:	e8 eb f1 ff ff       	call   800401 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80121e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801221:	89 1a                	mov    %ebx,(%edx)
}
  801223:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801226:	c9                   	leave  
  801227:	c3                   	ret    
			return 0;
  801228:	b8 00 00 00 00       	mov    $0x0,%eax
  80122d:	eb ef                	jmp    80121e <dev_lookup+0x40>

0080122f <fd_close>:
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	57                   	push   %edi
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
  801235:	83 ec 24             	sub    $0x24,%esp
  801238:	8b 75 08             	mov    0x8(%ebp),%esi
  80123b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80123e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801241:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801242:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801248:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80124b:	50                   	push   %eax
  80124c:	e8 3d ff ff ff       	call   80118e <fd_lookup>
  801251:	89 c3                	mov    %eax,%ebx
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	78 05                	js     80125f <fd_close+0x30>
	    || fd != fd2)
  80125a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80125d:	74 16                	je     801275 <fd_close+0x46>
		return (must_exist ? r : 0);
  80125f:	89 f8                	mov    %edi,%eax
  801261:	84 c0                	test   %al,%al
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
  801268:	0f 44 d8             	cmove  %eax,%ebx
}
  80126b:	89 d8                	mov    %ebx,%eax
  80126d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801275:	83 ec 08             	sub    $0x8,%esp
  801278:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80127b:	50                   	push   %eax
  80127c:	ff 36                	push   (%esi)
  80127e:	e8 5b ff ff ff       	call   8011de <dev_lookup>
  801283:	89 c3                	mov    %eax,%ebx
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 1a                	js     8012a6 <fd_close+0x77>
		if (dev->dev_close)
  80128c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801292:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801297:	85 c0                	test   %eax,%eax
  801299:	74 0b                	je     8012a6 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80129b:	83 ec 0c             	sub    $0xc,%esp
  80129e:	56                   	push   %esi
  80129f:	ff d0                	call   *%eax
  8012a1:	89 c3                	mov    %eax,%ebx
  8012a3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012a6:	83 ec 08             	sub    $0x8,%esp
  8012a9:	56                   	push   %esi
  8012aa:	6a 00                	push   $0x0
  8012ac:	e8 ab fb ff ff       	call   800e5c <sys_page_unmap>
	return r;
  8012b1:	83 c4 10             	add    $0x10,%esp
  8012b4:	eb b5                	jmp    80126b <fd_close+0x3c>

008012b6 <close>:

int
close(int fdnum)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	ff 75 08             	push   0x8(%ebp)
  8012c3:	e8 c6 fe ff ff       	call   80118e <fd_lookup>
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	79 02                	jns    8012d1 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    
		return fd_close(fd, 1);
  8012d1:	83 ec 08             	sub    $0x8,%esp
  8012d4:	6a 01                	push   $0x1
  8012d6:	ff 75 f4             	push   -0xc(%ebp)
  8012d9:	e8 51 ff ff ff       	call   80122f <fd_close>
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	eb ec                	jmp    8012cf <close+0x19>

008012e3 <close_all>:

void
close_all(void)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012ef:	83 ec 0c             	sub    $0xc,%esp
  8012f2:	53                   	push   %ebx
  8012f3:	e8 be ff ff ff       	call   8012b6 <close>
	for (i = 0; i < MAXFD; i++)
  8012f8:	83 c3 01             	add    $0x1,%ebx
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	83 fb 20             	cmp    $0x20,%ebx
  801301:	75 ec                	jne    8012ef <close_all+0xc>
}
  801303:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	57                   	push   %edi
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
  80130e:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801311:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 75 08             	push   0x8(%ebp)
  801318:	e8 71 fe ff ff       	call   80118e <fd_lookup>
  80131d:	89 c3                	mov    %eax,%ebx
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 7f                	js     8013a5 <dup+0x9d>
		return r;
	close(newfdnum);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	ff 75 0c             	push   0xc(%ebp)
  80132c:	e8 85 ff ff ff       	call   8012b6 <close>

	newfd = INDEX2FD(newfdnum);
  801331:	8b 75 0c             	mov    0xc(%ebp),%esi
  801334:	c1 e6 0c             	shl    $0xc,%esi
  801337:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80133d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801340:	89 3c 24             	mov    %edi,(%esp)
  801343:	e8 df fd ff ff       	call   801127 <fd2data>
  801348:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80134a:	89 34 24             	mov    %esi,(%esp)
  80134d:	e8 d5 fd ff ff       	call   801127 <fd2data>
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801358:	89 d8                	mov    %ebx,%eax
  80135a:	c1 e8 16             	shr    $0x16,%eax
  80135d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801364:	a8 01                	test   $0x1,%al
  801366:	74 11                	je     801379 <dup+0x71>
  801368:	89 d8                	mov    %ebx,%eax
  80136a:	c1 e8 0c             	shr    $0xc,%eax
  80136d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801374:	f6 c2 01             	test   $0x1,%dl
  801377:	75 36                	jne    8013af <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801379:	89 f8                	mov    %edi,%eax
  80137b:	c1 e8 0c             	shr    $0xc,%eax
  80137e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	25 07 0e 00 00       	and    $0xe07,%eax
  80138d:	50                   	push   %eax
  80138e:	56                   	push   %esi
  80138f:	6a 00                	push   $0x0
  801391:	57                   	push   %edi
  801392:	6a 00                	push   $0x0
  801394:	e8 81 fa ff ff       	call   800e1a <sys_page_map>
  801399:	89 c3                	mov    %eax,%ebx
  80139b:	83 c4 20             	add    $0x20,%esp
  80139e:	85 c0                	test   %eax,%eax
  8013a0:	78 33                	js     8013d5 <dup+0xcd>
		goto err;

	return newfdnum;
  8013a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013a5:	89 d8                	mov    %ebx,%eax
  8013a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5f                   	pop    %edi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013af:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8013be:	50                   	push   %eax
  8013bf:	ff 75 d4             	push   -0x2c(%ebp)
  8013c2:	6a 00                	push   $0x0
  8013c4:	53                   	push   %ebx
  8013c5:	6a 00                	push   $0x0
  8013c7:	e8 4e fa ff ff       	call   800e1a <sys_page_map>
  8013cc:	89 c3                	mov    %eax,%ebx
  8013ce:	83 c4 20             	add    $0x20,%esp
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	79 a4                	jns    801379 <dup+0x71>
	sys_page_unmap(0, newfd);
  8013d5:	83 ec 08             	sub    $0x8,%esp
  8013d8:	56                   	push   %esi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 7c fa ff ff       	call   800e5c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013e0:	83 c4 08             	add    $0x8,%esp
  8013e3:	ff 75 d4             	push   -0x2c(%ebp)
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 6f fa ff ff       	call   800e5c <sys_page_unmap>
	return r;
  8013ed:	83 c4 10             	add    $0x10,%esp
  8013f0:	eb b3                	jmp    8013a5 <dup+0x9d>

008013f2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 18             	sub    $0x18,%esp
  8013fa:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	56                   	push   %esi
  801402:	e8 87 fd ff ff       	call   80118e <fd_lookup>
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	78 3c                	js     80144a <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	ff 33                	push   (%ebx)
  80141a:	e8 bf fd ff ff       	call   8011de <dev_lookup>
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 24                	js     80144a <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801426:	8b 43 08             	mov    0x8(%ebx),%eax
  801429:	83 e0 03             	and    $0x3,%eax
  80142c:	83 f8 01             	cmp    $0x1,%eax
  80142f:	74 20                	je     801451 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801434:	8b 40 08             	mov    0x8(%eax),%eax
  801437:	85 c0                	test   %eax,%eax
  801439:	74 37                	je     801472 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	ff 75 10             	push   0x10(%ebp)
  801441:	ff 75 0c             	push   0xc(%ebp)
  801444:	53                   	push   %ebx
  801445:	ff d0                	call   *%eax
  801447:	83 c4 10             	add    $0x10,%esp
}
  80144a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80144d:	5b                   	pop    %ebx
  80144e:	5e                   	pop    %esi
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801451:	a1 00 44 80 00       	mov    0x804400,%eax
  801456:	8b 40 48             	mov    0x48(%eax),%eax
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	56                   	push   %esi
  80145d:	50                   	push   %eax
  80145e:	68 6d 26 80 00       	push   $0x80266d
  801463:	e8 99 ef ff ff       	call   800401 <cprintf>
		return -E_INVAL;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801470:	eb d8                	jmp    80144a <read+0x58>
		return -E_NOT_SUPP;
  801472:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801477:	eb d1                	jmp    80144a <read+0x58>

00801479 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	57                   	push   %edi
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 0c             	sub    $0xc,%esp
  801482:	8b 7d 08             	mov    0x8(%ebp),%edi
  801485:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801488:	bb 00 00 00 00       	mov    $0x0,%ebx
  80148d:	eb 02                	jmp    801491 <readn+0x18>
  80148f:	01 c3                	add    %eax,%ebx
  801491:	39 f3                	cmp    %esi,%ebx
  801493:	73 21                	jae    8014b6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	89 f0                	mov    %esi,%eax
  80149a:	29 d8                	sub    %ebx,%eax
  80149c:	50                   	push   %eax
  80149d:	89 d8                	mov    %ebx,%eax
  80149f:	03 45 0c             	add    0xc(%ebp),%eax
  8014a2:	50                   	push   %eax
  8014a3:	57                   	push   %edi
  8014a4:	e8 49 ff ff ff       	call   8013f2 <read>
		if (m < 0)
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 04                	js     8014b4 <readn+0x3b>
			return m;
		if (m == 0)
  8014b0:	75 dd                	jne    80148f <readn+0x16>
  8014b2:	eb 02                	jmp    8014b6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014b6:	89 d8                	mov    %ebx,%eax
  8014b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	83 ec 18             	sub    $0x18,%esp
  8014c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	53                   	push   %ebx
  8014d0:	e8 b9 fc ff ff       	call   80118e <fd_lookup>
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 37                	js     801513 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dc:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	ff 36                	push   (%esi)
  8014e8:	e8 f1 fc ff ff       	call   8011de <dev_lookup>
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 1f                	js     801513 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014f4:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014f8:	74 20                	je     80151a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801500:	85 c0                	test   %eax,%eax
  801502:	74 37                	je     80153b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801504:	83 ec 04             	sub    $0x4,%esp
  801507:	ff 75 10             	push   0x10(%ebp)
  80150a:	ff 75 0c             	push   0xc(%ebp)
  80150d:	56                   	push   %esi
  80150e:	ff d0                	call   *%eax
  801510:	83 c4 10             	add    $0x10,%esp
}
  801513:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801516:	5b                   	pop    %ebx
  801517:	5e                   	pop    %esi
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80151a:	a1 00 44 80 00       	mov    0x804400,%eax
  80151f:	8b 40 48             	mov    0x48(%eax),%eax
  801522:	83 ec 04             	sub    $0x4,%esp
  801525:	53                   	push   %ebx
  801526:	50                   	push   %eax
  801527:	68 89 26 80 00       	push   $0x802689
  80152c:	e8 d0 ee ff ff       	call   800401 <cprintf>
		return -E_INVAL;
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801539:	eb d8                	jmp    801513 <write+0x53>
		return -E_NOT_SUPP;
  80153b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801540:	eb d1                	jmp    801513 <write+0x53>

00801542 <seek>:

int
seek(int fdnum, off_t offset)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	ff 75 08             	push   0x8(%ebp)
  80154f:	e8 3a fc ff ff       	call   80118e <fd_lookup>
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 0e                	js     801569 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80155b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801561:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801564:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
  801570:	83 ec 18             	sub    $0x18,%esp
  801573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	53                   	push   %ebx
  80157b:	e8 0e fc ff ff       	call   80118e <fd_lookup>
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	85 c0                	test   %eax,%eax
  801585:	78 34                	js     8015bb <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	ff 36                	push   (%esi)
  801593:	e8 46 fc ff ff       	call   8011de <dev_lookup>
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 1c                	js     8015bb <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015a3:	74 1d                	je     8015c2 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a8:	8b 40 18             	mov    0x18(%eax),%eax
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	74 34                	je     8015e3 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	ff 75 0c             	push   0xc(%ebp)
  8015b5:	56                   	push   %esi
  8015b6:	ff d0                	call   *%eax
  8015b8:	83 c4 10             	add    $0x10,%esp
}
  8015bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015c2:	a1 00 44 80 00       	mov    0x804400,%eax
  8015c7:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ca:	83 ec 04             	sub    $0x4,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	50                   	push   %eax
  8015cf:	68 4c 26 80 00       	push   $0x80264c
  8015d4:	e8 28 ee ff ff       	call   800401 <cprintf>
		return -E_INVAL;
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e1:	eb d8                	jmp    8015bb <ftruncate+0x50>
		return -E_NOT_SUPP;
  8015e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015e8:	eb d1                	jmp    8015bb <ftruncate+0x50>

008015ea <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 18             	sub    $0x18,%esp
  8015f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	ff 75 08             	push   0x8(%ebp)
  8015fc:	e8 8d fb ff ff       	call   80118e <fd_lookup>
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	85 c0                	test   %eax,%eax
  801606:	78 49                	js     801651 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801608:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801611:	50                   	push   %eax
  801612:	ff 36                	push   (%esi)
  801614:	e8 c5 fb ff ff       	call   8011de <dev_lookup>
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 31                	js     801651 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801620:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801623:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801627:	74 2f                	je     801658 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801629:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80162c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801633:	00 00 00 
	stat->st_isdir = 0;
  801636:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80163d:	00 00 00 
	stat->st_dev = dev;
  801640:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801646:	83 ec 08             	sub    $0x8,%esp
  801649:	53                   	push   %ebx
  80164a:	56                   	push   %esi
  80164b:	ff 50 14             	call   *0x14(%eax)
  80164e:	83 c4 10             	add    $0x10,%esp
}
  801651:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801654:	5b                   	pop    %ebx
  801655:	5e                   	pop    %esi
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    
		return -E_NOT_SUPP;
  801658:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80165d:	eb f2                	jmp    801651 <fstat+0x67>

0080165f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	56                   	push   %esi
  801663:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	6a 00                	push   $0x0
  801669:	ff 75 08             	push   0x8(%ebp)
  80166c:	e8 e4 01 00 00       	call   801855 <open>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 1b                	js     801695 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	ff 75 0c             	push   0xc(%ebp)
  801680:	50                   	push   %eax
  801681:	e8 64 ff ff ff       	call   8015ea <fstat>
  801686:	89 c6                	mov    %eax,%esi
	close(fd);
  801688:	89 1c 24             	mov    %ebx,(%esp)
  80168b:	e8 26 fc ff ff       	call   8012b6 <close>
	return r;
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	89 f3                	mov    %esi,%ebx
}
  801695:	89 d8                	mov    %ebx,%eax
  801697:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80169a:	5b                   	pop    %ebx
  80169b:	5e                   	pop    %esi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	56                   	push   %esi
  8016a2:	53                   	push   %ebx
  8016a3:	89 c6                	mov    %eax,%esi
  8016a5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016ae:	74 27                	je     8016d7 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b0:	6a 07                	push   $0x7
  8016b2:	68 00 50 80 00       	push   $0x805000
  8016b7:	56                   	push   %esi
  8016b8:	ff 35 00 60 80 00    	push   0x806000
  8016be:	e8 6f 08 00 00       	call   801f32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016c3:	83 c4 0c             	add    $0xc,%esp
  8016c6:	6a 00                	push   $0x0
  8016c8:	53                   	push   %ebx
  8016c9:	6a 00                	push   $0x0
  8016cb:	e8 fb 07 00 00       	call   801ecb <ipc_recv>
}
  8016d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d3:	5b                   	pop    %ebx
  8016d4:	5e                   	pop    %esi
  8016d5:	5d                   	pop    %ebp
  8016d6:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016d7:	83 ec 0c             	sub    $0xc,%esp
  8016da:	6a 01                	push   $0x1
  8016dc:	e8 a5 08 00 00       	call   801f86 <ipc_find_env>
  8016e1:	a3 00 60 80 00       	mov    %eax,0x806000
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	eb c5                	jmp    8016b0 <fsipc+0x12>

008016eb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016ff:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801704:	ba 00 00 00 00       	mov    $0x0,%edx
  801709:	b8 02 00 00 00       	mov    $0x2,%eax
  80170e:	e8 8b ff ff ff       	call   80169e <fsipc>
}
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <devfile_flush>:
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	8b 40 0c             	mov    0xc(%eax),%eax
  801721:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801726:	ba 00 00 00 00       	mov    $0x0,%edx
  80172b:	b8 06 00 00 00       	mov    $0x6,%eax
  801730:	e8 69 ff ff ff       	call   80169e <fsipc>
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_stat>:
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	53                   	push   %ebx
  80173b:	83 ec 04             	sub    $0x4,%esp
  80173e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
  801744:	8b 40 0c             	mov    0xc(%eax),%eax
  801747:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80174c:	ba 00 00 00 00       	mov    $0x0,%edx
  801751:	b8 05 00 00 00       	mov    $0x5,%eax
  801756:	e8 43 ff ff ff       	call   80169e <fsipc>
  80175b:	85 c0                	test   %eax,%eax
  80175d:	78 2c                	js     80178b <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80175f:	83 ec 08             	sub    $0x8,%esp
  801762:	68 00 50 80 00       	push   $0x805000
  801767:	53                   	push   %ebx
  801768:	e8 6e f2 ff ff       	call   8009db <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176d:	a1 80 50 80 00       	mov    0x805080,%eax
  801772:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801778:	a1 84 50 80 00       	mov    0x805084,%eax
  80177d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80178b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <devfile_write>:
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	8b 45 10             	mov    0x10(%ebp),%eax
  801799:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80179e:	39 d0                	cmp    %edx,%eax
  8017a0:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8017a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017af:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017b4:	50                   	push   %eax
  8017b5:	ff 75 0c             	push   0xc(%ebp)
  8017b8:	68 08 50 80 00       	push   $0x805008
  8017bd:	e8 af f3 ff ff       	call   800b71 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8017cc:	e8 cd fe ff ff       	call   80169e <fsipc>
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <devfile_read>:
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017e6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f6:	e8 a3 fe ff ff       	call   80169e <fsipc>
  8017fb:	89 c3                	mov    %eax,%ebx
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 1f                	js     801820 <devfile_read+0x4d>
	assert(r <= n);
  801801:	39 f0                	cmp    %esi,%eax
  801803:	77 24                	ja     801829 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801805:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80180a:	7f 33                	jg     80183f <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	50                   	push   %eax
  801810:	68 00 50 80 00       	push   $0x805000
  801815:	ff 75 0c             	push   0xc(%ebp)
  801818:	e8 54 f3 ff ff       	call   800b71 <memmove>
	return r;
  80181d:	83 c4 10             	add    $0x10,%esp
}
  801820:	89 d8                	mov    %ebx,%eax
  801822:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801825:	5b                   	pop    %ebx
  801826:	5e                   	pop    %esi
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    
	assert(r <= n);
  801829:	68 b8 26 80 00       	push   $0x8026b8
  80182e:	68 bf 26 80 00       	push   $0x8026bf
  801833:	6a 7c                	push   $0x7c
  801835:	68 d4 26 80 00       	push   $0x8026d4
  80183a:	e8 e7 ea ff ff       	call   800326 <_panic>
	assert(r <= PGSIZE);
  80183f:	68 df 26 80 00       	push   $0x8026df
  801844:	68 bf 26 80 00       	push   $0x8026bf
  801849:	6a 7d                	push   $0x7d
  80184b:	68 d4 26 80 00       	push   $0x8026d4
  801850:	e8 d1 ea ff ff       	call   800326 <_panic>

00801855 <open>:
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	83 ec 1c             	sub    $0x1c,%esp
  80185d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801860:	56                   	push   %esi
  801861:	e8 3a f1 ff ff       	call   8009a0 <strlen>
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80186e:	7f 6c                	jg     8018dc <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801870:	83 ec 0c             	sub    $0xc,%esp
  801873:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	e8 c2 f8 ff ff       	call   80113e <fd_alloc>
  80187c:	89 c3                	mov    %eax,%ebx
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	85 c0                	test   %eax,%eax
  801883:	78 3c                	js     8018c1 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801885:	83 ec 08             	sub    $0x8,%esp
  801888:	56                   	push   %esi
  801889:	68 00 50 80 00       	push   $0x805000
  80188e:	e8 48 f1 ff ff       	call   8009db <strcpy>
	fsipcbuf.open.req_omode = mode;
  801893:	8b 45 0c             	mov    0xc(%ebp),%eax
  801896:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80189b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189e:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a3:	e8 f6 fd ff ff       	call   80169e <fsipc>
  8018a8:	89 c3                	mov    %eax,%ebx
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 19                	js     8018ca <open+0x75>
	return fd2num(fd);
  8018b1:	83 ec 0c             	sub    $0xc,%esp
  8018b4:	ff 75 f4             	push   -0xc(%ebp)
  8018b7:	e8 5b f8 ff ff       	call   801117 <fd2num>
  8018bc:	89 c3                	mov    %eax,%ebx
  8018be:	83 c4 10             	add    $0x10,%esp
}
  8018c1:	89 d8                	mov    %ebx,%eax
  8018c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    
		fd_close(fd, 0);
  8018ca:	83 ec 08             	sub    $0x8,%esp
  8018cd:	6a 00                	push   $0x0
  8018cf:	ff 75 f4             	push   -0xc(%ebp)
  8018d2:	e8 58 f9 ff ff       	call   80122f <fd_close>
		return r;
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	eb e5                	jmp    8018c1 <open+0x6c>
		return -E_BAD_PATH;
  8018dc:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018e1:	eb de                	jmp    8018c1 <open+0x6c>

008018e3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f3:	e8 a6 fd ff ff       	call   80169e <fsipc>
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018fa:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8018fe:	7f 01                	jg     801901 <writebuf+0x7>
  801900:	c3                   	ret    
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	53                   	push   %ebx
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  80190a:	ff 70 04             	push   0x4(%eax)
  80190d:	8d 40 10             	lea    0x10(%eax),%eax
  801910:	50                   	push   %eax
  801911:	ff 33                	push   (%ebx)
  801913:	e8 a8 fb ff ff       	call   8014c0 <write>
		if (result > 0)
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	85 c0                	test   %eax,%eax
  80191d:	7e 03                	jle    801922 <writebuf+0x28>
			b->result += result;
  80191f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801922:	39 43 04             	cmp    %eax,0x4(%ebx)
  801925:	74 0d                	je     801934 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801927:	85 c0                	test   %eax,%eax
  801929:	ba 00 00 00 00       	mov    $0x0,%edx
  80192e:	0f 4f c2             	cmovg  %edx,%eax
  801931:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801934:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <putch>:

static void
putch(int ch, void *thunk)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	53                   	push   %ebx
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801943:	8b 53 04             	mov    0x4(%ebx),%edx
  801946:	8d 42 01             	lea    0x1(%edx),%eax
  801949:	89 43 04             	mov    %eax,0x4(%ebx)
  80194c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194f:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801953:	3d 00 01 00 00       	cmp    $0x100,%eax
  801958:	74 05                	je     80195f <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  80195a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    
		writebuf(b);
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	e8 94 ff ff ff       	call   8018fa <writebuf>
		b->idx = 0;
  801966:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80196d:	eb eb                	jmp    80195a <putch+0x21>

0080196f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  801978:	8b 45 08             	mov    0x8(%ebp),%eax
  80197b:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801981:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801988:	00 00 00 
	b.result = 0;
  80198b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801992:	00 00 00 
	b.error = 1;
  801995:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80199c:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80199f:	ff 75 10             	push   0x10(%ebp)
  8019a2:	ff 75 0c             	push   0xc(%ebp)
  8019a5:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019ab:	50                   	push   %eax
  8019ac:	68 39 19 80 00       	push   $0x801939
  8019b1:	e8 42 eb ff ff       	call   8004f8 <vprintfmt>
	if (b.idx > 0)
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019c0:	7f 11                	jg     8019d3 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8019c2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    
		writebuf(&b);
  8019d3:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019d9:	e8 1c ff ff ff       	call   8018fa <writebuf>
  8019de:	eb e2                	jmp    8019c2 <vfprintf+0x53>

008019e0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019e6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019e9:	50                   	push   %eax
  8019ea:	ff 75 0c             	push   0xc(%ebp)
  8019ed:	ff 75 08             	push   0x8(%ebp)
  8019f0:	e8 7a ff ff ff       	call   80196f <vfprintf>
	va_end(ap);

	return cnt;
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <printf>:

int
printf(const char *fmt, ...)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a00:	50                   	push   %eax
  801a01:	ff 75 08             	push   0x8(%ebp)
  801a04:	6a 01                	push   $0x1
  801a06:	e8 64 ff ff ff       	call   80196f <vfprintf>
	va_end(ap);

	return cnt;
}
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a15:	83 ec 0c             	sub    $0xc,%esp
  801a18:	ff 75 08             	push   0x8(%ebp)
  801a1b:	e8 07 f7 ff ff       	call   801127 <fd2data>
  801a20:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a22:	83 c4 08             	add    $0x8,%esp
  801a25:	68 eb 26 80 00       	push   $0x8026eb
  801a2a:	53                   	push   %ebx
  801a2b:	e8 ab ef ff ff       	call   8009db <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a30:	8b 46 04             	mov    0x4(%esi),%eax
  801a33:	2b 06                	sub    (%esi),%eax
  801a35:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a3b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a42:	00 00 00 
	stat->st_dev = &devpipe;
  801a45:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a4c:	30 80 00 
	return 0;
}
  801a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	53                   	push   %ebx
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a65:	53                   	push   %ebx
  801a66:	6a 00                	push   $0x0
  801a68:	e8 ef f3 ff ff       	call   800e5c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a6d:	89 1c 24             	mov    %ebx,(%esp)
  801a70:	e8 b2 f6 ff ff       	call   801127 <fd2data>
  801a75:	83 c4 08             	add    $0x8,%esp
  801a78:	50                   	push   %eax
  801a79:	6a 00                	push   $0x0
  801a7b:	e8 dc f3 ff ff       	call   800e5c <sys_page_unmap>
}
  801a80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a83:	c9                   	leave  
  801a84:	c3                   	ret    

00801a85 <_pipeisclosed>:
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	57                   	push   %edi
  801a89:	56                   	push   %esi
  801a8a:	53                   	push   %ebx
  801a8b:	83 ec 1c             	sub    $0x1c,%esp
  801a8e:	89 c7                	mov    %eax,%edi
  801a90:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a92:	a1 00 44 80 00       	mov    0x804400,%eax
  801a97:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a9a:	83 ec 0c             	sub    $0xc,%esp
  801a9d:	57                   	push   %edi
  801a9e:	e8 1c 05 00 00       	call   801fbf <pageref>
  801aa3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aa6:	89 34 24             	mov    %esi,(%esp)
  801aa9:	e8 11 05 00 00       	call   801fbf <pageref>
		nn = thisenv->env_runs;
  801aae:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801ab4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab7:	83 c4 10             	add    $0x10,%esp
  801aba:	39 cb                	cmp    %ecx,%ebx
  801abc:	74 1b                	je     801ad9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801abe:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ac1:	75 cf                	jne    801a92 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ac3:	8b 42 58             	mov    0x58(%edx),%eax
  801ac6:	6a 01                	push   $0x1
  801ac8:	50                   	push   %eax
  801ac9:	53                   	push   %ebx
  801aca:	68 f2 26 80 00       	push   $0x8026f2
  801acf:	e8 2d e9 ff ff       	call   800401 <cprintf>
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	eb b9                	jmp    801a92 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ad9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801adc:	0f 94 c0             	sete   %al
  801adf:	0f b6 c0             	movzbl %al,%eax
}
  801ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5f                   	pop    %edi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <devpipe_write>:
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	57                   	push   %edi
  801aee:	56                   	push   %esi
  801aef:	53                   	push   %ebx
  801af0:	83 ec 28             	sub    $0x28,%esp
  801af3:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801af6:	56                   	push   %esi
  801af7:	e8 2b f6 ff ff       	call   801127 <fd2data>
  801afc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	bf 00 00 00 00       	mov    $0x0,%edi
  801b06:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b09:	75 09                	jne    801b14 <devpipe_write+0x2a>
	return i;
  801b0b:	89 f8                	mov    %edi,%eax
  801b0d:	eb 23                	jmp    801b32 <devpipe_write+0x48>
			sys_yield();
  801b0f:	e8 a4 f2 ff ff       	call   800db8 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b14:	8b 43 04             	mov    0x4(%ebx),%eax
  801b17:	8b 0b                	mov    (%ebx),%ecx
  801b19:	8d 51 20             	lea    0x20(%ecx),%edx
  801b1c:	39 d0                	cmp    %edx,%eax
  801b1e:	72 1a                	jb     801b3a <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801b20:	89 da                	mov    %ebx,%edx
  801b22:	89 f0                	mov    %esi,%eax
  801b24:	e8 5c ff ff ff       	call   801a85 <_pipeisclosed>
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	74 e2                	je     801b0f <devpipe_write+0x25>
				return 0;
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5f                   	pop    %edi
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b41:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b44:	89 c2                	mov    %eax,%edx
  801b46:	c1 fa 1f             	sar    $0x1f,%edx
  801b49:	89 d1                	mov    %edx,%ecx
  801b4b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b4e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b51:	83 e2 1f             	and    $0x1f,%edx
  801b54:	29 ca                	sub    %ecx,%edx
  801b56:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b5a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b5e:	83 c0 01             	add    $0x1,%eax
  801b61:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b64:	83 c7 01             	add    $0x1,%edi
  801b67:	eb 9d                	jmp    801b06 <devpipe_write+0x1c>

00801b69 <devpipe_read>:
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	57                   	push   %edi
  801b6d:	56                   	push   %esi
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 18             	sub    $0x18,%esp
  801b72:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b75:	57                   	push   %edi
  801b76:	e8 ac f5 ff ff       	call   801127 <fd2data>
  801b7b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	be 00 00 00 00       	mov    $0x0,%esi
  801b85:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b88:	75 13                	jne    801b9d <devpipe_read+0x34>
	return i;
  801b8a:	89 f0                	mov    %esi,%eax
  801b8c:	eb 02                	jmp    801b90 <devpipe_read+0x27>
				return i;
  801b8e:	89 f0                	mov    %esi,%eax
}
  801b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b93:	5b                   	pop    %ebx
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
			sys_yield();
  801b98:	e8 1b f2 ff ff       	call   800db8 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b9d:	8b 03                	mov    (%ebx),%eax
  801b9f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ba2:	75 18                	jne    801bbc <devpipe_read+0x53>
			if (i > 0)
  801ba4:	85 f6                	test   %esi,%esi
  801ba6:	75 e6                	jne    801b8e <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801ba8:	89 da                	mov    %ebx,%edx
  801baa:	89 f8                	mov    %edi,%eax
  801bac:	e8 d4 fe ff ff       	call   801a85 <_pipeisclosed>
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	74 e3                	je     801b98 <devpipe_read+0x2f>
				return 0;
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bba:	eb d4                	jmp    801b90 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bbc:	99                   	cltd   
  801bbd:	c1 ea 1b             	shr    $0x1b,%edx
  801bc0:	01 d0                	add    %edx,%eax
  801bc2:	83 e0 1f             	and    $0x1f,%eax
  801bc5:	29 d0                	sub    %edx,%eax
  801bc7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bcf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bd2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bd5:	83 c6 01             	add    $0x1,%esi
  801bd8:	eb ab                	jmp    801b85 <devpipe_read+0x1c>

00801bda <pipe>:
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	56                   	push   %esi
  801bde:	53                   	push   %ebx
  801bdf:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801be2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be5:	50                   	push   %eax
  801be6:	e8 53 f5 ff ff       	call   80113e <fd_alloc>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	85 c0                	test   %eax,%eax
  801bf2:	0f 88 23 01 00 00    	js     801d1b <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf8:	83 ec 04             	sub    $0x4,%esp
  801bfb:	68 07 04 00 00       	push   $0x407
  801c00:	ff 75 f4             	push   -0xc(%ebp)
  801c03:	6a 00                	push   $0x0
  801c05:	e8 cd f1 ff ff       	call   800dd7 <sys_page_alloc>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	0f 88 04 01 00 00    	js     801d1b <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1d:	50                   	push   %eax
  801c1e:	e8 1b f5 ff ff       	call   80113e <fd_alloc>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 db 00 00 00    	js     801d0b <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	68 07 04 00 00       	push   $0x407
  801c38:	ff 75 f0             	push   -0x10(%ebp)
  801c3b:	6a 00                	push   $0x0
  801c3d:	e8 95 f1 ff ff       	call   800dd7 <sys_page_alloc>
  801c42:	89 c3                	mov    %eax,%ebx
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	85 c0                	test   %eax,%eax
  801c49:	0f 88 bc 00 00 00    	js     801d0b <pipe+0x131>
	va = fd2data(fd0);
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	ff 75 f4             	push   -0xc(%ebp)
  801c55:	e8 cd f4 ff ff       	call   801127 <fd2data>
  801c5a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5c:	83 c4 0c             	add    $0xc,%esp
  801c5f:	68 07 04 00 00       	push   $0x407
  801c64:	50                   	push   %eax
  801c65:	6a 00                	push   $0x0
  801c67:	e8 6b f1 ff ff       	call   800dd7 <sys_page_alloc>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	85 c0                	test   %eax,%eax
  801c73:	0f 88 82 00 00 00    	js     801cfb <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	ff 75 f0             	push   -0x10(%ebp)
  801c7f:	e8 a3 f4 ff ff       	call   801127 <fd2data>
  801c84:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c8b:	50                   	push   %eax
  801c8c:	6a 00                	push   $0x0
  801c8e:	56                   	push   %esi
  801c8f:	6a 00                	push   $0x0
  801c91:	e8 84 f1 ff ff       	call   800e1a <sys_page_map>
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	83 c4 20             	add    $0x20,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 4e                	js     801ced <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c9f:	a1 20 30 80 00       	mov    0x803020,%eax
  801ca4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ca7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ca9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cac:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801cb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cb6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cc2:	83 ec 0c             	sub    $0xc,%esp
  801cc5:	ff 75 f4             	push   -0xc(%ebp)
  801cc8:	e8 4a f4 ff ff       	call   801117 <fd2num>
  801ccd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd2:	83 c4 04             	add    $0x4,%esp
  801cd5:	ff 75 f0             	push   -0x10(%ebp)
  801cd8:	e8 3a f4 ff ff       	call   801117 <fd2num>
  801cdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ceb:	eb 2e                	jmp    801d1b <pipe+0x141>
	sys_page_unmap(0, va);
  801ced:	83 ec 08             	sub    $0x8,%esp
  801cf0:	56                   	push   %esi
  801cf1:	6a 00                	push   $0x0
  801cf3:	e8 64 f1 ff ff       	call   800e5c <sys_page_unmap>
  801cf8:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801cfb:	83 ec 08             	sub    $0x8,%esp
  801cfe:	ff 75 f0             	push   -0x10(%ebp)
  801d01:	6a 00                	push   $0x0
  801d03:	e8 54 f1 ff ff       	call   800e5c <sys_page_unmap>
  801d08:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d0b:	83 ec 08             	sub    $0x8,%esp
  801d0e:	ff 75 f4             	push   -0xc(%ebp)
  801d11:	6a 00                	push   $0x0
  801d13:	e8 44 f1 ff ff       	call   800e5c <sys_page_unmap>
  801d18:	83 c4 10             	add    $0x10,%esp
}
  801d1b:	89 d8                	mov    %ebx,%eax
  801d1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    

00801d24 <pipeisclosed>:
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2d:	50                   	push   %eax
  801d2e:	ff 75 08             	push   0x8(%ebp)
  801d31:	e8 58 f4 ff ff       	call   80118e <fd_lookup>
  801d36:	83 c4 10             	add    $0x10,%esp
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 18                	js     801d55 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d3d:	83 ec 0c             	sub    $0xc,%esp
  801d40:	ff 75 f4             	push   -0xc(%ebp)
  801d43:	e8 df f3 ff ff       	call   801127 <fd2data>
  801d48:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4d:	e8 33 fd ff ff       	call   801a85 <_pipeisclosed>
  801d52:	83 c4 10             	add    $0x10,%esp
}
  801d55:	c9                   	leave  
  801d56:	c3                   	ret    

00801d57 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801d57:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5c:	c3                   	ret    

00801d5d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d63:	68 0a 27 80 00       	push   $0x80270a
  801d68:	ff 75 0c             	push   0xc(%ebp)
  801d6b:	e8 6b ec ff ff       	call   8009db <strcpy>
	return 0;
}
  801d70:	b8 00 00 00 00       	mov    $0x0,%eax
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <devcons_write>:
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	57                   	push   %edi
  801d7b:	56                   	push   %esi
  801d7c:	53                   	push   %ebx
  801d7d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d83:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d88:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d8e:	eb 2e                	jmp    801dbe <devcons_write+0x47>
		m = n - tot;
  801d90:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d93:	29 f3                	sub    %esi,%ebx
  801d95:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d9a:	39 c3                	cmp    %eax,%ebx
  801d9c:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d9f:	83 ec 04             	sub    $0x4,%esp
  801da2:	53                   	push   %ebx
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	03 45 0c             	add    0xc(%ebp),%eax
  801da8:	50                   	push   %eax
  801da9:	57                   	push   %edi
  801daa:	e8 c2 ed ff ff       	call   800b71 <memmove>
		sys_cputs(buf, m);
  801daf:	83 c4 08             	add    $0x8,%esp
  801db2:	53                   	push   %ebx
  801db3:	57                   	push   %edi
  801db4:	e8 62 ef ff ff       	call   800d1b <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801db9:	01 de                	add    %ebx,%esi
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc1:	72 cd                	jb     801d90 <devcons_write+0x19>
}
  801dc3:	89 f0                	mov    %esi,%eax
  801dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <devcons_read>:
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	83 ec 08             	sub    $0x8,%esp
  801dd3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801dd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ddc:	75 07                	jne    801de5 <devcons_read+0x18>
  801dde:	eb 1f                	jmp    801dff <devcons_read+0x32>
		sys_yield();
  801de0:	e8 d3 ef ff ff       	call   800db8 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801de5:	e8 4f ef ff ff       	call   800d39 <sys_cgetc>
  801dea:	85 c0                	test   %eax,%eax
  801dec:	74 f2                	je     801de0 <devcons_read+0x13>
	if (c < 0)
  801dee:	78 0f                	js     801dff <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801df0:	83 f8 04             	cmp    $0x4,%eax
  801df3:	74 0c                	je     801e01 <devcons_read+0x34>
	*(char*)vbuf = c;
  801df5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df8:	88 02                	mov    %al,(%edx)
	return 1;
  801dfa:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801dff:	c9                   	leave  
  801e00:	c3                   	ret    
		return 0;
  801e01:	b8 00 00 00 00       	mov    $0x0,%eax
  801e06:	eb f7                	jmp    801dff <devcons_read+0x32>

00801e08 <cputchar>:
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e11:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e14:	6a 01                	push   $0x1
  801e16:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e19:	50                   	push   %eax
  801e1a:	e8 fc ee ff ff       	call   800d1b <sys_cputs>
}
  801e1f:	83 c4 10             	add    $0x10,%esp
  801e22:	c9                   	leave  
  801e23:	c3                   	ret    

00801e24 <getchar>:
{
  801e24:	55                   	push   %ebp
  801e25:	89 e5                	mov    %esp,%ebp
  801e27:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e2a:	6a 01                	push   $0x1
  801e2c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2f:	50                   	push   %eax
  801e30:	6a 00                	push   $0x0
  801e32:	e8 bb f5 ff ff       	call   8013f2 <read>
	if (r < 0)
  801e37:	83 c4 10             	add    $0x10,%esp
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 06                	js     801e44 <getchar+0x20>
	if (r < 1)
  801e3e:	74 06                	je     801e46 <getchar+0x22>
	return c;
  801e40:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    
		return -E_EOF;
  801e46:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e4b:	eb f7                	jmp    801e44 <getchar+0x20>

00801e4d <iscons>:
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	ff 75 08             	push   0x8(%ebp)
  801e5a:	e8 2f f3 ff ff       	call   80118e <fd_lookup>
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	78 11                	js     801e77 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e69:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e6f:	39 10                	cmp    %edx,(%eax)
  801e71:	0f 94 c0             	sete   %al
  801e74:	0f b6 c0             	movzbl %al,%eax
}
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <opencons>:
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	e8 b6 f2 ff ff       	call   80113e <fd_alloc>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 3a                	js     801ec9 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e8f:	83 ec 04             	sub    $0x4,%esp
  801e92:	68 07 04 00 00       	push   $0x407
  801e97:	ff 75 f4             	push   -0xc(%ebp)
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 36 ef ff ff       	call   800dd7 <sys_page_alloc>
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	85 c0                	test   %eax,%eax
  801ea6:	78 21                	js     801ec9 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	50                   	push   %eax
  801ec1:	e8 51 f2 ff ff       	call   801117 <fd2num>
  801ec6:	83 c4 10             	add    $0x10,%esp
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ee0:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ee3:	83 ec 0c             	sub    $0xc,%esp
  801ee6:	50                   	push   %eax
  801ee7:	e8 9b f0 ff ff       	call   800f87 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	85 f6                	test   %esi,%esi
  801ef1:	74 14                	je     801f07 <ipc_recv+0x3c>
  801ef3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	78 09                	js     801f05 <ipc_recv+0x3a>
  801efc:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801f02:	8b 52 74             	mov    0x74(%edx),%edx
  801f05:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f07:	85 db                	test   %ebx,%ebx
  801f09:	74 14                	je     801f1f <ipc_recv+0x54>
  801f0b:	ba 00 00 00 00       	mov    $0x0,%edx
  801f10:	85 c0                	test   %eax,%eax
  801f12:	78 09                	js     801f1d <ipc_recv+0x52>
  801f14:	8b 15 00 44 80 00    	mov    0x804400,%edx
  801f1a:	8b 52 78             	mov    0x78(%edx),%edx
  801f1d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 08                	js     801f2b <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f23:	a1 00 44 80 00       	mov    0x804400,%eax
  801f28:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2e:	5b                   	pop    %ebx
  801f2f:	5e                   	pop    %esi
  801f30:	5d                   	pop    %ebp
  801f31:	c3                   	ret    

00801f32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f32:	55                   	push   %ebp
  801f33:	89 e5                	mov    %esp,%ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	83 ec 0c             	sub    $0xc,%esp
  801f3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f44:	85 db                	test   %ebx,%ebx
  801f46:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f4b:	0f 44 d8             	cmove  %eax,%ebx
  801f4e:	eb 05                	jmp    801f55 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f50:	e8 63 ee ff ff       	call   800db8 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f55:	ff 75 14             	push   0x14(%ebp)
  801f58:	53                   	push   %ebx
  801f59:	56                   	push   %esi
  801f5a:	57                   	push   %edi
  801f5b:	e8 04 f0 ff ff       	call   800f64 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f66:	74 e8                	je     801f50 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 08                	js     801f74 <ipc_send+0x42>
	}while (r<0);

}
  801f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f74:	50                   	push   %eax
  801f75:	68 16 27 80 00       	push   $0x802716
  801f7a:	6a 3d                	push   $0x3d
  801f7c:	68 2a 27 80 00       	push   $0x80272a
  801f81:	e8 a0 e3 ff ff       	call   800326 <_panic>

00801f86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f8c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f91:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f94:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f9a:	8b 52 50             	mov    0x50(%edx),%edx
  801f9d:	39 ca                	cmp    %ecx,%edx
  801f9f:	74 11                	je     801fb2 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fa1:	83 c0 01             	add    $0x1,%eax
  801fa4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa9:	75 e6                	jne    801f91 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fab:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb0:	eb 0b                	jmp    801fbd <ipc_find_env+0x37>
			return envs[i].env_id;
  801fb2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fb5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fba:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    

00801fbf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc5:	89 c2                	mov    %eax,%edx
  801fc7:	c1 ea 16             	shr    $0x16,%edx
  801fca:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fd1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fd6:	f6 c1 01             	test   $0x1,%cl
  801fd9:	74 1c                	je     801ff7 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fdb:	c1 e8 0c             	shr    $0xc,%eax
  801fde:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fe5:	a8 01                	test   $0x1,%al
  801fe7:	74 0e                	je     801ff7 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe9:	c1 e8 0c             	shr    $0xc,%eax
  801fec:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ff3:	ef 
  801ff4:	0f b7 d2             	movzwl %dx,%edx
}
  801ff7:	89 d0                	mov    %edx,%eax
  801ff9:	5d                   	pop    %ebp
  801ffa:	c3                   	ret    
  801ffb:	66 90                	xchg   %ax,%ax
  801ffd:	66 90                	xchg   %ax,%ax
  801fff:	90                   	nop

00802000 <__udivdi3>:
  802000:	f3 0f 1e fb          	endbr32 
  802004:	55                   	push   %ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 1c             	sub    $0x1c,%esp
  80200b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80200f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802013:	8b 74 24 34          	mov    0x34(%esp),%esi
  802017:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80201b:	85 c0                	test   %eax,%eax
  80201d:	75 19                	jne    802038 <__udivdi3+0x38>
  80201f:	39 f3                	cmp    %esi,%ebx
  802021:	76 4d                	jbe    802070 <__udivdi3+0x70>
  802023:	31 ff                	xor    %edi,%edi
  802025:	89 e8                	mov    %ebp,%eax
  802027:	89 f2                	mov    %esi,%edx
  802029:	f7 f3                	div    %ebx
  80202b:	89 fa                	mov    %edi,%edx
  80202d:	83 c4 1c             	add    $0x1c,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	39 f0                	cmp    %esi,%eax
  80203a:	76 14                	jbe    802050 <__udivdi3+0x50>
  80203c:	31 ff                	xor    %edi,%edi
  80203e:	31 c0                	xor    %eax,%eax
  802040:	89 fa                	mov    %edi,%edx
  802042:	83 c4 1c             	add    $0x1c,%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    
  80204a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802050:	0f bd f8             	bsr    %eax,%edi
  802053:	83 f7 1f             	xor    $0x1f,%edi
  802056:	75 48                	jne    8020a0 <__udivdi3+0xa0>
  802058:	39 f0                	cmp    %esi,%eax
  80205a:	72 06                	jb     802062 <__udivdi3+0x62>
  80205c:	31 c0                	xor    %eax,%eax
  80205e:	39 eb                	cmp    %ebp,%ebx
  802060:	77 de                	ja     802040 <__udivdi3+0x40>
  802062:	b8 01 00 00 00       	mov    $0x1,%eax
  802067:	eb d7                	jmp    802040 <__udivdi3+0x40>
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d9                	mov    %ebx,%ecx
  802072:	85 db                	test   %ebx,%ebx
  802074:	75 0b                	jne    802081 <__udivdi3+0x81>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f3                	div    %ebx
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	f7 f1                	div    %ecx
  802087:	89 c6                	mov    %eax,%esi
  802089:	89 e8                	mov    %ebp,%eax
  80208b:	89 f7                	mov    %esi,%edi
  80208d:	f7 f1                	div    %ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	83 c4 1c             	add    $0x1c,%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5f                   	pop    %edi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 f9                	mov    %edi,%ecx
  8020a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020a7:	29 fa                	sub    %edi,%edx
  8020a9:	d3 e0                	shl    %cl,%eax
  8020ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020af:	89 d1                	mov    %edx,%ecx
  8020b1:	89 d8                	mov    %ebx,%eax
  8020b3:	d3 e8                	shr    %cl,%eax
  8020b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020b9:	09 c1                	or     %eax,%ecx
  8020bb:	89 f0                	mov    %esi,%eax
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e3                	shl    %cl,%ebx
  8020c5:	89 d1                	mov    %edx,%ecx
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 f9                	mov    %edi,%ecx
  8020cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020cf:	89 eb                	mov    %ebp,%ebx
  8020d1:	d3 e6                	shl    %cl,%esi
  8020d3:	89 d1                	mov    %edx,%ecx
  8020d5:	d3 eb                	shr    %cl,%ebx
  8020d7:	09 f3                	or     %esi,%ebx
  8020d9:	89 c6                	mov    %eax,%esi
  8020db:	89 f2                	mov    %esi,%edx
  8020dd:	89 d8                	mov    %ebx,%eax
  8020df:	f7 74 24 08          	divl   0x8(%esp)
  8020e3:	89 d6                	mov    %edx,%esi
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	f7 64 24 0c          	mull   0xc(%esp)
  8020eb:	39 d6                	cmp    %edx,%esi
  8020ed:	72 19                	jb     802108 <__udivdi3+0x108>
  8020ef:	89 f9                	mov    %edi,%ecx
  8020f1:	d3 e5                	shl    %cl,%ebp
  8020f3:	39 c5                	cmp    %eax,%ebp
  8020f5:	73 04                	jae    8020fb <__udivdi3+0xfb>
  8020f7:	39 d6                	cmp    %edx,%esi
  8020f9:	74 0d                	je     802108 <__udivdi3+0x108>
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	31 ff                	xor    %edi,%edi
  8020ff:	e9 3c ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80210b:	31 ff                	xor    %edi,%edi
  80210d:	e9 2e ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80212f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802133:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802137:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80213b:	89 f0                	mov    %esi,%eax
  80213d:	89 da                	mov    %ebx,%edx
  80213f:	85 ff                	test   %edi,%edi
  802141:	75 15                	jne    802158 <__umoddi3+0x38>
  802143:	39 dd                	cmp    %ebx,%ebp
  802145:	76 39                	jbe    802180 <__umoddi3+0x60>
  802147:	f7 f5                	div    %ebp
  802149:	89 d0                	mov    %edx,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 df                	cmp    %ebx,%edi
  80215a:	77 f1                	ja     80214d <__umoddi3+0x2d>
  80215c:	0f bd cf             	bsr    %edi,%ecx
  80215f:	83 f1 1f             	xor    $0x1f,%ecx
  802162:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802166:	75 40                	jne    8021a8 <__umoddi3+0x88>
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	72 04                	jb     802170 <__umoddi3+0x50>
  80216c:	39 f5                	cmp    %esi,%ebp
  80216e:	77 dd                	ja     80214d <__umoddi3+0x2d>
  802170:	89 da                	mov    %ebx,%edx
  802172:	89 f0                	mov    %esi,%eax
  802174:	29 e8                	sub    %ebp,%eax
  802176:	19 fa                	sbb    %edi,%edx
  802178:	eb d3                	jmp    80214d <__umoddi3+0x2d>
  80217a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802180:	89 e9                	mov    %ebp,%ecx
  802182:	85 ed                	test   %ebp,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x71>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f5                	div    %ebp
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	89 d8                	mov    %ebx,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f1                	div    %ecx
  802197:	89 f0                	mov    %esi,%eax
  802199:	f7 f1                	div    %ecx
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	eb ac                	jmp    80214d <__umoddi3+0x2d>
  8021a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8021b1:	29 c2                	sub    %eax,%edx
  8021b3:	89 c1                	mov    %eax,%ecx
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	d3 e7                	shl    %cl,%edi
  8021b9:	89 d1                	mov    %edx,%ecx
  8021bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021bf:	d3 e8                	shr    %cl,%eax
  8021c1:	89 c1                	mov    %eax,%ecx
  8021c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021c7:	09 f9                	or     %edi,%ecx
  8021c9:	89 df                	mov    %ebx,%edi
  8021cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	d3 e5                	shl    %cl,%ebp
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	d3 ef                	shr    %cl,%edi
  8021d7:	89 c1                	mov    %eax,%ecx
  8021d9:	89 f0                	mov    %esi,%eax
  8021db:	d3 e3                	shl    %cl,%ebx
  8021dd:	89 d1                	mov    %edx,%ecx
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	d3 e8                	shr    %cl,%eax
  8021e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021e8:	09 d8                	or     %ebx,%eax
  8021ea:	f7 74 24 08          	divl   0x8(%esp)
  8021ee:	89 d3                	mov    %edx,%ebx
  8021f0:	d3 e6                	shl    %cl,%esi
  8021f2:	f7 e5                	mul    %ebp
  8021f4:	89 c7                	mov    %eax,%edi
  8021f6:	89 d1                	mov    %edx,%ecx
  8021f8:	39 d3                	cmp    %edx,%ebx
  8021fa:	72 06                	jb     802202 <__umoddi3+0xe2>
  8021fc:	75 0e                	jne    80220c <__umoddi3+0xec>
  8021fe:	39 c6                	cmp    %eax,%esi
  802200:	73 0a                	jae    80220c <__umoddi3+0xec>
  802202:	29 e8                	sub    %ebp,%eax
  802204:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802208:	89 d1                	mov    %edx,%ecx
  80220a:	89 c7                	mov    %eax,%edi
  80220c:	89 f5                	mov    %esi,%ebp
  80220e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802212:	29 fd                	sub    %edi,%ebp
  802214:	19 cb                	sbb    %ecx,%ebx
  802216:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80221b:	89 d8                	mov    %ebx,%eax
  80221d:	d3 e0                	shl    %cl,%eax
  80221f:	89 f1                	mov    %esi,%ecx
  802221:	d3 ed                	shr    %cl,%ebp
  802223:	d3 eb                	shr    %cl,%ebx
  802225:	09 e8                	or     %ebp,%eax
  802227:	89 da                	mov    %ebx,%edx
  802229:	83 c4 1c             	add    $0x1c,%esp
  80222c:	5b                   	pop    %ebx
  80222d:	5e                   	pop    %esi
  80222e:	5f                   	pop    %edi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    
