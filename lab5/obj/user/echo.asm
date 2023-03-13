
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
  800058:	68 00 1e 80 00       	push   $0x801e00
  80005d:	ff 76 04             	push   0x4(%esi)
  800060:	e8 cb 01 00 00       	call   800230 <strcmp>
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
  800088:	e8 b7 00 00 00       	call   800144 <strlen>
  80008d:	83 c4 0c             	add    $0xc,%esp
  800090:	50                   	push   %eax
  800091:	ff 34 9e             	push   (%esi,%ebx,4)
  800094:	6a 01                	push   $0x1
  800096:	e8 7a 0a 00 00       	call   800b15 <write>
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
  8000af:	68 03 1e 80 00       	push   $0x801e03
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 5a 0a 00 00       	call   800b15 <write>
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
  8000d3:	68 13 1f 80 00       	push   $0x801f13
  8000d8:	6a 01                	push   $0x1
  8000da:	e8 36 0a 00 00       	call   800b15 <write>
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
  8000ef:	e8 49 04 00 00       	call   80053d <sys_getenvid>
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800106:	85 db                	test   %ebx,%ebx
  800108:	7e 07                	jle    800111 <libmain+0x2d>
		binaryname = argv[0];
  80010a:	8b 06                	mov    (%esi),%eax
  80010c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	e8 18 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011b:	e8 0a 00 00 00       	call   80012a <exit>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800130:	e8 03 08 00 00       	call   800938 <close_all>
	sys_env_destroy(0);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	6a 00                	push   $0x0
  80013a:	e8 bd 03 00 00       	call   8004fc <sys_env_destroy>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80014a:	b8 00 00 00 00       	mov    $0x0,%eax
  80014f:	eb 03                	jmp    800154 <strlen+0x10>
		n++;
  800151:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800154:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800158:	75 f7                	jne    800151 <strlen+0xd>
	return n;
}
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800162:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800165:	b8 00 00 00 00       	mov    $0x0,%eax
  80016a:	eb 03                	jmp    80016f <strnlen+0x13>
		n++;
  80016c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80016f:	39 d0                	cmp    %edx,%eax
  800171:	74 08                	je     80017b <strnlen+0x1f>
  800173:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800177:	75 f3                	jne    80016c <strnlen+0x10>
  800179:	89 c2                	mov    %eax,%edx
	return n;
}
  80017b:	89 d0                	mov    %edx,%eax
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	53                   	push   %ebx
  800183:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800189:	b8 00 00 00 00       	mov    $0x0,%eax
  80018e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800192:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800195:	83 c0 01             	add    $0x1,%eax
  800198:	84 d2                	test   %dl,%dl
  80019a:	75 f2                	jne    80018e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80019c:	89 c8                	mov    %ecx,%eax
  80019e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 10             	sub    $0x10,%esp
  8001aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001ad:	53                   	push   %ebx
  8001ae:	e8 91 ff ff ff       	call   800144 <strlen>
  8001b3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8001b6:	ff 75 0c             	push   0xc(%ebp)
  8001b9:	01 d8                	add    %ebx,%eax
  8001bb:	50                   	push   %eax
  8001bc:	e8 be ff ff ff       	call   80017f <strcpy>
	return dst;
}
  8001c1:	89 d8                	mov    %ebx,%eax
  8001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8001d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d3:	89 f3                	mov    %esi,%ebx
  8001d5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001d8:	89 f0                	mov    %esi,%eax
  8001da:	eb 0f                	jmp    8001eb <strncpy+0x23>
		*dst++ = *src;
  8001dc:	83 c0 01             	add    $0x1,%eax
  8001df:	0f b6 0a             	movzbl (%edx),%ecx
  8001e2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001e5:	80 f9 01             	cmp    $0x1,%cl
  8001e8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8001eb:	39 d8                	cmp    %ebx,%eax
  8001ed:	75 ed                	jne    8001dc <strncpy+0x14>
	}
	return ret;
}
  8001ef:	89 f0                	mov    %esi,%eax
  8001f1:	5b                   	pop    %ebx
  8001f2:	5e                   	pop    %esi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	56                   	push   %esi
  8001f9:	53                   	push   %ebx
  8001fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8001fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800200:	8b 55 10             	mov    0x10(%ebp),%edx
  800203:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800205:	85 d2                	test   %edx,%edx
  800207:	74 21                	je     80022a <strlcpy+0x35>
  800209:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80020d:	89 f2                	mov    %esi,%edx
  80020f:	eb 09                	jmp    80021a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800211:	83 c1 01             	add    $0x1,%ecx
  800214:	83 c2 01             	add    $0x1,%edx
  800217:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80021a:	39 c2                	cmp    %eax,%edx
  80021c:	74 09                	je     800227 <strlcpy+0x32>
  80021e:	0f b6 19             	movzbl (%ecx),%ebx
  800221:	84 db                	test   %bl,%bl
  800223:	75 ec                	jne    800211 <strlcpy+0x1c>
  800225:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800227:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80022a:	29 f0                	sub    %esi,%eax
}
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800236:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800239:	eb 06                	jmp    800241 <strcmp+0x11>
		p++, q++;
  80023b:	83 c1 01             	add    $0x1,%ecx
  80023e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800241:	0f b6 01             	movzbl (%ecx),%eax
  800244:	84 c0                	test   %al,%al
  800246:	74 04                	je     80024c <strcmp+0x1c>
  800248:	3a 02                	cmp    (%edx),%al
  80024a:	74 ef                	je     80023b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80024c:	0f b6 c0             	movzbl %al,%eax
  80024f:	0f b6 12             	movzbl (%edx),%edx
  800252:	29 d0                	sub    %edx,%eax
}
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	53                   	push   %ebx
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800260:	89 c3                	mov    %eax,%ebx
  800262:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800265:	eb 06                	jmp    80026d <strncmp+0x17>
		n--, p++, q++;
  800267:	83 c0 01             	add    $0x1,%eax
  80026a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80026d:	39 d8                	cmp    %ebx,%eax
  80026f:	74 18                	je     800289 <strncmp+0x33>
  800271:	0f b6 08             	movzbl (%eax),%ecx
  800274:	84 c9                	test   %cl,%cl
  800276:	74 04                	je     80027c <strncmp+0x26>
  800278:	3a 0a                	cmp    (%edx),%cl
  80027a:	74 eb                	je     800267 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80027c:	0f b6 00             	movzbl (%eax),%eax
  80027f:	0f b6 12             	movzbl (%edx),%edx
  800282:	29 d0                	sub    %edx,%eax
}
  800284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800287:	c9                   	leave  
  800288:	c3                   	ret    
		return 0;
  800289:	b8 00 00 00 00       	mov    $0x0,%eax
  80028e:	eb f4                	jmp    800284 <strncmp+0x2e>

00800290 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80029a:	eb 03                	jmp    80029f <strchr+0xf>
  80029c:	83 c0 01             	add    $0x1,%eax
  80029f:	0f b6 10             	movzbl (%eax),%edx
  8002a2:	84 d2                	test   %dl,%dl
  8002a4:	74 06                	je     8002ac <strchr+0x1c>
		if (*s == c)
  8002a6:	38 ca                	cmp    %cl,%dl
  8002a8:	75 f2                	jne    80029c <strchr+0xc>
  8002aa:	eb 05                	jmp    8002b1 <strchr+0x21>
			return (char *) s;
	return 0;
  8002ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002bd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002c0:	38 ca                	cmp    %cl,%dl
  8002c2:	74 09                	je     8002cd <strfind+0x1a>
  8002c4:	84 d2                	test   %dl,%dl
  8002c6:	74 05                	je     8002cd <strfind+0x1a>
	for (; *s; s++)
  8002c8:	83 c0 01             	add    $0x1,%eax
  8002cb:	eb f0                	jmp    8002bd <strfind+0xa>
			break;
	return (char *) s;
}
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002db:	85 c9                	test   %ecx,%ecx
  8002dd:	74 2f                	je     80030e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002df:	89 f8                	mov    %edi,%eax
  8002e1:	09 c8                	or     %ecx,%eax
  8002e3:	a8 03                	test   $0x3,%al
  8002e5:	75 21                	jne    800308 <memset+0x39>
		c &= 0xFF;
  8002e7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002eb:	89 d0                	mov    %edx,%eax
  8002ed:	c1 e0 08             	shl    $0x8,%eax
  8002f0:	89 d3                	mov    %edx,%ebx
  8002f2:	c1 e3 18             	shl    $0x18,%ebx
  8002f5:	89 d6                	mov    %edx,%esi
  8002f7:	c1 e6 10             	shl    $0x10,%esi
  8002fa:	09 f3                	or     %esi,%ebx
  8002fc:	09 da                	or     %ebx,%edx
  8002fe:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800300:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800303:	fc                   	cld    
  800304:	f3 ab                	rep stos %eax,%es:(%edi)
  800306:	eb 06                	jmp    80030e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030b:	fc                   	cld    
  80030c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80030e:	89 f8                	mov    %edi,%eax
  800310:	5b                   	pop    %ebx
  800311:	5e                   	pop    %esi
  800312:	5f                   	pop    %edi
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800320:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800323:	39 c6                	cmp    %eax,%esi
  800325:	73 32                	jae    800359 <memmove+0x44>
  800327:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80032a:	39 c2                	cmp    %eax,%edx
  80032c:	76 2b                	jbe    800359 <memmove+0x44>
		s += n;
		d += n;
  80032e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800331:	89 d6                	mov    %edx,%esi
  800333:	09 fe                	or     %edi,%esi
  800335:	09 ce                	or     %ecx,%esi
  800337:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80033d:	75 0e                	jne    80034d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80033f:	83 ef 04             	sub    $0x4,%edi
  800342:	8d 72 fc             	lea    -0x4(%edx),%esi
  800345:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800348:	fd                   	std    
  800349:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80034b:	eb 09                	jmp    800356 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80034d:	83 ef 01             	sub    $0x1,%edi
  800350:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800353:	fd                   	std    
  800354:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800356:	fc                   	cld    
  800357:	eb 1a                	jmp    800373 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800359:	89 f2                	mov    %esi,%edx
  80035b:	09 c2                	or     %eax,%edx
  80035d:	09 ca                	or     %ecx,%edx
  80035f:	f6 c2 03             	test   $0x3,%dl
  800362:	75 0a                	jne    80036e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800364:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800367:	89 c7                	mov    %eax,%edi
  800369:	fc                   	cld    
  80036a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80036c:	eb 05                	jmp    800373 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80036e:	89 c7                	mov    %eax,%edi
  800370:	fc                   	cld    
  800371:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800373:	5e                   	pop    %esi
  800374:	5f                   	pop    %edi
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80037d:	ff 75 10             	push   0x10(%ebp)
  800380:	ff 75 0c             	push   0xc(%ebp)
  800383:	ff 75 08             	push   0x8(%ebp)
  800386:	e8 8a ff ff ff       	call   800315 <memmove>
}
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 c6                	mov    %eax,%esi
  80039a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80039d:	eb 06                	jmp    8003a5 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80039f:	83 c0 01             	add    $0x1,%eax
  8003a2:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8003a5:	39 f0                	cmp    %esi,%eax
  8003a7:	74 14                	je     8003bd <memcmp+0x30>
		if (*s1 != *s2)
  8003a9:	0f b6 08             	movzbl (%eax),%ecx
  8003ac:	0f b6 1a             	movzbl (%edx),%ebx
  8003af:	38 d9                	cmp    %bl,%cl
  8003b1:	74 ec                	je     80039f <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8003b3:	0f b6 c1             	movzbl %cl,%eax
  8003b6:	0f b6 db             	movzbl %bl,%ebx
  8003b9:	29 d8                	sub    %ebx,%eax
  8003bb:	eb 05                	jmp    8003c2 <memcmp+0x35>
	}

	return 0;
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c2:	5b                   	pop    %ebx
  8003c3:	5e                   	pop    %esi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003d4:	eb 03                	jmp    8003d9 <memfind+0x13>
  8003d6:	83 c0 01             	add    $0x1,%eax
  8003d9:	39 d0                	cmp    %edx,%eax
  8003db:	73 04                	jae    8003e1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003dd:	38 08                	cmp    %cl,(%eax)
  8003df:	75 f5                	jne    8003d6 <memfind+0x10>
			break;
	return (void *) s;
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	57                   	push   %edi
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003ef:	eb 03                	jmp    8003f4 <strtol+0x11>
		s++;
  8003f1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  8003f4:	0f b6 02             	movzbl (%edx),%eax
  8003f7:	3c 20                	cmp    $0x20,%al
  8003f9:	74 f6                	je     8003f1 <strtol+0xe>
  8003fb:	3c 09                	cmp    $0x9,%al
  8003fd:	74 f2                	je     8003f1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8003ff:	3c 2b                	cmp    $0x2b,%al
  800401:	74 2a                	je     80042d <strtol+0x4a>
	int neg = 0;
  800403:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800408:	3c 2d                	cmp    $0x2d,%al
  80040a:	74 2b                	je     800437 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80040c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800412:	75 0f                	jne    800423 <strtol+0x40>
  800414:	80 3a 30             	cmpb   $0x30,(%edx)
  800417:	74 28                	je     800441 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800419:	85 db                	test   %ebx,%ebx
  80041b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800420:	0f 44 d8             	cmove  %eax,%ebx
  800423:	b9 00 00 00 00       	mov    $0x0,%ecx
  800428:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80042b:	eb 46                	jmp    800473 <strtol+0x90>
		s++;
  80042d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800430:	bf 00 00 00 00       	mov    $0x0,%edi
  800435:	eb d5                	jmp    80040c <strtol+0x29>
		s++, neg = 1;
  800437:	83 c2 01             	add    $0x1,%edx
  80043a:	bf 01 00 00 00       	mov    $0x1,%edi
  80043f:	eb cb                	jmp    80040c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800441:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800445:	74 0e                	je     800455 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800447:	85 db                	test   %ebx,%ebx
  800449:	75 d8                	jne    800423 <strtol+0x40>
		s++, base = 8;
  80044b:	83 c2 01             	add    $0x1,%edx
  80044e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800453:	eb ce                	jmp    800423 <strtol+0x40>
		s += 2, base = 16;
  800455:	83 c2 02             	add    $0x2,%edx
  800458:	bb 10 00 00 00       	mov    $0x10,%ebx
  80045d:	eb c4                	jmp    800423 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80045f:	0f be c0             	movsbl %al,%eax
  800462:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800465:	3b 45 10             	cmp    0x10(%ebp),%eax
  800468:	7d 3a                	jge    8004a4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80046a:	83 c2 01             	add    $0x1,%edx
  80046d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800471:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800473:	0f b6 02             	movzbl (%edx),%eax
  800476:	8d 70 d0             	lea    -0x30(%eax),%esi
  800479:	89 f3                	mov    %esi,%ebx
  80047b:	80 fb 09             	cmp    $0x9,%bl
  80047e:	76 df                	jbe    80045f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800480:	8d 70 9f             	lea    -0x61(%eax),%esi
  800483:	89 f3                	mov    %esi,%ebx
  800485:	80 fb 19             	cmp    $0x19,%bl
  800488:	77 08                	ja     800492 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80048a:	0f be c0             	movsbl %al,%eax
  80048d:	83 e8 57             	sub    $0x57,%eax
  800490:	eb d3                	jmp    800465 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800492:	8d 70 bf             	lea    -0x41(%eax),%esi
  800495:	89 f3                	mov    %esi,%ebx
  800497:	80 fb 19             	cmp    $0x19,%bl
  80049a:	77 08                	ja     8004a4 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80049c:	0f be c0             	movsbl %al,%eax
  80049f:	83 e8 37             	sub    $0x37,%eax
  8004a2:	eb c1                	jmp    800465 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8004a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a8:	74 05                	je     8004af <strtol+0xcc>
		*endptr = (char *) s;
  8004aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ad:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8004af:	89 c8                	mov    %ecx,%eax
  8004b1:	f7 d8                	neg    %eax
  8004b3:	85 ff                	test   %edi,%edi
  8004b5:	0f 45 c8             	cmovne %eax,%ecx
}
  8004b8:	89 c8                	mov    %ecx,%eax
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	57                   	push   %edi
  8004c3:	56                   	push   %esi
  8004c4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8004cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d0:	89 c3                	mov    %eax,%ebx
  8004d2:	89 c7                	mov    %eax,%edi
  8004d4:	89 c6                	mov    %eax,%esi
  8004d6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d8:	5b                   	pop    %ebx
  8004d9:	5e                   	pop    %esi
  8004da:	5f                   	pop    %edi
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <sys_cgetc>:

