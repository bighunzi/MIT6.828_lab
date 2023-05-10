
obj/user/echo.debug：     文件格式 elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7f 07                	jg     800055 <umain+0x22>
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80004e:	bb 01 00 00 00       	mov    $0x1,%ebx
  800053:	eb 4c                	jmp    8000a1 <umain+0x6e>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	68 e0 22 80 00       	push   $0x8022e0
  80005d:	ff 76 04             	push   0x4(%esi)
  800060:	e8 ce 01 00 00       	call   800233 <strcmp>
  800065:	83 c4 10             	add    $0x10,%esp
	nflag = 0;
  800068:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 db                	jne    80004e <umain+0x1b>
		argc--;
  800073:	83 ef 01             	sub    $0x1,%edi
		argv++;
  800076:	83 c6 04             	add    $0x4,%esi
		nflag = 1;
  800079:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800080:	eb cc                	jmp    80004e <umain+0x1b>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
  800082:	83 ec 0c             	sub    $0xc,%esp
  800085:	ff 34 9e             	push   (%esi,%ebx,4)
  800088:	e8 ba 00 00 00       	call   800147 <strlen>
  80008d:	83 c4 0c             	add    $0xc,%esp
  800090:	50                   	push   %eax
  800091:	ff 34 9e             	push   (%esi,%ebx,4)
  800094:	6a 01                	push   $0x1
  800096:	e8 e3 0a 00 00       	call   800b7e <write>
	for (i = 1; i < argc; i++) {
  80009b:	83 c3 01             	add    $0x1,%ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	39 df                	cmp    %ebx,%edi
  8000a3:	7e 1b                	jle    8000c0 <umain+0x8d>
		if (i > 1)
  8000a5:	83 fb 01             	cmp    $0x1,%ebx
  8000a8:	7e d8                	jle    800082 <umain+0x4f>
			write(1, " ", 1);
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	6a 01                	push   $0x1
  8000af:	68 e3 22 80 00       	push   $0x8022e3
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 c3 0a 00 00       	call   800b7e <write>
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	eb c2                	jmp    800082 <umain+0x4f>
	}
	if (!nflag)
  8000c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c4:	74 08                	je     8000ce <umain+0x9b>
		write(1, "\n", 1);
}
  8000c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    
		write(1, "\n", 1);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 01                	push   $0x1
  8000d3:	68 30 24 80 00       	push   $0x802430
  8000d8:	6a 01                	push   $0x1
  8000da:	e8 9f 0a 00 00       	call   800b7e <write>
  8000df:	83 c4 10             	add    $0x10,%esp
}
  8000e2:	eb e2                	jmp    8000c6 <umain+0x93>

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ef:	e8 4c 04 00 00       	call   800540 <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800104:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800109:	85 db                	test   %ebx,%ebx
  80010b:	7e 07                	jle    800114 <libmain+0x30>
		binaryname = argv[0];
  80010d:	8b 06                	mov    (%esi),%eax
  80010f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	e8 15 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011e:	e8 0a 00 00 00       	call   80012d <exit>
}
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800133:	e8 69 08 00 00       	call   8009a1 <close_all>
	sys_env_destroy(0);
  800138:	83 ec 0c             	sub    $0xc,%esp
  80013b:	6a 00                	push   $0x0
  80013d:	e8 bd 03 00 00       	call   8004ff <sys_env_destroy>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80014d:	b8 00 00 00 00       	mov    $0x0,%eax
  800152:	eb 03                	jmp    800157 <strlen+0x10>
		n++;
  800154:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800157:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80015b:	75 f7                	jne    800154 <strlen+0xd>
	return n;
}
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
  80016d:	eb 03                	jmp    800172 <strnlen+0x13>
		n++;
  80016f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800172:	39 d0                	cmp    %edx,%eax
  800174:	74 08                	je     80017e <strnlen+0x1f>
  800176:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80017a:	75 f3                	jne    80016f <strnlen+0x10>
  80017c:	89 c2                	mov    %eax,%edx
	return n;
}
  80017e:	89 d0                	mov    %edx,%eax
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    

00800182 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80018c:	b8 00 00 00 00       	mov    $0x0,%eax
  800191:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800195:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800198:	83 c0 01             	add    $0x1,%eax
  80019b:	84 d2                	test   %dl,%dl
  80019d:	75 f2                	jne    800191 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80019f:	89 c8                	mov    %ecx,%eax
  8001a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 10             	sub    $0x10,%esp
  8001ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001b0:	53                   	push   %ebx
  8001b1:	e8 91 ff ff ff       	call   800147 <strlen>
  8001b6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8001b9:	ff 75 0c             	push   0xc(%ebp)
  8001bc:	01 d8                	add    %ebx,%eax
  8001be:	50                   	push   %eax
  8001bf:	e8 be ff ff ff       	call   800182 <strcpy>
	return dst;
}
  8001c4:	89 d8                	mov    %ebx,%eax
  8001c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d6:	89 f3                	mov    %esi,%ebx
  8001d8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001db:	89 f0                	mov    %esi,%eax
  8001dd:	eb 0f                	jmp    8001ee <strncpy+0x23>
		*dst++ = *src;
  8001df:	83 c0 01             	add    $0x1,%eax
  8001e2:	0f b6 0a             	movzbl (%edx),%ecx
  8001e5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001e8:	80 f9 01             	cmp    $0x1,%cl
  8001eb:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8001ee:	39 d8                	cmp    %ebx,%eax
  8001f0:	75 ed                	jne    8001df <strncpy+0x14>
	}
	return ret;
}
  8001f2:	89 f0                	mov    %esi,%eax
  8001f4:	5b                   	pop    %ebx
  8001f5:	5e                   	pop    %esi
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	8b 75 08             	mov    0x8(%ebp),%esi
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 10             	mov    0x10(%ebp),%edx
  800206:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800208:	85 d2                	test   %edx,%edx
  80020a:	74 21                	je     80022d <strlcpy+0x35>
  80020c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800210:	89 f2                	mov    %esi,%edx
  800212:	eb 09                	jmp    80021d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800214:	83 c1 01             	add    $0x1,%ecx
  800217:	83 c2 01             	add    $0x1,%edx
  80021a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80021d:	39 c2                	cmp    %eax,%edx
  80021f:	74 09                	je     80022a <strlcpy+0x32>
  800221:	0f b6 19             	movzbl (%ecx),%ebx
  800224:	84 db                	test   %bl,%bl
  800226:	75 ec                	jne    800214 <strlcpy+0x1c>
  800228:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80022a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80022d:	29 f0                	sub    %esi,%eax
}
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80023c:	eb 06                	jmp    800244 <strcmp+0x11>
		p++, q++;
  80023e:	83 c1 01             	add    $0x1,%ecx
  800241:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800244:	0f b6 01             	movzbl (%ecx),%eax
  800247:	84 c0                	test   %al,%al
  800249:	74 04                	je     80024f <strcmp+0x1c>
  80024b:	3a 02                	cmp    (%edx),%al
  80024d:	74 ef                	je     80023e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80024f:	0f b6 c0             	movzbl %al,%eax
  800252:	0f b6 12             	movzbl (%edx),%edx
  800255:	29 d0                	sub    %edx,%eax
}
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	53                   	push   %ebx
  80025d:	8b 45 08             	mov    0x8(%ebp),%eax
  800260:	8b 55 0c             	mov    0xc(%ebp),%edx
  800263:	89 c3                	mov    %eax,%ebx
  800265:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800268:	eb 06                	jmp    800270 <strncmp+0x17>
		n--, p++, q++;
  80026a:	83 c0 01             	add    $0x1,%eax
  80026d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800270:	39 d8                	cmp    %ebx,%eax
  800272:	74 18                	je     80028c <strncmp+0x33>
  800274:	0f b6 08             	movzbl (%eax),%ecx
  800277:	84 c9                	test   %cl,%cl
  800279:	74 04                	je     80027f <strncmp+0x26>
  80027b:	3a 0a                	cmp    (%edx),%cl
  80027d:	74 eb                	je     80026a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80027f:	0f b6 00             	movzbl (%eax),%eax
  800282:	0f b6 12             	movzbl (%edx),%edx
  800285:	29 d0                	sub    %edx,%eax
}
  800287:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    
		return 0;
  80028c:	b8 00 00 00 00       	mov    $0x0,%eax
  800291:	eb f4                	jmp    800287 <strncmp+0x2e>

00800293 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80029d:	eb 03                	jmp    8002a2 <strchr+0xf>
  80029f:	83 c0 01             	add    $0x1,%eax
  8002a2:	0f b6 10             	movzbl (%eax),%edx
  8002a5:	84 d2                	test   %dl,%dl
  8002a7:	74 06                	je     8002af <strchr+0x1c>
		if (*s == c)
  8002a9:	38 ca                	cmp    %cl,%dl
  8002ab:	75 f2                	jne    80029f <strchr+0xc>
  8002ad:	eb 05                	jmp    8002b4 <strchr+0x21>
			return (char *) s;
	return 0;
  8002af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002c0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002c3:	38 ca                	cmp    %cl,%dl
  8002c5:	74 09                	je     8002d0 <strfind+0x1a>
  8002c7:	84 d2                	test   %dl,%dl
  8002c9:	74 05                	je     8002d0 <strfind+0x1a>
	for (; *s; s++)
  8002cb:	83 c0 01             	add    $0x1,%eax
  8002ce:	eb f0                	jmp    8002c0 <strfind+0xa>
			break;
	return (char *) s;
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002db:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002de:	85 c9                	test   %ecx,%ecx
  8002e0:	74 2f                	je     800311 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002e2:	89 f8                	mov    %edi,%eax
  8002e4:	09 c8                	or     %ecx,%eax
  8002e6:	a8 03                	test   $0x3,%al
  8002e8:	75 21                	jne    80030b <memset+0x39>
		c &= 0xFF;
  8002ea:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002ee:	89 d0                	mov    %edx,%eax
  8002f0:	c1 e0 08             	shl    $0x8,%eax
  8002f3:	89 d3                	mov    %edx,%ebx
  8002f5:	c1 e3 18             	shl    $0x18,%ebx
  8002f8:	89 d6                	mov    %edx,%esi
  8002fa:	c1 e6 10             	shl    $0x10,%esi
  8002fd:	09 f3                	or     %esi,%ebx
  8002ff:	09 da                	or     %ebx,%edx
  800301:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800303:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800306:	fc                   	cld    
  800307:	f3 ab                	rep stos %eax,%es:(%edi)
  800309:	eb 06                	jmp    800311 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80030b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030e:	fc                   	cld    
  80030f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800311:	89 f8                	mov    %edi,%eax
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	8b 75 0c             	mov    0xc(%ebp),%esi
  800323:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800326:	39 c6                	cmp    %eax,%esi
  800328:	73 32                	jae    80035c <memmove+0x44>
  80032a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80032d:	39 c2                	cmp    %eax,%edx
  80032f:	76 2b                	jbe    80035c <memmove+0x44>
		s += n;
		d += n;
  800331:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800334:	89 d6                	mov    %edx,%esi
  800336:	09 fe                	or     %edi,%esi
  800338:	09 ce                	or     %ecx,%esi
  80033a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800340:	75 0e                	jne    800350 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800342:	83 ef 04             	sub    $0x4,%edi
  800345:	8d 72 fc             	lea    -0x4(%edx),%esi
  800348:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80034b:	fd                   	std    
  80034c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80034e:	eb 09                	jmp    800359 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800350:	83 ef 01             	sub    $0x1,%edi
  800353:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800356:	fd                   	std    
  800357:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800359:	fc                   	cld    
  80035a:	eb 1a                	jmp    800376 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80035c:	89 f2                	mov    %esi,%edx
  80035e:	09 c2                	or     %eax,%edx
  800360:	09 ca                	or     %ecx,%edx
  800362:	f6 c2 03             	test   $0x3,%dl
  800365:	75 0a                	jne    800371 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800367:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80036a:	89 c7                	mov    %eax,%edi
  80036c:	fc                   	cld    
  80036d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80036f:	eb 05                	jmp    800376 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800371:	89 c7                	mov    %eax,%edi
  800373:	fc                   	cld    
  800374:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800380:	ff 75 10             	push   0x10(%ebp)
  800383:	ff 75 0c             	push   0xc(%ebp)
  800386:	ff 75 08             	push   0x8(%ebp)
  800389:	e8 8a ff ff ff       	call   800318 <memmove>
}
  80038e:	c9                   	leave  
  80038f:	c3                   	ret    

00800390 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	8b 55 0c             	mov    0xc(%ebp),%edx
  80039b:	89 c6                	mov    %eax,%esi
  80039d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003a0:	eb 06                	jmp    8003a8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8003a2:	83 c0 01             	add    $0x1,%eax
  8003a5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8003a8:	39 f0                	cmp    %esi,%eax
  8003aa:	74 14                	je     8003c0 <memcmp+0x30>
		if (*s1 != *s2)
  8003ac:	0f b6 08             	movzbl (%eax),%ecx
  8003af:	0f b6 1a             	movzbl (%edx),%ebx
  8003b2:	38 d9                	cmp    %bl,%cl
  8003b4:	74 ec                	je     8003a2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8003b6:	0f b6 c1             	movzbl %cl,%eax
  8003b9:	0f b6 db             	movzbl %bl,%ebx
  8003bc:	29 d8                	sub    %ebx,%eax
  8003be:	eb 05                	jmp    8003c5 <memcmp+0x35>
	}

	return 0;
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003d2:	89 c2                	mov    %eax,%edx
  8003d4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003d7:	eb 03                	jmp    8003dc <memfind+0x13>
  8003d9:	83 c0 01             	add    $0x1,%eax
  8003dc:	39 d0                	cmp    %edx,%eax
  8003de:	73 04                	jae    8003e4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003e0:	38 08                	cmp    %cl,(%eax)
  8003e2:	75 f5                	jne    8003d9 <memfind+0x10>
			break;
	return (void *) s;
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	57                   	push   %edi
  8003ea:	56                   	push   %esi
  8003eb:	53                   	push   %ebx
  8003ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003f2:	eb 03                	jmp    8003f7 <strtol+0x11>
		s++;
  8003f4:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8003f7:	0f b6 02             	movzbl (%edx),%eax
  8003fa:	3c 20                	cmp    $0x20,%al
  8003fc:	74 f6                	je     8003f4 <strtol+0xe>
  8003fe:	3c 09                	cmp    $0x9,%al
  800400:	74 f2                	je     8003f4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800402:	3c 2b                	cmp    $0x2b,%al
  800404:	74 2a                	je     800430 <strtol+0x4a>
	int neg = 0;
  800406:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80040b:	3c 2d                	cmp    $0x2d,%al
  80040d:	74 2b                	je     80043a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80040f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800415:	75 0f                	jne    800426 <strtol+0x40>
  800417:	80 3a 30             	cmpb   $0x30,(%edx)
  80041a:	74 28                	je     800444 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80041c:	85 db                	test   %ebx,%ebx
  80041e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800423:	0f 44 d8             	cmove  %eax,%ebx
  800426:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80042e:	eb 46                	jmp    800476 <strtol+0x90>
		s++;
  800430:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800433:	bf 00 00 00 00       	mov    $0x0,%edi
  800438:	eb d5                	jmp    80040f <strtol+0x29>
		s++, neg = 1;
  80043a:	83 c2 01             	add    $0x1,%edx
  80043d:	bf 01 00 00 00       	mov    $0x1,%edi
  800442:	eb cb                	jmp    80040f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800444:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800448:	74 0e                	je     800458 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80044a:	85 db                	test   %ebx,%ebx
  80044c:	75 d8                	jne    800426 <strtol+0x40>
		s++, base = 8;
  80044e:	83 c2 01             	add    $0x1,%edx
  800451:	bb 08 00 00 00       	mov    $0x8,%ebx
  800456:	eb ce                	jmp    800426 <strtol+0x40>
		s += 2, base = 16;
  800458:	83 c2 02             	add    $0x2,%edx
  80045b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800460:	eb c4                	jmp    800426 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800462:	0f be c0             	movsbl %al,%eax
  800465:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800468:	3b 45 10             	cmp    0x10(%ebp),%eax
  80046b:	7d 3a                	jge    8004a7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80046d:	83 c2 01             	add    $0x1,%edx
  800470:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800474:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800476:	0f b6 02             	movzbl (%edx),%eax
  800479:	8d 70 d0             	lea    -0x30(%eax),%esi
  80047c:	89 f3                	mov    %esi,%ebx
  80047e:	80 fb 09             	cmp    $0x9,%bl
  800481:	76 df                	jbe    800462 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800483:	8d 70 9f             	lea    -0x61(%eax),%esi
  800486:	89 f3                	mov    %esi,%ebx
  800488:	80 fb 19             	cmp    $0x19,%bl
  80048b:	77 08                	ja     800495 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80048d:	0f be c0             	movsbl %al,%eax
  800490:	83 e8 57             	sub    $0x57,%eax
  800493:	eb d3                	jmp    800468 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800495:	8d 70 bf             	lea    -0x41(%eax),%esi
  800498:	89 f3                	mov    %esi,%ebx
  80049a:	80 fb 19             	cmp    $0x19,%bl
  80049d:	77 08                	ja     8004a7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80049f:	0f be c0             	movsbl %al,%eax
  8004a2:	83 e8 37             	sub    $0x37,%eax
  8004a5:	eb c1                	jmp    800468 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8004a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004ab:	74 05                	je     8004b2 <strtol+0xcc>
		*endptr = (char *) s;
  8004ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8004b2:	89 c8                	mov    %ecx,%eax
  8004b4:	f7 d8                	neg    %eax
  8004b6:	85 ff                	test   %edi,%edi
  8004b8:	0f 45 c8             	cmovne %eax,%ecx
}
  8004bb:	89 c8                	mov    %ecx,%eax
  8004bd:	5b                   	pop    %ebx
  8004be:	5e                   	pop    %esi
  8004bf:	5f                   	pop    %edi
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    

