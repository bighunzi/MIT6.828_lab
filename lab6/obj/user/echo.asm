
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
  800096:	e8 e0 0a 00 00       	call   800b7b <write>
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
  8000b6:	e8 c0 0a 00 00       	call   800b7b <write>
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
  8000da:	e8 9c 0a 00 00       	call   800b7b <write>
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
  800130:	e8 69 08 00 00       	call   80099e <close_all>
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
  80052c:	68 ef 22 80 00       	push   $0x8022ef
  800531:	6a 2a                	push   $0x2a
  800533:	68 0c 23 80 00       	push   $0x80230c
  800538:	e8 9e 13 00 00       	call   8018db <_panic>

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
  8005ad:	68 ef 22 80 00       	push   $0x8022ef
  8005b2:	6a 2a                	push   $0x2a
  8005b4:	68 0c 23 80 00       	push   $0x80230c
  8005b9:	e8 1d 13 00 00       	call   8018db <_panic>

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
  8005ef:	68 ef 22 80 00       	push   $0x8022ef
  8005f4:	6a 2a                	push   $0x2a
  8005f6:	68 0c 23 80 00       	push   $0x80230c
  8005fb:	e8 db 12 00 00       	call   8018db <_panic>

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
  800631:	68 ef 22 80 00       	push   $0x8022ef
  800636:	6a 2a                	push   $0x2a
  800638:	68 0c 23 80 00       	push   $0x80230c
  80063d:	e8 99 12 00 00       	call   8018db <_panic>

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
  800673:	68 ef 22 80 00       	push   $0x8022ef
  800678:	6a 2a                	push   $0x2a
  80067a:	68 0c 23 80 00       	push   $0x80230c
  80067f:	e8 57 12 00 00       	call   8018db <_panic>

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
  8006b5:	68 ef 22 80 00       	push   $0x8022ef
  8006ba:	6a 2a                	push   $0x2a
  8006bc:	68 0c 23 80 00       	push   $0x80230c
  8006c1:	e8 15 12 00 00       	call   8018db <_panic>

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
  8006f7:	68 ef 22 80 00       	push   $0x8022ef
  8006fc:	6a 2a                	push   $0x2a
  8006fe:	68 0c 23 80 00       	push   $0x80230c
  800703:	e8 d3 11 00 00       	call   8018db <_panic>

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
  80075b:	68 ef 22 80 00       	push   $0x8022ef
  800760:	6a 2a                	push   $0x2a
  800762:	68 0c 23 80 00       	push   $0x80230c
  800767:	e8 6f 11 00 00       	call   8018db <_panic>

0080076c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	57                   	push   %edi
  800770:	56                   	push   %esi
  800771:	53                   	push   %ebx
	asm volatile("int %1\n"
  800772:	ba 00 00 00 00       	mov    $0x0,%edx
  800777:	b8 0e 00 00 00       	mov    $0xe,%eax
  80077c:	89 d1                	mov    %edx,%ecx
  80077e:	89 d3                	mov    %edx,%ebx
  800780:	89 d7                	mov    %edx,%edi
  800782:	89 d6                	mov    %edx,%esi
  800784:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5f                   	pop    %edi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	57                   	push   %edi
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
	asm volatile("int %1\n"
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	8b 55 08             	mov    0x8(%ebp),%edx
  800799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079c:	b8 0f 00 00 00       	mov    $0xf,%eax
  8007a1:	89 df                	mov    %ebx,%edi
  8007a3:	89 de                	mov    %ebx,%esi
  8007a5:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5f                   	pop    %edi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	57                   	push   %edi
  8007b0:	56                   	push   %esi
  8007b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8007b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c2:	89 df                	mov    %ebx,%edi
  8007c4:	89 de                	mov    %ebx,%esi
  8007c6:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5f                   	pop    %edi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8007d8:	c1 e8 0c             	shr    $0xc,%eax
}
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8007e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007ed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	c1 ea 16             	shr    $0x16,%edx
  800801:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800808:	f6 c2 01             	test   $0x1,%dl
  80080b:	74 29                	je     800836 <fd_alloc+0x42>
  80080d:	89 c2                	mov    %eax,%edx
  80080f:	c1 ea 0c             	shr    $0xc,%edx
  800812:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800819:	f6 c2 01             	test   $0x1,%dl
  80081c:	74 18                	je     800836 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80081e:	05 00 10 00 00       	add    $0x1000,%eax
  800823:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800828:	75 d2                	jne    8007fc <fd_alloc+0x8>
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80082f:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800834:	eb 05                	jmp    80083b <fd_alloc+0x47>
			return 0;
  800836:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80083b:	8b 55 08             	mov    0x8(%ebp),%edx
  80083e:	89 02                	mov    %eax,(%edx)
}
  800840:	89 c8                	mov    %ecx,%eax
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80084a:	83 f8 1f             	cmp    $0x1f,%eax
  80084d:	77 30                	ja     80087f <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80084f:	c1 e0 0c             	shl    $0xc,%eax
  800852:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800857:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80085d:	f6 c2 01             	test   $0x1,%dl
  800860:	74 24                	je     800886 <fd_lookup+0x42>
  800862:	89 c2                	mov    %eax,%edx
  800864:	c1 ea 0c             	shr    $0xc,%edx
  800867:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80086e:	f6 c2 01             	test   $0x1,%dl
  800871:	74 1a                	je     80088d <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
  800876:	89 02                	mov    %eax,(%edx)
	return 0;
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    
		return -E_INVAL;
  80087f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800884:	eb f7                	jmp    80087d <fd_lookup+0x39>
		return -E_INVAL;
  800886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088b:	eb f0                	jmp    80087d <fd_lookup+0x39>
  80088d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800892:	eb e9                	jmp    80087d <fd_lookup+0x39>

00800894 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	83 ec 04             	sub    $0x4,%esp
  80089b:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8008a8:	39 13                	cmp    %edx,(%ebx)
  8008aa:	74 37                	je     8008e3 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	8b 1c 85 98 23 80 00 	mov    0x802398(,%eax,4),%ebx
  8008b6:	85 db                	test   %ebx,%ebx
  8008b8:	75 ee                	jne    8008a8 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008ba:	a1 00 40 80 00       	mov    0x804000,%eax
  8008bf:	8b 40 48             	mov    0x48(%eax),%eax
  8008c2:	83 ec 04             	sub    $0x4,%esp
  8008c5:	52                   	push   %edx
  8008c6:	50                   	push   %eax
  8008c7:	68 1c 23 80 00       	push   $0x80231c
  8008cc:	e8 e5 10 00 00       	call   8019b6 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 1a                	mov    %ebx,(%edx)
}
  8008de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e1:	c9                   	leave  
  8008e2:	c3                   	ret    
			return 0;
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e8:	eb ef                	jmp    8008d9 <dev_lookup+0x45>

008008ea <fd_close>:
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	57                   	push   %edi
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
  8008f0:	83 ec 24             	sub    $0x24,%esp
  8008f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008fc:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008fd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800903:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800906:	50                   	push   %eax
  800907:	e8 38 ff ff ff       	call   800844 <fd_lookup>
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	85 c0                	test   %eax,%eax
  800913:	78 05                	js     80091a <fd_close+0x30>
	    || fd != fd2)
  800915:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800918:	74 16                	je     800930 <fd_close+0x46>
		return (must_exist ? r : 0);
  80091a:	89 f8                	mov    %edi,%eax
  80091c:	84 c0                	test   %al,%al
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	0f 44 d8             	cmove  %eax,%ebx
}
  800926:	89 d8                	mov    %ebx,%eax
  800928:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5f                   	pop    %edi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800936:	50                   	push   %eax
  800937:	ff 36                	push   (%esi)
  800939:	e8 56 ff ff ff       	call   800894 <dev_lookup>
  80093e:	89 c3                	mov    %eax,%ebx
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	85 c0                	test   %eax,%eax
  800945:	78 1a                	js     800961 <fd_close+0x77>
		if (dev->dev_close)
  800947:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80094a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80094d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800952:	85 c0                	test   %eax,%eax
  800954:	74 0b                	je     800961 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800956:	83 ec 0c             	sub    $0xc,%esp
  800959:	56                   	push   %esi
  80095a:	ff d0                	call   *%eax
  80095c:	89 c3                	mov    %eax,%ebx
  80095e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800961:	83 ec 08             	sub    $0x8,%esp
  800964:	56                   	push   %esi
  800965:	6a 00                	push   $0x0
  800967:	e8 94 fc ff ff       	call   800600 <sys_page_unmap>
	return r;
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	eb b5                	jmp    800926 <fd_close+0x3c>

00800971 <close>:

int
close(int fdnum)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800977:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80097a:	50                   	push   %eax
  80097b:	ff 75 08             	push   0x8(%ebp)
  80097e:	e8 c1 fe ff ff       	call   800844 <fd_lookup>
  800983:	83 c4 10             	add    $0x10,%esp
  800986:	85 c0                	test   %eax,%eax
  800988:	79 02                	jns    80098c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    
		return fd_close(fd, 1);
  80098c:	83 ec 08             	sub    $0x8,%esp
  80098f:	6a 01                	push   $0x1
  800991:	ff 75 f4             	push   -0xc(%ebp)
  800994:	e8 51 ff ff ff       	call   8008ea <fd_close>
  800999:	83 c4 10             	add    $0x10,%esp
  80099c:	eb ec                	jmp    80098a <close+0x19>

0080099e <close_all>:

void
close_all(void)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009a5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009aa:	83 ec 0c             	sub    $0xc,%esp
  8009ad:	53                   	push   %ebx
  8009ae:	e8 be ff ff ff       	call   800971 <close>
	for (i = 0; i < MAXFD; i++)
  8009b3:	83 c3 01             	add    $0x1,%ebx
  8009b6:	83 c4 10             	add    $0x10,%esp
  8009b9:	83 fb 20             	cmp    $0x20,%ebx
  8009bc:	75 ec                	jne    8009aa <close_all+0xc>
}
  8009be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	57                   	push   %edi
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009cf:	50                   	push   %eax
  8009d0:	ff 75 08             	push   0x8(%ebp)
  8009d3:	e8 6c fe ff ff       	call   800844 <fd_lookup>
  8009d8:	89 c3                	mov    %eax,%ebx
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	85 c0                	test   %eax,%eax
  8009df:	78 7f                	js     800a60 <dup+0x9d>
		return r;
	close(newfdnum);
  8009e1:	83 ec 0c             	sub    $0xc,%esp
  8009e4:	ff 75 0c             	push   0xc(%ebp)
  8009e7:	e8 85 ff ff ff       	call   800971 <close>

	newfd = INDEX2FD(newfdnum);
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	c1 e6 0c             	shl    $0xc,%esi
  8009f2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8009f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009fb:	89 3c 24             	mov    %edi,(%esp)
  8009fe:	e8 da fd ff ff       	call   8007dd <fd2data>
  800a03:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a05:	89 34 24             	mov    %esi,(%esp)
  800a08:	e8 d0 fd ff ff       	call   8007dd <fd2data>
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a13:	89 d8                	mov    %ebx,%eax
  800a15:	c1 e8 16             	shr    $0x16,%eax
  800a18:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a1f:	a8 01                	test   $0x1,%al
  800a21:	74 11                	je     800a34 <dup+0x71>
  800a23:	89 d8                	mov    %ebx,%eax
  800a25:	c1 e8 0c             	shr    $0xc,%eax
  800a28:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a2f:	f6 c2 01             	test   $0x1,%dl
  800a32:	75 36                	jne    800a6a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a34:	89 f8                	mov    %edi,%eax
  800a36:	c1 e8 0c             	shr    $0xc,%eax
  800a39:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a40:	83 ec 0c             	sub    $0xc,%esp
  800a43:	25 07 0e 00 00       	and    $0xe07,%eax
  800a48:	50                   	push   %eax
  800a49:	56                   	push   %esi
  800a4a:	6a 00                	push   $0x0
  800a4c:	57                   	push   %edi
  800a4d:	6a 00                	push   $0x0
  800a4f:	e8 6a fb ff ff       	call   8005be <sys_page_map>
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	83 c4 20             	add    $0x20,%esp
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	78 33                	js     800a90 <dup+0xcd>
		goto err;

	return newfdnum;
  800a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a60:	89 d8                	mov    %ebx,%eax
  800a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5f                   	pop    %edi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a71:	83 ec 0c             	sub    $0xc,%esp
  800a74:	25 07 0e 00 00       	and    $0xe07,%eax
  800a79:	50                   	push   %eax
  800a7a:	ff 75 d4             	push   -0x2c(%ebp)
  800a7d:	6a 00                	push   $0x0
  800a7f:	53                   	push   %ebx
  800a80:	6a 00                	push   $0x0
  800a82:	e8 37 fb ff ff       	call   8005be <sys_page_map>
  800a87:	89 c3                	mov    %eax,%ebx
  800a89:	83 c4 20             	add    $0x20,%esp
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	79 a4                	jns    800a34 <dup+0x71>
	sys_page_unmap(0, newfd);
  800a90:	83 ec 08             	sub    $0x8,%esp
  800a93:	56                   	push   %esi
  800a94:	6a 00                	push   $0x0
  800a96:	e8 65 fb ff ff       	call   800600 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a9b:	83 c4 08             	add    $0x8,%esp
  800a9e:	ff 75 d4             	push   -0x2c(%ebp)
  800aa1:	6a 00                	push   $0x0
  800aa3:	e8 58 fb ff ff       	call   800600 <sys_page_unmap>
	return r;
  800aa8:	83 c4 10             	add    $0x10,%esp
  800aab:	eb b3                	jmp    800a60 <dup+0x9d>