int
sys_cgetc(void)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	57                   	push   %edi
  8004e1:	56                   	push   %esi
  8004e2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ed:	89 d1                	mov    %edx,%ecx
  8004ef:	89 d3                	mov    %edx,%ebx
  8004f1:	89 d7                	mov    %edx,%edi
  8004f3:	89 d6                	mov    %edx,%esi
  8004f5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5f                   	pop    %edi
  8004fa:	5d                   	pop    %ebp
  8004fb:	c3                   	ret    

008004fc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fc:	55                   	push   %ebp
  8004fd:	89 e5                	mov    %esp,%ebp
  8004ff:	57                   	push   %edi
  800500:	56                   	push   %esi
  800501:	53                   	push   %ebx
  800502:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800505:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050a:	8b 55 08             	mov    0x8(%ebp),%edx
  80050d:	b8 03 00 00 00       	mov    $0x3,%eax
  800512:	89 cb                	mov    %ecx,%ebx
  800514:	89 cf                	mov    %ecx,%edi
  800516:	89 ce                	mov    %ecx,%esi
  800518:	cd 30                	int    $0x30
	if(check && ret > 0)
  80051a:	85 c0                	test   %eax,%eax
  80051c:	7f 08                	jg     800526 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80051e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800521:	5b                   	pop    %ebx
  800522:	5e                   	pop    %esi
  800523:	5f                   	pop    %edi
  800524:	5d                   	pop    %ebp
  800525:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	50                   	push   %eax
  80052a:	6a 03                	push   $0x3
  80052c:	68 0f 1e 80 00       	push   $0x801e0f
  800531:	6a 2a                	push   $0x2a
  800533:	68 2c 1e 80 00       	push   $0x801e2c
  800538:	e8 d0 0e 00 00       	call   80140d <_panic>

0080053d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	57                   	push   %edi
  800541:	56                   	push   %esi
  800542:	53                   	push   %ebx
	asm volatile("int %1\n"
  800543:	ba 00 00 00 00       	mov    $0x0,%edx
  800548:	b8 02 00 00 00       	mov    $0x2,%eax
  80054d:	89 d1                	mov    %edx,%ecx
  80054f:	89 d3                	mov    %edx,%ebx
  800551:	89 d7                	mov    %edx,%edi
  800553:	89 d6                	mov    %edx,%esi
  800555:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800557:	5b                   	pop    %ebx
  800558:	5e                   	pop    %esi
  800559:	5f                   	pop    %edi
  80055a:	5d                   	pop    %ebp
  80055b:	c3                   	ret    

0080055c <sys_yield>:

void
sys_yield(void)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	57                   	push   %edi
  800560:	56                   	push   %esi
  800561:	53                   	push   %ebx
	asm volatile("int %1\n"
  800562:	ba 00 00 00 00       	mov    $0x0,%edx
  800567:	b8 0b 00 00 00       	mov    $0xb,%eax
  80056c:	89 d1                	mov    %edx,%ecx
  80056e:	89 d3                	mov    %edx,%ebx
  800570:	89 d7                	mov    %edx,%edi
  800572:	89 d6                	mov    %edx,%esi
  800574:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800576:	5b                   	pop    %ebx
  800577:	5e                   	pop    %esi
  800578:	5f                   	pop    %edi
  800579:	5d                   	pop    %ebp
  80057a:	c3                   	ret    

0080057b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80057b:	55                   	push   %ebp
  80057c:	89 e5                	mov    %esp,%ebp
  80057e:	57                   	push   %edi
  80057f:	56                   	push   %esi
  800580:	53                   	push   %ebx
  800581:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800584:	be 00 00 00 00       	mov    $0x0,%esi
  800589:	8b 55 08             	mov    0x8(%ebp),%edx
  80058c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80058f:	b8 04 00 00 00       	mov    $0x4,%eax
  800594:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800597:	89 f7                	mov    %esi,%edi
  800599:	cd 30                	int    $0x30
	if(check && ret > 0)
  80059b:	85 c0                	test   %eax,%eax
  80059d:	7f 08                	jg     8005a7 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80059f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005a2:	5b                   	pop    %ebx
  8005a3:	5e                   	pop    %esi
  8005a4:	5f                   	pop    %edi
  8005a5:	5d                   	pop    %ebp
  8005a6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a7:	83 ec 0c             	sub    $0xc,%esp
  8005aa:	50                   	push   %eax
  8005ab:	6a 04                	push   $0x4
  8005ad:	68 0f 1e 80 00       	push   $0x801e0f
  8005b2:	6a 2a                	push   $0x2a
  8005b4:	68 2c 1e 80 00       	push   $0x801e2c
  8005b9:	e8 4f 0e 00 00       	call   80140d <_panic>

008005be <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
  8005c1:	57                   	push   %edi
  8005c2:	56                   	push   %esi
  8005c3:	53                   	push   %ebx
  8005c4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8005c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8005d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005d5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d8:	8b 75 18             	mov    0x18(%ebp),%esi
  8005db:	cd 30                	int    $0x30
	if(check && ret > 0)
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	7f 08                	jg     8005e9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e4:	5b                   	pop    %ebx
  8005e5:	5e                   	pop    %esi
  8005e6:	5f                   	pop    %edi
  8005e7:	5d                   	pop    %ebp
  8005e8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e9:	83 ec 0c             	sub    $0xc,%esp
  8005ec:	50                   	push   %eax
  8005ed:	6a 05                	push   $0x5
  8005ef:	68 0f 1e 80 00       	push   $0x801e0f
  8005f4:	6a 2a                	push   $0x2a
  8005f6:	68 2c 1e 80 00       	push   $0x801e2c
  8005fb:	e8 0d 0e 00 00       	call   80140d <_panic>

00800600 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800600:	55                   	push   %ebp
  800601:	89 e5                	mov    %esp,%ebp
  800603:	57                   	push   %edi
  800604:	56                   	push   %esi
  800605:	53                   	push   %ebx
  800606:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800609:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060e:	8b 55 08             	mov    0x8(%ebp),%edx
  800611:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800614:	b8 06 00 00 00       	mov    $0x6,%eax
  800619:	89 df                	mov    %ebx,%edi
  80061b:	89 de                	mov    %ebx,%esi
  80061d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80061f:	85 c0                	test   %eax,%eax
  800621:	7f 08                	jg     80062b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80062b:	83 ec 0c             	sub    $0xc,%esp
  80062e:	50                   	push   %eax
  80062f:	6a 06                	push   $0x6
  800631:	68 0f 1e 80 00       	push   $0x801e0f
  800636:	6a 2a                	push   $0x2a
  800638:	68 2c 1e 80 00       	push   $0x801e2c
  80063d:	e8 cb 0d 00 00       	call   80140d <_panic>

00800642 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	57                   	push   %edi
  800646:	56                   	push   %esi
  800647:	53                   	push   %ebx
  800648:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80064b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800650:	8b 55 08             	mov    0x8(%ebp),%edx
  800653:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800656:	b8 08 00 00 00       	mov    $0x8,%eax
  80065b:	89 df                	mov    %ebx,%edi
  80065d:	89 de                	mov    %ebx,%esi
  80065f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800661:	85 c0                	test   %eax,%eax
  800663:	7f 08                	jg     80066d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800668:	5b                   	pop    %ebx
  800669:	5e                   	pop    %esi
  80066a:	5f                   	pop    %edi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80066d:	83 ec 0c             	sub    $0xc,%esp
  800670:	50                   	push   %eax
  800671:	6a 08                	push   $0x8
  800673:	68 0f 1e 80 00       	push   $0x801e0f
  800678:	6a 2a                	push   $0x2a
  80067a:	68 2c 1e 80 00       	push   $0x801e2c
  80067f:	e8 89 0d 00 00       	call   80140d <_panic>

00800684 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	57                   	push   %edi
  800688:	56                   	push   %esi
  800689:	53                   	push   %ebx
  80068a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80068d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800692:	8b 55 08             	mov    0x8(%ebp),%edx
  800695:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800698:	b8 09 00 00 00       	mov    $0x9,%eax
  80069d:	89 df                	mov    %ebx,%edi
  80069f:	89 de                	mov    %ebx,%esi
  8006a1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	7f 08                	jg     8006af <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006aa:	5b                   	pop    %ebx
  8006ab:	5e                   	pop    %esi
  8006ac:	5f                   	pop    %edi
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006af:	83 ec 0c             	sub    $0xc,%esp
  8006b2:	50                   	push   %eax
  8006b3:	6a 09                	push   $0x9
  8006b5:	68 0f 1e 80 00       	push   $0x801e0f
  8006ba:	6a 2a                	push   $0x2a
  8006bc:	68 2c 1e 80 00       	push   $0x801e2c
  8006c1:	e8 47 0d 00 00       	call   80140d <_panic>

008006c6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	57                   	push   %edi
  8006ca:	56                   	push   %esi
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8006cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006df:	89 df                	mov    %ebx,%edi
  8006e1:	89 de                	mov    %ebx,%esi
  8006e3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	7f 08                	jg     8006f1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006f1:	83 ec 0c             	sub    $0xc,%esp
  8006f4:	50                   	push   %eax
  8006f5:	6a 0a                	push   $0xa
  8006f7:	68 0f 1e 80 00       	push   $0x801e0f
  8006fc:	6a 2a                	push   $0x2a
  8006fe:	68 2c 1e 80 00       	push   $0x801e2c
  800703:	e8 05 0d 00 00       	call   80140d <_panic>

00800708 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	57                   	push   %edi
  80070c:	56                   	push   %esi
  80070d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80070e:	8b 55 08             	mov    0x8(%ebp),%edx
  800711:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800714:	b8 0c 00 00 00       	mov    $0xc,%eax
  800719:	be 00 00 00 00       	mov    $0x0,%esi
  80071e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800721:	8b 7d 14             	mov    0x14(%ebp),%edi
  800724:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	57                   	push   %edi
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
  800731:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
  80073c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800741:	89 cb                	mov    %ecx,%ebx
  800743:	89 cf                	mov    %ecx,%edi
  800745:	89 ce                	mov    %ecx,%esi
  800747:	cd 30                	int    $0x30
	if(check && ret > 0)
  800749:	85 c0                	test   %eax,%eax
  80074b:	7f 08                	jg     800755 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80074d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800755:	83 ec 0c             	sub    $0xc,%esp
  800758:	50                   	push   %eax
  800759:	6a 0d                	push   $0xd
  80075b:	68 0f 1e 80 00       	push   $0x801e0f
  800760:	6a 2a                	push   $0x2a
  800762:	68 2c 1e 80 00       	push   $0x801e2c
  800767:	e8 a1 0c 00 00       	call   80140d <_panic>

0080076c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	05 00 00 00 30       	add    $0x30000000,%eax
  800777:	c1 e8 0c             	shr    $0xc,%eax
}
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80077f:	8b 45 08             	mov    0x8(%ebp),%eax
  800782:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800787:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80078c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	c1 ea 16             	shr    $0x16,%edx
  8007a0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a7:	f6 c2 01             	test   $0x1,%dl
  8007aa:	74 29                	je     8007d5 <fd_alloc+0x42>
  8007ac:	89 c2                	mov    %eax,%edx
  8007ae:	c1 ea 0c             	shr    $0xc,%edx
  8007b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007b8:	f6 c2 01             	test   $0x1,%dl
  8007bb:	74 18                	je     8007d5 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8007bd:	05 00 10 00 00       	add    $0x1000,%eax
  8007c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007c7:	75 d2                	jne    80079b <fd_alloc+0x8>
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8007ce:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8007d3:	eb 05                	jmp    8007da <fd_alloc+0x47>
			return 0;
  8007d5:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8007da:	8b 55 08             	mov    0x8(%ebp),%edx
  8007dd:	89 02                	mov    %eax,(%edx)
}
  8007df:	89 c8                	mov    %ecx,%eax
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007e9:	83 f8 1f             	cmp    $0x1f,%eax
  8007ec:	77 30                	ja     80081e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007ee:	c1 e0 0c             	shl    $0xc,%eax
  8007f1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007f6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8007fc:	f6 c2 01             	test   $0x1,%dl
  8007ff:	74 24                	je     800825 <fd_lookup+0x42>
  800801:	89 c2                	mov    %eax,%edx
  800803:	c1 ea 0c             	shr    $0xc,%edx
  800806:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80080d:	f6 c2 01             	test   $0x1,%dl
  800810:	74 1a                	je     80082c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	89 02                	mov    %eax,(%edx)
	return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    
		return -E_INVAL;
  80081e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800823:	eb f7                	jmp    80081c <fd_lookup+0x39>
		return -E_INVAL;
  800825:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082a:	eb f0                	jmp    80081c <fd_lookup+0x39>
  80082c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800831:	eb e9                	jmp    80081c <fd_lookup+0x39>