008004c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	57                   	push   %edi
  8004c6:	56                   	push   %esi
  8004c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	89 c7                	mov    %eax,%edi
  8004d7:	89 c6                	mov    %eax,%esi
  8004d9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004db:	5b                   	pop    %ebx
  8004dc:	5e                   	pop    %esi
  8004dd:	5f                   	pop    %edi
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8004f0:	89 d1                	mov    %edx,%ecx
  8004f2:	89 d3                	mov    %edx,%ebx
  8004f4:	89 d7                	mov    %edx,%edi
  8004f6:	89 d6                	mov    %edx,%esi
  8004f8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004fa:	5b                   	pop    %ebx
  8004fb:	5e                   	pop    %esi
  8004fc:	5f                   	pop    %edi
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	57                   	push   %edi
  800503:	56                   	push   %esi
  800504:	53                   	push   %ebx
  800505:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800508:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050d:	8b 55 08             	mov    0x8(%ebp),%edx
  800510:	b8 03 00 00 00       	mov    $0x3,%eax
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	89 cf                	mov    %ecx,%edi
  800519:	89 ce                	mov    %ecx,%esi
  80051b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80051d:	85 c0                	test   %eax,%eax
  80051f:	7f 08                	jg     800529 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800521:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800524:	5b                   	pop    %ebx
  800525:	5e                   	pop    %esi
  800526:	5f                   	pop    %edi
  800527:	5d                   	pop    %ebp
  800528:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	50                   	push   %eax
  80052d:	6a 03                	push   $0x3
  80052f:	68 ef 22 80 00       	push   $0x8022ef
  800534:	6a 2a                	push   $0x2a
  800536:	68 0c 23 80 00       	push   $0x80230c
  80053b:	e8 9e 13 00 00       	call   8018de <_panic>

00800540 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	57                   	push   %edi
  800544:	56                   	push   %esi
  800545:	53                   	push   %ebx
	asm volatile("int %1\n"
  800546:	ba 00 00 00 00       	mov    $0x0,%edx
  80054b:	b8 02 00 00 00       	mov    $0x2,%eax
  800550:	89 d1                	mov    %edx,%ecx
  800552:	89 d3                	mov    %edx,%ebx
  800554:	89 d7                	mov    %edx,%edi
  800556:	89 d6                	mov    %edx,%esi
  800558:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80055a:	5b                   	pop    %ebx
  80055b:	5e                   	pop    %esi
  80055c:	5f                   	pop    %edi
  80055d:	5d                   	pop    %ebp
  80055e:	c3                   	ret    

0080055f <sys_yield>:

void
sys_yield(void)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	57                   	push   %edi
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
	asm volatile("int %1\n"
  800565:	ba 00 00 00 00       	mov    $0x0,%edx
  80056a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056f:	89 d1                	mov    %edx,%ecx
  800571:	89 d3                	mov    %edx,%ebx
  800573:	89 d7                	mov    %edx,%edi
  800575:	89 d6                	mov    %edx,%esi
  800577:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800579:	5b                   	pop    %ebx
  80057a:	5e                   	pop    %esi
  80057b:	5f                   	pop    %edi
  80057c:	5d                   	pop    %ebp
  80057d:	c3                   	ret    

0080057e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	57                   	push   %edi
  800582:	56                   	push   %esi
  800583:	53                   	push   %ebx
  800584:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800587:	be 00 00 00 00       	mov    $0x0,%esi
  80058c:	8b 55 08             	mov    0x8(%ebp),%edx
  80058f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800592:	b8 04 00 00 00       	mov    $0x4,%eax
  800597:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059a:	89 f7                	mov    %esi,%edi
  80059c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	7f 08                	jg     8005aa <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005a5:	5b                   	pop    %ebx
  8005a6:	5e                   	pop    %esi
  8005a7:	5f                   	pop    %edi
  8005a8:	5d                   	pop    %ebp
  8005a9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	50                   	push   %eax
  8005ae:	6a 04                	push   $0x4
  8005b0:	68 ef 22 80 00       	push   $0x8022ef
  8005b5:	6a 2a                	push   $0x2a
  8005b7:	68 0c 23 80 00       	push   $0x80230c
  8005bc:	e8 1d 13 00 00       	call   8018de <_panic>

008005c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005c1:	55                   	push   %ebp
  8005c2:	89 e5                	mov    %esp,%ebp
  8005c4:	57                   	push   %edi
  8005c5:	56                   	push   %esi
  8005c6:	53                   	push   %ebx
  8005c7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8005ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8005cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8005d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005db:	8b 75 18             	mov    0x18(%ebp),%esi
  8005de:	cd 30                	int    $0x30
	if(check && ret > 0)
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	7f 08                	jg     8005ec <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e7:	5b                   	pop    %ebx
  8005e8:	5e                   	pop    %esi
  8005e9:	5f                   	pop    %edi
  8005ea:	5d                   	pop    %ebp
  8005eb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	50                   	push   %eax
  8005f0:	6a 05                	push   $0x5
  8005f2:	68 ef 22 80 00       	push   $0x8022ef
  8005f7:	6a 2a                	push   $0x2a
  8005f9:	68 0c 23 80 00       	push   $0x80230c
  8005fe:	e8 db 12 00 00       	call   8018de <_panic>

00800603 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800603:	55                   	push   %ebp
  800604:	89 e5                	mov    %esp,%ebp
  800606:	57                   	push   %edi
  800607:	56                   	push   %esi
  800608:	53                   	push   %ebx
  800609:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80060c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800611:	8b 55 08             	mov    0x8(%ebp),%edx
  800614:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800617:	b8 06 00 00 00       	mov    $0x6,%eax
  80061c:	89 df                	mov    %ebx,%edi
  80061e:	89 de                	mov    %ebx,%esi
  800620:	cd 30                	int    $0x30
	if(check && ret > 0)
  800622:	85 c0                	test   %eax,%eax
  800624:	7f 08                	jg     80062e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800626:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800629:	5b                   	pop    %ebx
  80062a:	5e                   	pop    %esi
  80062b:	5f                   	pop    %edi
  80062c:	5d                   	pop    %ebp
  80062d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	50                   	push   %eax
  800632:	6a 06                	push   $0x6
  800634:	68 ef 22 80 00       	push   $0x8022ef
  800639:	6a 2a                	push   $0x2a
  80063b:	68 0c 23 80 00       	push   $0x80230c
  800640:	e8 99 12 00 00       	call   8018de <_panic>

00800645 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800645:	55                   	push   %ebp
  800646:	89 e5                	mov    %esp,%ebp
  800648:	57                   	push   %edi
  800649:	56                   	push   %esi
  80064a:	53                   	push   %ebx
  80064b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80064e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800653:	8b 55 08             	mov    0x8(%ebp),%edx
  800656:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800659:	b8 08 00 00 00       	mov    $0x8,%eax
  80065e:	89 df                	mov    %ebx,%edi
  800660:	89 de                	mov    %ebx,%esi
  800662:	cd 30                	int    $0x30
	if(check && ret > 0)
  800664:	85 c0                	test   %eax,%eax
  800666:	7f 08                	jg     800670 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800670:	83 ec 0c             	sub    $0xc,%esp
  800673:	50                   	push   %eax
  800674:	6a 08                	push   $0x8
  800676:	68 ef 22 80 00       	push   $0x8022ef
  80067b:	6a 2a                	push   $0x2a
  80067d:	68 0c 23 80 00       	push   $0x80230c
  800682:	e8 57 12 00 00       	call   8018de <_panic>

00800687 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	57                   	push   %edi
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800690:	bb 00 00 00 00       	mov    $0x0,%ebx
  800695:	8b 55 08             	mov    0x8(%ebp),%edx
  800698:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069b:	b8 09 00 00 00       	mov    $0x9,%eax
  8006a0:	89 df                	mov    %ebx,%edi
  8006a2:	89 de                	mov    %ebx,%esi
  8006a4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	7f 08                	jg     8006b2 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ad:	5b                   	pop    %ebx
  8006ae:	5e                   	pop    %esi
  8006af:	5f                   	pop    %edi
  8006b0:	5d                   	pop    %ebp
  8006b1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006b2:	83 ec 0c             	sub    $0xc,%esp
  8006b5:	50                   	push   %eax
  8006b6:	6a 09                	push   $0x9
  8006b8:	68 ef 22 80 00       	push   $0x8022ef
  8006bd:	6a 2a                	push   $0x2a
  8006bf:	68 0c 23 80 00       	push   $0x80230c
  8006c4:	e8 15 12 00 00       	call   8018de <_panic>

008006c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	57                   	push   %edi
  8006cd:	56                   	push   %esi
  8006ce:	53                   	push   %ebx
  8006cf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8006d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	89 df                	mov    %ebx,%edi
  8006e4:	89 de                	mov    %ebx,%esi
  8006e6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	7f 08                	jg     8006f4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ef:	5b                   	pop    %ebx
  8006f0:	5e                   	pop    %esi
  8006f1:	5f                   	pop    %edi
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f4:	83 ec 0c             	sub    $0xc,%esp
  8006f7:	50                   	push   %eax
  8006f8:	6a 0a                	push   $0xa
  8006fa:	68 ef 22 80 00       	push   $0x8022ef
  8006ff:	6a 2a                	push   $0x2a
  800701:	68 0c 23 80 00       	push   $0x80230c
  800706:	e8 d3 11 00 00       	call   8018de <_panic>

0080070b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	57                   	push   %edi
  80070f:	56                   	push   %esi
  800710:	53                   	push   %ebx
	asm volatile("int %1\n"
  800711:	8b 55 08             	mov    0x8(%ebp),%edx
  800714:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800717:	b8 0c 00 00 00       	mov    $0xc,%eax
  80071c:	be 00 00 00 00       	mov    $0x0,%esi
  800721:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800724:	8b 7d 14             	mov    0x14(%ebp),%edi
  800727:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800729:	5b                   	pop    %ebx
  80072a:	5e                   	pop    %esi
  80072b:	5f                   	pop    %edi
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	57                   	push   %edi
  800732:	56                   	push   %esi
  800733:	53                   	push   %ebx
  800734:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8b 55 08             	mov    0x8(%ebp),%edx
  80073f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800744:	89 cb                	mov    %ecx,%ebx
  800746:	89 cf                	mov    %ecx,%edi
  800748:	89 ce                	mov    %ecx,%esi
  80074a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	7f 08                	jg     800758 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800750:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800753:	5b                   	pop    %ebx
  800754:	5e                   	pop    %esi
  800755:	5f                   	pop    %edi
  800756:	5d                   	pop    %ebp
  800757:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800758:	83 ec 0c             	sub    $0xc,%esp
  80075b:	50                   	push   %eax
  80075c:	6a 0d                	push   $0xd
  80075e:	68 ef 22 80 00       	push   $0x8022ef
  800763:	6a 2a                	push   $0x2a
  800765:	68 0c 23 80 00       	push   $0x80230c
  80076a:	e8 6f 11 00 00       	call   8018de <_panic>

0080076f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	57                   	push   %edi
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
	asm volatile("int %1\n"
  800775:	ba 00 00 00 00       	mov    $0x0,%edx
  80077a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80077f:	89 d1                	mov    %edx,%ecx
  800781:	89 d3                	mov    %edx,%ebx
  800783:	89 d7                	mov    %edx,%edi
  800785:	89 d6                	mov    %edx,%esi
  800787:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800789:	5b                   	pop    %ebx
  80078a:	5e                   	pop    %esi
  80078b:	5f                   	pop    %edi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	57                   	push   %edi
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
	asm volatile("int %1\n"
  800794:	bb 00 00 00 00       	mov    $0x0,%ebx
  800799:	8b 55 08             	mov    0x8(%ebp),%edx
  80079c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079f:	b8 0f 00 00 00       	mov    $0xf,%eax
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	89 de                	mov    %ebx,%esi
  8007a8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	57                   	push   %edi
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8007b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c5:	89 df                	mov    %ebx,%edi
  8007c7:	89 de                	mov    %ebx,%esi
  8007c9:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5f                   	pop    %edi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8007db:	c1 e8 0c             	shr    $0xc,%eax
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8007eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007f0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	c1 ea 16             	shr    $0x16,%edx
  800804:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80080b:	f6 c2 01             	test   $0x1,%dl
  80080e:	74 29                	je     800839 <fd_alloc+0x42>
  800810:	89 c2                	mov    %eax,%edx
  800812:	c1 ea 0c             	shr    $0xc,%edx
  800815:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80081c:	f6 c2 01             	test   $0x1,%dl
  80081f:	74 18                	je     800839 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800821:	05 00 10 00 00       	add    $0x1000,%eax
  800826:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80082b:	75 d2                	jne    8007ff <fd_alloc+0x8>
  80082d:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800832:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800837:	eb 05                	jmp    80083e <fd_alloc+0x47>
			return 0;
  800839:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80083e:	8b 55 08             	mov    0x8(%ebp),%edx
  800841:	89 02                	mov    %eax,(%edx)
}
  800843:	89 c8                	mov    %ecx,%eax
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80084d:	83 f8 1f             	cmp    $0x1f,%eax
  800850:	77 30                	ja     800882 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800852:	c1 e0 0c             	shl    $0xc,%eax
  800855:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80085a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800860:	f6 c2 01             	test   $0x1,%dl
  800863:	74 24                	je     800889 <fd_lookup+0x42>
  800865:	89 c2                	mov    %eax,%edx
  800867:	c1 ea 0c             	shr    $0xc,%edx
  80086a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800871:	f6 c2 01             	test   $0x1,%dl
  800874:	74 1a                	je     800890 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800876:	8b 55 0c             	mov    0xc(%ebp),%edx
  800879:	89 02                	mov    %eax,(%edx)
	return 0;
  80087b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    
		return -E_INVAL;
  800882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800887:	eb f7                	jmp    800880 <fd_lookup+0x39>
		return -E_INVAL;
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb f0                	jmp    800880 <fd_lookup+0x39>
  800890:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800895:	eb e9                	jmp    800880 <fd_lookup+0x39>

00800897 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	53                   	push   %ebx
  80089b:	83 ec 04             	sub    $0x4,%esp
  80089e:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8008ab:	39 13                	cmp    %edx,(%ebx)
  8008ad:	74 37                	je     8008e6 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	8b 1c 85 98 23 80 00 	mov    0x802398(,%eax,4),%ebx
  8008b9:	85 db                	test   %ebx,%ebx
  8008bb:	75 ee                	jne    8008ab <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008bd:	a1 00 40 80 00       	mov    0x804000,%eax
  8008c2:	8b 40 58             	mov    0x58(%eax),%eax
  8008c5:	83 ec 04             	sub    $0x4,%esp
  8008c8:	52                   	push   %edx
  8008c9:	50                   	push   %eax
  8008ca:	68 1c 23 80 00       	push   $0x80231c
  8008cf:	e8 e5 10 00 00       	call   8019b9 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	89 1a                	mov    %ebx,(%edx)
}
  8008e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    
			return 0;
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb ef                	jmp    8008dc <dev_lookup+0x45>

008008ed <fd_close>:
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	57                   	push   %edi
  8008f1:	56                   	push   %esi
  8008f2:	53                   	push   %ebx
  8008f3:	83 ec 24             	sub    $0x24,%esp
  8008f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008ff:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800900:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800906:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800909:	50                   	push   %eax
  80090a:	e8 38 ff ff ff       	call   800847 <fd_lookup>
  80090f:	89 c3                	mov    %eax,%ebx
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	85 c0                	test   %eax,%eax
  800916:	78 05                	js     80091d <fd_close+0x30>
	    || fd != fd2)
  800918:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80091b:	74 16                	je     800933 <fd_close+0x46>
		return (must_exist ? r : 0);
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	84 c0                	test   %al,%al
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
  800926:	0f 44 d8             	cmove  %eax,%ebx
}
  800929:	89 d8                	mov    %ebx,%eax
  80092b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5f                   	pop    %edi
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800939:	50                   	push   %eax
  80093a:	ff 36                	push   (%esi)
  80093c:	e8 56 ff ff ff       	call   800897 <dev_lookup>
  800941:	89 c3                	mov    %eax,%ebx
  800943:	83 c4 10             	add    $0x10,%esp
  800946:	85 c0                	test   %eax,%eax
  800948:	78 1a                	js     800964 <fd_close+0x77>
		if (dev->dev_close)
  80094a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80094d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800950:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800955:	85 c0                	test   %eax,%eax
  800957:	74 0b                	je     800964 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800959:	83 ec 0c             	sub    $0xc,%esp
  80095c:	56                   	push   %esi
  80095d:	ff d0                	call   *%eax
  80095f:	89 c3                	mov    %eax,%ebx
  800961:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800964:	83 ec 08             	sub    $0x8,%esp
  800967:	56                   	push   %esi
  800968:	6a 00                	push   $0x0
  80096a:	e8 94 fc ff ff       	call   800603 <sys_page_unmap>
	return r;
  80096f:	83 c4 10             	add    $0x10,%esp
  800972:	eb b5                	jmp    800929 <fd_close+0x3c>

00800974 <close>:

int
close(int fdnum)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80097a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80097d:	50                   	push   %eax
  80097e:	ff 75 08             	push   0x8(%ebp)
  800981:	e8 c1 fe ff ff       	call   800847 <fd_lookup>
  800986:	83 c4 10             	add    $0x10,%esp
  800989:	85 c0                	test   %eax,%eax
  80098b:	79 02                	jns    80098f <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80098d:	c9                   	leave  
  80098e:	c3                   	ret    
		return fd_close(fd, 1);
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	6a 01                	push   $0x1
  800994:	ff 75 f4             	push   -0xc(%ebp)
  800997:	e8 51 ff ff ff       	call   8008ed <fd_close>
  80099c:	83 c4 10             	add    $0x10,%esp
  80099f:	eb ec                	jmp    80098d <close+0x19>

008009a1 <close_all>:

void
close_all(void)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009a8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009ad:	83 ec 0c             	sub    $0xc,%esp
  8009b0:	53                   	push   %ebx
  8009b1:	e8 be ff ff ff       	call   800974 <close>
	for (i = 0; i < MAXFD; i++)
  8009b6:	83 c3 01             	add    $0x1,%ebx
  8009b9:	83 c4 10             	add    $0x10,%esp
  8009bc:	83 fb 20             	cmp    $0x20,%ebx
  8009bf:	75 ec                	jne    8009ad <close_all+0xc>
}
  8009c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c4:	c9                   	leave  
  8009c5:	c3                   	ret    