00800aad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 18             	sub    $0x18,%esp
  800ab5:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ab8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800abb:	50                   	push   %eax
  800abc:	56                   	push   %esi
  800abd:	e8 82 fd ff ff       	call   800844 <fd_lookup>
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	85 c0                	test   %eax,%eax
  800ac7:	78 3c                	js     800b05 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ac9:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800acc:	83 ec 08             	sub    $0x8,%esp
  800acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad2:	50                   	push   %eax
  800ad3:	ff 33                	push   (%ebx)
  800ad5:	e8 ba fd ff ff       	call   800894 <dev_lookup>
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	85 c0                	test   %eax,%eax
  800adf:	78 24                	js     800b05 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ae1:	8b 43 08             	mov    0x8(%ebx),%eax
  800ae4:	83 e0 03             	and    $0x3,%eax
  800ae7:	83 f8 01             	cmp    $0x1,%eax
  800aea:	74 20                	je     800b0c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800aef:	8b 40 08             	mov    0x8(%eax),%eax
  800af2:	85 c0                	test   %eax,%eax
  800af4:	74 37                	je     800b2d <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800af6:	83 ec 04             	sub    $0x4,%esp
  800af9:	ff 75 10             	push   0x10(%ebp)
  800afc:	ff 75 0c             	push   0xc(%ebp)
  800aff:	53                   	push   %ebx
  800b00:	ff d0                	call   *%eax
  800b02:	83 c4 10             	add    $0x10,%esp
}
  800b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b0c:	a1 00 40 80 00       	mov    0x804000,%eax
  800b11:	8b 40 48             	mov    0x48(%eax),%eax
  800b14:	83 ec 04             	sub    $0x4,%esp
  800b17:	56                   	push   %esi
  800b18:	50                   	push   %eax
  800b19:	68 5d 23 80 00       	push   $0x80235d
  800b1e:	e8 93 0e 00 00       	call   8019b6 <cprintf>
		return -E_INVAL;
  800b23:	83 c4 10             	add    $0x10,%esp
  800b26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b2b:	eb d8                	jmp    800b05 <read+0x58>
		return -E_NOT_SUPP;
  800b2d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b32:	eb d1                	jmp    800b05 <read+0x58>

00800b34 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	83 ec 0c             	sub    $0xc,%esp
  800b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b40:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b48:	eb 02                	jmp    800b4c <readn+0x18>
  800b4a:	01 c3                	add    %eax,%ebx
  800b4c:	39 f3                	cmp    %esi,%ebx
  800b4e:	73 21                	jae    800b71 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b50:	83 ec 04             	sub    $0x4,%esp
  800b53:	89 f0                	mov    %esi,%eax
  800b55:	29 d8                	sub    %ebx,%eax
  800b57:	50                   	push   %eax
  800b58:	89 d8                	mov    %ebx,%eax
  800b5a:	03 45 0c             	add    0xc(%ebp),%eax
  800b5d:	50                   	push   %eax
  800b5e:	57                   	push   %edi
  800b5f:	e8 49 ff ff ff       	call   800aad <read>
		if (m < 0)
  800b64:	83 c4 10             	add    $0x10,%esp
  800b67:	85 c0                	test   %eax,%eax
  800b69:	78 04                	js     800b6f <readn+0x3b>
			return m;
		if (m == 0)
  800b6b:	75 dd                	jne    800b4a <readn+0x16>
  800b6d:	eb 02                	jmp    800b71 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b6f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800b71:	89 d8                	mov    %ebx,%eax
  800b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 18             	sub    $0x18,%esp
  800b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b89:	50                   	push   %eax
  800b8a:	53                   	push   %ebx
  800b8b:	e8 b4 fc ff ff       	call   800844 <fd_lookup>
  800b90:	83 c4 10             	add    $0x10,%esp
  800b93:	85 c0                	test   %eax,%eax
  800b95:	78 37                	js     800bce <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b97:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800b9a:	83 ec 08             	sub    $0x8,%esp
  800b9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba0:	50                   	push   %eax
  800ba1:	ff 36                	push   (%esi)
  800ba3:	e8 ec fc ff ff       	call   800894 <dev_lookup>
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	85 c0                	test   %eax,%eax
  800bad:	78 1f                	js     800bce <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800baf:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800bb3:	74 20                	je     800bd5 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bb8:	8b 40 0c             	mov    0xc(%eax),%eax
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	74 37                	je     800bf6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800bbf:	83 ec 04             	sub    $0x4,%esp
  800bc2:	ff 75 10             	push   0x10(%ebp)
  800bc5:	ff 75 0c             	push   0xc(%ebp)
  800bc8:	56                   	push   %esi
  800bc9:	ff d0                	call   *%eax
  800bcb:	83 c4 10             	add    $0x10,%esp
}
  800bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800bd5:	a1 00 40 80 00       	mov    0x804000,%eax
  800bda:	8b 40 48             	mov    0x48(%eax),%eax
  800bdd:	83 ec 04             	sub    $0x4,%esp
  800be0:	53                   	push   %ebx
  800be1:	50                   	push   %eax
  800be2:	68 79 23 80 00       	push   $0x802379
  800be7:	e8 ca 0d 00 00       	call   8019b6 <cprintf>
		return -E_INVAL;
  800bec:	83 c4 10             	add    $0x10,%esp
  800bef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bf4:	eb d8                	jmp    800bce <write+0x53>
		return -E_NOT_SUPP;
  800bf6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800bfb:	eb d1                	jmp    800bce <write+0x53>

00800bfd <seek>:

int
seek(int fdnum, off_t offset)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c06:	50                   	push   %eax
  800c07:	ff 75 08             	push   0x8(%ebp)
  800c0a:	e8 35 fc ff ff       	call   800844 <fd_lookup>
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	85 c0                	test   %eax,%eax
  800c14:	78 0e                	js     800c24 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c24:	c9                   	leave  
  800c25:	c3                   	ret    

00800c26 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 18             	sub    $0x18,%esp
  800c2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c34:	50                   	push   %eax
  800c35:	53                   	push   %ebx
  800c36:	e8 09 fc ff ff       	call   800844 <fd_lookup>
  800c3b:	83 c4 10             	add    $0x10,%esp
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	78 34                	js     800c76 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c42:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800c45:	83 ec 08             	sub    $0x8,%esp
  800c48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c4b:	50                   	push   %eax
  800c4c:	ff 36                	push   (%esi)
  800c4e:	e8 41 fc ff ff       	call   800894 <dev_lookup>
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	85 c0                	test   %eax,%eax
  800c58:	78 1c                	js     800c76 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c5a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800c5e:	74 1d                	je     800c7d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c63:	8b 40 18             	mov    0x18(%eax),%eax
  800c66:	85 c0                	test   %eax,%eax
  800c68:	74 34                	je     800c9e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c6a:	83 ec 08             	sub    $0x8,%esp
  800c6d:	ff 75 0c             	push   0xc(%ebp)
  800c70:	56                   	push   %esi
  800c71:	ff d0                	call   *%eax
  800c73:	83 c4 10             	add    $0x10,%esp
}
  800c76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    
			thisenv->env_id, fdnum);
  800c7d:	a1 00 40 80 00       	mov    0x804000,%eax
  800c82:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c85:	83 ec 04             	sub    $0x4,%esp
  800c88:	53                   	push   %ebx
  800c89:	50                   	push   %eax
  800c8a:	68 3c 23 80 00       	push   $0x80233c
  800c8f:	e8 22 0d 00 00       	call   8019b6 <cprintf>
		return -E_INVAL;
  800c94:	83 c4 10             	add    $0x10,%esp
  800c97:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c9c:	eb d8                	jmp    800c76 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800c9e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800ca3:	eb d1                	jmp    800c76 <ftruncate+0x50>

00800ca5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 18             	sub    $0x18,%esp
  800cad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb3:	50                   	push   %eax
  800cb4:	ff 75 08             	push   0x8(%ebp)
  800cb7:	e8 88 fb ff ff       	call   800844 <fd_lookup>
  800cbc:	83 c4 10             	add    $0x10,%esp
  800cbf:	85 c0                	test   %eax,%eax
  800cc1:	78 49                	js     800d0c <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800cc6:	83 ec 08             	sub    $0x8,%esp
  800cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ccc:	50                   	push   %eax
  800ccd:	ff 36                	push   (%esi)
  800ccf:	e8 c0 fb ff ff       	call   800894 <dev_lookup>
  800cd4:	83 c4 10             	add    $0x10,%esp
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	78 31                	js     800d0c <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cde:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ce2:	74 2f                	je     800d13 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ce4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ce7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cee:	00 00 00 
	stat->st_isdir = 0;
  800cf1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cf8:	00 00 00 
	stat->st_dev = dev;
  800cfb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d01:	83 ec 08             	sub    $0x8,%esp
  800d04:	53                   	push   %ebx
  800d05:	56                   	push   %esi
  800d06:	ff 50 14             	call   *0x14(%eax)
  800d09:	83 c4 10             	add    $0x10,%esp
}
  800d0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
		return -E_NOT_SUPP;
  800d13:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800d18:	eb f2                	jmp    800d0c <fstat+0x67>

00800d1a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d1f:	83 ec 08             	sub    $0x8,%esp
  800d22:	6a 00                	push   $0x0
  800d24:	ff 75 08             	push   0x8(%ebp)
  800d27:	e8 e4 01 00 00       	call   800f10 <open>
  800d2c:	89 c3                	mov    %eax,%ebx
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	85 c0                	test   %eax,%eax
  800d33:	78 1b                	js     800d50 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d35:	83 ec 08             	sub    $0x8,%esp
  800d38:	ff 75 0c             	push   0xc(%ebp)
  800d3b:	50                   	push   %eax
  800d3c:	e8 64 ff ff ff       	call   800ca5 <fstat>
  800d41:	89 c6                	mov    %eax,%esi
	close(fd);
  800d43:	89 1c 24             	mov    %ebx,(%esp)
  800d46:	e8 26 fc ff ff       	call   800971 <close>
	return r;
  800d4b:	83 c4 10             	add    $0x10,%esp
  800d4e:	89 f3                	mov    %esi,%ebx
}
  800d50:	89 d8                	mov    %ebx,%eax
  800d52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	89 c6                	mov    %eax,%esi
  800d60:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d62:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800d69:	74 27                	je     800d92 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d6b:	6a 07                	push   $0x7
  800d6d:	68 00 50 80 00       	push   $0x805000
  800d72:	56                   	push   %esi
  800d73:	ff 35 00 60 80 00    	push   0x806000
  800d79:	e8 3e 12 00 00       	call   801fbc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d7e:	83 c4 0c             	add    $0xc,%esp
  800d81:	6a 00                	push   $0x0
  800d83:	53                   	push   %ebx
  800d84:	6a 00                	push   $0x0
  800d86:	e8 ca 11 00 00       	call   801f55 <ipc_recv>
}
  800d8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d8e:	5b                   	pop    %ebx
  800d8f:	5e                   	pop    %esi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	6a 01                	push   $0x1
  800d97:	e8 74 12 00 00       	call   802010 <ipc_find_env>
  800d9c:	a3 00 60 80 00       	mov    %eax,0x806000
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	eb c5                	jmp    800d6b <fsipc+0x12>

00800da6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	8b 40 0c             	mov    0xc(%eax),%eax
  800db2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800db7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800dbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc4:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc9:	e8 8b ff ff ff       	call   800d59 <fsipc>
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <devfile_flush>:
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd9:	8b 40 0c             	mov    0xc(%eax),%eax
  800ddc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800de1:	ba 00 00 00 00       	mov    $0x0,%edx
  800de6:	b8 06 00 00 00       	mov    $0x6,%eax
  800deb:	e8 69 ff ff ff       	call   800d59 <fsipc>
}
  800df0:	c9                   	leave  
  800df1:	c3                   	ret    