00800833 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	8b 55 08             	mov    0x8(%ebp),%edx
  80083d:	b8 b8 1e 80 00       	mov    $0x801eb8,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800842:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800847:	39 13                	cmp    %edx,(%ebx)
  800849:	74 32                	je     80087d <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  80084b:	83 c0 04             	add    $0x4,%eax
  80084e:	8b 18                	mov    (%eax),%ebx
  800850:	85 db                	test   %ebx,%ebx
  800852:	75 f3                	jne    800847 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800854:	a1 00 40 80 00       	mov    0x804000,%eax
  800859:	8b 40 48             	mov    0x48(%eax),%eax
  80085c:	83 ec 04             	sub    $0x4,%esp
  80085f:	52                   	push   %edx
  800860:	50                   	push   %eax
  800861:	68 3c 1e 80 00       	push   $0x801e3c
  800866:	e8 7d 0c 00 00       	call   8014e8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	89 1a                	mov    %ebx,(%edx)
}
  800878:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    
			return 0;
  80087d:	b8 00 00 00 00       	mov    $0x0,%eax
  800882:	eb ef                	jmp    800873 <dev_lookup+0x40>

00800884 <fd_close>:
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	57                   	push   %edi
  800888:	56                   	push   %esi
  800889:	53                   	push   %ebx
  80088a:	83 ec 24             	sub    $0x24,%esp
  80088d:	8b 75 08             	mov    0x8(%ebp),%esi
  800890:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800893:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800896:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800897:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80089d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008a0:	50                   	push   %eax
  8008a1:	e8 3d ff ff ff       	call   8007e3 <fd_lookup>
  8008a6:	89 c3                	mov    %eax,%ebx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	78 05                	js     8008b4 <fd_close+0x30>
	    || fd != fd2)
  8008af:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8008b2:	74 16                	je     8008ca <fd_close+0x46>
		return (must_exist ? r : 0);
  8008b4:	89 f8                	mov    %edi,%eax
  8008b6:	84 c0                	test   %al,%al
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bd:	0f 44 d8             	cmove  %eax,%ebx
}
  8008c0:	89 d8                	mov    %ebx,%eax
  8008c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8008d0:	50                   	push   %eax
  8008d1:	ff 36                	push   (%esi)
  8008d3:	e8 5b ff ff ff       	call   800833 <dev_lookup>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1a                	js     8008fb <fd_close+0x77>
		if (dev->dev_close)
  8008e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8008e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8008ec:	85 c0                	test   %eax,%eax
  8008ee:	74 0b                	je     8008fb <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8008f0:	83 ec 0c             	sub    $0xc,%esp
  8008f3:	56                   	push   %esi
  8008f4:	ff d0                	call   *%eax
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8008fb:	83 ec 08             	sub    $0x8,%esp
  8008fe:	56                   	push   %esi
  8008ff:	6a 00                	push   $0x0
  800901:	e8 fa fc ff ff       	call   800600 <sys_page_unmap>
	return r;
  800906:	83 c4 10             	add    $0x10,%esp
  800909:	eb b5                	jmp    8008c0 <fd_close+0x3c>

0080090b <close>:

int
close(int fdnum)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800911:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800914:	50                   	push   %eax
  800915:	ff 75 08             	push   0x8(%ebp)
  800918:	e8 c6 fe ff ff       	call   8007e3 <fd_lookup>
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	85 c0                	test   %eax,%eax
  800922:	79 02                	jns    800926 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    
		return fd_close(fd, 1);
  800926:	83 ec 08             	sub    $0x8,%esp
  800929:	6a 01                	push   $0x1
  80092b:	ff 75 f4             	push   -0xc(%ebp)
  80092e:	e8 51 ff ff ff       	call   800884 <fd_close>
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	eb ec                	jmp    800924 <close+0x19>

00800938 <close_all>:

void
close_all(void)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80093f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800944:	83 ec 0c             	sub    $0xc,%esp
  800947:	53                   	push   %ebx
  800948:	e8 be ff ff ff       	call   80090b <close>
	for (i = 0; i < MAXFD; i++)
  80094d:	83 c3 01             	add    $0x1,%ebx
  800950:	83 c4 10             	add    $0x10,%esp
  800953:	83 fb 20             	cmp    $0x20,%ebx
  800956:	75 ec                	jne    800944 <close_all+0xc>
}
  800958:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800966:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800969:	50                   	push   %eax
  80096a:	ff 75 08             	push   0x8(%ebp)
  80096d:	e8 71 fe ff ff       	call   8007e3 <fd_lookup>
  800972:	89 c3                	mov    %eax,%ebx
  800974:	83 c4 10             	add    $0x10,%esp
  800977:	85 c0                	test   %eax,%eax
  800979:	78 7f                	js     8009fa <dup+0x9d>
		return r;
	close(newfdnum);
  80097b:	83 ec 0c             	sub    $0xc,%esp
  80097e:	ff 75 0c             	push   0xc(%ebp)
  800981:	e8 85 ff ff ff       	call   80090b <close>

	newfd = INDEX2FD(newfdnum);
  800986:	8b 75 0c             	mov    0xc(%ebp),%esi
  800989:	c1 e6 0c             	shl    $0xc,%esi
  80098c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800992:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800995:	89 3c 24             	mov    %edi,(%esp)
  800998:	e8 df fd ff ff       	call   80077c <fd2data>
  80099d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80099f:	89 34 24             	mov    %esi,(%esp)
  8009a2:	e8 d5 fd ff ff       	call   80077c <fd2data>
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	c1 e8 16             	shr    $0x16,%eax
  8009b2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009b9:	a8 01                	test   $0x1,%al
  8009bb:	74 11                	je     8009ce <dup+0x71>
  8009bd:	89 d8                	mov    %ebx,%eax
  8009bf:	c1 e8 0c             	shr    $0xc,%eax
  8009c2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009c9:	f6 c2 01             	test   $0x1,%dl
  8009cc:	75 36                	jne    800a04 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009ce:	89 f8                	mov    %edi,%eax
  8009d0:	c1 e8 0c             	shr    $0xc,%eax
  8009d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009da:	83 ec 0c             	sub    $0xc,%esp
  8009dd:	25 07 0e 00 00       	and    $0xe07,%eax
  8009e2:	50                   	push   %eax
  8009e3:	56                   	push   %esi
  8009e4:	6a 00                	push   $0x0
  8009e6:	57                   	push   %edi
  8009e7:	6a 00                	push   $0x0
  8009e9:	e8 d0 fb ff ff       	call   8005be <sys_page_map>
  8009ee:	89 c3                	mov    %eax,%ebx
  8009f0:	83 c4 20             	add    $0x20,%esp
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	78 33                	js     800a2a <dup+0xcd>
		goto err;

	return newfdnum;
  8009f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8009fa:	89 d8                	mov    %ebx,%eax
  8009fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5f                   	pop    %edi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a0b:	83 ec 0c             	sub    $0xc,%esp
  800a0e:	25 07 0e 00 00       	and    $0xe07,%eax
  800a13:	50                   	push   %eax
  800a14:	ff 75 d4             	push   -0x2c(%ebp)
  800a17:	6a 00                	push   $0x0
  800a19:	53                   	push   %ebx
  800a1a:	6a 00                	push   $0x0
  800a1c:	e8 9d fb ff ff       	call   8005be <sys_page_map>
  800a21:	89 c3                	mov    %eax,%ebx
  800a23:	83 c4 20             	add    $0x20,%esp
  800a26:	85 c0                	test   %eax,%eax
  800a28:	79 a4                	jns    8009ce <dup+0x71>
	sys_page_unmap(0, newfd);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	56                   	push   %esi
  800a2e:	6a 00                	push   $0x0
  800a30:	e8 cb fb ff ff       	call   800600 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a35:	83 c4 08             	add    $0x8,%esp
  800a38:	ff 75 d4             	push   -0x2c(%ebp)
  800a3b:	6a 00                	push   $0x0
  800a3d:	e8 be fb ff ff       	call   800600 <sys_page_unmap>
	return r;
  800a42:	83 c4 10             	add    $0x10,%esp
  800a45:	eb b3                	jmp    8009fa <dup+0x9d>

00800a47 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	56                   	push   %esi
  800a4b:	53                   	push   %ebx
  800a4c:	83 ec 18             	sub    $0x18,%esp
  800a4f:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a52:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a55:	50                   	push   %eax
  800a56:	56                   	push   %esi
  800a57:	e8 87 fd ff ff       	call   8007e3 <fd_lookup>
  800a5c:	83 c4 10             	add    $0x10,%esp
  800a5f:	85 c0                	test   %eax,%eax
  800a61:	78 3c                	js     800a9f <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a63:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800a66:	83 ec 08             	sub    $0x8,%esp
  800a69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6c:	50                   	push   %eax
  800a6d:	ff 33                	push   (%ebx)
  800a6f:	e8 bf fd ff ff       	call   800833 <dev_lookup>
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	85 c0                	test   %eax,%eax
  800a79:	78 24                	js     800a9f <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a7b:	8b 43 08             	mov    0x8(%ebx),%eax
  800a7e:	83 e0 03             	and    $0x3,%eax
  800a81:	83 f8 01             	cmp    $0x1,%eax
  800a84:	74 20                	je     800aa6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a89:	8b 40 08             	mov    0x8(%eax),%eax
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	74 37                	je     800ac7 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a90:	83 ec 04             	sub    $0x4,%esp
  800a93:	ff 75 10             	push   0x10(%ebp)
  800a96:	ff 75 0c             	push   0xc(%ebp)
  800a99:	53                   	push   %ebx
  800a9a:	ff d0                	call   *%eax
  800a9c:	83 c4 10             	add    $0x10,%esp
}
  800a9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800aa6:	a1 00 40 80 00       	mov    0x804000,%eax
  800aab:	8b 40 48             	mov    0x48(%eax),%eax
  800aae:	83 ec 04             	sub    $0x4,%esp
  800ab1:	56                   	push   %esi
  800ab2:	50                   	push   %eax
  800ab3:	68 7d 1e 80 00       	push   $0x801e7d
  800ab8:	e8 2b 0a 00 00       	call   8014e8 <cprintf>
		return -E_INVAL;
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac5:	eb d8                	jmp    800a9f <read+0x58>
		return -E_NOT_SUPP;
  800ac7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800acc:	eb d1                	jmp    800a9f <read+0x58>