008009c6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009d2:	50                   	push   %eax
  8009d3:	ff 75 08             	push   0x8(%ebp)
  8009d6:	e8 6c fe ff ff       	call   800847 <fd_lookup>
  8009db:	89 c3                	mov    %eax,%ebx
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	85 c0                	test   %eax,%eax
  8009e2:	78 7f                	js     800a63 <dup+0x9d>
		return r;
	close(newfdnum);
  8009e4:	83 ec 0c             	sub    $0xc,%esp
  8009e7:	ff 75 0c             	push   0xc(%ebp)
  8009ea:	e8 85 ff ff ff       	call   800974 <close>

	newfd = INDEX2FD(newfdnum);
  8009ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f2:	c1 e6 0c             	shl    $0xc,%esi
  8009f5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8009fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009fe:	89 3c 24             	mov    %edi,(%esp)
  800a01:	e8 da fd ff ff       	call   8007e0 <fd2data>
  800a06:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a08:	89 34 24             	mov    %esi,(%esp)
  800a0b:	e8 d0 fd ff ff       	call   8007e0 <fd2data>
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a16:	89 d8                	mov    %ebx,%eax
  800a18:	c1 e8 16             	shr    $0x16,%eax
  800a1b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a22:	a8 01                	test   $0x1,%al
  800a24:	74 11                	je     800a37 <dup+0x71>
  800a26:	89 d8                	mov    %ebx,%eax
  800a28:	c1 e8 0c             	shr    $0xc,%eax
  800a2b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a32:	f6 c2 01             	test   $0x1,%dl
  800a35:	75 36                	jne    800a6d <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a37:	89 f8                	mov    %edi,%eax
  800a39:	c1 e8 0c             	shr    $0xc,%eax
  800a3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a43:	83 ec 0c             	sub    $0xc,%esp
  800a46:	25 07 0e 00 00       	and    $0xe07,%eax
  800a4b:	50                   	push   %eax
  800a4c:	56                   	push   %esi
  800a4d:	6a 00                	push   $0x0
  800a4f:	57                   	push   %edi
  800a50:	6a 00                	push   $0x0
  800a52:	e8 6a fb ff ff       	call   8005c1 <sys_page_map>
  800a57:	89 c3                	mov    %eax,%ebx
  800a59:	83 c4 20             	add    $0x20,%esp
  800a5c:	85 c0                	test   %eax,%eax
  800a5e:	78 33                	js     800a93 <dup+0xcd>
		goto err;

	return newfdnum;
  800a60:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a63:	89 d8                	mov    %ebx,%eax
  800a65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a74:	83 ec 0c             	sub    $0xc,%esp
  800a77:	25 07 0e 00 00       	and    $0xe07,%eax
  800a7c:	50                   	push   %eax
  800a7d:	ff 75 d4             	push   -0x2c(%ebp)
  800a80:	6a 00                	push   $0x0
  800a82:	53                   	push   %ebx
  800a83:	6a 00                	push   $0x0
  800a85:	e8 37 fb ff ff       	call   8005c1 <sys_page_map>
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	83 c4 20             	add    $0x20,%esp
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	79 a4                	jns    800a37 <dup+0x71>
	sys_page_unmap(0, newfd);
  800a93:	83 ec 08             	sub    $0x8,%esp
  800a96:	56                   	push   %esi
  800a97:	6a 00                	push   $0x0
  800a99:	e8 65 fb ff ff       	call   800603 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a9e:	83 c4 08             	add    $0x8,%esp
  800aa1:	ff 75 d4             	push   -0x2c(%ebp)
  800aa4:	6a 00                	push   $0x0
  800aa6:	e8 58 fb ff ff       	call   800603 <sys_page_unmap>
	return r;
  800aab:	83 c4 10             	add    $0x10,%esp
  800aae:	eb b3                	jmp    800a63 <dup+0x9d>

00800ab0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	83 ec 18             	sub    $0x18,%esp
  800ab8:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800abb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800abe:	50                   	push   %eax
  800abf:	56                   	push   %esi
  800ac0:	e8 82 fd ff ff       	call   800847 <fd_lookup>
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	78 3c                	js     800b08 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800acc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800acf:	83 ec 08             	sub    $0x8,%esp
  800ad2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad5:	50                   	push   %eax
  800ad6:	ff 33                	push   (%ebx)
  800ad8:	e8 ba fd ff ff       	call   800897 <dev_lookup>
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	78 24                	js     800b08 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ae4:	8b 43 08             	mov    0x8(%ebx),%eax
  800ae7:	83 e0 03             	and    $0x3,%eax
  800aea:	83 f8 01             	cmp    $0x1,%eax
  800aed:	74 20                	je     800b0f <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af2:	8b 40 08             	mov    0x8(%eax),%eax
  800af5:	85 c0                	test   %eax,%eax
  800af7:	74 37                	je     800b30 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800af9:	83 ec 04             	sub    $0x4,%esp
  800afc:	ff 75 10             	push   0x10(%ebp)
  800aff:	ff 75 0c             	push   0xc(%ebp)
  800b02:	53                   	push   %ebx
  800b03:	ff d0                	call   *%eax
  800b05:	83 c4 10             	add    $0x10,%esp
}
  800b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b0f:	a1 00 40 80 00       	mov    0x804000,%eax
  800b14:	8b 40 58             	mov    0x58(%eax),%eax
  800b17:	83 ec 04             	sub    $0x4,%esp
  800b1a:	56                   	push   %esi
  800b1b:	50                   	push   %eax
  800b1c:	68 5d 23 80 00       	push   $0x80235d
  800b21:	e8 93 0e 00 00       	call   8019b9 <cprintf>
		return -E_INVAL;
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b2e:	eb d8                	jmp    800b08 <read+0x58>
		return -E_NOT_SUPP;
  800b30:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b35:	eb d1                	jmp    800b08 <read+0x58>

00800b37 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b43:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b4b:	eb 02                	jmp    800b4f <readn+0x18>
  800b4d:	01 c3                	add    %eax,%ebx
  800b4f:	39 f3                	cmp    %esi,%ebx
  800b51:	73 21                	jae    800b74 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b53:	83 ec 04             	sub    $0x4,%esp
  800b56:	89 f0                	mov    %esi,%eax
  800b58:	29 d8                	sub    %ebx,%eax
  800b5a:	50                   	push   %eax
  800b5b:	89 d8                	mov    %ebx,%eax
  800b5d:	03 45 0c             	add    0xc(%ebp),%eax
  800b60:	50                   	push   %eax
  800b61:	57                   	push   %edi
  800b62:	e8 49 ff ff ff       	call   800ab0 <read>
		if (m < 0)
  800b67:	83 c4 10             	add    $0x10,%esp
  800b6a:	85 c0                	test   %eax,%eax
  800b6c:	78 04                	js     800b72 <readn+0x3b>
			return m;
		if (m == 0)
  800b6e:	75 dd                	jne    800b4d <readn+0x16>
  800b70:	eb 02                	jmp    800b74 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b72:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800b74:	89 d8                	mov    %ebx,%eax
  800b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 18             	sub    $0x18,%esp
  800b86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b8c:	50                   	push   %eax
  800b8d:	53                   	push   %ebx
  800b8e:	e8 b4 fc ff ff       	call   800847 <fd_lookup>
  800b93:	83 c4 10             	add    $0x10,%esp
  800b96:	85 c0                	test   %eax,%eax
  800b98:	78 37                	js     800bd1 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b9a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800b9d:	83 ec 08             	sub    $0x8,%esp
  800ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba3:	50                   	push   %eax
  800ba4:	ff 36                	push   (%esi)
  800ba6:	e8 ec fc ff ff       	call   800897 <dev_lookup>
  800bab:	83 c4 10             	add    $0x10,%esp
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	78 1f                	js     800bd1 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bb2:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800bb6:	74 20                	je     800bd8 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bbb:	8b 40 0c             	mov    0xc(%eax),%eax
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	74 37                	je     800bf9 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800bc2:	83 ec 04             	sub    $0x4,%esp
  800bc5:	ff 75 10             	push   0x10(%ebp)
  800bc8:	ff 75 0c             	push   0xc(%ebp)
  800bcb:	56                   	push   %esi
  800bcc:	ff d0                	call   *%eax
  800bce:	83 c4 10             	add    $0x10,%esp
}
  800bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800bd8:	a1 00 40 80 00       	mov    0x804000,%eax
  800bdd:	8b 40 58             	mov    0x58(%eax),%eax
  800be0:	83 ec 04             	sub    $0x4,%esp
  800be3:	53                   	push   %ebx
  800be4:	50                   	push   %eax
  800be5:	68 79 23 80 00       	push   $0x802379
  800bea:	e8 ca 0d 00 00       	call   8019b9 <cprintf>
		return -E_INVAL;
  800bef:	83 c4 10             	add    $0x10,%esp
  800bf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf7:	eb d8                	jmp    800bd1 <write+0x53>
		return -E_NOT_SUPP;
  800bf9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bfe:	eb d1                	jmp    800bd1 <write+0x53>

00800c00 <seek>:

int
seek(int fdnum, off_t offset)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c09:	50                   	push   %eax
  800c0a:	ff 75 08             	push   0x8(%ebp)
  800c0d:	e8 35 fc ff ff       	call   800847 <fd_lookup>
  800c12:	83 c4 10             	add    $0x10,%esp
  800c15:	85 c0                	test   %eax,%eax
  800c17:	78 0e                	js     800c27 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 18             	sub    $0x18,%esp
  800c31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c37:	50                   	push   %eax
  800c38:	53                   	push   %ebx
  800c39:	e8 09 fc ff ff       	call   800847 <fd_lookup>
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	85 c0                	test   %eax,%eax
  800c43:	78 34                	js     800c79 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c45:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c48:	83 ec 08             	sub    $0x8,%esp
  800c4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c4e:	50                   	push   %eax
  800c4f:	ff 36                	push   (%esi)
  800c51:	e8 41 fc ff ff       	call   800897 <dev_lookup>
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	78 1c                	js     800c79 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c5d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800c61:	74 1d                	je     800c80 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c66:	8b 40 18             	mov    0x18(%eax),%eax
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	74 34                	je     800ca1 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c6d:	83 ec 08             	sub    $0x8,%esp
  800c70:	ff 75 0c             	push   0xc(%ebp)
  800c73:	56                   	push   %esi
  800c74:	ff d0                	call   *%eax
  800c76:	83 c4 10             	add    $0x10,%esp
}
  800c79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    
			thisenv->env_id, fdnum);
  800c80:	a1 00 40 80 00       	mov    0x804000,%eax
  800c85:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c88:	83 ec 04             	sub    $0x4,%esp
  800c8b:	53                   	push   %ebx
  800c8c:	50                   	push   %eax
  800c8d:	68 3c 23 80 00       	push   $0x80233c
  800c92:	e8 22 0d 00 00       	call   8019b9 <cprintf>
		return -E_INVAL;
  800c97:	83 c4 10             	add    $0x10,%esp
  800c9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c9f:	eb d8                	jmp    800c79 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800ca1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800ca6:	eb d1                	jmp    800c79 <ftruncate+0x50>