00800df2 <devfile_stat>:
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	53                   	push   %ebx
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	8b 40 0c             	mov    0xc(%eax),%eax
  800e02:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 05 00 00 00       	mov    $0x5,%eax
  800e11:	e8 43 ff ff ff       	call   800d59 <fsipc>
  800e16:	85 c0                	test   %eax,%eax
  800e18:	78 2c                	js     800e46 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	68 00 50 80 00       	push   $0x805000
  800e22:	53                   	push   %ebx
  800e23:	e8 57 f3 ff ff       	call   80017f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e28:	a1 80 50 80 00       	mov    0x805080,%eax
  800e2d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e33:	a1 84 50 80 00       	mov    0x805084,%eax
  800e38:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e49:	c9                   	leave  
  800e4a:	c3                   	ret    

00800e4b <devfile_write>:
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	83 ec 0c             	sub    $0xc,%esp
  800e51:	8b 45 10             	mov    0x10(%ebp),%eax
  800e54:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800e59:	39 d0                	cmp    %edx,%eax
  800e5b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e61:	8b 52 0c             	mov    0xc(%edx),%edx
  800e64:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800e6a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800e6f:	50                   	push   %eax
  800e70:	ff 75 0c             	push   0xc(%ebp)
  800e73:	68 08 50 80 00       	push   $0x805008
  800e78:	e8 98 f4 ff ff       	call   800315 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e82:	b8 04 00 00 00       	mov    $0x4,%eax
  800e87:	e8 cd fe ff ff       	call   800d59 <fsipc>
}
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <devfile_read>:
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
  800e93:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e96:	8b 45 08             	mov    0x8(%ebp),%eax
  800e99:	8b 40 0c             	mov    0xc(%eax),%eax
  800e9c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ea1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb1:	e8 a3 fe ff ff       	call   800d59 <fsipc>
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	85 c0                	test   %eax,%eax
  800eba:	78 1f                	js     800edb <devfile_read+0x4d>
	assert(r <= n);
  800ebc:	39 f0                	cmp    %esi,%eax
  800ebe:	77 24                	ja     800ee4 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800ec0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ec5:	7f 33                	jg     800efa <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ec7:	83 ec 04             	sub    $0x4,%esp
  800eca:	50                   	push   %eax
  800ecb:	68 00 50 80 00       	push   $0x805000
  800ed0:	ff 75 0c             	push   0xc(%ebp)
  800ed3:	e8 3d f4 ff ff       	call   800315 <memmove>
	return r;
  800ed8:	83 c4 10             	add    $0x10,%esp
}
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    
	assert(r <= n);
  800ee4:	68 ac 23 80 00       	push   $0x8023ac
  800ee9:	68 b3 23 80 00       	push   $0x8023b3
  800eee:	6a 7c                	push   $0x7c
  800ef0:	68 c8 23 80 00       	push   $0x8023c8
  800ef5:	e8 e1 09 00 00       	call   8018db <_panic>
	assert(r <= PGSIZE);
  800efa:	68 d3 23 80 00       	push   $0x8023d3
  800eff:	68 b3 23 80 00       	push   $0x8023b3
  800f04:	6a 7d                	push   $0x7d
  800f06:	68 c8 23 80 00       	push   $0x8023c8
  800f0b:	e8 cb 09 00 00       	call   8018db <_panic>

00800f10 <open>:
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	56                   	push   %esi
  800f14:	53                   	push   %ebx
  800f15:	83 ec 1c             	sub    $0x1c,%esp
  800f18:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800f1b:	56                   	push   %esi
  800f1c:	e8 23 f2 ff ff       	call   800144 <strlen>
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f29:	7f 6c                	jg     800f97 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f31:	50                   	push   %eax
  800f32:	e8 bd f8 ff ff       	call   8007f4 <fd_alloc>
  800f37:	89 c3                	mov    %eax,%ebx
  800f39:	83 c4 10             	add    $0x10,%esp
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	78 3c                	js     800f7c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800f40:	83 ec 08             	sub    $0x8,%esp
  800f43:	56                   	push   %esi
  800f44:	68 00 50 80 00       	push   $0x805000
  800f49:	e8 31 f2 ff ff       	call   80017f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f51:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f59:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5e:	e8 f6 fd ff ff       	call   800d59 <fsipc>
  800f63:	89 c3                	mov    %eax,%ebx
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	78 19                	js     800f85 <open+0x75>
	return fd2num(fd);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	ff 75 f4             	push   -0xc(%ebp)
  800f72:	e8 56 f8 ff ff       	call   8007cd <fd2num>
  800f77:	89 c3                	mov    %eax,%ebx
  800f79:	83 c4 10             	add    $0x10,%esp
}
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
		fd_close(fd, 0);
  800f85:	83 ec 08             	sub    $0x8,%esp
  800f88:	6a 00                	push   $0x0
  800f8a:	ff 75 f4             	push   -0xc(%ebp)
  800f8d:	e8 58 f9 ff ff       	call   8008ea <fd_close>
		return r;
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	eb e5                	jmp    800f7c <open+0x6c>
		return -E_BAD_PATH;
  800f97:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f9c:	eb de                	jmp    800f7c <open+0x6c>

00800f9e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800fa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fae:	e8 a6 fd ff ff       	call   800d59 <fsipc>
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800fbb:	68 df 23 80 00       	push   $0x8023df
  800fc0:	ff 75 0c             	push   0xc(%ebp)
  800fc3:	e8 b7 f1 ff ff       	call   80017f <strcpy>
	return 0;
}
  800fc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <devsock_close>:
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 10             	sub    $0x10,%esp
  800fd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800fd9:	53                   	push   %ebx
  800fda:	e8 6a 10 00 00       	call   802049 <pageref>
  800fdf:	89 c2                	mov    %eax,%edx
  800fe1:	83 c4 10             	add    $0x10,%esp
		return 0;
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800fe9:	83 fa 01             	cmp    $0x1,%edx
  800fec:	74 05                	je     800ff3 <devsock_close+0x24>
}
  800fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	ff 73 0c             	push   0xc(%ebx)
  800ff9:	e8 b7 02 00 00       	call   8012b5 <nsipc_close>
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	eb eb                	jmp    800fee <devsock_close+0x1f>

00801003 <devsock_write>:
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801009:	6a 00                	push   $0x0
  80100b:	ff 75 10             	push   0x10(%ebp)
  80100e:	ff 75 0c             	push   0xc(%ebp)
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
  801014:	ff 70 0c             	push   0xc(%eax)
  801017:	e8 79 03 00 00       	call   801395 <nsipc_send>
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <devsock_read>:
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801024:	6a 00                	push   $0x0
  801026:	ff 75 10             	push   0x10(%ebp)
  801029:	ff 75 0c             	push   0xc(%ebp)
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
  80102f:	ff 70 0c             	push   0xc(%eax)
  801032:	e8 ef 02 00 00       	call   801326 <nsipc_recv>
}
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <fd2sockid>:
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  80103f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801042:	52                   	push   %edx
  801043:	50                   	push   %eax
  801044:	e8 fb f7 ff ff       	call   800844 <fd_lookup>
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	85 c0                	test   %eax,%eax
  80104e:	78 10                	js     801060 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801050:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801053:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801059:	39 08                	cmp    %ecx,(%eax)
  80105b:	75 05                	jne    801062 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80105d:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801060:	c9                   	leave  
  801061:	c3                   	ret    
		return -E_NOT_SUPP;
  801062:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801067:	eb f7                	jmp    801060 <fd2sockid+0x27>

00801069 <alloc_sockfd>:
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
  80106e:	83 ec 1c             	sub    $0x1c,%esp
  801071:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801076:	50                   	push   %eax
  801077:	e8 78 f7 ff ff       	call   8007f4 <fd_alloc>
  80107c:	89 c3                	mov    %eax,%ebx
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	78 43                	js     8010c8 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801085:	83 ec 04             	sub    $0x4,%esp
  801088:	68 07 04 00 00       	push   $0x407
  80108d:	ff 75 f4             	push   -0xc(%ebp)
  801090:	6a 00                	push   $0x0
  801092:	e8 e4 f4 ff ff       	call   80057b <sys_page_alloc>
  801097:	89 c3                	mov    %eax,%ebx
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	85 c0                	test   %eax,%eax
  80109e:	78 28                	js     8010c8 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8010a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8010a9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8010ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8010b5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	50                   	push   %eax
  8010bc:	e8 0c f7 ff ff       	call   8007cd <fd2num>
  8010c1:	89 c3                	mov    %eax,%ebx
  8010c3:	83 c4 10             	add    $0x10,%esp
  8010c6:	eb 0c                	jmp    8010d4 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	56                   	push   %esi
  8010cc:	e8 e4 01 00 00       	call   8012b5 <nsipc_close>
		return r;
  8010d1:	83 c4 10             	add    $0x10,%esp
}
  8010d4:	89 d8                	mov    %ebx,%eax
  8010d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d9:	5b                   	pop    %ebx
  8010da:	5e                   	pop    %esi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <accept>:
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8010e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e6:	e8 4e ff ff ff       	call   801039 <fd2sockid>
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 1b                	js     80110a <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8010ef:	83 ec 04             	sub    $0x4,%esp
  8010f2:	ff 75 10             	push   0x10(%ebp)
  8010f5:	ff 75 0c             	push   0xc(%ebp)
  8010f8:	50                   	push   %eax
  8010f9:	e8 0e 01 00 00       	call   80120c <nsipc_accept>
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	78 05                	js     80110a <accept+0x2d>
	return alloc_sockfd(r);
  801105:	e8 5f ff ff ff       	call   801069 <alloc_sockfd>
}
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <bind>:
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	e8 1f ff ff ff       	call   801039 <fd2sockid>
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 12                	js     801130 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	ff 75 10             	push   0x10(%ebp)
  801124:	ff 75 0c             	push   0xc(%ebp)
  801127:	50                   	push   %eax
  801128:	e8 31 01 00 00       	call   80125e <nsipc_bind>
  80112d:	83 c4 10             	add    $0x10,%esp
}
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <shutdown>:
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	e8 f9 fe ff ff       	call   801039 <fd2sockid>
  801140:	85 c0                	test   %eax,%eax
  801142:	78 0f                	js     801153 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801144:	83 ec 08             	sub    $0x8,%esp
  801147:	ff 75 0c             	push   0xc(%ebp)
  80114a:	50                   	push   %eax
  80114b:	e8 43 01 00 00       	call   801293 <nsipc_shutdown>
  801150:	83 c4 10             	add    $0x10,%esp
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <connect>:
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	e8 d6 fe ff ff       	call   801039 <fd2sockid>
  801163:	85 c0                	test   %eax,%eax
  801165:	78 12                	js     801179 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801167:	83 ec 04             	sub    $0x4,%esp
  80116a:	ff 75 10             	push   0x10(%ebp)
  80116d:	ff 75 0c             	push   0xc(%ebp)
  801170:	50                   	push   %eax
  801171:	e8 59 01 00 00       	call   8012cf <nsipc_connect>
  801176:	83 c4 10             	add    $0x10,%esp
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <listen>:
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801181:	8b 45 08             	mov    0x8(%ebp),%eax
  801184:	e8 b0 fe ff ff       	call   801039 <fd2sockid>
  801189:	85 c0                	test   %eax,%eax
  80118b:	78 0f                	js     80119c <listen+0x21>
	return nsipc_listen(r, backlog);
  80118d:	83 ec 08             	sub    $0x8,%esp
  801190:	ff 75 0c             	push   0xc(%ebp)
  801193:	50                   	push   %eax
  801194:	e8 6b 01 00 00       	call   801304 <nsipc_listen>
  801199:	83 c4 10             	add    $0x10,%esp
}
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <socket>:

int
socket(int domain, int type, int protocol)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8011a4:	ff 75 10             	push   0x10(%ebp)
  8011a7:	ff 75 0c             	push   0xc(%ebp)
  8011aa:	ff 75 08             	push   0x8(%ebp)
  8011ad:	e8 41 02 00 00       	call   8013f3 <nsipc_socket>
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	78 05                	js     8011be <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8011b9:	e8 ab fe ff ff       	call   801069 <alloc_sockfd>
}
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8011c9:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8011d0:	74 26                	je     8011f8 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8011d2:	6a 07                	push   $0x7
  8011d4:	68 00 70 80 00       	push   $0x807000
  8011d9:	53                   	push   %ebx
  8011da:	ff 35 00 80 80 00    	push   0x808000
  8011e0:	e8 d7 0d 00 00       	call   801fbc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8011e5:	83 c4 0c             	add    $0xc,%esp
  8011e8:	6a 00                	push   $0x0
  8011ea:	6a 00                	push   $0x0
  8011ec:	6a 00                	push   $0x0
  8011ee:	e8 62 0d 00 00       	call   801f55 <ipc_recv>
}
  8011f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8011f8:	83 ec 0c             	sub    $0xc,%esp
  8011fb:	6a 02                	push   $0x2
  8011fd:	e8 0e 0e 00 00       	call   802010 <ipc_find_env>
  801202:	a3 00 80 80 00       	mov    %eax,0x808000
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	eb c6                	jmp    8011d2 <nsipc+0x12>