00800ace <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	83 ec 0c             	sub    $0xc,%esp
  800ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ada:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800add:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae2:	eb 02                	jmp    800ae6 <readn+0x18>
  800ae4:	01 c3                	add    %eax,%ebx
  800ae6:	39 f3                	cmp    %esi,%ebx
  800ae8:	73 21                	jae    800b0b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aea:	83 ec 04             	sub    $0x4,%esp
  800aed:	89 f0                	mov    %esi,%eax
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	50                   	push   %eax
  800af2:	89 d8                	mov    %ebx,%eax
  800af4:	03 45 0c             	add    0xc(%ebp),%eax
  800af7:	50                   	push   %eax
  800af8:	57                   	push   %edi
  800af9:	e8 49 ff ff ff       	call   800a47 <read>
		if (m < 0)
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	85 c0                	test   %eax,%eax
  800b03:	78 04                	js     800b09 <readn+0x3b>
			return m;
		if (m == 0)
  800b05:	75 dd                	jne    800ae4 <readn+0x16>
  800b07:	eb 02                	jmp    800b0b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b09:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800b0b:	89 d8                	mov    %ebx,%eax
  800b0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 18             	sub    $0x18,%esp
  800b1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b20:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b23:	50                   	push   %eax
  800b24:	53                   	push   %ebx
  800b25:	e8 b9 fc ff ff       	call   8007e3 <fd_lookup>
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	78 37                	js     800b68 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b31:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800b34:	83 ec 08             	sub    $0x8,%esp
  800b37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3a:	50                   	push   %eax
  800b3b:	ff 36                	push   (%esi)
  800b3d:	e8 f1 fc ff ff       	call   800833 <dev_lookup>
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	85 c0                	test   %eax,%eax
  800b47:	78 1f                	js     800b68 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b49:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800b4d:	74 20                	je     800b6f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b52:	8b 40 0c             	mov    0xc(%eax),%eax
  800b55:	85 c0                	test   %eax,%eax
  800b57:	74 37                	je     800b90 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b59:	83 ec 04             	sub    $0x4,%esp
  800b5c:	ff 75 10             	push   0x10(%ebp)
  800b5f:	ff 75 0c             	push   0xc(%ebp)
  800b62:	56                   	push   %esi
  800b63:	ff d0                	call   *%eax
  800b65:	83 c4 10             	add    $0x10,%esp
}
  800b68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b6f:	a1 00 40 80 00       	mov    0x804000,%eax
  800b74:	8b 40 48             	mov    0x48(%eax),%eax
  800b77:	83 ec 04             	sub    $0x4,%esp
  800b7a:	53                   	push   %ebx
  800b7b:	50                   	push   %eax
  800b7c:	68 99 1e 80 00       	push   $0x801e99
  800b81:	e8 62 09 00 00       	call   8014e8 <cprintf>
		return -E_INVAL;
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b8e:	eb d8                	jmp    800b68 <write+0x53>
		return -E_NOT_SUPP;
  800b90:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b95:	eb d1                	jmp    800b68 <write+0x53>

00800b97 <seek>:

int
seek(int fdnum, off_t offset)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba0:	50                   	push   %eax
  800ba1:	ff 75 08             	push   0x8(%ebp)
  800ba4:	e8 3a fc ff ff       	call   8007e3 <fd_lookup>
  800ba9:	83 c4 10             	add    $0x10,%esp
  800bac:	85 c0                	test   %eax,%eax
  800bae:	78 0e                	js     800bbe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bb6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 18             	sub    $0x18,%esp
  800bc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bcb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bce:	50                   	push   %eax
  800bcf:	53                   	push   %ebx
  800bd0:	e8 0e fc ff ff       	call   8007e3 <fd_lookup>
  800bd5:	83 c4 10             	add    $0x10,%esp
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	78 34                	js     800c10 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bdc:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800bdf:	83 ec 08             	sub    $0x8,%esp
  800be2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be5:	50                   	push   %eax
  800be6:	ff 36                	push   (%esi)
  800be8:	e8 46 fc ff ff       	call   800833 <dev_lookup>
  800bed:	83 c4 10             	add    $0x10,%esp
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	78 1c                	js     800c10 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bf4:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800bf8:	74 1d                	je     800c17 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bfd:	8b 40 18             	mov    0x18(%eax),%eax
  800c00:	85 c0                	test   %eax,%eax
  800c02:	74 34                	je     800c38 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c04:	83 ec 08             	sub    $0x8,%esp
  800c07:	ff 75 0c             	push   0xc(%ebp)
  800c0a:	56                   	push   %esi
  800c0b:	ff d0                	call   *%eax
  800c0d:	83 c4 10             	add    $0x10,%esp
}
  800c10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    
			thisenv->env_id, fdnum);
  800c17:	a1 00 40 80 00       	mov    0x804000,%eax
  800c1c:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c1f:	83 ec 04             	sub    $0x4,%esp
  800c22:	53                   	push   %ebx
  800c23:	50                   	push   %eax
  800c24:	68 5c 1e 80 00       	push   $0x801e5c
  800c29:	e8 ba 08 00 00       	call   8014e8 <cprintf>
		return -E_INVAL;
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c36:	eb d8                	jmp    800c10 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800c38:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c3d:	eb d1                	jmp    800c10 <ftruncate+0x50>

00800c3f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 18             	sub    $0x18,%esp
  800c47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c4d:	50                   	push   %eax
  800c4e:	ff 75 08             	push   0x8(%ebp)
  800c51:	e8 8d fb ff ff       	call   8007e3 <fd_lookup>
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	78 49                	js     800ca6 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c5d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c60:	83 ec 08             	sub    $0x8,%esp
  800c63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c66:	50                   	push   %eax
  800c67:	ff 36                	push   (%esi)
  800c69:	e8 c5 fb ff ff       	call   800833 <dev_lookup>
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	85 c0                	test   %eax,%eax
  800c73:	78 31                	js     800ca6 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c78:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c7c:	74 2f                	je     800cad <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c7e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c81:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c88:	00 00 00 
	stat->st_isdir = 0;
  800c8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c92:	00 00 00 
	stat->st_dev = dev;
  800c95:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c9b:	83 ec 08             	sub    $0x8,%esp
  800c9e:	53                   	push   %ebx
  800c9f:	56                   	push   %esi
  800ca0:	ff 50 14             	call   *0x14(%eax)
  800ca3:	83 c4 10             	add    $0x10,%esp
}
  800ca6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    
		return -E_NOT_SUPP;
  800cad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800cb2:	eb f2                	jmp    800ca6 <fstat+0x67>

00800cb4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800cb9:	83 ec 08             	sub    $0x8,%esp
  800cbc:	6a 00                	push   $0x0
  800cbe:	ff 75 08             	push   0x8(%ebp)
  800cc1:	e8 e4 01 00 00       	call   800eaa <open>
  800cc6:	89 c3                	mov    %eax,%ebx
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	78 1b                	js     800cea <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800ccf:	83 ec 08             	sub    $0x8,%esp
  800cd2:	ff 75 0c             	push   0xc(%ebp)
  800cd5:	50                   	push   %eax
  800cd6:	e8 64 ff ff ff       	call   800c3f <fstat>
  800cdb:	89 c6                	mov    %eax,%esi
	close(fd);
  800cdd:	89 1c 24             	mov    %ebx,(%esp)
  800ce0:	e8 26 fc ff ff       	call   80090b <close>
	return r;
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	89 f3                	mov    %esi,%ebx
}
  800cea:	89 d8                	mov    %ebx,%eax
  800cec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	89 c6                	mov    %eax,%esi
  800cfa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800cfc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800d03:	74 27                	je     800d2c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d05:	6a 07                	push   $0x7
  800d07:	68 00 50 80 00       	push   $0x805000
  800d0c:	56                   	push   %esi
  800d0d:	ff 35 00 60 80 00    	push   0x806000
  800d13:	e8 d6 0d 00 00       	call   801aee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d18:	83 c4 0c             	add    $0xc,%esp
  800d1b:	6a 00                	push   $0x0
  800d1d:	53                   	push   %ebx
  800d1e:	6a 00                	push   $0x0
  800d20:	e8 62 0d 00 00       	call   801a87 <ipc_recv>
}
  800d25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	6a 01                	push   $0x1
  800d31:	e8 0c 0e 00 00       	call   801b42 <ipc_find_env>
  800d36:	a3 00 60 80 00       	mov    %eax,0x806000
  800d3b:	83 c4 10             	add    $0x10,%esp
  800d3e:	eb c5                	jmp    800d05 <fsipc+0x12>

00800d40 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	8b 40 0c             	mov    0xc(%eax),%eax
  800d4c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d54:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d59:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d63:	e8 8b ff ff ff       	call   800cf3 <fsipc>
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <devfile_flush>:
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	8b 40 0c             	mov    0xc(%eax),%eax
  800d76:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d80:	b8 06 00 00 00       	mov    $0x6,%eax
  800d85:	e8 69 ff ff ff       	call   800cf3 <fsipc>
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <devfile_stat>:
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 04             	sub    $0x4,%esp
  800d93:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d96:	8b 45 08             	mov    0x8(%ebp),%eax
  800d99:	8b 40 0c             	mov    0xc(%eax),%eax
  800d9c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800da1:	ba 00 00 00 00       	mov    $0x0,%edx
  800da6:	b8 05 00 00 00       	mov    $0x5,%eax
  800dab:	e8 43 ff ff ff       	call   800cf3 <fsipc>
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 2c                	js     800de0 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800db4:	83 ec 08             	sub    $0x8,%esp
  800db7:	68 00 50 80 00       	push   $0x805000
  800dbc:	53                   	push   %ebx
  800dbd:	e8 bd f3 ff ff       	call   80017f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800dc2:	a1 80 50 80 00       	mov    0x805080,%eax
  800dc7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dcd:	a1 84 50 80 00       	mov    0x805084,%eax
  800dd2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <devfile_write>:
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	8b 45 10             	mov    0x10(%ebp),%eax
  800dee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800df3:	39 d0                	cmp    %edx,%eax
  800df5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	8b 52 0c             	mov    0xc(%edx),%edx
  800dfe:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800e04:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800e09:	50                   	push   %eax
  800e0a:	ff 75 0c             	push   0xc(%ebp)
  800e0d:	68 08 50 80 00       	push   $0x805008
  800e12:	e8 fe f4 ff ff       	call   800315 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800e17:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e21:	e8 cd fe ff ff       	call   800cf3 <fsipc>
}
  800e26:	c9                   	leave  
  800e27:	c3                   	ret    

00800e28 <devfile_read>:
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	8b 40 0c             	mov    0xc(%eax),%eax
  800e36:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e3b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e41:	ba 00 00 00 00       	mov    $0x0,%edx
  800e46:	b8 03 00 00 00       	mov    $0x3,%eax
  800e4b:	e8 a3 fe ff ff       	call   800cf3 <fsipc>
  800e50:	89 c3                	mov    %eax,%ebx
  800e52:	85 c0                	test   %eax,%eax
  800e54:	78 1f                	js     800e75 <devfile_read+0x4d>
	assert(r <= n);
  800e56:	39 f0                	cmp    %esi,%eax
  800e58:	77 24                	ja     800e7e <devfile_read+0x56>
	assert(r <= PGSIZE);
  800e5a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e5f:	7f 33                	jg     800e94 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	50                   	push   %eax
  800e65:	68 00 50 80 00       	push   $0x805000
  800e6a:	ff 75 0c             	push   0xc(%ebp)
  800e6d:	e8 a3 f4 ff ff       	call   800315 <memmove>
	return r;
  800e72:	83 c4 10             	add    $0x10,%esp
}
  800e75:	89 d8                	mov    %ebx,%eax
  800e77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    
	assert(r <= n);
  800e7e:	68 c8 1e 80 00       	push   $0x801ec8
  800e83:	68 cf 1e 80 00       	push   $0x801ecf
  800e88:	6a 7c                	push   $0x7c
  800e8a:	68 e4 1e 80 00       	push   $0x801ee4
  800e8f:	e8 79 05 00 00       	call   80140d <_panic>
	assert(r <= PGSIZE);
  800e94:	68 ef 1e 80 00       	push   $0x801eef
  800e99:	68 cf 1e 80 00       	push   $0x801ecf
  800e9e:	6a 7d                	push   $0x7d
  800ea0:	68 e4 1e 80 00       	push   $0x801ee4
  800ea5:	e8 63 05 00 00       	call   80140d <_panic>

00800eaa <open>:
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 1c             	sub    $0x1c,%esp
  800eb2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800eb5:	56                   	push   %esi
  800eb6:	e8 89 f2 ff ff       	call   800144 <strlen>
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ec3:	7f 6c                	jg     800f31 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecb:	50                   	push   %eax
  800ecc:	e8 c2 f8 ff ff       	call   800793 <fd_alloc>
  800ed1:	89 c3                	mov    %eax,%ebx
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 3c                	js     800f16 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800eda:	83 ec 08             	sub    $0x8,%esp
  800edd:	56                   	push   %esi
  800ede:	68 00 50 80 00       	push   $0x805000
  800ee3:	e8 97 f2 ff ff       	call   80017f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eeb:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ef0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ef3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef8:	e8 f6 fd ff ff       	call   800cf3 <fsipc>
  800efd:	89 c3                	mov    %eax,%ebx
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	78 19                	js     800f1f <open+0x75>
	return fd2num(fd);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	ff 75 f4             	push   -0xc(%ebp)
  800f0c:	e8 5b f8 ff ff       	call   80076c <fd2num>
  800f11:	89 c3                	mov    %eax,%ebx
  800f13:	83 c4 10             	add    $0x10,%esp
}
  800f16:	89 d8                	mov    %ebx,%eax
  800f18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    
		fd_close(fd, 0);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	6a 00                	push   $0x0
  800f24:	ff 75 f4             	push   -0xc(%ebp)
  800f27:	e8 58 f9 ff ff       	call   800884 <fd_close>
		return r;
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	eb e5                	jmp    800f16 <open+0x6c>
		return -E_BAD_PATH;
  800f31:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f36:	eb de                	jmp    800f16 <open+0x6c>