00800ca8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
  800cad:	83 ec 18             	sub    $0x18,%esp
  800cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb6:	50                   	push   %eax
  800cb7:	ff 75 08             	push   0x8(%ebp)
  800cba:	e8 88 fb ff ff       	call   800847 <fd_lookup>
  800cbf:	83 c4 10             	add    $0x10,%esp
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	78 49                	js     800d0f <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800cc9:	83 ec 08             	sub    $0x8,%esp
  800ccc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ccf:	50                   	push   %eax
  800cd0:	ff 36                	push   (%esi)
  800cd2:	e8 c0 fb ff ff       	call   800897 <dev_lookup>
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	78 31                	js     800d0f <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ce5:	74 2f                	je     800d16 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ce7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cf1:	00 00 00 
	stat->st_isdir = 0;
  800cf4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cfb:	00 00 00 
	stat->st_dev = dev;
  800cfe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d04:	83 ec 08             	sub    $0x8,%esp
  800d07:	53                   	push   %ebx
  800d08:	56                   	push   %esi
  800d09:	ff 50 14             	call   *0x14(%eax)
  800d0c:	83 c4 10             	add    $0x10,%esp
}
  800d0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    
		return -E_NOT_SUPP;
  800d16:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800d1b:	eb f2                	jmp    800d0f <fstat+0x67>

00800d1d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d22:	83 ec 08             	sub    $0x8,%esp
  800d25:	6a 00                	push   $0x0
  800d27:	ff 75 08             	push   0x8(%ebp)
  800d2a:	e8 e4 01 00 00       	call   800f13 <open>
  800d2f:	89 c3                	mov    %eax,%ebx
  800d31:	83 c4 10             	add    $0x10,%esp
  800d34:	85 c0                	test   %eax,%eax
  800d36:	78 1b                	js     800d53 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d38:	83 ec 08             	sub    $0x8,%esp
  800d3b:	ff 75 0c             	push   0xc(%ebp)
  800d3e:	50                   	push   %eax
  800d3f:	e8 64 ff ff ff       	call   800ca8 <fstat>
  800d44:	89 c6                	mov    %eax,%esi
	close(fd);
  800d46:	89 1c 24             	mov    %ebx,(%esp)
  800d49:	e8 26 fc ff ff       	call   800974 <close>
	return r;
  800d4e:	83 c4 10             	add    $0x10,%esp
  800d51:	89 f3                	mov    %esi,%ebx
}
  800d53:	89 d8                	mov    %ebx,%eax
  800d55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    

00800d5c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	89 c6                	mov    %eax,%esi
  800d63:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d65:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800d6c:	74 27                	je     800d95 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d6e:	6a 07                	push   $0x7
  800d70:	68 00 50 80 00       	push   $0x805000
  800d75:	56                   	push   %esi
  800d76:	ff 35 00 60 80 00    	push   0x806000
  800d7c:	e8 47 12 00 00       	call   801fc8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d81:	83 c4 0c             	add    $0xc,%esp
  800d84:	6a 00                	push   $0x0
  800d86:	53                   	push   %ebx
  800d87:	6a 00                	push   $0x0
  800d89:	e8 ca 11 00 00       	call   801f58 <ipc_recv>
}
  800d8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	6a 01                	push   $0x1
  800d9a:	e8 7d 12 00 00       	call   80201c <ipc_find_env>
  800d9f:	a3 00 60 80 00       	mov    %eax,0x806000
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	eb c5                	jmp    800d6e <fsipc+0x12>

00800da9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	8b 40 0c             	mov    0xc(%eax),%eax
  800db5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc7:	b8 02 00 00 00       	mov    $0x2,%eax
  800dcc:	e8 8b ff ff ff       	call   800d5c <fsipc>
}
  800dd1:	c9                   	leave  
  800dd2:	c3                   	ret    

00800dd3 <devfile_flush>:
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	8b 40 0c             	mov    0xc(%eax),%eax
  800ddf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800de4:	ba 00 00 00 00       	mov    $0x0,%edx
  800de9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dee:	e8 69 ff ff ff       	call   800d5c <fsipc>
}
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <devfile_stat>:
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	53                   	push   %ebx
  800df9:	83 ec 04             	sub    $0x4,%esp
  800dfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	8b 40 0c             	mov    0xc(%eax),%eax
  800e05:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e14:	e8 43 ff ff ff       	call   800d5c <fsipc>
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	78 2c                	js     800e49 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e1d:	83 ec 08             	sub    $0x8,%esp
  800e20:	68 00 50 80 00       	push   $0x805000
  800e25:	53                   	push   %ebx
  800e26:	e8 57 f3 ff ff       	call   800182 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e2b:	a1 80 50 80 00       	mov    0x805080,%eax
  800e30:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e36:	a1 84 50 80 00       	mov    0x805084,%eax
  800e3b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <devfile_write>:
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	83 ec 0c             	sub    $0xc,%esp
  800e54:	8b 45 10             	mov    0x10(%ebp),%eax
  800e57:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800e5c:	39 d0                	cmp    %edx,%eax
  800e5e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	8b 52 0c             	mov    0xc(%edx),%edx
  800e67:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800e6d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800e72:	50                   	push   %eax
  800e73:	ff 75 0c             	push   0xc(%ebp)
  800e76:	68 08 50 80 00       	push   $0x805008
  800e7b:	e8 98 f4 ff ff       	call   800318 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800e80:	ba 00 00 00 00       	mov    $0x0,%edx
  800e85:	b8 04 00 00 00       	mov    $0x4,%eax
  800e8a:	e8 cd fe ff ff       	call   800d5c <fsipc>
}
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <devfile_read>:
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	8b 40 0c             	mov    0xc(%eax),%eax
  800e9f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ea4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800eaa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eaf:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb4:	e8 a3 fe ff ff       	call   800d5c <fsipc>
  800eb9:	89 c3                	mov    %eax,%ebx
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 1f                	js     800ede <devfile_read+0x4d>
	assert(r <= n);
  800ebf:	39 f0                	cmp    %esi,%eax
  800ec1:	77 24                	ja     800ee7 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800ec3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ec8:	7f 33                	jg     800efd <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	50                   	push   %eax
  800ece:	68 00 50 80 00       	push   $0x805000
  800ed3:	ff 75 0c             	push   0xc(%ebp)
  800ed6:	e8 3d f4 ff ff       	call   800318 <memmove>
	return r;
  800edb:	83 c4 10             	add    $0x10,%esp
}
  800ede:	89 d8                	mov    %ebx,%eax
  800ee0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5d                   	pop    %ebp
  800ee6:	c3                   	ret    
	assert(r <= n);
  800ee7:	68 ac 23 80 00       	push   $0x8023ac
  800eec:	68 b3 23 80 00       	push   $0x8023b3
  800ef1:	6a 7c                	push   $0x7c
  800ef3:	68 c8 23 80 00       	push   $0x8023c8
  800ef8:	e8 e1 09 00 00       	call   8018de <_panic>
	assert(r <= PGSIZE);
  800efd:	68 d3 23 80 00       	push   $0x8023d3
  800f02:	68 b3 23 80 00       	push   $0x8023b3
  800f07:	6a 7d                	push   $0x7d
  800f09:	68 c8 23 80 00       	push   $0x8023c8
  800f0e:	e8 cb 09 00 00       	call   8018de <_panic>

00800f13 <open>:
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
  800f1b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800f1e:	56                   	push   %esi
  800f1f:	e8 23 f2 ff ff       	call   800147 <strlen>
  800f24:	83 c4 10             	add    $0x10,%esp
  800f27:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f2c:	7f 6c                	jg     800f9a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f34:	50                   	push   %eax
  800f35:	e8 bd f8 ff ff       	call   8007f7 <fd_alloc>
  800f3a:	89 c3                	mov    %eax,%ebx
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 3c                	js     800f7f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800f43:	83 ec 08             	sub    $0x8,%esp
  800f46:	56                   	push   %esi
  800f47:	68 00 50 80 00       	push   $0x805000
  800f4c:	e8 31 f2 ff ff       	call   800182 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f54:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	e8 f6 fd ff ff       	call   800d5c <fsipc>
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 19                	js     800f88 <open+0x75>
	return fd2num(fd);
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	ff 75 f4             	push   -0xc(%ebp)
  800f75:	e8 56 f8 ff ff       	call   8007d0 <fd2num>
  800f7a:	89 c3                	mov    %eax,%ebx
  800f7c:	83 c4 10             	add    $0x10,%esp
}
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    
		fd_close(fd, 0);
  800f88:	83 ec 08             	sub    $0x8,%esp
  800f8b:	6a 00                	push   $0x0
  800f8d:	ff 75 f4             	push   -0xc(%ebp)
  800f90:	e8 58 f9 ff ff       	call   8008ed <fd_close>
		return r;
  800f95:	83 c4 10             	add    $0x10,%esp
  800f98:	eb e5                	jmp    800f7f <open+0x6c>
		return -E_BAD_PATH;
  800f9a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f9f:	eb de                	jmp    800f7f <open+0x6c>

00800fa1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800fa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fac:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb1:	e8 a6 fd ff ff       	call   800d5c <fsipc>
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800fbe:	68 df 23 80 00       	push   $0x8023df
  800fc3:	ff 75 0c             	push   0xc(%ebp)
  800fc6:	e8 b7 f1 ff ff       	call   800182 <strcpy>
	return 0;
}
  800fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <devsock_close>:
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 10             	sub    $0x10,%esp
  800fd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800fdc:	53                   	push   %ebx
  800fdd:	e8 79 10 00 00       	call   80205b <pageref>
  800fe2:	89 c2                	mov    %eax,%edx
  800fe4:	83 c4 10             	add    $0x10,%esp
		return 0;
  800fe7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800fec:	83 fa 01             	cmp    $0x1,%edx
  800fef:	74 05                	je     800ff6 <devsock_close+0x24>
}
  800ff1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800ff6:	83 ec 0c             	sub    $0xc,%esp
  800ff9:	ff 73 0c             	push   0xc(%ebx)
  800ffc:	e8 b7 02 00 00       	call   8012b8 <nsipc_close>
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	eb eb                	jmp    800ff1 <devsock_close+0x1f>

00801006 <devsock_write>:
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80100c:	6a 00                	push   $0x0
  80100e:	ff 75 10             	push   0x10(%ebp)
  801011:	ff 75 0c             	push   0xc(%ebp)
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	ff 70 0c             	push   0xc(%eax)
  80101a:	e8 79 03 00 00       	call   801398 <nsipc_send>
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <devsock_read>:
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801027:	6a 00                	push   $0x0
  801029:	ff 75 10             	push   0x10(%ebp)
  80102c:	ff 75 0c             	push   0xc(%ebp)
  80102f:	8b 45 08             	mov    0x8(%ebp),%eax
  801032:	ff 70 0c             	push   0xc(%eax)
  801035:	e8 ef 02 00 00       	call   801329 <nsipc_recv>
}
  80103a:	c9                   	leave  
  80103b:	c3                   	ret    

0080103c <fd2sockid>:
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801042:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801045:	52                   	push   %edx
  801046:	50                   	push   %eax
  801047:	e8 fb f7 ff ff       	call   800847 <fd_lookup>
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 10                	js     801063 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801053:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801056:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80105c:	39 08                	cmp    %ecx,(%eax)
  80105e:	75 05                	jne    801065 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801060:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801063:	c9                   	leave  
  801064:	c3                   	ret    
		return -E_NOT_SUPP;
  801065:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80106a:	eb f7                	jmp    801063 <fd2sockid+0x27>

0080106c <alloc_sockfd>:
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 1c             	sub    $0x1c,%esp
  801074:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801076:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801079:	50                   	push   %eax
  80107a:	e8 78 f7 ff ff       	call   8007f7 <fd_alloc>
  80107f:	89 c3                	mov    %eax,%ebx
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 43                	js     8010cb <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	68 07 04 00 00       	push   $0x407
  801090:	ff 75 f4             	push   -0xc(%ebp)
  801093:	6a 00                	push   $0x0
  801095:	e8 e4 f4 ff ff       	call   80057e <sys_page_alloc>
  80109a:	89 c3                	mov    %eax,%ebx
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 28                	js     8010cb <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8010a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8010ac:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8010ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8010b8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	50                   	push   %eax
  8010bf:	e8 0c f7 ff ff       	call   8007d0 <fd2num>
  8010c4:	89 c3                	mov    %eax,%ebx
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	eb 0c                	jmp    8010d7 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	56                   	push   %esi
  8010cf:	e8 e4 01 00 00       	call   8012b8 <nsipc_close>
		return r;
  8010d4:	83 c4 10             	add    $0x10,%esp
}
  8010d7:	89 d8                	mov    %ebx,%eax
  8010d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    

008010e0 <accept>:
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	e8 4e ff ff ff       	call   80103c <fd2sockid>
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	78 1b                	js     80110d <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8010f2:	83 ec 04             	sub    $0x4,%esp
  8010f5:	ff 75 10             	push   0x10(%ebp)
  8010f8:	ff 75 0c             	push   0xc(%ebp)
  8010fb:	50                   	push   %eax
  8010fc:	e8 0e 01 00 00       	call   80120f <nsipc_accept>
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	85 c0                	test   %eax,%eax
  801106:	78 05                	js     80110d <accept+0x2d>
	return alloc_sockfd(r);
  801108:	e8 5f ff ff ff       	call   80106c <alloc_sockfd>
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <bind>:
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	e8 1f ff ff ff       	call   80103c <fd2sockid>
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 12                	js     801133 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801121:	83 ec 04             	sub    $0x4,%esp
  801124:	ff 75 10             	push   0x10(%ebp)
  801127:	ff 75 0c             	push   0xc(%ebp)
  80112a:	50                   	push   %eax
  80112b:	e8 31 01 00 00       	call   801261 <nsipc_bind>
  801130:	83 c4 10             	add    $0x10,%esp
}
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <shutdown>:
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	e8 f9 fe ff ff       	call   80103c <fd2sockid>
  801143:	85 c0                	test   %eax,%eax
  801145:	78 0f                	js     801156 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801147:	83 ec 08             	sub    $0x8,%esp
  80114a:	ff 75 0c             	push   0xc(%ebp)
  80114d:	50                   	push   %eax
  80114e:	e8 43 01 00 00       	call   801296 <nsipc_shutdown>
  801153:	83 c4 10             	add    $0x10,%esp
}
  801156:	c9                   	leave  
  801157:	c3                   	ret    

00801158 <connect>:
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80115e:	8b 45 08             	mov    0x8(%ebp),%eax
  801161:	e8 d6 fe ff ff       	call   80103c <fd2sockid>
  801166:	85 c0                	test   %eax,%eax
  801168:	78 12                	js     80117c <connect+0x24>
	return nsipc_connect(r, name, namelen);
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	ff 75 10             	push   0x10(%ebp)
  801170:	ff 75 0c             	push   0xc(%ebp)
  801173:	50                   	push   %eax
  801174:	e8 59 01 00 00       	call   8012d2 <nsipc_connect>
  801179:	83 c4 10             	add    $0x10,%esp
}
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <listen>:
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
  801187:	e8 b0 fe ff ff       	call   80103c <fd2sockid>
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 0f                	js     80119f <listen+0x21>
	return nsipc_listen(r, backlog);
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	ff 75 0c             	push   0xc(%ebp)
  801196:	50                   	push   %eax
  801197:	e8 6b 01 00 00       	call   801307 <nsipc_listen>
  80119c:	83 c4 10             	add    $0x10,%esp
}
  80119f:	c9                   	leave  
  8011a0:	c3                   	ret    