0080120c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801214:	8b 45 08             	mov    0x8(%ebp),%eax
  801217:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80121c:	8b 06                	mov    (%esi),%eax
  80121e:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801223:	b8 01 00 00 00       	mov    $0x1,%eax
  801228:	e8 93 ff ff ff       	call   8011c0 <nsipc>
  80122d:	89 c3                	mov    %eax,%ebx
  80122f:	85 c0                	test   %eax,%eax
  801231:	79 09                	jns    80123c <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801233:	89 d8                	mov    %ebx,%eax
  801235:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80123c:	83 ec 04             	sub    $0x4,%esp
  80123f:	ff 35 10 70 80 00    	push   0x807010
  801245:	68 00 70 80 00       	push   $0x807000
  80124a:	ff 75 0c             	push   0xc(%ebp)
  80124d:	e8 c3 f0 ff ff       	call   800315 <memmove>
		*addrlen = ret->ret_addrlen;
  801252:	a1 10 70 80 00       	mov    0x807010,%eax
  801257:	89 06                	mov    %eax,(%esi)
  801259:	83 c4 10             	add    $0x10,%esp
	return r;
  80125c:	eb d5                	jmp    801233 <nsipc_accept+0x27>

0080125e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	53                   	push   %ebx
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801270:	53                   	push   %ebx
  801271:	ff 75 0c             	push   0xc(%ebp)
  801274:	68 04 70 80 00       	push   $0x807004
  801279:	e8 97 f0 ff ff       	call   800315 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80127e:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801284:	b8 02 00 00 00       	mov    $0x2,%eax
  801289:	e8 32 ff ff ff       	call   8011c0 <nsipc>
}
  80128e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801299:	8b 45 08             	mov    0x8(%ebp),%eax
  80129c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8012a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8012a9:	b8 03 00 00 00       	mov    $0x3,%eax
  8012ae:	e8 0d ff ff ff       	call   8011c0 <nsipc>
}
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <nsipc_close>:

int
nsipc_close(int s)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8012bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012be:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8012c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8012c8:	e8 f3 fe ff ff       	call   8011c0 <nsipc>
}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8012d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012dc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8012e1:	53                   	push   %ebx
  8012e2:	ff 75 0c             	push   0xc(%ebp)
  8012e5:	68 04 70 80 00       	push   $0x807004
  8012ea:	e8 26 f0 ff ff       	call   800315 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8012ef:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8012f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8012fa:	e8 c1 fe ff ff       	call   8011c0 <nsipc>
}
  8012ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80130a:	8b 45 08             	mov    0x8(%ebp),%eax
  80130d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801312:	8b 45 0c             	mov    0xc(%ebp),%eax
  801315:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  80131a:	b8 06 00 00 00       	mov    $0x6,%eax
  80131f:	e8 9c fe ff ff       	call   8011c0 <nsipc>
}
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801336:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80133c:	8b 45 14             	mov    0x14(%ebp),%eax
  80133f:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801344:	b8 07 00 00 00       	mov    $0x7,%eax
  801349:	e8 72 fe ff ff       	call   8011c0 <nsipc>
  80134e:	89 c3                	mov    %eax,%ebx
  801350:	85 c0                	test   %eax,%eax
  801352:	78 22                	js     801376 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801354:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801359:	39 c6                	cmp    %eax,%esi
  80135b:	0f 4e c6             	cmovle %esi,%eax
  80135e:	39 c3                	cmp    %eax,%ebx
  801360:	7f 1d                	jg     80137f <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801362:	83 ec 04             	sub    $0x4,%esp
  801365:	53                   	push   %ebx
  801366:	68 00 70 80 00       	push   $0x807000
  80136b:	ff 75 0c             	push   0xc(%ebp)
  80136e:	e8 a2 ef ff ff       	call   800315 <memmove>
  801373:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801376:	89 d8                	mov    %ebx,%eax
  801378:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5d                   	pop    %ebp
  80137e:	c3                   	ret    
		assert(r < 1600 && r <= len);
  80137f:	68 eb 23 80 00       	push   $0x8023eb
  801384:	68 b3 23 80 00       	push   $0x8023b3
  801389:	6a 62                	push   $0x62
  80138b:	68 00 24 80 00       	push   $0x802400
  801390:	e8 46 05 00 00       	call   8018db <_panic>

00801395 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	83 ec 04             	sub    $0x4,%esp
  80139c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80139f:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a2:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8013a7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8013ad:	7f 2e                	jg     8013dd <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8013af:	83 ec 04             	sub    $0x4,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	ff 75 0c             	push   0xc(%ebp)
  8013b6:	68 0c 70 80 00       	push   $0x80700c
  8013bb:	e8 55 ef ff ff       	call   800315 <memmove>
	nsipcbuf.send.req_size = size;
  8013c0:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8013c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c9:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8013ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8013d3:	e8 e8 fd ff ff       	call   8011c0 <nsipc>
}
  8013d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    
	assert(size < 1600);
  8013dd:	68 0c 24 80 00       	push   $0x80240c
  8013e2:	68 b3 23 80 00       	push   $0x8023b3
  8013e7:	6a 6d                	push   $0x6d
  8013e9:	68 00 24 80 00       	push   $0x802400
  8013ee:	e8 e8 04 00 00       	call   8018db <_panic>

008013f3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801401:	8b 45 0c             	mov    0xc(%ebp),%eax
  801404:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801409:	8b 45 10             	mov    0x10(%ebp),%eax
  80140c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801411:	b8 09 00 00 00       	mov    $0x9,%eax
  801416:	e8 a5 fd ff ff       	call   8011c0 <nsipc>
}
  80141b:	c9                   	leave  
  80141c:	c3                   	ret    

0080141d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
  801422:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	ff 75 08             	push   0x8(%ebp)
  80142b:	e8 ad f3 ff ff       	call   8007dd <fd2data>
  801430:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801432:	83 c4 08             	add    $0x8,%esp
  801435:	68 18 24 80 00       	push   $0x802418
  80143a:	53                   	push   %ebx
  80143b:	e8 3f ed ff ff       	call   80017f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801440:	8b 46 04             	mov    0x4(%esi),%eax
  801443:	2b 06                	sub    (%esi),%eax
  801445:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80144b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801452:	00 00 00 
	stat->st_dev = &devpipe;
  801455:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80145c:	30 80 00 
	return 0;
}
  80145f:	b8 00 00 00 00       	mov    $0x0,%eax
  801464:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    

0080146b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	53                   	push   %ebx
  80146f:	83 ec 0c             	sub    $0xc,%esp
  801472:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801475:	53                   	push   %ebx
  801476:	6a 00                	push   $0x0
  801478:	e8 83 f1 ff ff       	call   800600 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80147d:	89 1c 24             	mov    %ebx,(%esp)
  801480:	e8 58 f3 ff ff       	call   8007dd <fd2data>
  801485:	83 c4 08             	add    $0x8,%esp
  801488:	50                   	push   %eax
  801489:	6a 00                	push   $0x0
  80148b:	e8 70 f1 ff ff       	call   800600 <sys_page_unmap>
}
  801490:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801493:	c9                   	leave  
  801494:	c3                   	ret    

00801495 <_pipeisclosed>:
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	57                   	push   %edi
  801499:	56                   	push   %esi
  80149a:	53                   	push   %ebx
  80149b:	83 ec 1c             	sub    $0x1c,%esp
  80149e:	89 c7                	mov    %eax,%edi
  8014a0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8014a2:	a1 00 40 80 00       	mov    0x804000,%eax
  8014a7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8014aa:	83 ec 0c             	sub    $0xc,%esp
  8014ad:	57                   	push   %edi
  8014ae:	e8 96 0b 00 00       	call   802049 <pageref>
  8014b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8014b6:	89 34 24             	mov    %esi,(%esp)
  8014b9:	e8 8b 0b 00 00       	call   802049 <pageref>
		nn = thisenv->env_runs;
  8014be:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8014c4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	39 cb                	cmp    %ecx,%ebx
  8014cc:	74 1b                	je     8014e9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8014ce:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8014d1:	75 cf                	jne    8014a2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8014d3:	8b 42 58             	mov    0x58(%edx),%eax
  8014d6:	6a 01                	push   $0x1
  8014d8:	50                   	push   %eax
  8014d9:	53                   	push   %ebx
  8014da:	68 1f 24 80 00       	push   $0x80241f
  8014df:	e8 d2 04 00 00       	call   8019b6 <cprintf>
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	eb b9                	jmp    8014a2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8014e9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8014ec:	0f 94 c0             	sete   %al
  8014ef:	0f b6 c0             	movzbl %al,%eax
}
  8014f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5f                   	pop    %edi
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    

008014fa <devpipe_write>:
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	57                   	push   %edi
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 28             	sub    $0x28,%esp
  801503:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801506:	56                   	push   %esi
  801507:	e8 d1 f2 ff ff       	call   8007dd <fd2data>
  80150c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	bf 00 00 00 00       	mov    $0x0,%edi
  801516:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801519:	75 09                	jne    801524 <devpipe_write+0x2a>
	return i;
  80151b:	89 f8                	mov    %edi,%eax
  80151d:	eb 23                	jmp    801542 <devpipe_write+0x48>
			sys_yield();
  80151f:	e8 38 f0 ff ff       	call   80055c <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801524:	8b 43 04             	mov    0x4(%ebx),%eax
  801527:	8b 0b                	mov    (%ebx),%ecx
  801529:	8d 51 20             	lea    0x20(%ecx),%edx
  80152c:	39 d0                	cmp    %edx,%eax
  80152e:	72 1a                	jb     80154a <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801530:	89 da                	mov    %ebx,%edx
  801532:	89 f0                	mov    %esi,%eax
  801534:	e8 5c ff ff ff       	call   801495 <_pipeisclosed>
  801539:	85 c0                	test   %eax,%eax
  80153b:	74 e2                	je     80151f <devpipe_write+0x25>
				return 0;
  80153d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801542:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801545:	5b                   	pop    %ebx
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80154a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80154d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801551:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801554:	89 c2                	mov    %eax,%edx
  801556:	c1 fa 1f             	sar    $0x1f,%edx
  801559:	89 d1                	mov    %edx,%ecx
  80155b:	c1 e9 1b             	shr    $0x1b,%ecx
  80155e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801561:	83 e2 1f             	and    $0x1f,%edx
  801564:	29 ca                	sub    %ecx,%edx
  801566:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80156a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80156e:	83 c0 01             	add    $0x1,%eax
  801571:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801574:	83 c7 01             	add    $0x1,%edi
  801577:	eb 9d                	jmp    801516 <devpipe_write+0x1c>

00801579 <devpipe_read>:
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	57                   	push   %edi
  80157d:	56                   	push   %esi
  80157e:	53                   	push   %ebx
  80157f:	83 ec 18             	sub    $0x18,%esp
  801582:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801585:	57                   	push   %edi
  801586:	e8 52 f2 ff ff       	call   8007dd <fd2data>
  80158b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	be 00 00 00 00       	mov    $0x0,%esi
  801595:	3b 75 10             	cmp    0x10(%ebp),%esi
  801598:	75 13                	jne    8015ad <devpipe_read+0x34>
	return i;
  80159a:	89 f0                	mov    %esi,%eax
  80159c:	eb 02                	jmp    8015a0 <devpipe_read+0x27>
				return i;
  80159e:	89 f0                	mov    %esi,%eax
}
  8015a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a3:	5b                   	pop    %ebx
  8015a4:	5e                   	pop    %esi
  8015a5:	5f                   	pop    %edi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    
			sys_yield();
  8015a8:	e8 af ef ff ff       	call   80055c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8015ad:	8b 03                	mov    (%ebx),%eax
  8015af:	3b 43 04             	cmp    0x4(%ebx),%eax
  8015b2:	75 18                	jne    8015cc <devpipe_read+0x53>
			if (i > 0)
  8015b4:	85 f6                	test   %esi,%esi
  8015b6:	75 e6                	jne    80159e <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8015b8:	89 da                	mov    %ebx,%edx
  8015ba:	89 f8                	mov    %edi,%eax
  8015bc:	e8 d4 fe ff ff       	call   801495 <_pipeisclosed>
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 e3                	je     8015a8 <devpipe_read+0x2f>
				return 0;
  8015c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ca:	eb d4                	jmp    8015a0 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8015cc:	99                   	cltd   
  8015cd:	c1 ea 1b             	shr    $0x1b,%edx
  8015d0:	01 d0                	add    %edx,%eax
  8015d2:	83 e0 1f             	and    $0x1f,%eax
  8015d5:	29 d0                	sub    %edx,%eax
  8015d7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8015dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015df:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8015e2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8015e5:	83 c6 01             	add    $0x1,%esi
  8015e8:	eb ab                	jmp    801595 <devpipe_read+0x1c>