00800f38 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f43:	b8 08 00 00 00       	mov    $0x8,%eax
  800f48:	e8 a6 fd ff ff       	call   800cf3 <fsipc>
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	ff 75 08             	push   0x8(%ebp)
  800f5d:	e8 1a f8 ff ff       	call   80077c <fd2data>
  800f62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f64:	83 c4 08             	add    $0x8,%esp
  800f67:	68 fb 1e 80 00       	push   $0x801efb
  800f6c:	53                   	push   %ebx
  800f6d:	e8 0d f2 ff ff       	call   80017f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f72:	8b 46 04             	mov    0x4(%esi),%eax
  800f75:	2b 06                	sub    (%esi),%eax
  800f77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f84:	00 00 00 
	stat->st_dev = &devpipe;
  800f87:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f8e:	30 80 00 
	return 0;
}
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
  800f96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800fa7:	53                   	push   %ebx
  800fa8:	6a 00                	push   $0x0
  800faa:	e8 51 f6 ff ff       	call   800600 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800faf:	89 1c 24             	mov    %ebx,(%esp)
  800fb2:	e8 c5 f7 ff ff       	call   80077c <fd2data>
  800fb7:	83 c4 08             	add    $0x8,%esp
  800fba:	50                   	push   %eax
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 3e f6 ff ff       	call   800600 <sys_page_unmap>
}
  800fc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <_pipeisclosed>:
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	57                   	push   %edi
  800fcb:	56                   	push   %esi
  800fcc:	53                   	push   %ebx
  800fcd:	83 ec 1c             	sub    $0x1c,%esp
  800fd0:	89 c7                	mov    %eax,%edi
  800fd2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800fd4:	a1 00 40 80 00       	mov    0x804000,%eax
  800fd9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	57                   	push   %edi
  800fe0:	e8 96 0b 00 00       	call   801b7b <pageref>
  800fe5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe8:	89 34 24             	mov    %esi,(%esp)
  800feb:	e8 8b 0b 00 00       	call   801b7b <pageref>
		nn = thisenv->env_runs;
  800ff0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800ff6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	39 cb                	cmp    %ecx,%ebx
  800ffe:	74 1b                	je     80101b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801000:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801003:	75 cf                	jne    800fd4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801005:	8b 42 58             	mov    0x58(%edx),%eax
  801008:	6a 01                	push   $0x1
  80100a:	50                   	push   %eax
  80100b:	53                   	push   %ebx
  80100c:	68 02 1f 80 00       	push   $0x801f02
  801011:	e8 d2 04 00 00       	call   8014e8 <cprintf>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	eb b9                	jmp    800fd4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80101b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80101e:	0f 94 c0             	sete   %al
  801021:	0f b6 c0             	movzbl %al,%eax
}
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <devpipe_write>:
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	57                   	push   %edi
  801030:	56                   	push   %esi
  801031:	53                   	push   %ebx
  801032:	83 ec 28             	sub    $0x28,%esp
  801035:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801038:	56                   	push   %esi
  801039:	e8 3e f7 ff ff       	call   80077c <fd2data>
  80103e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	bf 00 00 00 00       	mov    $0x0,%edi
  801048:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80104b:	75 09                	jne    801056 <devpipe_write+0x2a>
	return i;
  80104d:	89 f8                	mov    %edi,%eax
  80104f:	eb 23                	jmp    801074 <devpipe_write+0x48>
			sys_yield();
  801051:	e8 06 f5 ff ff       	call   80055c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801056:	8b 43 04             	mov    0x4(%ebx),%eax
  801059:	8b 0b                	mov    (%ebx),%ecx
  80105b:	8d 51 20             	lea    0x20(%ecx),%edx
  80105e:	39 d0                	cmp    %edx,%eax
  801060:	72 1a                	jb     80107c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801062:	89 da                	mov    %ebx,%edx
  801064:	89 f0                	mov    %esi,%eax
  801066:	e8 5c ff ff ff       	call   800fc7 <_pipeisclosed>
  80106b:	85 c0                	test   %eax,%eax
  80106d:	74 e2                	je     801051 <devpipe_write+0x25>
				return 0;
  80106f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801074:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80107c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801083:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801086:	89 c2                	mov    %eax,%edx
  801088:	c1 fa 1f             	sar    $0x1f,%edx
  80108b:	89 d1                	mov    %edx,%ecx
  80108d:	c1 e9 1b             	shr    $0x1b,%ecx
  801090:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801093:	83 e2 1f             	and    $0x1f,%edx
  801096:	29 ca                	sub    %ecx,%edx
  801098:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80109c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010a0:	83 c0 01             	add    $0x1,%eax
  8010a3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8010a6:	83 c7 01             	add    $0x1,%edi
  8010a9:	eb 9d                	jmp    801048 <devpipe_write+0x1c>

008010ab <devpipe_read>:
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 18             	sub    $0x18,%esp
  8010b4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8010b7:	57                   	push   %edi
  8010b8:	e8 bf f6 ff ff       	call   80077c <fd2data>
  8010bd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	be 00 00 00 00       	mov    $0x0,%esi
  8010c7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8010ca:	75 13                	jne    8010df <devpipe_read+0x34>
	return i;
  8010cc:	89 f0                	mov    %esi,%eax
  8010ce:	eb 02                	jmp    8010d2 <devpipe_read+0x27>
				return i;
  8010d0:	89 f0                	mov    %esi,%eax
}
  8010d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    
			sys_yield();
  8010da:	e8 7d f4 ff ff       	call   80055c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8010df:	8b 03                	mov    (%ebx),%eax
  8010e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8010e4:	75 18                	jne    8010fe <devpipe_read+0x53>
			if (i > 0)
  8010e6:	85 f6                	test   %esi,%esi
  8010e8:	75 e6                	jne    8010d0 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8010ea:	89 da                	mov    %ebx,%edx
  8010ec:	89 f8                	mov    %edi,%eax
  8010ee:	e8 d4 fe ff ff       	call   800fc7 <_pipeisclosed>
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 e3                	je     8010da <devpipe_read+0x2f>
				return 0;
  8010f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010fc:	eb d4                	jmp    8010d2 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010fe:	99                   	cltd   
  8010ff:	c1 ea 1b             	shr    $0x1b,%edx
  801102:	01 d0                	add    %edx,%eax
  801104:	83 e0 1f             	and    $0x1f,%eax
  801107:	29 d0                	sub    %edx,%eax
  801109:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80110e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801111:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801114:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801117:	83 c6 01             	add    $0x1,%esi
  80111a:	eb ab                	jmp    8010c7 <devpipe_read+0x1c>

0080111c <pipe>:
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801124:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	e8 66 f6 ff ff       	call   800793 <fd_alloc>
  80112d:	89 c3                	mov    %eax,%ebx
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	0f 88 23 01 00 00    	js     80125d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	68 07 04 00 00       	push   $0x407
  801142:	ff 75 f4             	push   -0xc(%ebp)
  801145:	6a 00                	push   $0x0
  801147:	e8 2f f4 ff ff       	call   80057b <sys_page_alloc>
  80114c:	89 c3                	mov    %eax,%ebx
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	0f 88 04 01 00 00    	js     80125d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	e8 2e f6 ff ff       	call   800793 <fd_alloc>
  801165:	89 c3                	mov    %eax,%ebx
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	0f 88 db 00 00 00    	js     80124d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	68 07 04 00 00       	push   $0x407
  80117a:	ff 75 f0             	push   -0x10(%ebp)
  80117d:	6a 00                	push   $0x0
  80117f:	e8 f7 f3 ff ff       	call   80057b <sys_page_alloc>
  801184:	89 c3                	mov    %eax,%ebx
  801186:	83 c4 10             	add    $0x10,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	0f 88 bc 00 00 00    	js     80124d <pipe+0x131>
	va = fd2data(fd0);
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	ff 75 f4             	push   -0xc(%ebp)
  801197:	e8 e0 f5 ff ff       	call   80077c <fd2data>
  80119c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80119e:	83 c4 0c             	add    $0xc,%esp
  8011a1:	68 07 04 00 00       	push   $0x407
  8011a6:	50                   	push   %eax
  8011a7:	6a 00                	push   $0x0
  8011a9:	e8 cd f3 ff ff       	call   80057b <sys_page_alloc>
  8011ae:	89 c3                	mov    %eax,%ebx
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	0f 88 82 00 00 00    	js     80123d <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	ff 75 f0             	push   -0x10(%ebp)
  8011c1:	e8 b6 f5 ff ff       	call   80077c <fd2data>
  8011c6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011cd:	50                   	push   %eax
  8011ce:	6a 00                	push   $0x0
  8011d0:	56                   	push   %esi
  8011d1:	6a 00                	push   $0x0
  8011d3:	e8 e6 f3 ff ff       	call   8005be <sys_page_map>
  8011d8:	89 c3                	mov    %eax,%ebx
  8011da:	83 c4 20             	add    $0x20,%esp
  8011dd:	85 c0                	test   %eax,%eax
  8011df:	78 4e                	js     80122f <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8011e1:	a1 20 30 80 00       	mov    0x803020,%eax
  8011e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e9:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8011eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ee:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8011f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011f8:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8011fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	ff 75 f4             	push   -0xc(%ebp)
  80120a:	e8 5d f5 ff ff       	call   80076c <fd2num>
  80120f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801212:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801214:	83 c4 04             	add    $0x4,%esp
  801217:	ff 75 f0             	push   -0x10(%ebp)
  80121a:	e8 4d f5 ff ff       	call   80076c <fd2num>
  80121f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801222:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122d:	eb 2e                	jmp    80125d <pipe+0x141>
	sys_page_unmap(0, va);
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	56                   	push   %esi
  801233:	6a 00                	push   $0x0
  801235:	e8 c6 f3 ff ff       	call   800600 <sys_page_unmap>
  80123a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	ff 75 f0             	push   -0x10(%ebp)
  801243:	6a 00                	push   $0x0
  801245:	e8 b6 f3 ff ff       	call   800600 <sys_page_unmap>
  80124a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80124d:	83 ec 08             	sub    $0x8,%esp
  801250:	ff 75 f4             	push   -0xc(%ebp)
  801253:	6a 00                	push   $0x0
  801255:	e8 a6 f3 ff ff       	call   800600 <sys_page_unmap>
  80125a:	83 c4 10             	add    $0x10,%esp
}
  80125d:	89 d8                	mov    %ebx,%eax
  80125f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801262:	5b                   	pop    %ebx
  801263:	5e                   	pop    %esi
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    

00801266 <pipeisclosed>:
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	ff 75 08             	push   0x8(%ebp)
  801273:	e8 6b f5 ff ff       	call   8007e3 <fd_lookup>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	85 c0                	test   %eax,%eax
  80127d:	78 18                	js     801297 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	ff 75 f4             	push   -0xc(%ebp)
  801285:	e8 f2 f4 ff ff       	call   80077c <fd2data>
  80128a:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80128c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128f:	e8 33 fd ff ff       	call   800fc7 <_pipeisclosed>
  801294:	83 c4 10             	add    $0x10,%esp
}
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
  80129e:	c3                   	ret    

0080129f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012a5:	68 1a 1f 80 00       	push   $0x801f1a
  8012aa:	ff 75 0c             	push   0xc(%ebp)
  8012ad:	e8 cd ee ff ff       	call   80017f <strcpy>
	return 0;
}
  8012b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <devcons_write>:
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	57                   	push   %edi
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8012c5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8012ca:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8012d0:	eb 2e                	jmp    801300 <devcons_write+0x47>
		m = n - tot;
  8012d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d5:	29 f3                	sub    %esi,%ebx
  8012d7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8012dc:	39 c3                	cmp    %eax,%ebx
  8012de:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	53                   	push   %ebx
  8012e5:	89 f0                	mov    %esi,%eax
  8012e7:	03 45 0c             	add    0xc(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	57                   	push   %edi
  8012ec:	e8 24 f0 ff ff       	call   800315 <memmove>
		sys_cputs(buf, m);
  8012f1:	83 c4 08             	add    $0x8,%esp
  8012f4:	53                   	push   %ebx
  8012f5:	57                   	push   %edi
  8012f6:	e8 c4 f1 ff ff       	call   8004bf <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8012fb:	01 de                	add    %ebx,%esi
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	3b 75 10             	cmp    0x10(%ebp),%esi
  801303:	72 cd                	jb     8012d2 <devcons_write+0x19>
}
  801305:	89 f0                	mov    %esi,%eax
  801307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5f                   	pop    %edi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <devcons_read>:
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80131a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80131e:	75 07                	jne    801327 <devcons_read+0x18>
  801320:	eb 1f                	jmp    801341 <devcons_read+0x32>
		sys_yield();
  801322:	e8 35 f2 ff ff       	call   80055c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801327:	e8 b1 f1 ff ff       	call   8004dd <sys_cgetc>
  80132c:	85 c0                	test   %eax,%eax
  80132e:	74 f2                	je     801322 <devcons_read+0x13>
	if (c < 0)
  801330:	78 0f                	js     801341 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801332:	83 f8 04             	cmp    $0x4,%eax
  801335:	74 0c                	je     801343 <devcons_read+0x34>
	*(char*)vbuf = c;
  801337:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133a:	88 02                	mov    %al,(%edx)
	return 1;
  80133c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801341:	c9                   	leave  
  801342:	c3                   	ret    
		return 0;
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
  801348:	eb f7                	jmp    801341 <devcons_read+0x32>