008011a1 <socket>:

int
socket(int domain, int type, int protocol)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8011a7:	ff 75 10             	push   0x10(%ebp)
  8011aa:	ff 75 0c             	push   0xc(%ebp)
  8011ad:	ff 75 08             	push   0x8(%ebp)
  8011b0:	e8 41 02 00 00       	call   8013f6 <nsipc_socket>
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	78 05                	js     8011c1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8011bc:	e8 ab fe ff ff       	call   80106c <alloc_sockfd>
}
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    

008011c3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8011cc:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8011d3:	74 26                	je     8011fb <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8011d5:	6a 07                	push   $0x7
  8011d7:	68 00 70 80 00       	push   $0x807000
  8011dc:	53                   	push   %ebx
  8011dd:	ff 35 00 80 80 00    	push   0x808000
  8011e3:	e8 e0 0d 00 00       	call   801fc8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8011e8:	83 c4 0c             	add    $0xc,%esp
  8011eb:	6a 00                	push   $0x0
  8011ed:	6a 00                	push   $0x0
  8011ef:	6a 00                	push   $0x0
  8011f1:	e8 62 0d 00 00       	call   801f58 <ipc_recv>
}
  8011f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f9:	c9                   	leave  
  8011fa:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8011fb:	83 ec 0c             	sub    $0xc,%esp
  8011fe:	6a 02                	push   $0x2
  801200:	e8 17 0e 00 00       	call   80201c <ipc_find_env>
  801205:	a3 00 80 80 00       	mov    %eax,0x808000
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	eb c6                	jmp    8011d5 <nsipc+0x12>

0080120f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80121f:	8b 06                	mov    (%esi),%eax
  801221:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801226:	b8 01 00 00 00       	mov    $0x1,%eax
  80122b:	e8 93 ff ff ff       	call   8011c3 <nsipc>
  801230:	89 c3                	mov    %eax,%ebx
  801232:	85 c0                	test   %eax,%eax
  801234:	79 09                	jns    80123f <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801236:	89 d8                	mov    %ebx,%eax
  801238:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80123f:	83 ec 04             	sub    $0x4,%esp
  801242:	ff 35 10 70 80 00    	push   0x807010
  801248:	68 00 70 80 00       	push   $0x807000
  80124d:	ff 75 0c             	push   0xc(%ebp)
  801250:	e8 c3 f0 ff ff       	call   800318 <memmove>
		*addrlen = ret->ret_addrlen;
  801255:	a1 10 70 80 00       	mov    0x807010,%eax
  80125a:	89 06                	mov    %eax,(%esi)
  80125c:	83 c4 10             	add    $0x10,%esp
	return r;
  80125f:	eb d5                	jmp    801236 <nsipc_accept+0x27>

00801261 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	53                   	push   %ebx
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801273:	53                   	push   %ebx
  801274:	ff 75 0c             	push   0xc(%ebp)
  801277:	68 04 70 80 00       	push   $0x807004
  80127c:	e8 97 f0 ff ff       	call   800318 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801281:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801287:	b8 02 00 00 00       	mov    $0x2,%eax
  80128c:	e8 32 ff ff ff       	call   8011c3 <nsipc>
}
  801291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80129c:	8b 45 08             	mov    0x8(%ebp),%eax
  80129f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8012a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8012ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8012b1:	e8 0d ff ff ff       	call   8011c3 <nsipc>
}
  8012b6:	c9                   	leave  
  8012b7:	c3                   	ret    

008012b8 <nsipc_close>:

int
nsipc_close(int s)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8012be:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c1:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8012c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8012cb:	e8 f3 fe ff ff       	call   8011c3 <nsipc>
}
  8012d0:	c9                   	leave  
  8012d1:	c3                   	ret    

008012d2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	53                   	push   %ebx
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8012dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012df:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8012e4:	53                   	push   %ebx
  8012e5:	ff 75 0c             	push   0xc(%ebp)
  8012e8:	68 04 70 80 00       	push   $0x807004
  8012ed:	e8 26 f0 ff ff       	call   800318 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8012f2:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8012f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8012fd:	e8 c1 fe ff ff       	call   8011c3 <nsipc>
}
  801302:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801305:	c9                   	leave  
  801306:	c3                   	ret    

00801307 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80130d:	8b 45 08             	mov    0x8(%ebp),%eax
  801310:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801315:	8b 45 0c             	mov    0xc(%ebp),%eax
  801318:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80131d:	b8 06 00 00 00       	mov    $0x6,%eax
  801322:	e8 9c fe ff ff       	call   8011c3 <nsipc>
}
  801327:	c9                   	leave  
  801328:	c3                   	ret    

00801329 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	56                   	push   %esi
  80132d:	53                   	push   %ebx
  80132e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801331:	8b 45 08             	mov    0x8(%ebp),%eax
  801334:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801339:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80133f:	8b 45 14             	mov    0x14(%ebp),%eax
  801342:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801347:	b8 07 00 00 00       	mov    $0x7,%eax
  80134c:	e8 72 fe ff ff       	call   8011c3 <nsipc>
  801351:	89 c3                	mov    %eax,%ebx
  801353:	85 c0                	test   %eax,%eax
  801355:	78 22                	js     801379 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801357:	b8 3f 06 00 00       	mov    $0x63f,%eax
  80135c:	39 c6                	cmp    %eax,%esi
  80135e:	0f 4e c6             	cmovle %esi,%eax
  801361:	39 c3                	cmp    %eax,%ebx
  801363:	7f 1d                	jg     801382 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801365:	83 ec 04             	sub    $0x4,%esp
  801368:	53                   	push   %ebx
  801369:	68 00 70 80 00       	push   $0x807000
  80136e:	ff 75 0c             	push   0xc(%ebp)
  801371:	e8 a2 ef ff ff       	call   800318 <memmove>
  801376:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801379:	89 d8                	mov    %ebx,%eax
  80137b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137e:	5b                   	pop    %ebx
  80137f:	5e                   	pop    %esi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801382:	68 eb 23 80 00       	push   $0x8023eb
  801387:	68 b3 23 80 00       	push   $0x8023b3
  80138c:	6a 62                	push   $0x62
  80138e:	68 00 24 80 00       	push   $0x802400
  801393:	e8 46 05 00 00       	call   8018de <_panic>

00801398 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a5:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8013aa:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013b0:	7f 2e                	jg     8013e0 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8013b2:	83 ec 04             	sub    $0x4,%esp
  8013b5:	53                   	push   %ebx
  8013b6:	ff 75 0c             	push   0xc(%ebp)
  8013b9:	68 0c 70 80 00       	push   $0x80700c
  8013be:	e8 55 ef ff ff       	call   800318 <memmove>
	nsipcbuf.send.req_size = size;
  8013c3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8013c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8013d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8013d6:	e8 e8 fd ff ff       	call   8011c3 <nsipc>
}
  8013db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013de:	c9                   	leave  
  8013df:	c3                   	ret    
	assert(size < 1600);
  8013e0:	68 0c 24 80 00       	push   $0x80240c
  8013e5:	68 b3 23 80 00       	push   $0x8023b3
  8013ea:	6a 6d                	push   $0x6d
  8013ec:	68 00 24 80 00       	push   $0x802400
  8013f1:	e8 e8 04 00 00       	call   8018de <_panic>

008013f6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801404:	8b 45 0c             	mov    0xc(%ebp),%eax
  801407:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80140c:	8b 45 10             	mov    0x10(%ebp),%eax
  80140f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801414:	b8 09 00 00 00       	mov    $0x9,%eax
  801419:	e8 a5 fd ff ff       	call   8011c3 <nsipc>
}
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	56                   	push   %esi
  801424:	53                   	push   %ebx
  801425:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801428:	83 ec 0c             	sub    $0xc,%esp
  80142b:	ff 75 08             	push   0x8(%ebp)
  80142e:	e8 ad f3 ff ff       	call   8007e0 <fd2data>
  801433:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801435:	83 c4 08             	add    $0x8,%esp
  801438:	68 18 24 80 00       	push   $0x802418
  80143d:	53                   	push   %ebx
  80143e:	e8 3f ed ff ff       	call   800182 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801443:	8b 46 04             	mov    0x4(%esi),%eax
  801446:	2b 06                	sub    (%esi),%eax
  801448:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80144e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801455:	00 00 00 
	stat->st_dev = &devpipe;
  801458:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80145f:	30 80 00 
	return 0;
}
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
  801467:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146a:	5b                   	pop    %ebx
  80146b:	5e                   	pop    %esi
  80146c:	5d                   	pop    %ebp
  80146d:	c3                   	ret    

0080146e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	53                   	push   %ebx
  801472:	83 ec 0c             	sub    $0xc,%esp
  801475:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801478:	53                   	push   %ebx
  801479:	6a 00                	push   $0x0
  80147b:	e8 83 f1 ff ff       	call   800603 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801480:	89 1c 24             	mov    %ebx,(%esp)
  801483:	e8 58 f3 ff ff       	call   8007e0 <fd2data>
  801488:	83 c4 08             	add    $0x8,%esp
  80148b:	50                   	push   %eax
  80148c:	6a 00                	push   $0x0
  80148e:	e8 70 f1 ff ff       	call   800603 <sys_page_unmap>
}
  801493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <_pipeisclosed>:
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	57                   	push   %edi
  80149c:	56                   	push   %esi
  80149d:	53                   	push   %ebx
  80149e:	83 ec 1c             	sub    $0x1c,%esp
  8014a1:	89 c7                	mov    %eax,%edi
  8014a3:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8014a5:	a1 00 40 80 00       	mov    0x804000,%eax
  8014aa:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	57                   	push   %edi
  8014b1:	e8 a5 0b 00 00       	call   80205b <pageref>
  8014b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8014b9:	89 34 24             	mov    %esi,(%esp)
  8014bc:	e8 9a 0b 00 00       	call   80205b <pageref>
		nn = thisenv->env_runs;
  8014c1:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8014c7:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	39 cb                	cmp    %ecx,%ebx
  8014cf:	74 1b                	je     8014ec <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8014d1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8014d4:	75 cf                	jne    8014a5 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8014d6:	8b 42 68             	mov    0x68(%edx),%eax
  8014d9:	6a 01                	push   $0x1
  8014db:	50                   	push   %eax
  8014dc:	53                   	push   %ebx
  8014dd:	68 1f 24 80 00       	push   $0x80241f
  8014e2:	e8 d2 04 00 00       	call   8019b9 <cprintf>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	eb b9                	jmp    8014a5 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8014ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8014ef:	0f 94 c0             	sete   %al
  8014f2:	0f b6 c0             	movzbl %al,%eax
}
  8014f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5e                   	pop    %esi
  8014fa:	5f                   	pop    %edi
  8014fb:	5d                   	pop    %ebp
  8014fc:	c3                   	ret    

008014fd <devpipe_write>:
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	57                   	push   %edi
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	83 ec 28             	sub    $0x28,%esp
  801506:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801509:	56                   	push   %esi
  80150a:	e8 d1 f2 ff ff       	call   8007e0 <fd2data>
  80150f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	bf 00 00 00 00       	mov    $0x0,%edi
  801519:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80151c:	75 09                	jne    801527 <devpipe_write+0x2a>
	return i;
  80151e:	89 f8                	mov    %edi,%eax
  801520:	eb 23                	jmp    801545 <devpipe_write+0x48>
			sys_yield();
  801522:	e8 38 f0 ff ff       	call   80055f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801527:	8b 43 04             	mov    0x4(%ebx),%eax
  80152a:	8b 0b                	mov    (%ebx),%ecx
  80152c:	8d 51 20             	lea    0x20(%ecx),%edx
  80152f:	39 d0                	cmp    %edx,%eax
  801531:	72 1a                	jb     80154d <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801533:	89 da                	mov    %ebx,%edx
  801535:	89 f0                	mov    %esi,%eax
  801537:	e8 5c ff ff ff       	call   801498 <_pipeisclosed>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	74 e2                	je     801522 <devpipe_write+0x25>
				return 0;
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801545:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5f                   	pop    %edi
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80154d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801550:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801554:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801557:	89 c2                	mov    %eax,%edx
  801559:	c1 fa 1f             	sar    $0x1f,%edx
  80155c:	89 d1                	mov    %edx,%ecx
  80155e:	c1 e9 1b             	shr    $0x1b,%ecx
  801561:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801564:	83 e2 1f             	and    $0x1f,%edx
  801567:	29 ca                	sub    %ecx,%edx
  801569:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80156d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801571:	83 c0 01             	add    $0x1,%eax
  801574:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801577:	83 c7 01             	add    $0x1,%edi
  80157a:	eb 9d                	jmp    801519 <devpipe_write+0x1c>

0080157c <devpipe_read>:
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	57                   	push   %edi
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
  801582:	83 ec 18             	sub    $0x18,%esp
  801585:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801588:	57                   	push   %edi
  801589:	e8 52 f2 ff ff       	call   8007e0 <fd2data>
  80158e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	be 00 00 00 00       	mov    $0x0,%esi
  801598:	3b 75 10             	cmp    0x10(%ebp),%esi
  80159b:	75 13                	jne    8015b0 <devpipe_read+0x34>
	return i;
  80159d:	89 f0                	mov    %esi,%eax
  80159f:	eb 02                	jmp    8015a3 <devpipe_read+0x27>
				return i;
  8015a1:	89 f0                	mov    %esi,%eax
}
  8015a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a6:	5b                   	pop    %ebx
  8015a7:	5e                   	pop    %esi
  8015a8:	5f                   	pop    %edi
  8015a9:	5d                   	pop    %ebp
  8015aa:	c3                   	ret    
			sys_yield();
  8015ab:	e8 af ef ff ff       	call   80055f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8015b0:	8b 03                	mov    (%ebx),%eax
  8015b2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8015b5:	75 18                	jne    8015cf <devpipe_read+0x53>
			if (i > 0)
  8015b7:	85 f6                	test   %esi,%esi
  8015b9:	75 e6                	jne    8015a1 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8015bb:	89 da                	mov    %ebx,%edx
  8015bd:	89 f8                	mov    %edi,%eax
  8015bf:	e8 d4 fe ff ff       	call   801498 <_pipeisclosed>
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	74 e3                	je     8015ab <devpipe_read+0x2f>
				return 0;
  8015c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cd:	eb d4                	jmp    8015a3 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8015cf:	99                   	cltd   
  8015d0:	c1 ea 1b             	shr    $0x1b,%edx
  8015d3:	01 d0                	add    %edx,%eax
  8015d5:	83 e0 1f             	and    $0x1f,%eax
  8015d8:	29 d0                	sub    %edx,%eax
  8015da:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8015df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8015e5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8015e8:	83 c6 01             	add    $0x1,%esi
  8015eb:	eb ab                	jmp    801598 <devpipe_read+0x1c>