008015ea <pipe>:
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	56                   	push   %esi
  8015ee:	53                   	push   %ebx
  8015ef:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8015f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	e8 f9 f1 ff ff       	call   8007f4 <fd_alloc>
  8015fb:	89 c3                	mov    %eax,%ebx
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	0f 88 23 01 00 00    	js     80172b <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801608:	83 ec 04             	sub    $0x4,%esp
  80160b:	68 07 04 00 00       	push   $0x407
  801610:	ff 75 f4             	push   -0xc(%ebp)
  801613:	6a 00                	push   $0x0
  801615:	e8 61 ef ff ff       	call   80057b <sys_page_alloc>
  80161a:	89 c3                	mov    %eax,%ebx
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	85 c0                	test   %eax,%eax
  801621:	0f 88 04 01 00 00    	js     80172b <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801627:	83 ec 0c             	sub    $0xc,%esp
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	e8 c1 f1 ff ff       	call   8007f4 <fd_alloc>
  801633:	89 c3                	mov    %eax,%ebx
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	0f 88 db 00 00 00    	js     80171b <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	68 07 04 00 00       	push   $0x407
  801648:	ff 75 f0             	push   -0x10(%ebp)
  80164b:	6a 00                	push   $0x0
  80164d:	e8 29 ef ff ff       	call   80057b <sys_page_alloc>
  801652:	89 c3                	mov    %eax,%ebx
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	0f 88 bc 00 00 00    	js     80171b <pipe+0x131>
	va = fd2data(fd0);
  80165f:	83 ec 0c             	sub    $0xc,%esp
  801662:	ff 75 f4             	push   -0xc(%ebp)
  801665:	e8 73 f1 ff ff       	call   8007dd <fd2data>
  80166a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80166c:	83 c4 0c             	add    $0xc,%esp
  80166f:	68 07 04 00 00       	push   $0x407
  801674:	50                   	push   %eax
  801675:	6a 00                	push   $0x0
  801677:	e8 ff ee ff ff       	call   80057b <sys_page_alloc>
  80167c:	89 c3                	mov    %eax,%ebx
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	85 c0                	test   %eax,%eax
  801683:	0f 88 82 00 00 00    	js     80170b <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801689:	83 ec 0c             	sub    $0xc,%esp
  80168c:	ff 75 f0             	push   -0x10(%ebp)
  80168f:	e8 49 f1 ff ff       	call   8007dd <fd2data>
  801694:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80169b:	50                   	push   %eax
  80169c:	6a 00                	push   $0x0
  80169e:	56                   	push   %esi
  80169f:	6a 00                	push   $0x0
  8016a1:	e8 18 ef ff ff       	call   8005be <sys_page_map>
  8016a6:	89 c3                	mov    %eax,%ebx
  8016a8:	83 c4 20             	add    $0x20,%esp
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 4e                	js     8016fd <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8016af:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8016b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8016b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016bc:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8016c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016c6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8016c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	ff 75 f4             	push   -0xc(%ebp)
  8016d8:	e8 f0 f0 ff ff       	call   8007cd <fd2num>
  8016dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8016e2:	83 c4 04             	add    $0x4,%esp
  8016e5:	ff 75 f0             	push   -0x10(%ebp)
  8016e8:	e8 e0 f0 ff ff       	call   8007cd <fd2num>
  8016ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fb:	eb 2e                	jmp    80172b <pipe+0x141>
	sys_page_unmap(0, va);
  8016fd:	83 ec 08             	sub    $0x8,%esp
  801700:	56                   	push   %esi
  801701:	6a 00                	push   $0x0
  801703:	e8 f8 ee ff ff       	call   800600 <sys_page_unmap>
  801708:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80170b:	83 ec 08             	sub    $0x8,%esp
  80170e:	ff 75 f0             	push   -0x10(%ebp)
  801711:	6a 00                	push   $0x0
  801713:	e8 e8 ee ff ff       	call   800600 <sys_page_unmap>
  801718:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	ff 75 f4             	push   -0xc(%ebp)
  801721:	6a 00                	push   $0x0
  801723:	e8 d8 ee ff ff       	call   800600 <sys_page_unmap>
  801728:	83 c4 10             	add    $0x10,%esp
}
  80172b:	89 d8                	mov    %ebx,%eax
  80172d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801730:	5b                   	pop    %ebx
  801731:	5e                   	pop    %esi
  801732:	5d                   	pop    %ebp
  801733:	c3                   	ret    

00801734 <pipeisclosed>:
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	ff 75 08             	push   0x8(%ebp)
  801741:	e8 fe f0 ff ff       	call   800844 <fd_lookup>
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 18                	js     801765 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80174d:	83 ec 0c             	sub    $0xc,%esp
  801750:	ff 75 f4             	push   -0xc(%ebp)
  801753:	e8 85 f0 ff ff       	call   8007dd <fd2data>
  801758:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80175a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175d:	e8 33 fd ff ff       	call   801495 <_pipeisclosed>
  801762:	83 c4 10             	add    $0x10,%esp
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
  80176c:	c3                   	ret    

0080176d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801773:	68 37 24 80 00       	push   $0x802437
  801778:	ff 75 0c             	push   0xc(%ebp)
  80177b:	e8 ff e9 ff ff       	call   80017f <strcpy>
	return 0;
}
  801780:	b8 00 00 00 00       	mov    $0x0,%eax
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devcons_write>:
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	57                   	push   %edi
  80178b:	56                   	push   %esi
  80178c:	53                   	push   %ebx
  80178d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801793:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801798:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80179e:	eb 2e                	jmp    8017ce <devcons_write+0x47>
		m = n - tot;
  8017a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017a3:	29 f3                	sub    %esi,%ebx
  8017a5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8017aa:	39 c3                	cmp    %eax,%ebx
  8017ac:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8017af:	83 ec 04             	sub    $0x4,%esp
  8017b2:	53                   	push   %ebx
  8017b3:	89 f0                	mov    %esi,%eax
  8017b5:	03 45 0c             	add    0xc(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	57                   	push   %edi
  8017ba:	e8 56 eb ff ff       	call   800315 <memmove>
		sys_cputs(buf, m);
  8017bf:	83 c4 08             	add    $0x8,%esp
  8017c2:	53                   	push   %ebx
  8017c3:	57                   	push   %edi
  8017c4:	e8 f6 ec ff ff       	call   8004bf <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8017c9:	01 de                	add    %ebx,%esi
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017d1:	72 cd                	jb     8017a0 <devcons_write+0x19>
}
  8017d3:	89 f0                	mov    %esi,%eax
  8017d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5f                   	pop    %edi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <devcons_read>:
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	83 ec 08             	sub    $0x8,%esp
  8017e3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8017e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8017ec:	75 07                	jne    8017f5 <devcons_read+0x18>
  8017ee:	eb 1f                	jmp    80180f <devcons_read+0x32>
		sys_yield();
  8017f0:	e8 67 ed ff ff       	call   80055c <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8017f5:	e8 e3 ec ff ff       	call   8004dd <sys_cgetc>
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	74 f2                	je     8017f0 <devcons_read+0x13>
	if (c < 0)
  8017fe:	78 0f                	js     80180f <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801800:	83 f8 04             	cmp    $0x4,%eax
  801803:	74 0c                	je     801811 <devcons_read+0x34>
	*(char*)vbuf = c;
  801805:	8b 55 0c             	mov    0xc(%ebp),%edx
  801808:	88 02                	mov    %al,(%edx)
	return 1;
  80180a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    
		return 0;
  801811:	b8 00 00 00 00       	mov    $0x0,%eax
  801816:	eb f7                	jmp    80180f <devcons_read+0x32>

00801818 <cputchar>:
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801824:	6a 01                	push   $0x1
  801826:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801829:	50                   	push   %eax
  80182a:	e8 90 ec ff ff       	call   8004bf <sys_cputs>
}
  80182f:	83 c4 10             	add    $0x10,%esp
  801832:	c9                   	leave  
  801833:	c3                   	ret    

00801834 <getchar>:
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80183a:	6a 01                	push   $0x1
  80183c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80183f:	50                   	push   %eax
  801840:	6a 00                	push   $0x0
  801842:	e8 66 f2 ff ff       	call   800aad <read>
	if (r < 0)
  801847:	83 c4 10             	add    $0x10,%esp
  80184a:	85 c0                	test   %eax,%eax
  80184c:	78 06                	js     801854 <getchar+0x20>
	if (r < 1)
  80184e:	74 06                	je     801856 <getchar+0x22>
	return c;
  801850:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801854:	c9                   	leave  
  801855:	c3                   	ret    
		return -E_EOF;
  801856:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80185b:	eb f7                	jmp    801854 <getchar+0x20>

0080185d <iscons>:
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801863:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801866:	50                   	push   %eax
  801867:	ff 75 08             	push   0x8(%ebp)
  80186a:	e8 d5 ef ff ff       	call   800844 <fd_lookup>
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	85 c0                	test   %eax,%eax
  801874:	78 11                	js     801887 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801879:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80187f:	39 10                	cmp    %edx,(%eax)
  801881:	0f 94 c0             	sete   %al
  801884:	0f b6 c0             	movzbl %al,%eax
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <opencons>:
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80188f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801892:	50                   	push   %eax
  801893:	e8 5c ef ff ff       	call   8007f4 <fd_alloc>
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 3a                	js     8018d9 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80189f:	83 ec 04             	sub    $0x4,%esp
  8018a2:	68 07 04 00 00       	push   $0x407
  8018a7:	ff 75 f4             	push   -0xc(%ebp)
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 ca ec ff ff       	call   80057b <sys_page_alloc>
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	78 21                	js     8018d9 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8018b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8018c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8018c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8018cd:	83 ec 0c             	sub    $0xc,%esp
  8018d0:	50                   	push   %eax
  8018d1:	e8 f7 ee ff ff       	call   8007cd <fd2num>
  8018d6:	83 c4 10             	add    $0x10,%esp
}
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	56                   	push   %esi
  8018df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8018e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8018e9:	e8 4f ec ff ff       	call   80053d <sys_getenvid>
  8018ee:	83 ec 0c             	sub    $0xc,%esp
  8018f1:	ff 75 0c             	push   0xc(%ebp)
  8018f4:	ff 75 08             	push   0x8(%ebp)
  8018f7:	56                   	push   %esi
  8018f8:	50                   	push   %eax
  8018f9:	68 44 24 80 00       	push   $0x802444
  8018fe:	e8 b3 00 00 00       	call   8019b6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801903:	83 c4 18             	add    $0x18,%esp
  801906:	53                   	push   %ebx
  801907:	ff 75 10             	push   0x10(%ebp)
  80190a:	e8 56 00 00 00       	call   801965 <vcprintf>
	cprintf("\n");
  80190f:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  801916:	e8 9b 00 00 00       	call   8019b6 <cprintf>
  80191b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80191e:	cc                   	int3   
  80191f:	eb fd                	jmp    80191e <_panic+0x43>

00801921 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80192b:	8b 13                	mov    (%ebx),%edx
  80192d:	8d 42 01             	lea    0x1(%edx),%eax
  801930:	89 03                	mov    %eax,(%ebx)
  801932:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801935:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801939:	3d ff 00 00 00       	cmp    $0xff,%eax
  80193e:	74 09                	je     801949 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801940:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801944:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801947:	c9                   	leave  
  801948:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	68 ff 00 00 00       	push   $0xff
  801951:	8d 43 08             	lea    0x8(%ebx),%eax
  801954:	50                   	push   %eax
  801955:	e8 65 eb ff ff       	call   8004bf <sys_cputs>
		b->idx = 0;
  80195a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	eb db                	jmp    801940 <putch+0x1f>