0080134a <cputchar>:
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801350:	8b 45 08             	mov    0x8(%ebp),%eax
  801353:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801356:	6a 01                	push   $0x1
  801358:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	e8 5e f1 ff ff       	call   8004bf <sys_cputs>
}
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	c9                   	leave  
  801365:	c3                   	ret    

00801366 <getchar>:
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80136c:	6a 01                	push   $0x1
  80136e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801371:	50                   	push   %eax
  801372:	6a 00                	push   $0x0
  801374:	e8 ce f6 ff ff       	call   800a47 <read>
	if (r < 0)
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 06                	js     801386 <getchar+0x20>
	if (r < 1)
  801380:	74 06                	je     801388 <getchar+0x22>
	return c;
  801382:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    
		return -E_EOF;
  801388:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80138d:	eb f7                	jmp    801386 <getchar+0x20>

0080138f <iscons>:
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 75 08             	push   0x8(%ebp)
  80139c:	e8 42 f4 ff ff       	call   8007e3 <fd_lookup>
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 11                	js     8013b9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8013a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ab:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013b1:	39 10                	cmp    %edx,(%eax)
  8013b3:	0f 94 c0             	sete   %al
  8013b6:	0f b6 c0             	movzbl %al,%eax
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <opencons>:
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8013c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	e8 c9 f3 ff ff       	call   800793 <fd_alloc>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	78 3a                	js     80140b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	68 07 04 00 00       	push   $0x407
  8013d9:	ff 75 f4             	push   -0xc(%ebp)
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 98 f1 ff ff       	call   80057b <sys_page_alloc>
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 21                	js     80140b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8013ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ed:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013f3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	50                   	push   %eax
  801403:	e8 64 f3 ff ff       	call   80076c <fd2num>
  801408:	83 c4 10             	add    $0x10,%esp
}
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	56                   	push   %esi
  801411:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801412:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801415:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80141b:	e8 1d f1 ff ff       	call   80053d <sys_getenvid>
  801420:	83 ec 0c             	sub    $0xc,%esp
  801423:	ff 75 0c             	push   0xc(%ebp)
  801426:	ff 75 08             	push   0x8(%ebp)
  801429:	56                   	push   %esi
  80142a:	50                   	push   %eax
  80142b:	68 28 1f 80 00       	push   $0x801f28
  801430:	e8 b3 00 00 00       	call   8014e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801435:	83 c4 18             	add    $0x18,%esp
  801438:	53                   	push   %ebx
  801439:	ff 75 10             	push   0x10(%ebp)
  80143c:	e8 56 00 00 00       	call   801497 <vcprintf>
	cprintf("\n");
  801441:	c7 04 24 13 1f 80 00 	movl   $0x801f13,(%esp)
  801448:	e8 9b 00 00 00       	call   8014e8 <cprintf>
  80144d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801450:	cc                   	int3   
  801451:	eb fd                	jmp    801450 <_panic+0x43>

00801453 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	53                   	push   %ebx
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80145d:	8b 13                	mov    (%ebx),%edx
  80145f:	8d 42 01             	lea    0x1(%edx),%eax
  801462:	89 03                	mov    %eax,(%ebx)
  801464:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801467:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80146b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801470:	74 09                	je     80147b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801472:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801476:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801479:	c9                   	leave  
  80147a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	68 ff 00 00 00       	push   $0xff
  801483:	8d 43 08             	lea    0x8(%ebx),%eax
  801486:	50                   	push   %eax
  801487:	e8 33 f0 ff ff       	call   8004bf <sys_cputs>
		b->idx = 0;
  80148c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb db                	jmp    801472 <putch+0x1f>

00801497 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014a7:	00 00 00 
	b.cnt = 0;
  8014aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014b4:	ff 75 0c             	push   0xc(%ebp)
  8014b7:	ff 75 08             	push   0x8(%ebp)
  8014ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	68 53 14 80 00       	push   $0x801453
  8014c6:	e8 14 01 00 00       	call   8015df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014cb:	83 c4 08             	add    $0x8,%esp
  8014ce:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8014d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	e8 df ef ff ff       	call   8004bf <sys_cputs>

	return b.cnt;
}
  8014e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    