008015ed <pipe>:
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8015f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f8:	50                   	push   %eax
  8015f9:	e8 f9 f1 ff ff       	call   8007f7 <fd_alloc>
  8015fe:	89 c3                	mov    %eax,%ebx
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	0f 88 23 01 00 00    	js     80172e <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	68 07 04 00 00       	push   $0x407
  801613:	ff 75 f4             	push   -0xc(%ebp)
  801616:	6a 00                	push   $0x0
  801618:	e8 61 ef ff ff       	call   80057e <sys_page_alloc>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	0f 88 04 01 00 00    	js     80172e <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	e8 c1 f1 ff ff       	call   8007f7 <fd_alloc>
  801636:	89 c3                	mov    %eax,%ebx
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	0f 88 db 00 00 00    	js     80171e <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	68 07 04 00 00       	push   $0x407
  80164b:	ff 75 f0             	push   -0x10(%ebp)
  80164e:	6a 00                	push   $0x0
  801650:	e8 29 ef ff ff       	call   80057e <sys_page_alloc>
  801655:	89 c3                	mov    %eax,%ebx
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	0f 88 bc 00 00 00    	js     80171e <pipe+0x131>
	va = fd2data(fd0);
  801662:	83 ec 0c             	sub    $0xc,%esp
  801665:	ff 75 f4             	push   -0xc(%ebp)
  801668:	e8 73 f1 ff ff       	call   8007e0 <fd2data>
  80166d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80166f:	83 c4 0c             	add    $0xc,%esp
  801672:	68 07 04 00 00       	push   $0x407
  801677:	50                   	push   %eax
  801678:	6a 00                	push   $0x0
  80167a:	e8 ff ee ff ff       	call   80057e <sys_page_alloc>
  80167f:	89 c3                	mov    %eax,%ebx
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	0f 88 82 00 00 00    	js     80170e <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	ff 75 f0             	push   -0x10(%ebp)
  801692:	e8 49 f1 ff ff       	call   8007e0 <fd2data>
  801697:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80169e:	50                   	push   %eax
  80169f:	6a 00                	push   $0x0
  8016a1:	56                   	push   %esi
  8016a2:	6a 00                	push   $0x0
  8016a4:	e8 18 ef ff ff       	call   8005c1 <sys_page_map>
  8016a9:	89 c3                	mov    %eax,%ebx
  8016ab:	83 c4 20             	add    $0x20,%esp
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 4e                	js     801700 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8016b2:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8016b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ba:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8016bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bf:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8016c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c9:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8016d5:	83 ec 0c             	sub    $0xc,%esp
  8016d8:	ff 75 f4             	push   -0xc(%ebp)
  8016db:	e8 f0 f0 ff ff       	call   8007d0 <fd2num>
  8016e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8016e5:	83 c4 04             	add    $0x4,%esp
  8016e8:	ff 75 f0             	push   -0x10(%ebp)
  8016eb:	e8 e0 f0 ff ff       	call   8007d0 <fd2num>
  8016f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8016f6:	83 c4 10             	add    $0x10,%esp
  8016f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fe:	eb 2e                	jmp    80172e <pipe+0x141>
	sys_page_unmap(0, va);
  801700:	83 ec 08             	sub    $0x8,%esp
  801703:	56                   	push   %esi
  801704:	6a 00                	push   $0x0
  801706:	e8 f8 ee ff ff       	call   800603 <sys_page_unmap>
  80170b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	ff 75 f0             	push   -0x10(%ebp)
  801714:	6a 00                	push   $0x0
  801716:	e8 e8 ee ff ff       	call   800603 <sys_page_unmap>
  80171b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80171e:	83 ec 08             	sub    $0x8,%esp
  801721:	ff 75 f4             	push   -0xc(%ebp)
  801724:	6a 00                	push   $0x0
  801726:	e8 d8 ee ff ff       	call   800603 <sys_page_unmap>
  80172b:	83 c4 10             	add    $0x10,%esp
}
  80172e:	89 d8                	mov    %ebx,%eax
  801730:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801733:	5b                   	pop    %ebx
  801734:	5e                   	pop    %esi
  801735:	5d                   	pop    %ebp
  801736:	c3                   	ret    

00801737 <pipeisclosed>:
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801740:	50                   	push   %eax
  801741:	ff 75 08             	push   0x8(%ebp)
  801744:	e8 fe f0 ff ff       	call   800847 <fd_lookup>
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 18                	js     801768 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	ff 75 f4             	push   -0xc(%ebp)
  801756:	e8 85 f0 ff ff       	call   8007e0 <fd2data>
  80175b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80175d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801760:	e8 33 fd ff ff       	call   801498 <_pipeisclosed>
  801765:	83 c4 10             	add    $0x10,%esp
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80176a:	b8 00 00 00 00       	mov    $0x0,%eax
  80176f:	c3                   	ret    

00801770 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801776:	68 37 24 80 00       	push   $0x802437
  80177b:	ff 75 0c             	push   0xc(%ebp)
  80177e:	e8 ff e9 ff ff       	call   800182 <strcpy>
	return 0;
}
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
  801788:	c9                   	leave  
  801789:	c3                   	ret    

0080178a <devcons_write>:
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	57                   	push   %edi
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801796:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80179b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8017a1:	eb 2e                	jmp    8017d1 <devcons_write+0x47>
		m = n - tot;
  8017a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017a6:	29 f3                	sub    %esi,%ebx
  8017a8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8017ad:	39 c3                	cmp    %eax,%ebx
  8017af:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8017b2:	83 ec 04             	sub    $0x4,%esp
  8017b5:	53                   	push   %ebx
  8017b6:	89 f0                	mov    %esi,%eax
  8017b8:	03 45 0c             	add    0xc(%ebp),%eax
  8017bb:	50                   	push   %eax
  8017bc:	57                   	push   %edi
  8017bd:	e8 56 eb ff ff       	call   800318 <memmove>
		sys_cputs(buf, m);
  8017c2:	83 c4 08             	add    $0x8,%esp
  8017c5:	53                   	push   %ebx
  8017c6:	57                   	push   %edi
  8017c7:	e8 f6 ec ff ff       	call   8004c2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8017cc:	01 de                	add    %ebx,%esi
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017d4:	72 cd                	jb     8017a3 <devcons_write+0x19>
}
  8017d6:	89 f0                	mov    %esi,%eax
  8017d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	5f                   	pop    %edi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <devcons_read>:
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 08             	sub    $0x8,%esp
  8017e6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8017eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017ef:	75 07                	jne    8017f8 <devcons_read+0x18>
  8017f1:	eb 1f                	jmp    801812 <devcons_read+0x32>
		sys_yield();
  8017f3:	e8 67 ed ff ff       	call   80055f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8017f8:	e8 e3 ec ff ff       	call   8004e0 <sys_cgetc>
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	74 f2                	je     8017f3 <devcons_read+0x13>
	if (c < 0)
  801801:	78 0f                	js     801812 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801803:	83 f8 04             	cmp    $0x4,%eax
  801806:	74 0c                	je     801814 <devcons_read+0x34>
	*(char*)vbuf = c;
  801808:	8b 55 0c             	mov    0xc(%ebp),%edx
  80180b:	88 02                	mov    %al,(%edx)
	return 1;
  80180d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801812:	c9                   	leave  
  801813:	c3                   	ret    
		return 0;
  801814:	b8 00 00 00 00       	mov    $0x0,%eax
  801819:	eb f7                	jmp    801812 <devcons_read+0x32>

0080181b <cputchar>:
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801827:	6a 01                	push   $0x1
  801829:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80182c:	50                   	push   %eax
  80182d:	e8 90 ec ff ff       	call   8004c2 <sys_cputs>
}
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	c9                   	leave  
  801836:	c3                   	ret    

00801837 <getchar>:
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80183d:	6a 01                	push   $0x1
  80183f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801842:	50                   	push   %eax
  801843:	6a 00                	push   $0x0
  801845:	e8 66 f2 ff ff       	call   800ab0 <read>
	if (r < 0)
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 06                	js     801857 <getchar+0x20>
	if (r < 1)
  801851:	74 06                	je     801859 <getchar+0x22>
	return c;
  801853:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801857:	c9                   	leave  
  801858:	c3                   	ret    
		return -E_EOF;
  801859:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80185e:	eb f7                	jmp    801857 <getchar+0x20>

00801860 <iscons>:
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801866:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801869:	50                   	push   %eax
  80186a:	ff 75 08             	push   0x8(%ebp)
  80186d:	e8 d5 ef ff ff       	call   800847 <fd_lookup>
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	78 11                	js     80188a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801882:	39 10                	cmp    %edx,(%eax)
  801884:	0f 94 c0             	sete   %al
  801887:	0f b6 c0             	movzbl %al,%eax
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <opencons>:
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	e8 5c ef ff ff       	call   8007f7 <fd_alloc>
  80189b:	83 c4 10             	add    $0x10,%esp
  80189e:	85 c0                	test   %eax,%eax
  8018a0:	78 3a                	js     8018dc <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8018a2:	83 ec 04             	sub    $0x4,%esp
  8018a5:	68 07 04 00 00       	push   $0x407
  8018aa:	ff 75 f4             	push   -0xc(%ebp)
  8018ad:	6a 00                	push   $0x0
  8018af:	e8 ca ec ff ff       	call   80057e <sys_page_alloc>
  8018b4:	83 c4 10             	add    $0x10,%esp
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 21                	js     8018dc <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8018bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018be:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018c4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8018c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8018d0:	83 ec 0c             	sub    $0xc,%esp
  8018d3:	50                   	push   %eax
  8018d4:	e8 f7 ee ff ff       	call   8007d0 <fd2num>
  8018d9:	83 c4 10             	add    $0x10,%esp
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	56                   	push   %esi
  8018e2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8018e3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018e6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8018ec:	e8 4f ec ff ff       	call   800540 <sys_getenvid>
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	ff 75 0c             	push   0xc(%ebp)
  8018f7:	ff 75 08             	push   0x8(%ebp)
  8018fa:	56                   	push   %esi
  8018fb:	50                   	push   %eax
  8018fc:	68 44 24 80 00       	push   $0x802444
  801901:	e8 b3 00 00 00       	call   8019b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801906:	83 c4 18             	add    $0x18,%esp
  801909:	53                   	push   %ebx
  80190a:	ff 75 10             	push   0x10(%ebp)
  80190d:	e8 56 00 00 00       	call   801968 <vcprintf>
	cprintf("\n");
  801912:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  801919:	e8 9b 00 00 00       	call   8019b9 <cprintf>
  80191e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801921:	cc                   	int3   
  801922:	eb fd                	jmp    801921 <_panic+0x43>

00801924 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 04             	sub    $0x4,%esp
  80192b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80192e:	8b 13                	mov    (%ebx),%edx
  801930:	8d 42 01             	lea    0x1(%edx),%eax
  801933:	89 03                	mov    %eax,(%ebx)
  801935:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801938:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80193c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801941:	74 09                	je     80194c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801943:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801947:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	68 ff 00 00 00       	push   $0xff
  801954:	8d 43 08             	lea    0x8(%ebx),%eax
  801957:	50                   	push   %eax
  801958:	e8 65 eb ff ff       	call   8004c2 <sys_cputs>
		b->idx = 0;
  80195d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	eb db                	jmp    801943 <putch+0x1f>

00801968 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801971:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801978:	00 00 00 
	b.cnt = 0;
  80197b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801982:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801985:	ff 75 0c             	push   0xc(%ebp)
  801988:	ff 75 08             	push   0x8(%ebp)
  80198b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801991:	50                   	push   %eax
  801992:	68 24 19 80 00       	push   $0x801924
  801997:	e8 14 01 00 00       	call   801ab0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80199c:	83 c4 08             	add    $0x8,%esp
  80199f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8019a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8019ab:	50                   	push   %eax
  8019ac:	e8 11 eb ff ff       	call   8004c2 <sys_cputs>

	return b.cnt;
}
  8019b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019bf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8019c2:	50                   	push   %eax
  8019c3:	ff 75 08             	push   0x8(%ebp)
  8019c6:	e8 9d ff ff ff       	call   801968 <vcprintf>
	va_end(ap);

	return cnt;
}
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    

008019cd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	57                   	push   %edi
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	83 ec 1c             	sub    $0x1c,%esp
  8019d6:	89 c7                	mov    %eax,%edi
  8019d8:	89 d6                	mov    %edx,%esi
  8019da:	8b 45 08             	mov    0x8(%ebp),%eax
  8019dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e0:	89 d1                	mov    %edx,%ecx
  8019e2:	89 c2                	mov    %eax,%edx
  8019e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8019f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019fa:	39 c2                	cmp    %eax,%edx
  8019fc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8019ff:	72 3e                	jb     801a3f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a01:	83 ec 0c             	sub    $0xc,%esp
  801a04:	ff 75 18             	push   0x18(%ebp)
  801a07:	83 eb 01             	sub    $0x1,%ebx
  801a0a:	53                   	push   %ebx
  801a0b:	50                   	push   %eax
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	ff 75 e4             	push   -0x1c(%ebp)
  801a12:	ff 75 e0             	push   -0x20(%ebp)
  801a15:	ff 75 dc             	push   -0x24(%ebp)
  801a18:	ff 75 d8             	push   -0x28(%ebp)
  801a1b:	e8 80 06 00 00       	call   8020a0 <__udivdi3>
  801a20:	83 c4 18             	add    $0x18,%esp
  801a23:	52                   	push   %edx
  801a24:	50                   	push   %eax
  801a25:	89 f2                	mov    %esi,%edx
  801a27:	89 f8                	mov    %edi,%eax
  801a29:	e8 9f ff ff ff       	call   8019cd <printnum>
  801a2e:	83 c4 20             	add    $0x20,%esp
  801a31:	eb 13                	jmp    801a46 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801a33:	83 ec 08             	sub    $0x8,%esp
  801a36:	56                   	push   %esi
  801a37:	ff 75 18             	push   0x18(%ebp)
  801a3a:	ff d7                	call   *%edi
  801a3c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801a3f:	83 eb 01             	sub    $0x1,%ebx
  801a42:	85 db                	test   %ebx,%ebx
  801a44:	7f ed                	jg     801a33 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	56                   	push   %esi
  801a4a:	83 ec 04             	sub    $0x4,%esp
  801a4d:	ff 75 e4             	push   -0x1c(%ebp)
  801a50:	ff 75 e0             	push   -0x20(%ebp)
  801a53:	ff 75 dc             	push   -0x24(%ebp)
  801a56:	ff 75 d8             	push   -0x28(%ebp)
  801a59:	e8 62 07 00 00       	call   8021c0 <__umoddi3>
  801a5e:	83 c4 14             	add    $0x14,%esp
  801a61:	0f be 80 67 24 80 00 	movsbl 0x802467(%eax),%eax
  801a68:	50                   	push   %eax
  801a69:	ff d7                	call   *%edi
}
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5f                   	pop    %edi
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801a7c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801a80:	8b 10                	mov    (%eax),%edx
  801a82:	3b 50 04             	cmp    0x4(%eax),%edx
  801a85:	73 0a                	jae    801a91 <sprintputch+0x1b>
		*b->buf++ = ch;
  801a87:	8d 4a 01             	lea    0x1(%edx),%ecx
  801a8a:	89 08                	mov    %ecx,(%eax)
  801a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8f:	88 02                	mov    %al,(%edx)
}
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <printfmt>:
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801a99:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801a9c:	50                   	push   %eax
  801a9d:	ff 75 10             	push   0x10(%ebp)
  801aa0:	ff 75 0c             	push   0xc(%ebp)
  801aa3:	ff 75 08             	push   0x8(%ebp)
  801aa6:	e8 05 00 00 00       	call   801ab0 <vprintfmt>
}
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    