00801965 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80196e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801975:	00 00 00 
	b.cnt = 0;
  801978:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80197f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801982:	ff 75 0c             	push   0xc(%ebp)
  801985:	ff 75 08             	push   0x8(%ebp)
  801988:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80198e:	50                   	push   %eax
  80198f:	68 21 19 80 00       	push   $0x801921
  801994:	e8 14 01 00 00       	call   801aad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801999:	83 c4 08             	add    $0x8,%esp
  80199c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8019a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8019a8:	50                   	push   %eax
  8019a9:	e8 11 eb ff ff       	call   8004bf <sys_cputs>

	return b.cnt;
}
  8019ae:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019bc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8019bf:	50                   	push   %eax
  8019c0:	ff 75 08             	push   0x8(%ebp)
  8019c3:	e8 9d ff ff ff       	call   801965 <vcprintf>
	va_end(ap);

	return cnt;
}
  8019c8:	c9                   	leave  
  8019c9:	c3                   	ret    

008019ca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	57                   	push   %edi
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	83 ec 1c             	sub    $0x1c,%esp
  8019d3:	89 c7                	mov    %eax,%edi
  8019d5:	89 d6                	mov    %edx,%esi
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019dd:	89 d1                	mov    %edx,%ecx
  8019df:	89 c2                	mov    %eax,%edx
  8019e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8019ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019f7:	39 c2                	cmp    %eax,%edx
  8019f9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8019fc:	72 3e                	jb     801a3c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8019fe:	83 ec 0c             	sub    $0xc,%esp
  801a01:	ff 75 18             	push   0x18(%ebp)
  801a04:	83 eb 01             	sub    $0x1,%ebx
  801a07:	53                   	push   %ebx
  801a08:	50                   	push   %eax
  801a09:	83 ec 08             	sub    $0x8,%esp
  801a0c:	ff 75 e4             	push   -0x1c(%ebp)
  801a0f:	ff 75 e0             	push   -0x20(%ebp)
  801a12:	ff 75 dc             	push   -0x24(%ebp)
  801a15:	ff 75 d8             	push   -0x28(%ebp)
  801a18:	e8 73 06 00 00       	call   802090 <__udivdi3>
  801a1d:	83 c4 18             	add    $0x18,%esp
  801a20:	52                   	push   %edx
  801a21:	50                   	push   %eax
  801a22:	89 f2                	mov    %esi,%edx
  801a24:	89 f8                	mov    %edi,%eax
  801a26:	e8 9f ff ff ff       	call   8019ca <printnum>
  801a2b:	83 c4 20             	add    $0x20,%esp
  801a2e:	eb 13                	jmp    801a43 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	56                   	push   %esi
  801a34:	ff 75 18             	push   0x18(%ebp)
  801a37:	ff d7                	call   *%edi
  801a39:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801a3c:	83 eb 01             	sub    $0x1,%ebx
  801a3f:	85 db                	test   %ebx,%ebx
  801a41:	7f ed                	jg     801a30 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801a43:	83 ec 08             	sub    $0x8,%esp
  801a46:	56                   	push   %esi
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	ff 75 e4             	push   -0x1c(%ebp)
  801a4d:	ff 75 e0             	push   -0x20(%ebp)
  801a50:	ff 75 dc             	push   -0x24(%ebp)
  801a53:	ff 75 d8             	push   -0x28(%ebp)
  801a56:	e8 55 07 00 00       	call   8021b0 <__umoddi3>
  801a5b:	83 c4 14             	add    $0x14,%esp
  801a5e:	0f be 80 67 24 80 00 	movsbl 0x802467(%eax),%eax
  801a65:	50                   	push   %eax
  801a66:	ff d7                	call   *%edi
}
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5e                   	pop    %esi
  801a70:	5f                   	pop    %edi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    

00801a73 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801a79:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801a7d:	8b 10                	mov    (%eax),%edx
  801a7f:	3b 50 04             	cmp    0x4(%eax),%edx
  801a82:	73 0a                	jae    801a8e <sprintputch+0x1b>
		*b->buf++ = ch;
  801a84:	8d 4a 01             	lea    0x1(%edx),%ecx
  801a87:	89 08                	mov    %ecx,(%eax)
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	88 02                	mov    %al,(%edx)
}
  801a8e:	5d                   	pop    %ebp
  801a8f:	c3                   	ret    