008014e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014f1:	50                   	push   %eax
  8014f2:	ff 75 08             	push   0x8(%ebp)
  8014f5:	e8 9d ff ff ff       	call   801497 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	57                   	push   %edi
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
  801502:	83 ec 1c             	sub    $0x1c,%esp
  801505:	89 c7                	mov    %eax,%edi
  801507:	89 d6                	mov    %edx,%esi
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
  80150c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150f:	89 d1                	mov    %edx,%ecx
  801511:	89 c2                	mov    %eax,%edx
  801513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801516:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801519:	8b 45 10             	mov    0x10(%ebp),%eax
  80151c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80151f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801522:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801529:	39 c2                	cmp    %eax,%edx
  80152b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80152e:	72 3e                	jb     80156e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801530:	83 ec 0c             	sub    $0xc,%esp
  801533:	ff 75 18             	push   0x18(%ebp)
  801536:	83 eb 01             	sub    $0x1,%ebx
  801539:	53                   	push   %ebx
  80153a:	50                   	push   %eax
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	ff 75 e4             	push   -0x1c(%ebp)
  801541:	ff 75 e0             	push   -0x20(%ebp)
  801544:	ff 75 dc             	push   -0x24(%ebp)
  801547:	ff 75 d8             	push   -0x28(%ebp)
  80154a:	e8 71 06 00 00       	call   801bc0 <__udivdi3>
  80154f:	83 c4 18             	add    $0x18,%esp
  801552:	52                   	push   %edx
  801553:	50                   	push   %eax
  801554:	89 f2                	mov    %esi,%edx
  801556:	89 f8                	mov    %edi,%eax
  801558:	e8 9f ff ff ff       	call   8014fc <printnum>
  80155d:	83 c4 20             	add    $0x20,%esp
  801560:	eb 13                	jmp    801575 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	56                   	push   %esi
  801566:	ff 75 18             	push   0x18(%ebp)
  801569:	ff d7                	call   *%edi
  80156b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80156e:	83 eb 01             	sub    $0x1,%ebx
  801571:	85 db                	test   %ebx,%ebx
  801573:	7f ed                	jg     801562 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	56                   	push   %esi
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	ff 75 e4             	push   -0x1c(%ebp)
  80157f:	ff 75 e0             	push   -0x20(%ebp)
  801582:	ff 75 dc             	push   -0x24(%ebp)
  801585:	ff 75 d8             	push   -0x28(%ebp)
  801588:	e8 53 07 00 00       	call   801ce0 <__umoddi3>
  80158d:	83 c4 14             	add    $0x14,%esp
  801590:	0f be 80 4b 1f 80 00 	movsbl 0x801f4b(%eax),%eax
  801597:	50                   	push   %eax
  801598:	ff d7                	call   *%edi
}
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5f                   	pop    %edi
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015af:	8b 10                	mov    (%eax),%edx
  8015b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8015b4:	73 0a                	jae    8015c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015b9:	89 08                	mov    %ecx,(%eax)
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	88 02                	mov    %al,(%edx)
}
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <printfmt>:
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8015c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 10             	push   0x10(%ebp)
  8015cf:	ff 75 0c             	push   0xc(%ebp)
  8015d2:	ff 75 08             	push   0x8(%ebp)
  8015d5:	e8 05 00 00 00       	call   8015df <vprintfmt>
}
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <vprintfmt>:
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	57                   	push   %edi
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 3c             	sub    $0x3c,%esp
  8015e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015f1:	eb 0a                	jmp    8015fd <vprintfmt+0x1e>
			putch(ch, putdat);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	53                   	push   %ebx
  8015f7:	50                   	push   %eax
  8015f8:	ff d6                	call   *%esi
  8015fa:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015fd:	83 c7 01             	add    $0x1,%edi
  801600:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801604:	83 f8 25             	cmp    $0x25,%eax
  801607:	74 0c                	je     801615 <vprintfmt+0x36>
			if (ch == '\0')
  801609:	85 c0                	test   %eax,%eax
  80160b:	75 e6                	jne    8015f3 <vprintfmt+0x14>
}
  80160d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5f                   	pop    %edi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    
		padc = ' ';
  801615:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801619:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801620:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801627:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80162e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801633:	8d 47 01             	lea    0x1(%edi),%eax
  801636:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801639:	0f b6 17             	movzbl (%edi),%edx
  80163c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80163f:	3c 55                	cmp    $0x55,%al
  801641:	0f 87 bb 03 00 00    	ja     801a02 <vprintfmt+0x423>
  801647:	0f b6 c0             	movzbl %al,%eax
  80164a:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801654:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801658:	eb d9                	jmp    801633 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80165a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80165d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801661:	eb d0                	jmp    801633 <vprintfmt+0x54>
  801663:	0f b6 d2             	movzbl %dl,%edx
  801666:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801669:	b8 00 00 00 00       	mov    $0x0,%eax
  80166e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801671:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801674:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801678:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80167b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80167e:	83 f9 09             	cmp    $0x9,%ecx
  801681:	77 55                	ja     8016d8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801683:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801686:	eb e9                	jmp    801671 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801688:	8b 45 14             	mov    0x14(%ebp),%eax
  80168b:	8b 00                	mov    (%eax),%eax
  80168d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801690:	8b 45 14             	mov    0x14(%ebp),%eax
  801693:	8d 40 04             	lea    0x4(%eax),%eax
  801696:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80169c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016a0:	79 91                	jns    801633 <vprintfmt+0x54>
				width = precision, precision = -1;
  8016a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8016a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016a8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8016af:	eb 82                	jmp    801633 <vprintfmt+0x54>
  8016b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8016b4:	85 d2                	test   %edx,%edx
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bb:	0f 49 c2             	cmovns %edx,%eax
  8016be:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8016c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8016c4:	e9 6a ff ff ff       	jmp    801633 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8016c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8016cc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8016d3:	e9 5b ff ff ff       	jmp    801633 <vprintfmt+0x54>
  8016d8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8016db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016de:	eb bc                	jmp    80169c <vprintfmt+0xbd>
			lflag++;
  8016e0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8016e6:	e9 48 ff ff ff       	jmp    801633 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8016eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ee:	8d 78 04             	lea    0x4(%eax),%edi
  8016f1:	83 ec 08             	sub    $0x8,%esp
  8016f4:	53                   	push   %ebx
  8016f5:	ff 30                	push   (%eax)
  8016f7:	ff d6                	call   *%esi
			break;
  8016f9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8016fc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8016ff:	e9 9d 02 00 00       	jmp    8019a1 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  801704:	8b 45 14             	mov    0x14(%ebp),%eax
  801707:	8d 78 04             	lea    0x4(%eax),%edi
  80170a:	8b 10                	mov    (%eax),%edx
  80170c:	89 d0                	mov    %edx,%eax
  80170e:	f7 d8                	neg    %eax
  801710:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801713:	83 f8 0f             	cmp    $0xf,%eax
  801716:	7f 23                	jg     80173b <vprintfmt+0x15c>
  801718:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  80171f:	85 d2                	test   %edx,%edx
  801721:	74 18                	je     80173b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801723:	52                   	push   %edx
  801724:	68 e1 1e 80 00       	push   $0x801ee1
  801729:	53                   	push   %ebx
  80172a:	56                   	push   %esi
  80172b:	e8 92 fe ff ff       	call   8015c2 <printfmt>
  801730:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801733:	89 7d 14             	mov    %edi,0x14(%ebp)
  801736:	e9 66 02 00 00       	jmp    8019a1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80173b:	50                   	push   %eax
  80173c:	68 63 1f 80 00       	push   $0x801f63
  801741:	53                   	push   %ebx
  801742:	56                   	push   %esi
  801743:	e8 7a fe ff ff       	call   8015c2 <printfmt>
  801748:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80174b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80174e:	e9 4e 02 00 00       	jmp    8019a1 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801753:	8b 45 14             	mov    0x14(%ebp),%eax
  801756:	83 c0 04             	add    $0x4,%eax
  801759:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80175c:	8b 45 14             	mov    0x14(%ebp),%eax
  80175f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801761:	85 d2                	test   %edx,%edx
  801763:	b8 5c 1f 80 00       	mov    $0x801f5c,%eax
  801768:	0f 45 c2             	cmovne %edx,%eax
  80176b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80176e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801772:	7e 06                	jle    80177a <vprintfmt+0x19b>
  801774:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801778:	75 0d                	jne    801787 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80177a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80177d:	89 c7                	mov    %eax,%edi
  80177f:	03 45 e0             	add    -0x20(%ebp),%eax
  801782:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801785:	eb 55                	jmp    8017dc <vprintfmt+0x1fd>
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	ff 75 d8             	push   -0x28(%ebp)
  80178d:	ff 75 cc             	push   -0x34(%ebp)
  801790:	e8 c7 e9 ff ff       	call   80015c <strnlen>
  801795:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801798:	29 c1                	sub    %eax,%ecx
  80179a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8017a2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8017a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8017a9:	eb 0f                	jmp    8017ba <vprintfmt+0x1db>
					putch(padc, putdat);
  8017ab:	83 ec 08             	sub    $0x8,%esp
  8017ae:	53                   	push   %ebx
  8017af:	ff 75 e0             	push   -0x20(%ebp)
  8017b2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8017b4:	83 ef 01             	sub    $0x1,%edi
  8017b7:	83 c4 10             	add    $0x10,%esp
  8017ba:	85 ff                	test   %edi,%edi
  8017bc:	7f ed                	jg     8017ab <vprintfmt+0x1cc>
  8017be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8017c1:	85 d2                	test   %edx,%edx
  8017c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c8:	0f 49 c2             	cmovns %edx,%eax
  8017cb:	29 c2                	sub    %eax,%edx
  8017cd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8017d0:	eb a8                	jmp    80177a <vprintfmt+0x19b>
					putch(ch, putdat);
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	53                   	push   %ebx
  8017d6:	52                   	push   %edx
  8017d7:	ff d6                	call   *%esi
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017df:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017e1:	83 c7 01             	add    $0x1,%edi
  8017e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017e8:	0f be d0             	movsbl %al,%edx
  8017eb:	85 d2                	test   %edx,%edx
  8017ed:	74 4b                	je     80183a <vprintfmt+0x25b>
  8017ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017f3:	78 06                	js     8017fb <vprintfmt+0x21c>
  8017f5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8017f9:	78 1e                	js     801819 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8017fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8017ff:	74 d1                	je     8017d2 <vprintfmt+0x1f3>
  801801:	0f be c0             	movsbl %al,%eax
  801804:	83 e8 20             	sub    $0x20,%eax
  801807:	83 f8 5e             	cmp    $0x5e,%eax
  80180a:	76 c6                	jbe    8017d2 <vprintfmt+0x1f3>
					putch('?', putdat);
  80180c:	83 ec 08             	sub    $0x8,%esp
  80180f:	53                   	push   %ebx
  801810:	6a 3f                	push   $0x3f
  801812:	ff d6                	call   *%esi
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	eb c3                	jmp    8017dc <vprintfmt+0x1fd>
  801819:	89 cf                	mov    %ecx,%edi
  80181b:	eb 0e                	jmp    80182b <vprintfmt+0x24c>
				putch(' ', putdat);
  80181d:	83 ec 08             	sub    $0x8,%esp
  801820:	53                   	push   %ebx
  801821:	6a 20                	push   $0x20
  801823:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801825:	83 ef 01             	sub    $0x1,%edi
  801828:	83 c4 10             	add    $0x10,%esp
  80182b:	85 ff                	test   %edi,%edi
  80182d:	7f ee                	jg     80181d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80182f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801832:	89 45 14             	mov    %eax,0x14(%ebp)
  801835:	e9 67 01 00 00       	jmp    8019a1 <vprintfmt+0x3c2>
  80183a:	89 cf                	mov    %ecx,%edi
  80183c:	eb ed                	jmp    80182b <vprintfmt+0x24c>
	if (lflag >= 2)
  80183e:	83 f9 01             	cmp    $0x1,%ecx
  801841:	7f 1b                	jg     80185e <vprintfmt+0x27f>
	else if (lflag)
  801843:	85 c9                	test   %ecx,%ecx
  801845:	74 63                	je     8018aa <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801847:	8b 45 14             	mov    0x14(%ebp),%eax
  80184a:	8b 00                	mov    (%eax),%eax
  80184c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80184f:	99                   	cltd   
  801850:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801853:	8b 45 14             	mov    0x14(%ebp),%eax
  801856:	8d 40 04             	lea    0x4(%eax),%eax
  801859:	89 45 14             	mov    %eax,0x14(%ebp)
  80185c:	eb 17                	jmp    801875 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80185e:	8b 45 14             	mov    0x14(%ebp),%eax
  801861:	8b 50 04             	mov    0x4(%eax),%edx
  801864:	8b 00                	mov    (%eax),%eax
  801866:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801869:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80186c:	8b 45 14             	mov    0x14(%ebp),%eax
  80186f:	8d 40 08             	lea    0x8(%eax),%eax
  801872:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801875:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801878:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80187b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801880:	85 c9                	test   %ecx,%ecx
  801882:	0f 89 ff 00 00 00    	jns    801987 <vprintfmt+0x3a8>
				putch('-', putdat);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	53                   	push   %ebx
  80188c:	6a 2d                	push   $0x2d
  80188e:	ff d6                	call   *%esi
				num = -(long long) num;
  801890:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801893:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801896:	f7 da                	neg    %edx
  801898:	83 d1 00             	adc    $0x0,%ecx
  80189b:	f7 d9                	neg    %ecx
  80189d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8018a0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8018a5:	e9 dd 00 00 00       	jmp    801987 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8018aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ad:	8b 00                	mov    (%eax),%eax
  8018af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018b2:	99                   	cltd   
  8018b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b9:	8d 40 04             	lea    0x4(%eax),%eax
  8018bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8018bf:	eb b4                	jmp    801875 <vprintfmt+0x296>
	if (lflag >= 2)
  8018c1:	83 f9 01             	cmp    $0x1,%ecx
  8018c4:	7f 1e                	jg     8018e4 <vprintfmt+0x305>
	else if (lflag)
  8018c6:	85 c9                	test   %ecx,%ecx
  8018c8:	74 32                	je     8018fc <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8018ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8018cd:	8b 10                	mov    (%eax),%edx
  8018cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018d4:	8d 40 04             	lea    0x4(%eax),%eax
  8018d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8018da:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8018df:	e9 a3 00 00 00       	jmp    801987 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8018e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e7:	8b 10                	mov    (%eax),%edx
  8018e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8018ec:	8d 40 08             	lea    0x8(%eax),%eax
  8018ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8018f2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8018f7:	e9 8b 00 00 00       	jmp    801987 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8018fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ff:	8b 10                	mov    (%eax),%edx
  801901:	b9 00 00 00 00       	mov    $0x0,%ecx
  801906:	8d 40 04             	lea    0x4(%eax),%eax
  801909:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80190c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801911:	eb 74                	jmp    801987 <vprintfmt+0x3a8>
	if (lflag >= 2)
  801913:	83 f9 01             	cmp    $0x1,%ecx
  801916:	7f 1b                	jg     801933 <vprintfmt+0x354>
	else if (lflag)
  801918:	85 c9                	test   %ecx,%ecx
  80191a:	74 2c                	je     801948 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80191c:	8b 45 14             	mov    0x14(%ebp),%eax
  80191f:	8b 10                	mov    (%eax),%edx
  801921:	b9 00 00 00 00       	mov    $0x0,%ecx
  801926:	8d 40 04             	lea    0x4(%eax),%eax
  801929:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80192c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801931:	eb 54                	jmp    801987 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801933:	8b 45 14             	mov    0x14(%ebp),%eax
  801936:	8b 10                	mov    (%eax),%edx
  801938:	8b 48 04             	mov    0x4(%eax),%ecx
  80193b:	8d 40 08             	lea    0x8(%eax),%eax
  80193e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801941:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801946:	eb 3f                	jmp    801987 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801948:	8b 45 14             	mov    0x14(%ebp),%eax
  80194b:	8b 10                	mov    (%eax),%edx
  80194d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801952:	8d 40 04             	lea    0x4(%eax),%eax
  801955:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801958:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80195d:	eb 28                	jmp    801987 <vprintfmt+0x3a8>
			putch('0', putdat);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	53                   	push   %ebx
  801963:	6a 30                	push   $0x30
  801965:	ff d6                	call   *%esi
			putch('x', putdat);
  801967:	83 c4 08             	add    $0x8,%esp
  80196a:	53                   	push   %ebx
  80196b:	6a 78                	push   $0x78
  80196d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80196f:	8b 45 14             	mov    0x14(%ebp),%eax
  801972:	8b 10                	mov    (%eax),%edx
  801974:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801979:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80197c:	8d 40 04             	lea    0x4(%eax),%eax
  80197f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801982:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80198e:	50                   	push   %eax
  80198f:	ff 75 e0             	push   -0x20(%ebp)
  801992:	57                   	push   %edi
  801993:	51                   	push   %ecx
  801994:	52                   	push   %edx
  801995:	89 da                	mov    %ebx,%edx
  801997:	89 f0                	mov    %esi,%eax
  801999:	e8 5e fb ff ff       	call   8014fc <printnum>
			break;
  80199e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8019a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019a4:	e9 54 fc ff ff       	jmp    8015fd <vprintfmt+0x1e>
	if (lflag >= 2)
  8019a9:	83 f9 01             	cmp    $0x1,%ecx
  8019ac:	7f 1b                	jg     8019c9 <vprintfmt+0x3ea>
	else if (lflag)
  8019ae:	85 c9                	test   %ecx,%ecx
  8019b0:	74 2c                	je     8019de <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8019b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b5:	8b 10                	mov    (%eax),%edx
  8019b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019bc:	8d 40 04             	lea    0x4(%eax),%eax
  8019bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019c2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8019c7:	eb be                	jmp    801987 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cc:	8b 10                	mov    (%eax),%edx
  8019ce:	8b 48 04             	mov    0x4(%eax),%ecx
  8019d1:	8d 40 08             	lea    0x8(%eax),%eax
  8019d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019d7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8019dc:	eb a9                	jmp    801987 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019de:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e1:	8b 10                	mov    (%eax),%edx
  8019e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e8:	8d 40 04             	lea    0x4(%eax),%eax
  8019eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019ee:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8019f3:	eb 92                	jmp    801987 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	53                   	push   %ebx
  8019f9:	6a 25                	push   $0x25
  8019fb:	ff d6                	call   *%esi
			break;
  8019fd:	83 c4 10             	add    $0x10,%esp
  801a00:	eb 9f                	jmp    8019a1 <vprintfmt+0x3c2>
			putch('%', putdat);
  801a02:	83 ec 08             	sub    $0x8,%esp
  801a05:	53                   	push   %ebx
  801a06:	6a 25                	push   $0x25
  801a08:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	89 f8                	mov    %edi,%eax
  801a0f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801a13:	74 05                	je     801a1a <vprintfmt+0x43b>
  801a15:	83 e8 01             	sub    $0x1,%eax
  801a18:	eb f5                	jmp    801a0f <vprintfmt+0x430>
  801a1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a1d:	eb 82                	jmp    8019a1 <vprintfmt+0x3c2>

00801a1f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	83 ec 18             	sub    $0x18,%esp
  801a25:	8b 45 08             	mov    0x8(%ebp),%eax
  801a28:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a2e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a32:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	74 26                	je     801a66 <vsnprintf+0x47>
  801a40:	85 d2                	test   %edx,%edx
  801a42:	7e 22                	jle    801a66 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a44:	ff 75 14             	push   0x14(%ebp)
  801a47:	ff 75 10             	push   0x10(%ebp)
  801a4a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a4d:	50                   	push   %eax
  801a4e:	68 a5 15 80 00       	push   $0x8015a5
  801a53:	e8 87 fb ff ff       	call   8015df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a58:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a5b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a61:	83 c4 10             	add    $0x10,%esp
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    
		return -E_INVAL;
  801a66:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a6b:	eb f7                	jmp    801a64 <vsnprintf+0x45>

00801a6d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a73:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a76:	50                   	push   %eax
  801a77:	ff 75 10             	push   0x10(%ebp)
  801a7a:	ff 75 0c             	push   0xc(%ebp)
  801a7d:	ff 75 08             	push   0x8(%ebp)
  801a80:	e8 9a ff ff ff       	call   801a1f <vsnprintf>
	va_end(ap);

	return rc;
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801a95:	85 c0                	test   %eax,%eax
  801a97:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a9c:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	50                   	push   %eax
  801aa3:	e8 83 ec ff ff       	call   80072b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	85 f6                	test   %esi,%esi
  801aad:	74 14                	je     801ac3 <ipc_recv+0x3c>
  801aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	78 09                	js     801ac1 <ipc_recv+0x3a>
  801ab8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801abe:	8b 52 74             	mov    0x74(%edx),%edx
  801ac1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ac3:	85 db                	test   %ebx,%ebx
  801ac5:	74 14                	je     801adb <ipc_recv+0x54>
  801ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 09                	js     801ad9 <ipc_recv+0x52>
  801ad0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ad6:	8b 52 78             	mov    0x78(%edx),%edx
  801ad9:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 08                	js     801ae7 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801adf:	a1 00 40 80 00       	mov    0x804000,%eax
  801ae4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	57                   	push   %edi
  801af2:	56                   	push   %esi
  801af3:	53                   	push   %ebx
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afa:	8b 75 0c             	mov    0xc(%ebp),%esi
  801afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801b00:	85 db                	test   %ebx,%ebx
  801b02:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b07:	0f 44 d8             	cmove  %eax,%ebx
  801b0a:	eb 05                	jmp    801b11 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b0c:	e8 4b ea ff ff       	call   80055c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801b11:	ff 75 14             	push   0x14(%ebp)
  801b14:	53                   	push   %ebx
  801b15:	56                   	push   %esi
  801b16:	57                   	push   %edi
  801b17:	e8 ec eb ff ff       	call   800708 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b1c:	83 c4 10             	add    $0x10,%esp
  801b1f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b22:	74 e8                	je     801b0c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 08                	js     801b30 <ipc_send+0x42>
	}while (r<0);

}
  801b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5f                   	pop    %edi
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b30:	50                   	push   %eax
  801b31:	68 3f 22 80 00       	push   $0x80223f
  801b36:	6a 3d                	push   $0x3d
  801b38:	68 53 22 80 00       	push   $0x802253
  801b3d:	e8 cb f8 ff ff       	call   80140d <_panic>