00801ab0 <vprintfmt>:
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	57                   	push   %edi
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 3c             	sub    $0x3c,%esp
  801ab9:	8b 75 08             	mov    0x8(%ebp),%esi
  801abc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801abf:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ac2:	eb 0a                	jmp    801ace <vprintfmt+0x1e>
			putch(ch, putdat);
  801ac4:	83 ec 08             	sub    $0x8,%esp
  801ac7:	53                   	push   %ebx
  801ac8:	50                   	push   %eax
  801ac9:	ff d6                	call   *%esi
  801acb:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801ace:	83 c7 01             	add    $0x1,%edi
  801ad1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ad5:	83 f8 25             	cmp    $0x25,%eax
  801ad8:	74 0c                	je     801ae6 <vprintfmt+0x36>
			if (ch == '\0')
  801ada:	85 c0                	test   %eax,%eax
  801adc:	75 e6                	jne    801ac4 <vprintfmt+0x14>
}
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
		padc = ' ';
  801ae6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801aea:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801af1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801af8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801aff:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801b04:	8d 47 01             	lea    0x1(%edi),%eax
  801b07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b0a:	0f b6 17             	movzbl (%edi),%edx
  801b0d:	8d 42 dd             	lea    -0x23(%edx),%eax
  801b10:	3c 55                	cmp    $0x55,%al
  801b12:	0f 87 bb 03 00 00    	ja     801ed3 <vprintfmt+0x423>
  801b18:	0f b6 c0             	movzbl %al,%eax
  801b1b:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  801b22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801b25:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801b29:	eb d9                	jmp    801b04 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801b2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b2e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801b32:	eb d0                	jmp    801b04 <vprintfmt+0x54>
  801b34:	0f b6 d2             	movzbl %dl,%edx
  801b37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801b42:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801b45:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801b49:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801b4c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b4f:	83 f9 09             	cmp    $0x9,%ecx
  801b52:	77 55                	ja     801ba9 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801b54:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801b57:	eb e9                	jmp    801b42 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801b59:	8b 45 14             	mov    0x14(%ebp),%eax
  801b5c:	8b 00                	mov    (%eax),%eax
  801b5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b61:	8b 45 14             	mov    0x14(%ebp),%eax
  801b64:	8d 40 04             	lea    0x4(%eax),%eax
  801b67:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801b6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801b6d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801b71:	79 91                	jns    801b04 <vprintfmt+0x54>
				width = precision, precision = -1;
  801b73:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b76:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b79:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801b80:	eb 82                	jmp    801b04 <vprintfmt+0x54>
  801b82:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801b85:	85 d2                	test   %edx,%edx
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8c:	0f 49 c2             	cmovns %edx,%eax
  801b8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801b92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801b95:	e9 6a ff ff ff       	jmp    801b04 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801b9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801b9d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801ba4:	e9 5b ff ff ff       	jmp    801b04 <vprintfmt+0x54>
  801ba9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801bac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801baf:	eb bc                	jmp    801b6d <vprintfmt+0xbd>
			lflag++;
  801bb1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801bb4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801bb7:	e9 48 ff ff ff       	jmp    801b04 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbf:	8d 78 04             	lea    0x4(%eax),%edi
  801bc2:	83 ec 08             	sub    $0x8,%esp
  801bc5:	53                   	push   %ebx
  801bc6:	ff 30                	push   (%eax)
  801bc8:	ff d6                	call   *%esi
			break;
  801bca:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801bcd:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801bd0:	e9 9d 02 00 00       	jmp    801e72 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  801bd5:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd8:	8d 78 04             	lea    0x4(%eax),%edi
  801bdb:	8b 10                	mov    (%eax),%edx
  801bdd:	89 d0                	mov    %edx,%eax
  801bdf:	f7 d8                	neg    %eax
  801be1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801be4:	83 f8 0f             	cmp    $0xf,%eax
  801be7:	7f 23                	jg     801c0c <vprintfmt+0x15c>
  801be9:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  801bf0:	85 d2                	test   %edx,%edx
  801bf2:	74 18                	je     801c0c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801bf4:	52                   	push   %edx
  801bf5:	68 c5 23 80 00       	push   $0x8023c5
  801bfa:	53                   	push   %ebx
  801bfb:	56                   	push   %esi
  801bfc:	e8 92 fe ff ff       	call   801a93 <printfmt>
  801c01:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801c04:	89 7d 14             	mov    %edi,0x14(%ebp)
  801c07:	e9 66 02 00 00       	jmp    801e72 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801c0c:	50                   	push   %eax
  801c0d:	68 7f 24 80 00       	push   $0x80247f
  801c12:	53                   	push   %ebx
  801c13:	56                   	push   %esi
  801c14:	e8 7a fe ff ff       	call   801a93 <printfmt>
  801c19:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801c1c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801c1f:	e9 4e 02 00 00       	jmp    801e72 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801c24:	8b 45 14             	mov    0x14(%ebp),%eax
  801c27:	83 c0 04             	add    $0x4,%eax
  801c2a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801c2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801c30:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801c32:	85 d2                	test   %edx,%edx
  801c34:	b8 78 24 80 00       	mov    $0x802478,%eax
  801c39:	0f 45 c2             	cmovne %edx,%eax
  801c3c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801c3f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c43:	7e 06                	jle    801c4b <vprintfmt+0x19b>
  801c45:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801c49:	75 0d                	jne    801c58 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801c4b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801c4e:	89 c7                	mov    %eax,%edi
  801c50:	03 45 e0             	add    -0x20(%ebp),%eax
  801c53:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c56:	eb 55                	jmp    801cad <vprintfmt+0x1fd>
  801c58:	83 ec 08             	sub    $0x8,%esp
  801c5b:	ff 75 d8             	push   -0x28(%ebp)
  801c5e:	ff 75 cc             	push   -0x34(%ebp)
  801c61:	e8 f9 e4 ff ff       	call   80015f <strnlen>
  801c66:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c69:	29 c1                	sub    %eax,%ecx
  801c6b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801c6e:	83 c4 10             	add    $0x10,%esp
  801c71:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801c73:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801c77:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801c7a:	eb 0f                	jmp    801c8b <vprintfmt+0x1db>
					putch(padc, putdat);
  801c7c:	83 ec 08             	sub    $0x8,%esp
  801c7f:	53                   	push   %ebx
  801c80:	ff 75 e0             	push   -0x20(%ebp)
  801c83:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801c85:	83 ef 01             	sub    $0x1,%edi
  801c88:	83 c4 10             	add    $0x10,%esp
  801c8b:	85 ff                	test   %edi,%edi
  801c8d:	7f ed                	jg     801c7c <vprintfmt+0x1cc>
  801c8f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801c92:	85 d2                	test   %edx,%edx
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
  801c99:	0f 49 c2             	cmovns %edx,%eax
  801c9c:	29 c2                	sub    %eax,%edx
  801c9e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801ca1:	eb a8                	jmp    801c4b <vprintfmt+0x19b>
					putch(ch, putdat);
  801ca3:	83 ec 08             	sub    $0x8,%esp
  801ca6:	53                   	push   %ebx
  801ca7:	52                   	push   %edx
  801ca8:	ff d6                	call   *%esi
  801caa:	83 c4 10             	add    $0x10,%esp
  801cad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801cb0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801cb2:	83 c7 01             	add    $0x1,%edi
  801cb5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801cb9:	0f be d0             	movsbl %al,%edx
  801cbc:	85 d2                	test   %edx,%edx
  801cbe:	74 4b                	je     801d0b <vprintfmt+0x25b>
  801cc0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801cc4:	78 06                	js     801ccc <vprintfmt+0x21c>
  801cc6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801cca:	78 1e                	js     801cea <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  801ccc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801cd0:	74 d1                	je     801ca3 <vprintfmt+0x1f3>
  801cd2:	0f be c0             	movsbl %al,%eax
  801cd5:	83 e8 20             	sub    $0x20,%eax
  801cd8:	83 f8 5e             	cmp    $0x5e,%eax
  801cdb:	76 c6                	jbe    801ca3 <vprintfmt+0x1f3>
					putch('?', putdat);
  801cdd:	83 ec 08             	sub    $0x8,%esp
  801ce0:	53                   	push   %ebx
  801ce1:	6a 3f                	push   $0x3f
  801ce3:	ff d6                	call   *%esi
  801ce5:	83 c4 10             	add    $0x10,%esp
  801ce8:	eb c3                	jmp    801cad <vprintfmt+0x1fd>
  801cea:	89 cf                	mov    %ecx,%edi
  801cec:	eb 0e                	jmp    801cfc <vprintfmt+0x24c>
				putch(' ', putdat);
  801cee:	83 ec 08             	sub    $0x8,%esp
  801cf1:	53                   	push   %ebx
  801cf2:	6a 20                	push   $0x20
  801cf4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801cf6:	83 ef 01             	sub    $0x1,%edi
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 ff                	test   %edi,%edi
  801cfe:	7f ee                	jg     801cee <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801d00:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801d03:	89 45 14             	mov    %eax,0x14(%ebp)
  801d06:	e9 67 01 00 00       	jmp    801e72 <vprintfmt+0x3c2>
  801d0b:	89 cf                	mov    %ecx,%edi
  801d0d:	eb ed                	jmp    801cfc <vprintfmt+0x24c>
	if (lflag >= 2)
  801d0f:	83 f9 01             	cmp    $0x1,%ecx
  801d12:	7f 1b                	jg     801d2f <vprintfmt+0x27f>
	else if (lflag)
  801d14:	85 c9                	test   %ecx,%ecx
  801d16:	74 63                	je     801d7b <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801d18:	8b 45 14             	mov    0x14(%ebp),%eax
  801d1b:	8b 00                	mov    (%eax),%eax
  801d1d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d20:	99                   	cltd   
  801d21:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d24:	8b 45 14             	mov    0x14(%ebp),%eax
  801d27:	8d 40 04             	lea    0x4(%eax),%eax
  801d2a:	89 45 14             	mov    %eax,0x14(%ebp)
  801d2d:	eb 17                	jmp    801d46 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801d2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d32:	8b 50 04             	mov    0x4(%eax),%edx
  801d35:	8b 00                	mov    (%eax),%eax
  801d37:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d3a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801d40:	8d 40 08             	lea    0x8(%eax),%eax
  801d43:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801d46:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801d49:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801d4c:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801d51:	85 c9                	test   %ecx,%ecx
  801d53:	0f 89 ff 00 00 00    	jns    801e58 <vprintfmt+0x3a8>
				putch('-', putdat);
  801d59:	83 ec 08             	sub    $0x8,%esp
  801d5c:	53                   	push   %ebx
  801d5d:	6a 2d                	push   $0x2d
  801d5f:	ff d6                	call   *%esi
				num = -(long long) num;
  801d61:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801d64:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801d67:	f7 da                	neg    %edx
  801d69:	83 d1 00             	adc    $0x0,%ecx
  801d6c:	f7 d9                	neg    %ecx
  801d6e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801d71:	bf 0a 00 00 00       	mov    $0xa,%edi
  801d76:	e9 dd 00 00 00       	jmp    801e58 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801d7b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d7e:	8b 00                	mov    (%eax),%eax
  801d80:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d83:	99                   	cltd   
  801d84:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d87:	8b 45 14             	mov    0x14(%ebp),%eax
  801d8a:	8d 40 04             	lea    0x4(%eax),%eax
  801d8d:	89 45 14             	mov    %eax,0x14(%ebp)
  801d90:	eb b4                	jmp    801d46 <vprintfmt+0x296>
	if (lflag >= 2)
  801d92:	83 f9 01             	cmp    $0x1,%ecx
  801d95:	7f 1e                	jg     801db5 <vprintfmt+0x305>
	else if (lflag)
  801d97:	85 c9                	test   %ecx,%ecx
  801d99:	74 32                	je     801dcd <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801d9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9e:	8b 10                	mov    (%eax),%edx
  801da0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801da5:	8d 40 04             	lea    0x4(%eax),%eax
  801da8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801dab:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801db0:	e9 a3 00 00 00       	jmp    801e58 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801db5:	8b 45 14             	mov    0x14(%ebp),%eax
  801db8:	8b 10                	mov    (%eax),%edx
  801dba:	8b 48 04             	mov    0x4(%eax),%ecx
  801dbd:	8d 40 08             	lea    0x8(%eax),%eax
  801dc0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801dc3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  801dc8:	e9 8b 00 00 00       	jmp    801e58 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801dcd:	8b 45 14             	mov    0x14(%ebp),%eax
  801dd0:	8b 10                	mov    (%eax),%edx
  801dd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dd7:	8d 40 04             	lea    0x4(%eax),%eax
  801dda:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801ddd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801de2:	eb 74                	jmp    801e58 <vprintfmt+0x3a8>
	if (lflag >= 2)
  801de4:	83 f9 01             	cmp    $0x1,%ecx
  801de7:	7f 1b                	jg     801e04 <vprintfmt+0x354>
	else if (lflag)
  801de9:	85 c9                	test   %ecx,%ecx
  801deb:	74 2c                	je     801e19 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801ded:	8b 45 14             	mov    0x14(%ebp),%eax
  801df0:	8b 10                	mov    (%eax),%edx
  801df2:	b9 00 00 00 00       	mov    $0x0,%ecx
  801df7:	8d 40 04             	lea    0x4(%eax),%eax
  801dfa:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801dfd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801e02:	eb 54                	jmp    801e58 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801e04:	8b 45 14             	mov    0x14(%ebp),%eax
  801e07:	8b 10                	mov    (%eax),%edx
  801e09:	8b 48 04             	mov    0x4(%eax),%ecx
  801e0c:	8d 40 08             	lea    0x8(%eax),%eax
  801e0f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801e12:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801e17:	eb 3f                	jmp    801e58 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801e19:	8b 45 14             	mov    0x14(%ebp),%eax
  801e1c:	8b 10                	mov    (%eax),%edx
  801e1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e23:	8d 40 04             	lea    0x4(%eax),%eax
  801e26:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801e29:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801e2e:	eb 28                	jmp    801e58 <vprintfmt+0x3a8>
			putch('0', putdat);
  801e30:	83 ec 08             	sub    $0x8,%esp
  801e33:	53                   	push   %ebx
  801e34:	6a 30                	push   $0x30
  801e36:	ff d6                	call   *%esi
			putch('x', putdat);
  801e38:	83 c4 08             	add    $0x8,%esp
  801e3b:	53                   	push   %ebx
  801e3c:	6a 78                	push   $0x78
  801e3e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801e40:	8b 45 14             	mov    0x14(%ebp),%eax
  801e43:	8b 10                	mov    (%eax),%edx
  801e45:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801e4a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801e4d:	8d 40 04             	lea    0x4(%eax),%eax
  801e50:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801e53:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801e58:	83 ec 0c             	sub    $0xc,%esp
  801e5b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	ff 75 e0             	push   -0x20(%ebp)
  801e63:	57                   	push   %edi
  801e64:	51                   	push   %ecx
  801e65:	52                   	push   %edx
  801e66:	89 da                	mov    %ebx,%edx
  801e68:	89 f0                	mov    %esi,%eax
  801e6a:	e8 5e fb ff ff       	call   8019cd <printnum>
			break;
  801e6f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801e72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801e75:	e9 54 fc ff ff       	jmp    801ace <vprintfmt+0x1e>
	if (lflag >= 2)
  801e7a:	83 f9 01             	cmp    $0x1,%ecx
  801e7d:	7f 1b                	jg     801e9a <vprintfmt+0x3ea>
	else if (lflag)
  801e7f:	85 c9                	test   %ecx,%ecx
  801e81:	74 2c                	je     801eaf <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801e83:	8b 45 14             	mov    0x14(%ebp),%eax
  801e86:	8b 10                	mov    (%eax),%edx
  801e88:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e8d:	8d 40 04             	lea    0x4(%eax),%eax
  801e90:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801e93:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801e98:	eb be                	jmp    801e58 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801e9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9d:	8b 10                	mov    (%eax),%edx
  801e9f:	8b 48 04             	mov    0x4(%eax),%ecx
  801ea2:	8d 40 08             	lea    0x8(%eax),%eax
  801ea5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ea8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801ead:	eb a9                	jmp    801e58 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801eaf:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb2:	8b 10                	mov    (%eax),%edx
  801eb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801eb9:	8d 40 04             	lea    0x4(%eax),%eax
  801ebc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ebf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801ec4:	eb 92                	jmp    801e58 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ec6:	83 ec 08             	sub    $0x8,%esp
  801ec9:	53                   	push   %ebx
  801eca:	6a 25                	push   $0x25
  801ecc:	ff d6                	call   *%esi
			break;
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	eb 9f                	jmp    801e72 <vprintfmt+0x3c2>
			putch('%', putdat);
  801ed3:	83 ec 08             	sub    $0x8,%esp
  801ed6:	53                   	push   %ebx
  801ed7:	6a 25                	push   $0x25
  801ed9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801edb:	83 c4 10             	add    $0x10,%esp
  801ede:	89 f8                	mov    %edi,%eax
  801ee0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ee4:	74 05                	je     801eeb <vprintfmt+0x43b>
  801ee6:	83 e8 01             	sub    $0x1,%eax
  801ee9:	eb f5                	jmp    801ee0 <vprintfmt+0x430>
  801eeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eee:	eb 82                	jmp    801e72 <vprintfmt+0x3c2>