00801a90 <printfmt>:
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801a96:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801a99:	50                   	push   %eax
  801a9a:	ff 75 10             	push   0x10(%ebp)
  801a9d:	ff 75 0c             	push   0xc(%ebp)
  801aa0:	ff 75 08             	push   0x8(%ebp)
  801aa3:	e8 05 00 00 00       	call   801aad <vprintfmt>
}
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <vprintfmt>:
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	57                   	push   %edi
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 3c             	sub    $0x3c,%esp
  801ab6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801abc:	8b 7d 10             	mov    0x10(%ebp),%edi
  801abf:	eb 0a                	jmp    801acb <vprintfmt+0x1e>
			putch(ch, putdat);
  801ac1:	83 ec 08             	sub    $0x8,%esp
  801ac4:	53                   	push   %ebx
  801ac5:	50                   	push   %eax
  801ac6:	ff d6                	call   *%esi
  801ac8:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801acb:	83 c7 01             	add    $0x1,%edi
  801ace:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ad2:	83 f8 25             	cmp    $0x25,%eax
  801ad5:	74 0c                	je     801ae3 <vprintfmt+0x36>
			if (ch == '\0')
  801ad7:	85 c0                	test   %eax,%eax
  801ad9:	75 e6                	jne    801ac1 <vprintfmt+0x14>
}
  801adb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ade:	5b                   	pop    %ebx
  801adf:	5e                   	pop    %esi
  801ae0:	5f                   	pop    %edi
  801ae1:	5d                   	pop    %ebp
  801ae2:	c3                   	ret    
		padc = ' ';
  801ae3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801ae7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801aee:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801af5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801afc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801b01:	8d 47 01             	lea    0x1(%edi),%eax
  801b04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b07:	0f b6 17             	movzbl (%edi),%edx
  801b0a:	8d 42 dd             	lea    -0x23(%edx),%eax
  801b0d:	3c 55                	cmp    $0x55,%al
  801b0f:	0f 87 bb 03 00 00    	ja     801ed0 <vprintfmt+0x423>
  801b15:	0f b6 c0             	movzbl %al,%eax
  801b18:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  801b1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801b22:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801b26:	eb d9                	jmp    801b01 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801b28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b2b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801b2f:	eb d0                	jmp    801b01 <vprintfmt+0x54>
  801b31:	0f b6 d2             	movzbl %dl,%edx
  801b34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801b3f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801b42:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801b46:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801b49:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801b4c:	83 f9 09             	cmp    $0x9,%ecx
  801b4f:	77 55                	ja     801ba6 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801b51:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801b54:	eb e9                	jmp    801b3f <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801b56:	8b 45 14             	mov    0x14(%ebp),%eax
  801b59:	8b 00                	mov    (%eax),%eax
  801b5b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b5e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b61:	8d 40 04             	lea    0x4(%eax),%eax
  801b64:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801b67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801b6a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801b6e:	79 91                	jns    801b01 <vprintfmt+0x54>
				width = precision, precision = -1;
  801b70:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b76:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801b7d:	eb 82                	jmp    801b01 <vprintfmt+0x54>
  801b7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801b82:	85 d2                	test   %edx,%edx
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	0f 49 c2             	cmovns %edx,%eax
  801b8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801b8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801b92:	e9 6a ff ff ff       	jmp    801b01 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801b97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801b9a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801ba1:	e9 5b ff ff ff       	jmp    801b01 <vprintfmt+0x54>
  801ba6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801ba9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bac:	eb bc                	jmp    801b6a <vprintfmt+0xbd>
			lflag++;
  801bae:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801bb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801bb4:	e9 48 ff ff ff       	jmp    801b01 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801bb9:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbc:	8d 78 04             	lea    0x4(%eax),%edi
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	53                   	push   %ebx
  801bc3:	ff 30                	push   (%eax)
  801bc5:	ff d6                	call   *%esi
			break;
  801bc7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801bca:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801bcd:	e9 9d 02 00 00       	jmp    801e6f <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  801bd2:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd5:	8d 78 04             	lea    0x4(%eax),%edi
  801bd8:	8b 10                	mov    (%eax),%edx
  801bda:	89 d0                	mov    %edx,%eax
  801bdc:	f7 d8                	neg    %eax
  801bde:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801be1:	83 f8 0f             	cmp    $0xf,%eax
  801be4:	7f 23                	jg     801c09 <vprintfmt+0x15c>
  801be6:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  801bed:	85 d2                	test   %edx,%edx
  801bef:	74 18                	je     801c09 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801bf1:	52                   	push   %edx
  801bf2:	68 c5 23 80 00       	push   $0x8023c5
  801bf7:	53                   	push   %ebx
  801bf8:	56                   	push   %esi
  801bf9:	e8 92 fe ff ff       	call   801a90 <printfmt>
  801bfe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801c01:	89 7d 14             	mov    %edi,0x14(%ebp)
  801c04:	e9 66 02 00 00       	jmp    801e6f <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801c09:	50                   	push   %eax
  801c0a:	68 7f 24 80 00       	push   $0x80247f
  801c0f:	53                   	push   %ebx
  801c10:	56                   	push   %esi
  801c11:	e8 7a fe ff ff       	call   801a90 <printfmt>
  801c16:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801c19:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801c1c:	e9 4e 02 00 00       	jmp    801e6f <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801c21:	8b 45 14             	mov    0x14(%ebp),%eax
  801c24:	83 c0 04             	add    $0x4,%eax
  801c27:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801c2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c2d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801c2f:	85 d2                	test   %edx,%edx
  801c31:	b8 78 24 80 00       	mov    $0x802478,%eax
  801c36:	0f 45 c2             	cmovne %edx,%eax
  801c39:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801c3c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c40:	7e 06                	jle    801c48 <vprintfmt+0x19b>
  801c42:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801c46:	75 0d                	jne    801c55 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801c48:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801c4b:	89 c7                	mov    %eax,%edi
  801c4d:	03 45 e0             	add    -0x20(%ebp),%eax
  801c50:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c53:	eb 55                	jmp    801caa <vprintfmt+0x1fd>
  801c55:	83 ec 08             	sub    $0x8,%esp
  801c58:	ff 75 d8             	push   -0x28(%ebp)
  801c5b:	ff 75 cc             	push   -0x34(%ebp)
  801c5e:	e8 f9 e4 ff ff       	call   80015c <strnlen>
  801c63:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c66:	29 c1                	sub    %eax,%ecx
  801c68:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801c70:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801c74:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801c77:	eb 0f                	jmp    801c88 <vprintfmt+0x1db>
					putch(padc, putdat);
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	53                   	push   %ebx
  801c7d:	ff 75 e0             	push   -0x20(%ebp)
  801c80:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801c82:	83 ef 01             	sub    $0x1,%edi
  801c85:	83 c4 10             	add    $0x10,%esp
  801c88:	85 ff                	test   %edi,%edi
  801c8a:	7f ed                	jg     801c79 <vprintfmt+0x1cc>
  801c8c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801c8f:	85 d2                	test   %edx,%edx
  801c91:	b8 00 00 00 00       	mov    $0x0,%eax
  801c96:	0f 49 c2             	cmovns %edx,%eax
  801c99:	29 c2                	sub    %eax,%edx
  801c9b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801c9e:	eb a8                	jmp    801c48 <vprintfmt+0x19b>
					putch(ch, putdat);
  801ca0:	83 ec 08             	sub    $0x8,%esp
  801ca3:	53                   	push   %ebx
  801ca4:	52                   	push   %edx
  801ca5:	ff d6                	call   *%esi
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801cad:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801caf:	83 c7 01             	add    $0x1,%edi
  801cb2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801cb6:	0f be d0             	movsbl %al,%edx
  801cb9:	85 d2                	test   %edx,%edx
  801cbb:	74 4b                	je     801d08 <vprintfmt+0x25b>
  801cbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801cc1:	78 06                	js     801cc9 <vprintfmt+0x21c>
  801cc3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801cc7:	78 1e                	js     801ce7 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  801cc9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801ccd:	74 d1                	je     801ca0 <vprintfmt+0x1f3>
  801ccf:	0f be c0             	movsbl %al,%eax
  801cd2:	83 e8 20             	sub    $0x20,%eax
  801cd5:	83 f8 5e             	cmp    $0x5e,%eax
  801cd8:	76 c6                	jbe    801ca0 <vprintfmt+0x1f3>
					putch('?', putdat);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	53                   	push   %ebx
  801cde:	6a 3f                	push   $0x3f
  801ce0:	ff d6                	call   *%esi
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	eb c3                	jmp    801caa <vprintfmt+0x1fd>
  801ce7:	89 cf                	mov    %ecx,%edi
  801ce9:	eb 0e                	jmp    801cf9 <vprintfmt+0x24c>
				putch(' ', putdat);
  801ceb:	83 ec 08             	sub    $0x8,%esp
  801cee:	53                   	push   %ebx
  801cef:	6a 20                	push   $0x20
  801cf1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801cf3:	83 ef 01             	sub    $0x1,%edi
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	85 ff                	test   %edi,%edi
  801cfb:	7f ee                	jg     801ceb <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801cfd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801d00:	89 45 14             	mov    %eax,0x14(%ebp)
  801d03:	e9 67 01 00 00       	jmp    801e6f <vprintfmt+0x3c2>
  801d08:	89 cf                	mov    %ecx,%edi
  801d0a:	eb ed                	jmp    801cf9 <vprintfmt+0x24c>
	if (lflag >= 2)
  801d0c:	83 f9 01             	cmp    $0x1,%ecx
  801d0f:	7f 1b                	jg     801d2c <vprintfmt+0x27f>
	else if (lflag)
  801d11:	85 c9                	test   %ecx,%ecx
  801d13:	74 63                	je     801d78 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801d15:	8b 45 14             	mov    0x14(%ebp),%eax
  801d18:	8b 00                	mov    (%eax),%eax
  801d1a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d1d:	99                   	cltd   
  801d1e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d21:	8b 45 14             	mov    0x14(%ebp),%eax
  801d24:	8d 40 04             	lea    0x4(%eax),%eax
  801d27:	89 45 14             	mov    %eax,0x14(%ebp)
  801d2a:	eb 17                	jmp    801d43 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801d2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801d2f:	8b 50 04             	mov    0x4(%eax),%edx
  801d32:	8b 00                	mov    (%eax),%eax
  801d34:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d37:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d3a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d3d:	8d 40 08             	lea    0x8(%eax),%eax
  801d40:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801d43:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801d46:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801d49:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801d4e:	85 c9                	test   %ecx,%ecx
  801d50:	0f 89 ff 00 00 00    	jns    801e55 <vprintfmt+0x3a8>
				putch('-', putdat);
  801d56:	83 ec 08             	sub    $0x8,%esp
  801d59:	53                   	push   %ebx
  801d5a:	6a 2d                	push   $0x2d
  801d5c:	ff d6                	call   *%esi
				num = -(long long) num;
  801d5e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801d61:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801d64:	f7 da                	neg    %edx
  801d66:	83 d1 00             	adc    $0x0,%ecx
  801d69:	f7 d9                	neg    %ecx
  801d6b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801d6e:	bf 0a 00 00 00       	mov    $0xa,%edi
  801d73:	e9 dd 00 00 00       	jmp    801e55 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801d78:	8b 45 14             	mov    0x14(%ebp),%eax
  801d7b:	8b 00                	mov    (%eax),%eax
  801d7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801d80:	99                   	cltd   
  801d81:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801d84:	8b 45 14             	mov    0x14(%ebp),%eax
  801d87:	8d 40 04             	lea    0x4(%eax),%eax
  801d8a:	89 45 14             	mov    %eax,0x14(%ebp)
  801d8d:	eb b4                	jmp    801d43 <vprintfmt+0x296>
	if (lflag >= 2)
  801d8f:	83 f9 01             	cmp    $0x1,%ecx
  801d92:	7f 1e                	jg     801db2 <vprintfmt+0x305>
	else if (lflag)
  801d94:	85 c9                	test   %ecx,%ecx
  801d96:	74 32                	je     801dca <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801d98:	8b 45 14             	mov    0x14(%ebp),%eax
  801d9b:	8b 10                	mov    (%eax),%edx
  801d9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801da2:	8d 40 04             	lea    0x4(%eax),%eax
  801da5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801da8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801dad:	e9 a3 00 00 00       	jmp    801e55 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801db2:	8b 45 14             	mov    0x14(%ebp),%eax
  801db5:	8b 10                	mov    (%eax),%edx
  801db7:	8b 48 04             	mov    0x4(%eax),%ecx
  801dba:	8d 40 08             	lea    0x8(%eax),%eax
  801dbd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801dc0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  801dc5:	e9 8b 00 00 00       	jmp    801e55 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801dca:	8b 45 14             	mov    0x14(%ebp),%eax
  801dcd:	8b 10                	mov    (%eax),%edx
  801dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dd4:	8d 40 04             	lea    0x4(%eax),%eax
  801dd7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801dda:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801ddf:	eb 74                	jmp    801e55 <vprintfmt+0x3a8>
	if (lflag >= 2)
  801de1:	83 f9 01             	cmp    $0x1,%ecx
  801de4:	7f 1b                	jg     801e01 <vprintfmt+0x354>
	else if (lflag)
  801de6:	85 c9                	test   %ecx,%ecx
  801de8:	74 2c                	je     801e16 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801dea:	8b 45 14             	mov    0x14(%ebp),%eax
  801ded:	8b 10                	mov    (%eax),%edx
  801def:	b9 00 00 00 00       	mov    $0x0,%ecx
  801df4:	8d 40 04             	lea    0x4(%eax),%eax
  801df7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801dfa:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801dff:	eb 54                	jmp    801e55 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801e01:	8b 45 14             	mov    0x14(%ebp),%eax
  801e04:	8b 10                	mov    (%eax),%edx
  801e06:	8b 48 04             	mov    0x4(%eax),%ecx
  801e09:	8d 40 08             	lea    0x8(%eax),%eax
  801e0c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801e0f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801e14:	eb 3f                	jmp    801e55 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801e16:	8b 45 14             	mov    0x14(%ebp),%eax
  801e19:	8b 10                	mov    (%eax),%edx
  801e1b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e20:	8d 40 04             	lea    0x4(%eax),%eax
  801e23:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801e26:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801e2b:	eb 28                	jmp    801e55 <vprintfmt+0x3a8>
			putch('0', putdat);
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	53                   	push   %ebx
  801e31:	6a 30                	push   $0x30
  801e33:	ff d6                	call   *%esi
			putch('x', putdat);
  801e35:	83 c4 08             	add    $0x8,%esp
  801e38:	53                   	push   %ebx
  801e39:	6a 78                	push   $0x78
  801e3b:	ff d6                	call   *%esi
			num = (unsigned long long)
  801e3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e40:	8b 10                	mov    (%eax),%edx
  801e42:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801e47:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801e4a:	8d 40 04             	lea    0x4(%eax),%eax
  801e4d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801e50:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801e55:	83 ec 0c             	sub    $0xc,%esp
  801e58:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	ff 75 e0             	push   -0x20(%ebp)
  801e60:	57                   	push   %edi
  801e61:	51                   	push   %ecx
  801e62:	52                   	push   %edx
  801e63:	89 da                	mov    %ebx,%edx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	e8 5e fb ff ff       	call   8019ca <printnum>
			break;
  801e6c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801e6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801e72:	e9 54 fc ff ff       	jmp    801acb <vprintfmt+0x1e>
	if (lflag >= 2)
  801e77:	83 f9 01             	cmp    $0x1,%ecx
  801e7a:	7f 1b                	jg     801e97 <vprintfmt+0x3ea>
	else if (lflag)
  801e7c:	85 c9                	test   %ecx,%ecx
  801e7e:	74 2c                	je     801eac <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801e80:	8b 45 14             	mov    0x14(%ebp),%eax
  801e83:	8b 10                	mov    (%eax),%edx
  801e85:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e8a:	8d 40 04             	lea    0x4(%eax),%eax
  801e8d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801e90:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801e95:	eb be                	jmp    801e55 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801e97:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9a:	8b 10                	mov    (%eax),%edx
  801e9c:	8b 48 04             	mov    0x4(%eax),%ecx
  801e9f:	8d 40 08             	lea    0x8(%eax),%eax
  801ea2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ea5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801eaa:	eb a9                	jmp    801e55 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801eac:	8b 45 14             	mov    0x14(%ebp),%eax
  801eaf:	8b 10                	mov    (%eax),%edx
  801eb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801eb6:	8d 40 04             	lea    0x4(%eax),%eax
  801eb9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ebc:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801ec1:	eb 92                	jmp    801e55 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ec3:	83 ec 08             	sub    $0x8,%esp
  801ec6:	53                   	push   %ebx
  801ec7:	6a 25                	push   $0x25
  801ec9:	ff d6                	call   *%esi
			break;
  801ecb:	83 c4 10             	add    $0x10,%esp
  801ece:	eb 9f                	jmp    801e6f <vprintfmt+0x3c2>
			putch('%', putdat);
  801ed0:	83 ec 08             	sub    $0x8,%esp
  801ed3:	53                   	push   %ebx
  801ed4:	6a 25                	push   $0x25
  801ed6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	89 f8                	mov    %edi,%eax
  801edd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ee1:	74 05                	je     801ee8 <vprintfmt+0x43b>
  801ee3:	83 e8 01             	sub    $0x1,%eax
  801ee6:	eb f5                	jmp    801edd <vprintfmt+0x430>
  801ee8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eeb:	eb 82                	jmp    801e6f <vprintfmt+0x3c2>

00801eed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 18             	sub    $0x18,%esp
  801ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ef9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801efc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f00:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	74 26                	je     801f34 <vsnprintf+0x47>
  801f0e:	85 d2                	test   %edx,%edx
  801f10:	7e 22                	jle    801f34 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f12:	ff 75 14             	push   0x14(%ebp)
  801f15:	ff 75 10             	push   0x10(%ebp)
  801f18:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f1b:	50                   	push   %eax
  801f1c:	68 73 1a 80 00       	push   $0x801a73
  801f21:	e8 87 fb ff ff       	call   801aad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f29:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2f:	83 c4 10             	add    $0x10,%esp
}
  801f32:	c9                   	leave  
  801f33:	c3                   	ret    
		return -E_INVAL;
  801f34:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f39:	eb f7                	jmp    801f32 <vsnprintf+0x45>

00801f3b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801f41:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801f44:	50                   	push   %eax
  801f45:	ff 75 10             	push   0x10(%ebp)
  801f48:	ff 75 0c             	push   0xc(%ebp)
  801f4b:	ff 75 08             	push   0x8(%ebp)
  801f4e:	e8 9a ff ff ff       	call   801eed <vsnprintf>
	va_end(ap);

	return rc;
}
  801f53:	c9                   	leave  
  801f54:	c3                   	ret    

00801f55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	56                   	push   %esi
  801f59:	53                   	push   %ebx
  801f5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f63:	85 c0                	test   %eax,%eax
  801f65:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f6a:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	50                   	push   %eax
  801f71:	e8 b5 e7 ff ff       	call   80072b <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 f6                	test   %esi,%esi
  801f7b:	74 14                	je     801f91 <ipc_recv+0x3c>
  801f7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f82:	85 c0                	test   %eax,%eax
  801f84:	78 09                	js     801f8f <ipc_recv+0x3a>
  801f86:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f8c:	8b 52 74             	mov    0x74(%edx),%edx
  801f8f:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f91:	85 db                	test   %ebx,%ebx
  801f93:	74 14                	je     801fa9 <ipc_recv+0x54>
  801f95:	ba 00 00 00 00       	mov    $0x0,%edx
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	78 09                	js     801fa7 <ipc_recv+0x52>
  801f9e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fa4:	8b 52 78             	mov    0x78(%edx),%edx
  801fa7:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 08                	js     801fb5 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801fad:	a1 00 40 80 00       	mov    0x804000,%eax
  801fb2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	57                   	push   %edi
  801fc0:	56                   	push   %esi
  801fc1:	53                   	push   %ebx
  801fc2:	83 ec 0c             	sub    $0xc,%esp
  801fc5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fce:	85 db                	test   %ebx,%ebx
  801fd0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd5:	0f 44 d8             	cmove  %eax,%ebx
  801fd8:	eb 05                	jmp    801fdf <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fda:	e8 7d e5 ff ff       	call   80055c <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801fdf:	ff 75 14             	push   0x14(%ebp)
  801fe2:	53                   	push   %ebx
  801fe3:	56                   	push   %esi
  801fe4:	57                   	push   %edi
  801fe5:	e8 1e e7 ff ff       	call   800708 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ff0:	74 e8                	je     801fda <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ff2:	85 c0                	test   %eax,%eax
  801ff4:	78 08                	js     801ffe <ipc_send+0x42>
	}while (r<0);

}
  801ff6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff9:	5b                   	pop    %ebx
  801ffa:	5e                   	pop    %esi
  801ffb:	5f                   	pop    %edi
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ffe:	50                   	push   %eax
  801fff:	68 5f 27 80 00       	push   $0x80275f
  802004:	6a 3d                	push   $0x3d
  802006:	68 73 27 80 00       	push   $0x802773
  80200b:	e8 cb f8 ff ff       	call   8018db <_panic>