00801b42 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b48:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b4d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b50:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b56:	8b 52 50             	mov    0x50(%edx),%edx
  801b59:	39 ca                	cmp    %ecx,%edx
  801b5b:	74 11                	je     801b6e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b5d:	83 c0 01             	add    $0x1,%eax
  801b60:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b65:	75 e6                	jne    801b4d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6c:	eb 0b                	jmp    801b79 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b6e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b71:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b76:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b81:	89 c2                	mov    %eax,%edx
  801b83:	c1 ea 16             	shr    $0x16,%edx
  801b86:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b8d:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b92:	f6 c1 01             	test   $0x1,%cl
  801b95:	74 1c                	je     801bb3 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b97:	c1 e8 0c             	shr    $0xc,%eax
  801b9a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ba1:	a8 01                	test   $0x1,%al
  801ba3:	74 0e                	je     801bb3 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba5:	c1 e8 0c             	shr    $0xc,%eax
  801ba8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801baf:	ef 
  801bb0:	0f b7 d2             	movzwl %dx,%edx
}
  801bb3:	89 d0                	mov    %edx,%eax
  801bb5:	5d                   	pop    %ebp
  801bb6:	c3                   	ret    
  801bb7:	66 90                	xchg   %ax,%ax
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	f3 0f 1e fb          	endbr32 
  801bc4:	55                   	push   %ebp
  801bc5:	57                   	push   %edi
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	83 ec 1c             	sub    $0x1c,%esp
  801bcb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801bcf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	75 19                	jne    801bf8 <__udivdi3+0x38>
  801bdf:	39 f3                	cmp    %esi,%ebx
  801be1:	76 4d                	jbe    801c30 <__udivdi3+0x70>
  801be3:	31 ff                	xor    %edi,%edi
  801be5:	89 e8                	mov    %ebp,%eax
  801be7:	89 f2                	mov    %esi,%edx
  801be9:	f7 f3                	div    %ebx
  801beb:	89 fa                	mov    %edi,%edx
  801bed:	83 c4 1c             	add    $0x1c,%esp
  801bf0:	5b                   	pop    %ebx
  801bf1:	5e                   	pop    %esi
  801bf2:	5f                   	pop    %edi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    
  801bf5:	8d 76 00             	lea    0x0(%esi),%esi
  801bf8:	39 f0                	cmp    %esi,%eax
  801bfa:	76 14                	jbe    801c10 <__udivdi3+0x50>
  801bfc:	31 ff                	xor    %edi,%edi
  801bfe:	31 c0                	xor    %eax,%eax
  801c00:	89 fa                	mov    %edi,%edx
  801c02:	83 c4 1c             	add    $0x1c,%esp
  801c05:	5b                   	pop    %ebx
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
  801c0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c10:	0f bd f8             	bsr    %eax,%edi
  801c13:	83 f7 1f             	xor    $0x1f,%edi
  801c16:	75 48                	jne    801c60 <__udivdi3+0xa0>
  801c18:	39 f0                	cmp    %esi,%eax
  801c1a:	72 06                	jb     801c22 <__udivdi3+0x62>
  801c1c:	31 c0                	xor    %eax,%eax
  801c1e:	39 eb                	cmp    %ebp,%ebx
  801c20:	77 de                	ja     801c00 <__udivdi3+0x40>
  801c22:	b8 01 00 00 00       	mov    $0x1,%eax
  801c27:	eb d7                	jmp    801c00 <__udivdi3+0x40>
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 d9                	mov    %ebx,%ecx
  801c32:	85 db                	test   %ebx,%ebx
  801c34:	75 0b                	jne    801c41 <__udivdi3+0x81>
  801c36:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3b:	31 d2                	xor    %edx,%edx
  801c3d:	f7 f3                	div    %ebx
  801c3f:	89 c1                	mov    %eax,%ecx
  801c41:	31 d2                	xor    %edx,%edx
  801c43:	89 f0                	mov    %esi,%eax
  801c45:	f7 f1                	div    %ecx
  801c47:	89 c6                	mov    %eax,%esi
  801c49:	89 e8                	mov    %ebp,%eax
  801c4b:	89 f7                	mov    %esi,%edi
  801c4d:	f7 f1                	div    %ecx
  801c4f:	89 fa                	mov    %edi,%edx
  801c51:	83 c4 1c             	add    $0x1c,%esp
  801c54:	5b                   	pop    %ebx
  801c55:	5e                   	pop    %esi
  801c56:	5f                   	pop    %edi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 f9                	mov    %edi,%ecx
  801c62:	ba 20 00 00 00       	mov    $0x20,%edx
  801c67:	29 fa                	sub    %edi,%edx
  801c69:	d3 e0                	shl    %cl,%eax
  801c6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c6f:	89 d1                	mov    %edx,%ecx
  801c71:	89 d8                	mov    %ebx,%eax
  801c73:	d3 e8                	shr    %cl,%eax
  801c75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c79:	09 c1                	or     %eax,%ecx
  801c7b:	89 f0                	mov    %esi,%eax
  801c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c81:	89 f9                	mov    %edi,%ecx
  801c83:	d3 e3                	shl    %cl,%ebx
  801c85:	89 d1                	mov    %edx,%ecx
  801c87:	d3 e8                	shr    %cl,%eax
  801c89:	89 f9                	mov    %edi,%ecx
  801c8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c8f:	89 eb                	mov    %ebp,%ebx
  801c91:	d3 e6                	shl    %cl,%esi
  801c93:	89 d1                	mov    %edx,%ecx
  801c95:	d3 eb                	shr    %cl,%ebx
  801c97:	09 f3                	or     %esi,%ebx
  801c99:	89 c6                	mov    %eax,%esi
  801c9b:	89 f2                	mov    %esi,%edx
  801c9d:	89 d8                	mov    %ebx,%eax
  801c9f:	f7 74 24 08          	divl   0x8(%esp)
  801ca3:	89 d6                	mov    %edx,%esi
  801ca5:	89 c3                	mov    %eax,%ebx
  801ca7:	f7 64 24 0c          	mull   0xc(%esp)
  801cab:	39 d6                	cmp    %edx,%esi
  801cad:	72 19                	jb     801cc8 <__udivdi3+0x108>
  801caf:	89 f9                	mov    %edi,%ecx
  801cb1:	d3 e5                	shl    %cl,%ebp
  801cb3:	39 c5                	cmp    %eax,%ebp
  801cb5:	73 04                	jae    801cbb <__udivdi3+0xfb>
  801cb7:	39 d6                	cmp    %edx,%esi
  801cb9:	74 0d                	je     801cc8 <__udivdi3+0x108>
  801cbb:	89 d8                	mov    %ebx,%eax
  801cbd:	31 ff                	xor    %edi,%edi
  801cbf:	e9 3c ff ff ff       	jmp    801c00 <__udivdi3+0x40>
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801ccb:	31 ff                	xor    %edi,%edi
  801ccd:	e9 2e ff ff ff       	jmp    801c00 <__udivdi3+0x40>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	f3 0f 1e fb          	endbr32 
  801ce4:	55                   	push   %ebp
  801ce5:	57                   	push   %edi
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 1c             	sub    $0x1c,%esp
  801ceb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cf3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801cf7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801cfb:	89 f0                	mov    %esi,%eax
  801cfd:	89 da                	mov    %ebx,%edx
  801cff:	85 ff                	test   %edi,%edi
  801d01:	75 15                	jne    801d18 <__umoddi3+0x38>
  801d03:	39 dd                	cmp    %ebx,%ebp
  801d05:	76 39                	jbe    801d40 <__umoddi3+0x60>
  801d07:	f7 f5                	div    %ebp
  801d09:	89 d0                	mov    %edx,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	83 c4 1c             	add    $0x1c,%esp
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    
  801d15:	8d 76 00             	lea    0x0(%esi),%esi
  801d18:	39 df                	cmp    %ebx,%edi
  801d1a:	77 f1                	ja     801d0d <__umoddi3+0x2d>
  801d1c:	0f bd cf             	bsr    %edi,%ecx
  801d1f:	83 f1 1f             	xor    $0x1f,%ecx
  801d22:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d26:	75 40                	jne    801d68 <__umoddi3+0x88>
  801d28:	39 df                	cmp    %ebx,%edi
  801d2a:	72 04                	jb     801d30 <__umoddi3+0x50>
  801d2c:	39 f5                	cmp    %esi,%ebp
  801d2e:	77 dd                	ja     801d0d <__umoddi3+0x2d>
  801d30:	89 da                	mov    %ebx,%edx
  801d32:	89 f0                	mov    %esi,%eax
  801d34:	29 e8                	sub    %ebp,%eax
  801d36:	19 fa                	sbb    %edi,%edx
  801d38:	eb d3                	jmp    801d0d <__umoddi3+0x2d>
  801d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d40:	89 e9                	mov    %ebp,%ecx
  801d42:	85 ed                	test   %ebp,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x71>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f5                	div    %ebp
  801d4f:	89 c1                	mov    %eax,%ecx
  801d51:	89 d8                	mov    %ebx,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f1                	div    %ecx
  801d57:	89 f0                	mov    %esi,%eax
  801d59:	f7 f1                	div    %ecx
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	31 d2                	xor    %edx,%edx
  801d5f:	eb ac                	jmp    801d0d <__umoddi3+0x2d>
  801d61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d68:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d6c:	ba 20 00 00 00       	mov    $0x20,%edx
  801d71:	29 c2                	sub    %eax,%edx
  801d73:	89 c1                	mov    %eax,%ecx
  801d75:	89 e8                	mov    %ebp,%eax
  801d77:	d3 e7                	shl    %cl,%edi
  801d79:	89 d1                	mov    %edx,%ecx
  801d7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d7f:	d3 e8                	shr    %cl,%eax
  801d81:	89 c1                	mov    %eax,%ecx
  801d83:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d87:	09 f9                	or     %edi,%ecx
  801d89:	89 df                	mov    %ebx,%edi
  801d8b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d8f:	89 c1                	mov    %eax,%ecx
  801d91:	d3 e5                	shl    %cl,%ebp
  801d93:	89 d1                	mov    %edx,%ecx
  801d95:	d3 ef                	shr    %cl,%edi
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	89 f0                	mov    %esi,%eax
  801d9b:	d3 e3                	shl    %cl,%ebx
  801d9d:	89 d1                	mov    %edx,%ecx
  801d9f:	89 fa                	mov    %edi,%edx
  801da1:	d3 e8                	shr    %cl,%eax
  801da3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801da8:	09 d8                	or     %ebx,%eax
  801daa:	f7 74 24 08          	divl   0x8(%esp)
  801dae:	89 d3                	mov    %edx,%ebx
  801db0:	d3 e6                	shl    %cl,%esi
  801db2:	f7 e5                	mul    %ebp
  801db4:	89 c7                	mov    %eax,%edi
  801db6:	89 d1                	mov    %edx,%ecx
  801db8:	39 d3                	cmp    %edx,%ebx
  801dba:	72 06                	jb     801dc2 <__umoddi3+0xe2>
  801dbc:	75 0e                	jne    801dcc <__umoddi3+0xec>
  801dbe:	39 c6                	cmp    %eax,%esi
  801dc0:	73 0a                	jae    801dcc <__umoddi3+0xec>
  801dc2:	29 e8                	sub    %ebp,%eax
  801dc4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801dc8:	89 d1                	mov    %edx,%ecx
  801dca:	89 c7                	mov    %eax,%edi
  801dcc:	89 f5                	mov    %esi,%ebp
  801dce:	8b 74 24 04          	mov    0x4(%esp),%esi
  801dd2:	29 fd                	sub    %edi,%ebp
  801dd4:	19 cb                	sbb    %ecx,%ebx
  801dd6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801ddb:	89 d8                	mov    %ebx,%eax
  801ddd:	d3 e0                	shl    %cl,%eax
  801ddf:	89 f1                	mov    %esi,%ecx
  801de1:	d3 ed                	shr    %cl,%ebp
  801de3:	d3 eb                	shr    %cl,%ebx
  801de5:	09 e8                	or     %ebp,%eax
  801de7:	89 da                	mov    %ebx,%edx
  801de9:	83 c4 1c             	add    $0x1c,%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5e                   	pop    %esi
  801dee:	5f                   	pop    %edi
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    