00801ef0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 18             	sub    $0x18,%esp
  801ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801efc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801eff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f03:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f0d:	85 c0                	test   %eax,%eax
  801f0f:	74 26                	je     801f37 <vsnprintf+0x47>
  801f11:	85 d2                	test   %edx,%edx
  801f13:	7e 22                	jle    801f37 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f15:	ff 75 14             	push   0x14(%ebp)
  801f18:	ff 75 10             	push   0x10(%ebp)
  801f1b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f1e:	50                   	push   %eax
  801f1f:	68 76 1a 80 00       	push   $0x801a76
  801f24:	e8 87 fb ff ff       	call   801ab0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f29:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f2c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f32:	83 c4 10             	add    $0x10,%esp
}
  801f35:	c9                   	leave  
  801f36:	c3                   	ret    
		return -E_INVAL;
  801f37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f3c:	eb f7                	jmp    801f35 <vsnprintf+0x45>

00801f3e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f44:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f47:	50                   	push   %eax
  801f48:	ff 75 10             	push   0x10(%ebp)
  801f4b:	ff 75 0c             	push   0xc(%ebp)
  801f4e:	ff 75 08             	push   0x8(%ebp)
  801f51:	e8 9a ff ff ff       	call   801ef0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    

00801f58 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	56                   	push   %esi
  801f5c:	53                   	push   %ebx
  801f5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f66:	85 c0                	test   %eax,%eax
  801f68:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f6d:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	50                   	push   %eax
  801f74:	e8 b5 e7 ff ff       	call   80072e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f79:	83 c4 10             	add    $0x10,%esp
  801f7c:	85 f6                	test   %esi,%esi
  801f7e:	74 17                	je     801f97 <ipc_recv+0x3f>
  801f80:	ba 00 00 00 00       	mov    $0x0,%edx
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 0c                	js     801f95 <ipc_recv+0x3d>
  801f89:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f8f:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f95:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f97:	85 db                	test   %ebx,%ebx
  801f99:	74 17                	je     801fb2 <ipc_recv+0x5a>
  801f9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 0c                	js     801fb0 <ipc_recv+0x58>
  801fa4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801faa:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801fb0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fb2:	85 c0                	test   %eax,%eax
  801fb4:	78 0b                	js     801fc1 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801fb6:	a1 00 40 80 00       	mov    0x804000,%eax
  801fbb:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801fc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	57                   	push   %edi
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fda:	85 db                	test   %ebx,%ebx
  801fdc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fe1:	0f 44 d8             	cmove  %eax,%ebx
  801fe4:	eb 05                	jmp    801feb <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fe6:	e8 74 e5 ff ff       	call   80055f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801feb:	ff 75 14             	push   0x14(%ebp)
  801fee:	53                   	push   %ebx
  801fef:	56                   	push   %esi
  801ff0:	57                   	push   %edi
  801ff1:	e8 15 e7 ff ff       	call   80070b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ffc:	74 e8                	je     801fe6 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 08                	js     80200a <ipc_send+0x42>
	}while (r<0);

}
  802002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80200a:	50                   	push   %eax
  80200b:	68 5f 27 80 00       	push   $0x80275f
  802010:	6a 3d                	push   $0x3d
  802012:	68 73 27 80 00       	push   $0x802773
  802017:	e8 c2 f8 ff ff       	call   8018de <_panic>

0080201c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802027:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80202d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802033:	8b 52 60             	mov    0x60(%edx),%edx
  802036:	39 ca                	cmp    %ecx,%edx
  802038:	74 11                	je     80204b <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  80203a:	83 c0 01             	add    $0x1,%eax
  80203d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802042:	75 e3                	jne    802027 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802044:	b8 00 00 00 00       	mov    $0x0,%eax
  802049:	eb 0e                	jmp    802059 <ipc_find_env+0x3d>
			return envs[i].env_id;
  80204b:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  802051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802056:	8b 40 58             	mov    0x58(%eax),%eax
}
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    

0080205b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802061:	89 c2                	mov    %eax,%edx
  802063:	c1 ea 16             	shr    $0x16,%edx
  802066:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80206d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802072:	f6 c1 01             	test   $0x1,%cl
  802075:	74 1c                	je     802093 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802077:	c1 e8 0c             	shr    $0xc,%eax
  80207a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802081:	a8 01                	test   $0x1,%al
  802083:	74 0e                	je     802093 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802085:	c1 e8 0c             	shr    $0xc,%eax
  802088:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80208f:	ef 
  802090:	0f b7 d2             	movzwl %dx,%edx
}
  802093:	89 d0                	mov    %edx,%eax
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    
  802097:	66 90                	xchg   %ax,%ax
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	f3 0f 1e fb          	endbr32 
  8020a4:	55                   	push   %ebp
  8020a5:	57                   	push   %edi
  8020a6:	56                   	push   %esi
  8020a7:	53                   	push   %ebx
  8020a8:	83 ec 1c             	sub    $0x1c,%esp
  8020ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	75 19                	jne    8020d8 <__udivdi3+0x38>
  8020bf:	39 f3                	cmp    %esi,%ebx
  8020c1:	76 4d                	jbe    802110 <__udivdi3+0x70>
  8020c3:	31 ff                	xor    %edi,%edi
  8020c5:	89 e8                	mov    %ebp,%eax
  8020c7:	89 f2                	mov    %esi,%edx
  8020c9:	f7 f3                	div    %ebx
  8020cb:	89 fa                	mov    %edi,%edx
  8020cd:	83 c4 1c             	add    $0x1c,%esp
  8020d0:	5b                   	pop    %ebx
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    
  8020d5:	8d 76 00             	lea    0x0(%esi),%esi
  8020d8:	39 f0                	cmp    %esi,%eax
  8020da:	76 14                	jbe    8020f0 <__udivdi3+0x50>
  8020dc:	31 ff                	xor    %edi,%edi
  8020de:	31 c0                	xor    %eax,%eax
  8020e0:	89 fa                	mov    %edi,%edx
  8020e2:	83 c4 1c             	add    $0x1c,%esp
  8020e5:	5b                   	pop    %ebx
  8020e6:	5e                   	pop    %esi
  8020e7:	5f                   	pop    %edi
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    
  8020ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f0:	0f bd f8             	bsr    %eax,%edi
  8020f3:	83 f7 1f             	xor    $0x1f,%edi
  8020f6:	75 48                	jne    802140 <__udivdi3+0xa0>
  8020f8:	39 f0                	cmp    %esi,%eax
  8020fa:	72 06                	jb     802102 <__udivdi3+0x62>
  8020fc:	31 c0                	xor    %eax,%eax
  8020fe:	39 eb                	cmp    %ebp,%ebx
  802100:	77 de                	ja     8020e0 <__udivdi3+0x40>
  802102:	b8 01 00 00 00       	mov    $0x1,%eax
  802107:	eb d7                	jmp    8020e0 <__udivdi3+0x40>
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d9                	mov    %ebx,%ecx
  802112:	85 db                	test   %ebx,%ebx
  802114:	75 0b                	jne    802121 <__udivdi3+0x81>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f3                	div    %ebx
  80211f:	89 c1                	mov    %eax,%ecx
  802121:	31 d2                	xor    %edx,%edx
  802123:	89 f0                	mov    %esi,%eax
  802125:	f7 f1                	div    %ecx
  802127:	89 c6                	mov    %eax,%esi
  802129:	89 e8                	mov    %ebp,%eax
  80212b:	89 f7                	mov    %esi,%edi
  80212d:	f7 f1                	div    %ecx
  80212f:	89 fa                	mov    %edi,%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 f9                	mov    %edi,%ecx
  802142:	ba 20 00 00 00       	mov    $0x20,%edx
  802147:	29 fa                	sub    %edi,%edx
  802149:	d3 e0                	shl    %cl,%eax
  80214b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80214f:	89 d1                	mov    %edx,%ecx
  802151:	89 d8                	mov    %ebx,%eax
  802153:	d3 e8                	shr    %cl,%eax
  802155:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802159:	09 c1                	or     %eax,%ecx
  80215b:	89 f0                	mov    %esi,%eax
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e3                	shl    %cl,%ebx
  802165:	89 d1                	mov    %edx,%ecx
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 f9                	mov    %edi,%ecx
  80216b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80216f:	89 eb                	mov    %ebp,%ebx
  802171:	d3 e6                	shl    %cl,%esi
  802173:	89 d1                	mov    %edx,%ecx
  802175:	d3 eb                	shr    %cl,%ebx
  802177:	09 f3                	or     %esi,%ebx
  802179:	89 c6                	mov    %eax,%esi
  80217b:	89 f2                	mov    %esi,%edx
  80217d:	89 d8                	mov    %ebx,%eax
  80217f:	f7 74 24 08          	divl   0x8(%esp)
  802183:	89 d6                	mov    %edx,%esi
  802185:	89 c3                	mov    %eax,%ebx
  802187:	f7 64 24 0c          	mull   0xc(%esp)
  80218b:	39 d6                	cmp    %edx,%esi
  80218d:	72 19                	jb     8021a8 <__udivdi3+0x108>
  80218f:	89 f9                	mov    %edi,%ecx
  802191:	d3 e5                	shl    %cl,%ebp
  802193:	39 c5                	cmp    %eax,%ebp
  802195:	73 04                	jae    80219b <__udivdi3+0xfb>
  802197:	39 d6                	cmp    %edx,%esi
  802199:	74 0d                	je     8021a8 <__udivdi3+0x108>
  80219b:	89 d8                	mov    %ebx,%eax
  80219d:	31 ff                	xor    %edi,%edi
  80219f:	e9 3c ff ff ff       	jmp    8020e0 <__udivdi3+0x40>
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021ab:	31 ff                	xor    %edi,%edi
  8021ad:	e9 2e ff ff ff       	jmp    8020e0 <__udivdi3+0x40>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	f3 0f 1e fb          	endbr32 
  8021c4:	55                   	push   %ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 1c             	sub    $0x1c,%esp
  8021cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021db:	89 f0                	mov    %esi,%eax
  8021dd:	89 da                	mov    %ebx,%edx
  8021df:	85 ff                	test   %edi,%edi
  8021e1:	75 15                	jne    8021f8 <__umoddi3+0x38>
  8021e3:	39 dd                	cmp    %ebx,%ebp
  8021e5:	76 39                	jbe    802220 <__umoddi3+0x60>
  8021e7:	f7 f5                	div    %ebp
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	39 df                	cmp    %ebx,%edi
  8021fa:	77 f1                	ja     8021ed <__umoddi3+0x2d>
  8021fc:	0f bd cf             	bsr    %edi,%ecx
  8021ff:	83 f1 1f             	xor    $0x1f,%ecx
  802202:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802206:	75 40                	jne    802248 <__umoddi3+0x88>
  802208:	39 df                	cmp    %ebx,%edi
  80220a:	72 04                	jb     802210 <__umoddi3+0x50>
  80220c:	39 f5                	cmp    %esi,%ebp
  80220e:	77 dd                	ja     8021ed <__umoddi3+0x2d>
  802210:	89 da                	mov    %ebx,%edx
  802212:	89 f0                	mov    %esi,%eax
  802214:	29 e8                	sub    %ebp,%eax
  802216:	19 fa                	sbb    %edi,%edx
  802218:	eb d3                	jmp    8021ed <__umoddi3+0x2d>
  80221a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802220:	89 e9                	mov    %ebp,%ecx
  802222:	85 ed                	test   %ebp,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x71>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f5                	div    %ebp
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	89 d8                	mov    %ebx,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f1                	div    %ecx
  802237:	89 f0                	mov    %esi,%eax
  802239:	f7 f1                	div    %ecx
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	31 d2                	xor    %edx,%edx
  80223f:	eb ac                	jmp    8021ed <__umoddi3+0x2d>
  802241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802248:	8b 44 24 04          	mov    0x4(%esp),%eax
  80224c:	ba 20 00 00 00       	mov    $0x20,%edx
  802251:	29 c2                	sub    %eax,%edx
  802253:	89 c1                	mov    %eax,%ecx
  802255:	89 e8                	mov    %ebp,%eax
  802257:	d3 e7                	shl    %cl,%edi
  802259:	89 d1                	mov    %edx,%ecx
  80225b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80225f:	d3 e8                	shr    %cl,%eax
  802261:	89 c1                	mov    %eax,%ecx
  802263:	8b 44 24 04          	mov    0x4(%esp),%eax
  802267:	09 f9                	or     %edi,%ecx
  802269:	89 df                	mov    %ebx,%edi
  80226b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226f:	89 c1                	mov    %eax,%ecx
  802271:	d3 e5                	shl    %cl,%ebp
  802273:	89 d1                	mov    %edx,%ecx
  802275:	d3 ef                	shr    %cl,%edi
  802277:	89 c1                	mov    %eax,%ecx
  802279:	89 f0                	mov    %esi,%eax
  80227b:	d3 e3                	shl    %cl,%ebx
  80227d:	89 d1                	mov    %edx,%ecx
  80227f:	89 fa                	mov    %edi,%edx
  802281:	d3 e8                	shr    %cl,%eax
  802283:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802288:	09 d8                	or     %ebx,%eax
  80228a:	f7 74 24 08          	divl   0x8(%esp)
  80228e:	89 d3                	mov    %edx,%ebx
  802290:	d3 e6                	shl    %cl,%esi
  802292:	f7 e5                	mul    %ebp
  802294:	89 c7                	mov    %eax,%edi
  802296:	89 d1                	mov    %edx,%ecx
  802298:	39 d3                	cmp    %edx,%ebx
  80229a:	72 06                	jb     8022a2 <__umoddi3+0xe2>
  80229c:	75 0e                	jne    8022ac <__umoddi3+0xec>
  80229e:	39 c6                	cmp    %eax,%esi
  8022a0:	73 0a                	jae    8022ac <__umoddi3+0xec>
  8022a2:	29 e8                	sub    %ebp,%eax
  8022a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022a8:	89 d1                	mov    %edx,%ecx
  8022aa:	89 c7                	mov    %eax,%edi
  8022ac:	89 f5                	mov    %esi,%ebp
  8022ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022b2:	29 fd                	sub    %edi,%ebp
  8022b4:	19 cb                	sbb    %ecx,%ebx
  8022b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022bb:	89 d8                	mov    %ebx,%eax
  8022bd:	d3 e0                	shl    %cl,%eax
  8022bf:	89 f1                	mov    %esi,%ecx
  8022c1:	d3 ed                	shr    %cl,%ebp
  8022c3:	d3 eb                	shr    %cl,%ebx
  8022c5:	09 e8                	or     %ebp,%eax
  8022c7:	89 da                	mov    %ebx,%edx
  8022c9:	83 c4 1c             	add    $0x1c,%esp
  8022cc:	5b                   	pop    %ebx
  8022cd:	5e                   	pop    %esi
  8022ce:	5f                   	pop    %edi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    