00802010 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802016:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80201b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80201e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802024:	8b 52 50             	mov    0x50(%edx),%edx
  802027:	39 ca                	cmp    %ecx,%edx
  802029:	74 11                	je     80203c <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80202b:	83 c0 01             	add    $0x1,%eax
  80202e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802033:	75 e6                	jne    80201b <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802035:	b8 00 00 00 00       	mov    $0x0,%eax
  80203a:	eb 0b                	jmp    802047 <ipc_find_env+0x37>
			return envs[i].env_id;
  80203c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80203f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802044:	8b 40 48             	mov    0x48(%eax),%eax
}
  802047:	5d                   	pop    %ebp
  802048:	c3                   	ret    

00802049 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802049:	55                   	push   %ebp
  80204a:	89 e5                	mov    %esp,%ebp
  80204c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80204f:	89 c2                	mov    %eax,%edx
  802051:	c1 ea 16             	shr    $0x16,%edx
  802054:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80205b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802060:	f6 c1 01             	test   $0x1,%cl
  802063:	74 1c                	je     802081 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802065:	c1 e8 0c             	shr    $0xc,%eax
  802068:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80206f:	a8 01                	test   $0x1,%al
  802071:	74 0e                	je     802081 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802073:	c1 e8 0c             	shr    $0xc,%eax
  802076:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80207d:	ef 
  80207e:	0f b7 d2             	movzwl %dx,%edx
}
  802081:	89 d0                	mov    %edx,%eax
  802083:	5d                   	pop    %ebp
  802084:	c3                   	ret    
  802085:	66 90                	xchg   %ax,%ax
  802087:	66 90                	xchg   %ax,%ax
  802089:	66 90                	xchg   %ax,%ax
  80208b:	66 90                	xchg   %ax,%ax
  80208d:	66 90                	xchg   %ax,%ax
  80208f:	90                   	nop

00802090 <__udivdi3>:
  802090:	f3 0f 1e fb          	endbr32 
  802094:	55                   	push   %ebp
  802095:	57                   	push   %edi
  802096:	56                   	push   %esi
  802097:	53                   	push   %ebx
  802098:	83 ec 1c             	sub    $0x1c,%esp
  80209b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80209f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	75 19                	jne    8020c8 <__udivdi3+0x38>
  8020af:	39 f3                	cmp    %esi,%ebx
  8020b1:	76 4d                	jbe    802100 <__udivdi3+0x70>
  8020b3:	31 ff                	xor    %edi,%edi
  8020b5:	89 e8                	mov    %ebp,%eax
  8020b7:	89 f2                	mov    %esi,%edx
  8020b9:	f7 f3                	div    %ebx
  8020bb:	89 fa                	mov    %edi,%edx
  8020bd:	83 c4 1c             	add    $0x1c,%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    
  8020c5:	8d 76 00             	lea    0x0(%esi),%esi
  8020c8:	39 f0                	cmp    %esi,%eax
  8020ca:	76 14                	jbe    8020e0 <__udivdi3+0x50>
  8020cc:	31 ff                	xor    %edi,%edi
  8020ce:	31 c0                	xor    %eax,%eax
  8020d0:	89 fa                	mov    %edi,%edx
  8020d2:	83 c4 1c             	add    $0x1c,%esp
  8020d5:	5b                   	pop    %ebx
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	5d                   	pop    %ebp
  8020d9:	c3                   	ret    
  8020da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e0:	0f bd f8             	bsr    %eax,%edi
  8020e3:	83 f7 1f             	xor    $0x1f,%edi
  8020e6:	75 48                	jne    802130 <__udivdi3+0xa0>
  8020e8:	39 f0                	cmp    %esi,%eax
  8020ea:	72 06                	jb     8020f2 <__udivdi3+0x62>
  8020ec:	31 c0                	xor    %eax,%eax
  8020ee:	39 eb                	cmp    %ebp,%ebx
  8020f0:	77 de                	ja     8020d0 <__udivdi3+0x40>
  8020f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f7:	eb d7                	jmp    8020d0 <__udivdi3+0x40>
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	89 d9                	mov    %ebx,%ecx
  802102:	85 db                	test   %ebx,%ebx
  802104:	75 0b                	jne    802111 <__udivdi3+0x81>
  802106:	b8 01 00 00 00       	mov    $0x1,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	f7 f3                	div    %ebx
  80210f:	89 c1                	mov    %eax,%ecx
  802111:	31 d2                	xor    %edx,%edx
  802113:	89 f0                	mov    %esi,%eax
  802115:	f7 f1                	div    %ecx
  802117:	89 c6                	mov    %eax,%esi
  802119:	89 e8                	mov    %ebp,%eax
  80211b:	89 f7                	mov    %esi,%edi
  80211d:	f7 f1                	div    %ecx
  80211f:	89 fa                	mov    %edi,%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 f9                	mov    %edi,%ecx
  802132:	ba 20 00 00 00       	mov    $0x20,%edx
  802137:	29 fa                	sub    %edi,%edx
  802139:	d3 e0                	shl    %cl,%eax
  80213b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80213f:	89 d1                	mov    %edx,%ecx
  802141:	89 d8                	mov    %ebx,%eax
  802143:	d3 e8                	shr    %cl,%eax
  802145:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802149:	09 c1                	or     %eax,%ecx
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e3                	shl    %cl,%ebx
  802155:	89 d1                	mov    %edx,%ecx
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 f9                	mov    %edi,%ecx
  80215b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80215f:	89 eb                	mov    %ebp,%ebx
  802161:	d3 e6                	shl    %cl,%esi
  802163:	89 d1                	mov    %edx,%ecx
  802165:	d3 eb                	shr    %cl,%ebx
  802167:	09 f3                	or     %esi,%ebx
  802169:	89 c6                	mov    %eax,%esi
  80216b:	89 f2                	mov    %esi,%edx
  80216d:	89 d8                	mov    %ebx,%eax
  80216f:	f7 74 24 08          	divl   0x8(%esp)
  802173:	89 d6                	mov    %edx,%esi
  802175:	89 c3                	mov    %eax,%ebx
  802177:	f7 64 24 0c          	mull   0xc(%esp)
  80217b:	39 d6                	cmp    %edx,%esi
  80217d:	72 19                	jb     802198 <__udivdi3+0x108>
  80217f:	89 f9                	mov    %edi,%ecx
  802181:	d3 e5                	shl    %cl,%ebp
  802183:	39 c5                	cmp    %eax,%ebp
  802185:	73 04                	jae    80218b <__udivdi3+0xfb>
  802187:	39 d6                	cmp    %edx,%esi
  802189:	74 0d                	je     802198 <__udivdi3+0x108>
  80218b:	89 d8                	mov    %ebx,%eax
  80218d:	31 ff                	xor    %edi,%edi
  80218f:	e9 3c ff ff ff       	jmp    8020d0 <__udivdi3+0x40>
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80219b:	31 ff                	xor    %edi,%edi
  80219d:	e9 2e ff ff ff       	jmp    8020d0 <__udivdi3+0x40>
  8021a2:	66 90                	xchg   %ax,%ax
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__umoddi3>:
  8021b0:	f3 0f 1e fb          	endbr32 
  8021b4:	55                   	push   %ebp
  8021b5:	57                   	push   %edi
  8021b6:	56                   	push   %esi
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 1c             	sub    $0x1c,%esp
  8021bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021cb:	89 f0                	mov    %esi,%eax
  8021cd:	89 da                	mov    %ebx,%edx
  8021cf:	85 ff                	test   %edi,%edi
  8021d1:	75 15                	jne    8021e8 <__umoddi3+0x38>
  8021d3:	39 dd                	cmp    %ebx,%ebp
  8021d5:	76 39                	jbe    802210 <__umoddi3+0x60>
  8021d7:	f7 f5                	div    %ebp
  8021d9:	89 d0                	mov    %edx,%eax
  8021db:	31 d2                	xor    %edx,%edx
  8021dd:	83 c4 1c             	add    $0x1c,%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	39 df                	cmp    %ebx,%edi
  8021ea:	77 f1                	ja     8021dd <__umoddi3+0x2d>
  8021ec:	0f bd cf             	bsr    %edi,%ecx
  8021ef:	83 f1 1f             	xor    $0x1f,%ecx
  8021f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021f6:	75 40                	jne    802238 <__umoddi3+0x88>
  8021f8:	39 df                	cmp    %ebx,%edi
  8021fa:	72 04                	jb     802200 <__umoddi3+0x50>
  8021fc:	39 f5                	cmp    %esi,%ebp
  8021fe:	77 dd                	ja     8021dd <__umoddi3+0x2d>
  802200:	89 da                	mov    %ebx,%edx
  802202:	89 f0                	mov    %esi,%eax
  802204:	29 e8                	sub    %ebp,%eax
  802206:	19 fa                	sbb    %edi,%edx
  802208:	eb d3                	jmp    8021dd <__umoddi3+0x2d>
  80220a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802210:	89 e9                	mov    %ebp,%ecx
  802212:	85 ed                	test   %ebp,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x71>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f5                	div    %ebp
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	89 d8                	mov    %ebx,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f1                	div    %ecx
  802227:	89 f0                	mov    %esi,%eax
  802229:	f7 f1                	div    %ecx
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	31 d2                	xor    %edx,%edx
  80222f:	eb ac                	jmp    8021dd <__umoddi3+0x2d>
  802231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802238:	8b 44 24 04          	mov    0x4(%esp),%eax
  80223c:	ba 20 00 00 00       	mov    $0x20,%edx
  802241:	29 c2                	sub    %eax,%edx
  802243:	89 c1                	mov    %eax,%ecx
  802245:	89 e8                	mov    %ebp,%eax
  802247:	d3 e7                	shl    %cl,%edi
  802249:	89 d1                	mov    %edx,%ecx
  80224b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80224f:	d3 e8                	shr    %cl,%eax
  802251:	89 c1                	mov    %eax,%ecx
  802253:	8b 44 24 04          	mov    0x4(%esp),%eax
  802257:	09 f9                	or     %edi,%ecx
  802259:	89 df                	mov    %ebx,%edi
  80225b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	d3 e5                	shl    %cl,%ebp
  802263:	89 d1                	mov    %edx,%ecx
  802265:	d3 ef                	shr    %cl,%edi
  802267:	89 c1                	mov    %eax,%ecx
  802269:	89 f0                	mov    %esi,%eax
  80226b:	d3 e3                	shl    %cl,%ebx
  80226d:	89 d1                	mov    %edx,%ecx
  80226f:	89 fa                	mov    %edi,%edx
  802271:	d3 e8                	shr    %cl,%eax
  802273:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802278:	09 d8                	or     %ebx,%eax
  80227a:	f7 74 24 08          	divl   0x8(%esp)
  80227e:	89 d3                	mov    %edx,%ebx
  802280:	d3 e6                	shl    %cl,%esi
  802282:	f7 e5                	mul    %ebp
  802284:	89 c7                	mov    %eax,%edi
  802286:	89 d1                	mov    %edx,%ecx
  802288:	39 d3                	cmp    %edx,%ebx
  80228a:	72 06                	jb     802292 <__umoddi3+0xe2>
  80228c:	75 0e                	jne    80229c <__umoddi3+0xec>
  80228e:	39 c6                	cmp    %eax,%esi
  802290:	73 0a                	jae    80229c <__umoddi3+0xec>
  802292:	29 e8                	sub    %ebp,%eax
  802294:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802298:	89 d1                	mov    %edx,%ecx
  80229a:	89 c7                	mov    %eax,%edi
  80229c:	89 f5                	mov    %esi,%ebp
  80229e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022a2:	29 fd                	sub    %edi,%ebp
  8022a4:	19 cb                	sbb    %ecx,%ebx
  8022a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022ab:	89 d8                	mov    %ebx,%eax
  8022ad:	d3 e0                	shl    %cl,%eax
  8022af:	89 f1                	mov    %esi,%ecx
  8022b1:	d3 ed                	shr    %cl,%ebp
  8022b3:	d3 eb                	shr    %cl,%ebx
  8022b5:	09 e8                	or     %ebp,%eax
  8022b7:	89 da                	mov    %ebx,%edx
  8022b9:	83 c4 1c             	add    $0x1c,%esp
  8022bc:	5b                   	pop    %ebx
  8022bd:	5e                   	pop    %esi
  8022be:	5f                   	pop    %edi
  8022bf:	5d                   	pop    %ebp
  8022c0:	c3                   	ret    
