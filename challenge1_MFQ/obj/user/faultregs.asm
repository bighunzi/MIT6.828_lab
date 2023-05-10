
obj/user/faultregs.debug：     文件格式 elf32-i386


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
  80002c:	e8 b0 05 00 00       	call   8005e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	push   0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 b1 28 80 00       	push   $0x8028b1
  800049:	68 80 28 80 00       	push   $0x802880
  80004e:	e8 cc 06 00 00       	call   80071f <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	push   (%ebx)
  800055:	ff 36                	push   (%esi)
  800057:	68 90 28 80 00       	push   $0x802890
  80005c:	68 94 28 80 00       	push   $0x802894
  800061:	e8 b9 06 00 00       	call   80071f <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 a8 28 80 00       	push   $0x8028a8
  80007b:	e8 9f 06 00 00       	call   80071f <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	push   0x4(%ebx)
  80008b:	ff 76 04             	push   0x4(%esi)
  80008e:	68 b2 28 80 00       	push   $0x8028b2
  800093:	68 94 28 80 00       	push   $0x802894
  800098:	e8 82 06 00 00       	call   80071f <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 a8 28 80 00       	push   $0x8028a8
  8000b4:	e8 66 06 00 00       	call   80071f <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	push   0x8(%ebx)
  8000c4:	ff 76 08             	push   0x8(%esi)
  8000c7:	68 b6 28 80 00       	push   $0x8028b6
  8000cc:	68 94 28 80 00       	push   $0x802894
  8000d1:	e8 49 06 00 00       	call   80071f <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 a8 28 80 00       	push   $0x8028a8
  8000ed:	e8 2d 06 00 00       	call   80071f <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	push   0x10(%ebx)
  8000fd:	ff 76 10             	push   0x10(%esi)
  800100:	68 ba 28 80 00       	push   $0x8028ba
  800105:	68 94 28 80 00       	push   $0x802894
  80010a:	e8 10 06 00 00       	call   80071f <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 a8 28 80 00       	push   $0x8028a8
  800126:	e8 f4 05 00 00       	call   80071f <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	push   0x14(%ebx)
  800136:	ff 76 14             	push   0x14(%esi)
  800139:	68 be 28 80 00       	push   $0x8028be
  80013e:	68 94 28 80 00       	push   $0x802894
  800143:	e8 d7 05 00 00       	call   80071f <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 a8 28 80 00       	push   $0x8028a8
  80015f:	e8 bb 05 00 00       	call   80071f <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	push   0x18(%ebx)
  80016f:	ff 76 18             	push   0x18(%esi)
  800172:	68 c2 28 80 00       	push   $0x8028c2
  800177:	68 94 28 80 00       	push   $0x802894
  80017c:	e8 9e 05 00 00       	call   80071f <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 a8 28 80 00       	push   $0x8028a8
  800198:	e8 82 05 00 00       	call   80071f <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	push   0x1c(%ebx)
  8001a8:	ff 76 1c             	push   0x1c(%esi)
  8001ab:	68 c6 28 80 00       	push   $0x8028c6
  8001b0:	68 94 28 80 00       	push   $0x802894
  8001b5:	e8 65 05 00 00       	call   80071f <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 a8 28 80 00       	push   $0x8028a8
  8001d1:	e8 49 05 00 00       	call   80071f <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	push   0x20(%ebx)
  8001e1:	ff 76 20             	push   0x20(%esi)
  8001e4:	68 ca 28 80 00       	push   $0x8028ca
  8001e9:	68 94 28 80 00       	push   $0x802894
  8001ee:	e8 2c 05 00 00       	call   80071f <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 a8 28 80 00       	push   $0x8028a8
  80020a:	e8 10 05 00 00       	call   80071f <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	push   0x24(%ebx)
  80021a:	ff 76 24             	push   0x24(%esi)
  80021d:	68 ce 28 80 00       	push   $0x8028ce
  800222:	68 94 28 80 00       	push   $0x802894
  800227:	e8 f3 04 00 00       	call   80071f <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 a8 28 80 00       	push   $0x8028a8
  800243:	e8 d7 04 00 00       	call   80071f <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	push   0x28(%ebx)
  80024b:	ff 76 28             	push   0x28(%esi)
  80024e:	68 d5 28 80 00       	push   $0x8028d5
  800253:	68 94 28 80 00       	push   $0x802894
  800258:	e8 c2 04 00 00       	call   80071f <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 a8 28 80 00       	push   $0x8028a8
  800274:	e8 a6 04 00 00       	call   80071f <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	push   0xc(%ebp)
  80027f:	68 d9 28 80 00       	push   $0x8028d9
  800284:	e8 96 04 00 00       	call   80071f <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 a8 28 80 00       	push   $0x8028a8
  800294:	e8 86 04 00 00       	call   80071f <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 a4 28 80 00       	push   $0x8028a4
  8002a9:	e8 71 04 00 00       	call   80071f <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 a4 28 80 00       	push   $0x8028a4
  8002c3:	e8 57 04 00 00       	call   80071f <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 a4 28 80 00       	push   $0x8028a4
  8002d8:	e8 42 04 00 00       	call   80071f <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 a4 28 80 00       	push   $0x8028a4
  8002ed:	e8 2d 04 00 00       	call   80071f <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 a4 28 80 00       	push   $0x8028a4
  800302:	e8 18 04 00 00       	call   80071f <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 a4 28 80 00       	push   $0x8028a4
  800317:	e8 03 04 00 00       	call   80071f <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 a4 28 80 00       	push   $0x8028a4
  80032c:	e8 ee 03 00 00       	call   80071f <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 a4 28 80 00       	push   $0x8028a4
  800341:	e8 d9 03 00 00       	call   80071f <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 a4 28 80 00       	push   $0x8028a4
  800356:	e8 c4 03 00 00       	call   80071f <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	push   0x28(%ebx)
  80035e:	ff 76 28             	push   0x28(%esi)
  800361:	68 d5 28 80 00       	push   $0x8028d5
  800366:	68 94 28 80 00       	push   $0x802894
  80036b:	e8 af 03 00 00       	call   80071f <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 a4 28 80 00       	push   $0x8028a4
  800387:	e8 93 03 00 00       	call   80071f <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	push   0xc(%ebp)
  800392:	68 d9 28 80 00       	push   $0x8028d9
  800397:	e8 83 03 00 00       	call   80071f <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 a4 28 80 00       	push   $0x8028a4
  8003af:	e8 6b 03 00 00       	call   80071f <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 a4 28 80 00       	push   $0x8028a4
  8003c7:	e8 53 03 00 00       	call   80071f <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	push   0xc(%ebp)
  8003d2:	68 d9 28 80 00       	push   $0x8028d9
  8003d7:	e8 43 03 00 00       	call   80071f <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	0f 85 a3 00 00 00    	jne    80049e <pgfault+0xba>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003fb:	8b 50 08             	mov    0x8(%eax),%edx
  8003fe:	89 15 40 40 80 00    	mov    %edx,0x804040
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 44 40 80 00    	mov    %edx,0x804044
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 48 40 80 00    	mov    %edx,0x804048
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 50 40 80 00    	mov    %edx,0x804050
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 54 40 80 00    	mov    %edx,0x804054
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 58 40 80 00    	mov    %edx,0x804058
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 ff 28 80 00       	push   $0x8028ff
  80046b:	68 0d 29 80 00       	push   $0x80290d
  800470:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800475:	ba f8 28 80 00       	mov    $0x8028f8,%edx
  80047a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 60 0c 00 00       	call   8010f5 <sys_page_alloc>
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1a                	js     8004b6 <pgfault+0xd2>
		panic("sys_page_alloc: %e", r);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 70 28             	push   0x28(%eax)
  8004a4:	52                   	push   %edx
  8004a5:	68 40 29 80 00       	push   $0x802940
  8004aa:	6a 50                	push   $0x50
  8004ac:	68 e7 28 80 00       	push   $0x8028e7
  8004b1:	e8 8e 01 00 00       	call   800644 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 14 29 80 00       	push   $0x802914
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 e7 28 80 00       	push   $0x8028e7
  8004c3:	e8 7c 01 00 00       	call   800644 <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 6f 0e 00 00       	call   801347 <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004f9:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004ff:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  800505:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  80050b:	89 15 94 40 80 00    	mov    %edx,0x804094
  800511:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  800517:	a3 9c 40 80 00       	mov    %eax,0x80409c
  80051c:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 00 40 80 00    	mov    %edi,0x804000
  800532:	89 35 04 40 80 00    	mov    %esi,0x804004
  800538:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  80053e:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  800544:	89 15 14 40 80 00    	mov    %edx,0x804014
  80054a:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800550:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800555:	89 25 28 40 80 00    	mov    %esp,0x804028
  80055b:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800561:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800567:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80056d:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800573:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800579:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  80057f:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800584:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 24 40 80 00       	mov    %eax,0x804024
  800592:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80059d:	75 30                	jne    8005cf <umain+0x107>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  80059f:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  8005a4:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	68 27 29 80 00       	push   $0x802927
  8005b1:	68 38 29 80 00       	push   $0x802938
  8005b6:	b9 00 40 80 00       	mov    $0x804000,%ecx
  8005bb:	ba f8 28 80 00       	mov    $0x8028f8,%edx
  8005c0:	b8 80 40 80 00       	mov    $0x804080,%eax
  8005c5:	e8 69 fa ff ff       	call   800033 <check_regs>
}
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 74 29 80 00       	push   $0x802974
  8005d7:	e8 43 01 00 00       	call   80071f <cprintf>
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	eb be                	jmp    80059f <umain+0xd7>

008005e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8005ec:	e8 c6 0a 00 00       	call   8010b7 <sys_getenvid>
  8005f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005f6:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8005fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800601:	a3 ac 40 80 00       	mov    %eax,0x8040ac

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800606:	85 db                	test   %ebx,%ebx
  800608:	7e 07                	jle    800611 <libmain+0x30>
		binaryname = argv[0];
  80060a:	8b 06                	mov    (%esi),%eax
  80060c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	56                   	push   %esi
  800615:	53                   	push   %ebx
  800616:	e8 ad fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  80061b:	e8 0a 00 00 00       	call   80062a <exit>
}
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5d                   	pop    %ebp
  800629:	c3                   	ret    

0080062a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800630:	e8 7f 0f 00 00       	call   8015b4 <close_all>
	sys_env_destroy(0);
  800635:	83 ec 0c             	sub    $0xc,%esp
  800638:	6a 00                	push   $0x0
  80063a:	e8 37 0a 00 00       	call   801076 <sys_env_destroy>
}
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	c9                   	leave  
  800643:	c3                   	ret    

00800644 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	56                   	push   %esi
  800648:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800649:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80064c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800652:	e8 60 0a 00 00       	call   8010b7 <sys_getenvid>
  800657:	83 ec 0c             	sub    $0xc,%esp
  80065a:	ff 75 0c             	push   0xc(%ebp)
  80065d:	ff 75 08             	push   0x8(%ebp)
  800660:	56                   	push   %esi
  800661:	50                   	push   %eax
  800662:	68 a0 29 80 00       	push   $0x8029a0
  800667:	e8 b3 00 00 00       	call   80071f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80066c:	83 c4 18             	add    $0x18,%esp
  80066f:	53                   	push   %ebx
  800670:	ff 75 10             	push   0x10(%ebp)
  800673:	e8 56 00 00 00       	call   8006ce <vcprintf>
	cprintf("\n");
  800678:	c7 04 24 b0 28 80 00 	movl   $0x8028b0,(%esp)
  80067f:	e8 9b 00 00 00       	call   80071f <cprintf>
  800684:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800687:	cc                   	int3   
  800688:	eb fd                	jmp    800687 <_panic+0x43>

0080068a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	53                   	push   %ebx
  80068e:	83 ec 04             	sub    $0x4,%esp
  800691:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800694:	8b 13                	mov    (%ebx),%edx
  800696:	8d 42 01             	lea    0x1(%edx),%eax
  800699:	89 03                	mov    %eax,(%ebx)
  80069b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006a7:	74 09                	je     8006b2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	68 ff 00 00 00       	push   $0xff
  8006ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8006bd:	50                   	push   %eax
  8006be:	e8 76 09 00 00       	call   801039 <sys_cputs>
		b->idx = 0;
  8006c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb db                	jmp    8006a9 <putch+0x1f>

008006ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006de:	00 00 00 
	b.cnt = 0;
  8006e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006eb:	ff 75 0c             	push   0xc(%ebp)
  8006ee:	ff 75 08             	push   0x8(%ebp)
  8006f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006f7:	50                   	push   %eax
  8006f8:	68 8a 06 80 00       	push   $0x80068a
  8006fd:	e8 14 01 00 00       	call   800816 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80070b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	e8 22 09 00 00       	call   801039 <sys_cputs>

	return b.cnt;
}
  800717:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80071d:	c9                   	leave  
  80071e:	c3                   	ret    

0080071f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800725:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800728:	50                   	push   %eax
  800729:	ff 75 08             	push   0x8(%ebp)
  80072c:	e8 9d ff ff ff       	call   8006ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	57                   	push   %edi
  800737:	56                   	push   %esi
  800738:	53                   	push   %ebx
  800739:	83 ec 1c             	sub    $0x1c,%esp
  80073c:	89 c7                	mov    %eax,%edi
  80073e:	89 d6                	mov    %edx,%esi
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
  800746:	89 d1                	mov    %edx,%ecx
  800748:	89 c2                	mov    %eax,%edx
  80074a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800750:	8b 45 10             	mov    0x10(%ebp),%eax
  800753:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800756:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800759:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800760:	39 c2                	cmp    %eax,%edx
  800762:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800765:	72 3e                	jb     8007a5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800767:	83 ec 0c             	sub    $0xc,%esp
  80076a:	ff 75 18             	push   0x18(%ebp)
  80076d:	83 eb 01             	sub    $0x1,%ebx
  800770:	53                   	push   %ebx
  800771:	50                   	push   %eax
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	ff 75 e4             	push   -0x1c(%ebp)
  800778:	ff 75 e0             	push   -0x20(%ebp)
  80077b:	ff 75 dc             	push   -0x24(%ebp)
  80077e:	ff 75 d8             	push   -0x28(%ebp)
  800781:	e8 aa 1e 00 00       	call   802630 <__udivdi3>
  800786:	83 c4 18             	add    $0x18,%esp
  800789:	52                   	push   %edx
  80078a:	50                   	push   %eax
  80078b:	89 f2                	mov    %esi,%edx
  80078d:	89 f8                	mov    %edi,%eax
  80078f:	e8 9f ff ff ff       	call   800733 <printnum>
  800794:	83 c4 20             	add    $0x20,%esp
  800797:	eb 13                	jmp    8007ac <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	56                   	push   %esi
  80079d:	ff 75 18             	push   0x18(%ebp)
  8007a0:	ff d7                	call   *%edi
  8007a2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007a5:	83 eb 01             	sub    $0x1,%ebx
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7f ed                	jg     800799 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	56                   	push   %esi
  8007b0:	83 ec 04             	sub    $0x4,%esp
  8007b3:	ff 75 e4             	push   -0x1c(%ebp)
  8007b6:	ff 75 e0             	push   -0x20(%ebp)
  8007b9:	ff 75 dc             	push   -0x24(%ebp)
  8007bc:	ff 75 d8             	push   -0x28(%ebp)
  8007bf:	e8 8c 1f 00 00       	call   802750 <__umoddi3>
  8007c4:	83 c4 14             	add    $0x14,%esp
  8007c7:	0f be 80 c3 29 80 00 	movsbl 0x8029c3(%eax),%eax
  8007ce:	50                   	push   %eax
  8007cf:	ff d7                	call   *%edi
}
  8007d1:	83 c4 10             	add    $0x10,%esp
  8007d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d7:	5b                   	pop    %ebx
  8007d8:	5e                   	pop    %esi
  8007d9:	5f                   	pop    %edi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007e6:	8b 10                	mov    (%eax),%edx
  8007e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8007eb:	73 0a                	jae    8007f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007ed:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007f0:	89 08                	mov    %ecx,(%eax)
  8007f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f5:	88 02                	mov    %al,(%edx)
}
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <printfmt>:
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800802:	50                   	push   %eax
  800803:	ff 75 10             	push   0x10(%ebp)
  800806:	ff 75 0c             	push   0xc(%ebp)
  800809:	ff 75 08             	push   0x8(%ebp)
  80080c:	e8 05 00 00 00       	call   800816 <vprintfmt>
}
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <vprintfmt>:
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	57                   	push   %edi
  80081a:	56                   	push   %esi
  80081b:	53                   	push   %ebx
  80081c:	83 ec 3c             	sub    $0x3c,%esp
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800825:	8b 7d 10             	mov    0x10(%ebp),%edi
  800828:	eb 0a                	jmp    800834 <vprintfmt+0x1e>
			putch(ch, putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	53                   	push   %ebx
  80082e:	50                   	push   %eax
  80082f:	ff d6                	call   *%esi
  800831:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800834:	83 c7 01             	add    $0x1,%edi
  800837:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80083b:	83 f8 25             	cmp    $0x25,%eax
  80083e:	74 0c                	je     80084c <vprintfmt+0x36>
			if (ch == '\0')
  800840:	85 c0                	test   %eax,%eax
  800842:	75 e6                	jne    80082a <vprintfmt+0x14>
}
  800844:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5f                   	pop    %edi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    
		padc = ' ';
  80084c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800850:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800857:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80085e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800865:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80086a:	8d 47 01             	lea    0x1(%edi),%eax
  80086d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800870:	0f b6 17             	movzbl (%edi),%edx
  800873:	8d 42 dd             	lea    -0x23(%edx),%eax
  800876:	3c 55                	cmp    $0x55,%al
  800878:	0f 87 bb 03 00 00    	ja     800c39 <vprintfmt+0x423>
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	ff 24 85 00 2b 80 00 	jmp    *0x802b00(,%eax,4)
  800888:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80088b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80088f:	eb d9                	jmp    80086a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800894:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800898:	eb d0                	jmp    80086a <vprintfmt+0x54>
  80089a:	0f b6 d2             	movzbl %dl,%edx
  80089d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008b5:	83 f9 09             	cmp    $0x9,%ecx
  8008b8:	77 55                	ja     80090f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8008ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008bd:	eb e9                	jmp    8008a8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8008bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c2:	8b 00                	mov    (%eax),%eax
  8008c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 40 04             	lea    0x4(%eax),%eax
  8008cd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008d7:	79 91                	jns    80086a <vprintfmt+0x54>
				width = precision, precision = -1;
  8008d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008e6:	eb 82                	jmp    80086a <vprintfmt+0x54>
  8008e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008eb:	85 d2                	test   %edx,%edx
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f2:	0f 49 c2             	cmovns %edx,%eax
  8008f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8008fb:	e9 6a ff ff ff       	jmp    80086a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800903:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80090a:	e9 5b ff ff ff       	jmp    80086a <vprintfmt+0x54>
  80090f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800912:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800915:	eb bc                	jmp    8008d3 <vprintfmt+0xbd>
			lflag++;
  800917:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80091a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80091d:	e9 48 ff ff ff       	jmp    80086a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 78 04             	lea    0x4(%eax),%edi
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	53                   	push   %ebx
  80092c:	ff 30                	push   (%eax)
  80092e:	ff d6                	call   *%esi
			break;
  800930:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800933:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800936:	e9 9d 02 00 00       	jmp    800bd8 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80093b:	8b 45 14             	mov    0x14(%ebp),%eax
  80093e:	8d 78 04             	lea    0x4(%eax),%edi
  800941:	8b 10                	mov    (%eax),%edx
  800943:	89 d0                	mov    %edx,%eax
  800945:	f7 d8                	neg    %eax
  800947:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094a:	83 f8 0f             	cmp    $0xf,%eax
  80094d:	7f 23                	jg     800972 <vprintfmt+0x15c>
  80094f:	8b 14 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%edx
  800956:	85 d2                	test   %edx,%edx
  800958:	74 18                	je     800972 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80095a:	52                   	push   %edx
  80095b:	68 19 2e 80 00       	push   $0x802e19
  800960:	53                   	push   %ebx
  800961:	56                   	push   %esi
  800962:	e8 92 fe ff ff       	call   8007f9 <printfmt>
  800967:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80096a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80096d:	e9 66 02 00 00       	jmp    800bd8 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800972:	50                   	push   %eax
  800973:	68 db 29 80 00       	push   $0x8029db
  800978:	53                   	push   %ebx
  800979:	56                   	push   %esi
  80097a:	e8 7a fe ff ff       	call   8007f9 <printfmt>
  80097f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800982:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800985:	e9 4e 02 00 00       	jmp    800bd8 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80098a:	8b 45 14             	mov    0x14(%ebp),%eax
  80098d:	83 c0 04             	add    $0x4,%eax
  800990:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800998:	85 d2                	test   %edx,%edx
  80099a:	b8 d4 29 80 00       	mov    $0x8029d4,%eax
  80099f:	0f 45 c2             	cmovne %edx,%eax
  8009a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009a9:	7e 06                	jle    8009b1 <vprintfmt+0x19b>
  8009ab:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009af:	75 0d                	jne    8009be <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	03 45 e0             	add    -0x20(%ebp),%eax
  8009b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009bc:	eb 55                	jmp    800a13 <vprintfmt+0x1fd>
  8009be:	83 ec 08             	sub    $0x8,%esp
  8009c1:	ff 75 d8             	push   -0x28(%ebp)
  8009c4:	ff 75 cc             	push   -0x34(%ebp)
  8009c7:	e8 0a 03 00 00       	call   800cd6 <strnlen>
  8009cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009cf:	29 c1                	sub    %eax,%ecx
  8009d1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8009d4:	83 c4 10             	add    $0x10,%esp
  8009d7:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8009d9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e0:	eb 0f                	jmp    8009f1 <vprintfmt+0x1db>
					putch(padc, putdat);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	53                   	push   %ebx
  8009e6:	ff 75 e0             	push   -0x20(%ebp)
  8009e9:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009eb:	83 ef 01             	sub    $0x1,%edi
  8009ee:	83 c4 10             	add    $0x10,%esp
  8009f1:	85 ff                	test   %edi,%edi
  8009f3:	7f ed                	jg     8009e2 <vprintfmt+0x1cc>
  8009f5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009f8:	85 d2                	test   %edx,%edx
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	0f 49 c2             	cmovns %edx,%eax
  800a02:	29 c2                	sub    %eax,%edx
  800a04:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a07:	eb a8                	jmp    8009b1 <vprintfmt+0x19b>
					putch(ch, putdat);
  800a09:	83 ec 08             	sub    $0x8,%esp
  800a0c:	53                   	push   %ebx
  800a0d:	52                   	push   %edx
  800a0e:	ff d6                	call   *%esi
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a16:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a18:	83 c7 01             	add    $0x1,%edi
  800a1b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a1f:	0f be d0             	movsbl %al,%edx
  800a22:	85 d2                	test   %edx,%edx
  800a24:	74 4b                	je     800a71 <vprintfmt+0x25b>
  800a26:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a2a:	78 06                	js     800a32 <vprintfmt+0x21c>
  800a2c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a30:	78 1e                	js     800a50 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800a32:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a36:	74 d1                	je     800a09 <vprintfmt+0x1f3>
  800a38:	0f be c0             	movsbl %al,%eax
  800a3b:	83 e8 20             	sub    $0x20,%eax
  800a3e:	83 f8 5e             	cmp    $0x5e,%eax
  800a41:	76 c6                	jbe    800a09 <vprintfmt+0x1f3>
					putch('?', putdat);
  800a43:	83 ec 08             	sub    $0x8,%esp
  800a46:	53                   	push   %ebx
  800a47:	6a 3f                	push   $0x3f
  800a49:	ff d6                	call   *%esi
  800a4b:	83 c4 10             	add    $0x10,%esp
  800a4e:	eb c3                	jmp    800a13 <vprintfmt+0x1fd>
  800a50:	89 cf                	mov    %ecx,%edi
  800a52:	eb 0e                	jmp    800a62 <vprintfmt+0x24c>
				putch(' ', putdat);
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	53                   	push   %ebx
  800a58:	6a 20                	push   $0x20
  800a5a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a5c:	83 ef 01             	sub    $0x1,%edi
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	85 ff                	test   %edi,%edi
  800a64:	7f ee                	jg     800a54 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800a66:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a69:	89 45 14             	mov    %eax,0x14(%ebp)
  800a6c:	e9 67 01 00 00       	jmp    800bd8 <vprintfmt+0x3c2>
  800a71:	89 cf                	mov    %ecx,%edi
  800a73:	eb ed                	jmp    800a62 <vprintfmt+0x24c>
	if (lflag >= 2)
  800a75:	83 f9 01             	cmp    $0x1,%ecx
  800a78:	7f 1b                	jg     800a95 <vprintfmt+0x27f>
	else if (lflag)
  800a7a:	85 c9                	test   %ecx,%ecx
  800a7c:	74 63                	je     800ae1 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a81:	8b 00                	mov    (%eax),%eax
  800a83:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a86:	99                   	cltd   
  800a87:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8d 40 04             	lea    0x4(%eax),%eax
  800a90:	89 45 14             	mov    %eax,0x14(%ebp)
  800a93:	eb 17                	jmp    800aac <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8b 50 04             	mov    0x4(%eax),%edx
  800a9b:	8b 00                	mov    (%eax),%eax
  800a9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa6:	8d 40 08             	lea    0x8(%eax),%eax
  800aa9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800aac:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aaf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ab2:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800ab7:	85 c9                	test   %ecx,%ecx
  800ab9:	0f 89 ff 00 00 00    	jns    800bbe <vprintfmt+0x3a8>
				putch('-', putdat);
  800abf:	83 ec 08             	sub    $0x8,%esp
  800ac2:	53                   	push   %ebx
  800ac3:	6a 2d                	push   $0x2d
  800ac5:	ff d6                	call   *%esi
				num = -(long long) num;
  800ac7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800acd:	f7 da                	neg    %edx
  800acf:	83 d1 00             	adc    $0x0,%ecx
  800ad2:	f7 d9                	neg    %ecx
  800ad4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ad7:	bf 0a 00 00 00       	mov    $0xa,%edi
  800adc:	e9 dd 00 00 00       	jmp    800bbe <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800ae1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae4:	8b 00                	mov    (%eax),%eax
  800ae6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae9:	99                   	cltd   
  800aea:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aed:	8b 45 14             	mov    0x14(%ebp),%eax
  800af0:	8d 40 04             	lea    0x4(%eax),%eax
  800af3:	89 45 14             	mov    %eax,0x14(%ebp)
  800af6:	eb b4                	jmp    800aac <vprintfmt+0x296>
	if (lflag >= 2)
  800af8:	83 f9 01             	cmp    $0x1,%ecx
  800afb:	7f 1e                	jg     800b1b <vprintfmt+0x305>
	else if (lflag)
  800afd:	85 c9                	test   %ecx,%ecx
  800aff:	74 32                	je     800b33 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800b01:	8b 45 14             	mov    0x14(%ebp),%eax
  800b04:	8b 10                	mov    (%eax),%edx
  800b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0b:	8d 40 04             	lea    0x4(%eax),%eax
  800b0e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b11:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800b16:	e9 a3 00 00 00       	jmp    800bbe <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800b1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1e:	8b 10                	mov    (%eax),%edx
  800b20:	8b 48 04             	mov    0x4(%eax),%ecx
  800b23:	8d 40 08             	lea    0x8(%eax),%eax
  800b26:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b29:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800b2e:	e9 8b 00 00 00       	jmp    800bbe <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800b33:	8b 45 14             	mov    0x14(%ebp),%eax
  800b36:	8b 10                	mov    (%eax),%edx
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	8d 40 04             	lea    0x4(%eax),%eax
  800b40:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b43:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800b48:	eb 74                	jmp    800bbe <vprintfmt+0x3a8>
	if (lflag >= 2)
  800b4a:	83 f9 01             	cmp    $0x1,%ecx
  800b4d:	7f 1b                	jg     800b6a <vprintfmt+0x354>
	else if (lflag)
  800b4f:	85 c9                	test   %ecx,%ecx
  800b51:	74 2c                	je     800b7f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800b53:	8b 45 14             	mov    0x14(%ebp),%eax
  800b56:	8b 10                	mov    (%eax),%edx
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	8d 40 04             	lea    0x4(%eax),%eax
  800b60:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b63:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800b68:	eb 54                	jmp    800bbe <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800b6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6d:	8b 10                	mov    (%eax),%edx
  800b6f:	8b 48 04             	mov    0x4(%eax),%ecx
  800b72:	8d 40 08             	lea    0x8(%eax),%eax
  800b75:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b78:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800b7d:	eb 3f                	jmp    800bbe <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800b7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b82:	8b 10                	mov    (%eax),%edx
  800b84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b89:	8d 40 04             	lea    0x4(%eax),%eax
  800b8c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b8f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800b94:	eb 28                	jmp    800bbe <vprintfmt+0x3a8>
			putch('0', putdat);
  800b96:	83 ec 08             	sub    $0x8,%esp
  800b99:	53                   	push   %ebx
  800b9a:	6a 30                	push   $0x30
  800b9c:	ff d6                	call   *%esi
			putch('x', putdat);
  800b9e:	83 c4 08             	add    $0x8,%esp
  800ba1:	53                   	push   %ebx
  800ba2:	6a 78                	push   $0x78
  800ba4:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ba6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba9:	8b 10                	mov    (%eax),%edx
  800bab:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bb0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bb3:	8d 40 04             	lea    0x4(%eax),%eax
  800bb6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bb9:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800bc5:	50                   	push   %eax
  800bc6:	ff 75 e0             	push   -0x20(%ebp)
  800bc9:	57                   	push   %edi
  800bca:	51                   	push   %ecx
  800bcb:	52                   	push   %edx
  800bcc:	89 da                	mov    %ebx,%edx
  800bce:	89 f0                	mov    %esi,%eax
  800bd0:	e8 5e fb ff ff       	call   800733 <printnum>
			break;
  800bd5:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800bd8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bdb:	e9 54 fc ff ff       	jmp    800834 <vprintfmt+0x1e>
	if (lflag >= 2)
  800be0:	83 f9 01             	cmp    $0x1,%ecx
  800be3:	7f 1b                	jg     800c00 <vprintfmt+0x3ea>
	else if (lflag)
  800be5:	85 c9                	test   %ecx,%ecx
  800be7:	74 2c                	je     800c15 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800be9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bec:	8b 10                	mov    (%eax),%edx
  800bee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf3:	8d 40 04             	lea    0x4(%eax),%eax
  800bf6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bf9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800bfe:	eb be                	jmp    800bbe <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800c00:	8b 45 14             	mov    0x14(%ebp),%eax
  800c03:	8b 10                	mov    (%eax),%edx
  800c05:	8b 48 04             	mov    0x4(%eax),%ecx
  800c08:	8d 40 08             	lea    0x8(%eax),%eax
  800c0b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c0e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800c13:	eb a9                	jmp    800bbe <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800c15:	8b 45 14             	mov    0x14(%ebp),%eax
  800c18:	8b 10                	mov    (%eax),%edx
  800c1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1f:	8d 40 04             	lea    0x4(%eax),%eax
  800c22:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c25:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800c2a:	eb 92                	jmp    800bbe <vprintfmt+0x3a8>
			putch(ch, putdat);
  800c2c:	83 ec 08             	sub    $0x8,%esp
  800c2f:	53                   	push   %ebx
  800c30:	6a 25                	push   $0x25
  800c32:	ff d6                	call   *%esi
			break;
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	eb 9f                	jmp    800bd8 <vprintfmt+0x3c2>
			putch('%', putdat);
  800c39:	83 ec 08             	sub    $0x8,%esp
  800c3c:	53                   	push   %ebx
  800c3d:	6a 25                	push   $0x25
  800c3f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c4a:	74 05                	je     800c51 <vprintfmt+0x43b>
  800c4c:	83 e8 01             	sub    $0x1,%eax
  800c4f:	eb f5                	jmp    800c46 <vprintfmt+0x430>
  800c51:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c54:	eb 82                	jmp    800bd8 <vprintfmt+0x3c2>

00800c56 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 18             	sub    $0x18,%esp
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c65:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c69:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	74 26                	je     800c9d <vsnprintf+0x47>
  800c77:	85 d2                	test   %edx,%edx
  800c79:	7e 22                	jle    800c9d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c7b:	ff 75 14             	push   0x14(%ebp)
  800c7e:	ff 75 10             	push   0x10(%ebp)
  800c81:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c84:	50                   	push   %eax
  800c85:	68 dc 07 80 00       	push   $0x8007dc
  800c8a:	e8 87 fb ff ff       	call   800816 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c92:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c98:	83 c4 10             	add    $0x10,%esp
}
  800c9b:	c9                   	leave  
  800c9c:	c3                   	ret    
		return -E_INVAL;
  800c9d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ca2:	eb f7                	jmp    800c9b <vsnprintf+0x45>

00800ca4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800caa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cad:	50                   	push   %eax
  800cae:	ff 75 10             	push   0x10(%ebp)
  800cb1:	ff 75 0c             	push   0xc(%ebp)
  800cb4:	ff 75 08             	push   0x8(%ebp)
  800cb7:	e8 9a ff ff ff       	call   800c56 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cbc:	c9                   	leave  
  800cbd:	c3                   	ret    

00800cbe <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc9:	eb 03                	jmp    800cce <strlen+0x10>
		n++;
  800ccb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800cce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cd2:	75 f7                	jne    800ccb <strlen+0xd>
	return n;
}
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce4:	eb 03                	jmp    800ce9 <strnlen+0x13>
		n++;
  800ce6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce9:	39 d0                	cmp    %edx,%eax
  800ceb:	74 08                	je     800cf5 <strnlen+0x1f>
  800ced:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800cf1:	75 f3                	jne    800ce6 <strnlen+0x10>
  800cf3:	89 c2                	mov    %eax,%edx
	return n;
}
  800cf5:	89 d0                	mov    %edx,%eax
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	53                   	push   %ebx
  800cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d03:	b8 00 00 00 00       	mov    $0x0,%eax
  800d08:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d0c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d0f:	83 c0 01             	add    $0x1,%eax
  800d12:	84 d2                	test   %dl,%dl
  800d14:	75 f2                	jne    800d08 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d16:	89 c8                	mov    %ecx,%eax
  800d18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	53                   	push   %ebx
  800d21:	83 ec 10             	sub    $0x10,%esp
  800d24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d27:	53                   	push   %ebx
  800d28:	e8 91 ff ff ff       	call   800cbe <strlen>
  800d2d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d30:	ff 75 0c             	push   0xc(%ebp)
  800d33:	01 d8                	add    %ebx,%eax
  800d35:	50                   	push   %eax
  800d36:	e8 be ff ff ff       	call   800cf9 <strcpy>
	return dst;
}
  800d3b:	89 d8                	mov    %ebx,%eax
  800d3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4d:	89 f3                	mov    %esi,%ebx
  800d4f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d52:	89 f0                	mov    %esi,%eax
  800d54:	eb 0f                	jmp    800d65 <strncpy+0x23>
		*dst++ = *src;
  800d56:	83 c0 01             	add    $0x1,%eax
  800d59:	0f b6 0a             	movzbl (%edx),%ecx
  800d5c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d5f:	80 f9 01             	cmp    $0x1,%cl
  800d62:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800d65:	39 d8                	cmp    %ebx,%eax
  800d67:	75 ed                	jne    800d56 <strncpy+0x14>
	}
	return ret;
}
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	8b 75 08             	mov    0x8(%ebp),%esi
  800d77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7a:	8b 55 10             	mov    0x10(%ebp),%edx
  800d7d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d7f:	85 d2                	test   %edx,%edx
  800d81:	74 21                	je     800da4 <strlcpy+0x35>
  800d83:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d87:	89 f2                	mov    %esi,%edx
  800d89:	eb 09                	jmp    800d94 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d8b:	83 c1 01             	add    $0x1,%ecx
  800d8e:	83 c2 01             	add    $0x1,%edx
  800d91:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800d94:	39 c2                	cmp    %eax,%edx
  800d96:	74 09                	je     800da1 <strlcpy+0x32>
  800d98:	0f b6 19             	movzbl (%ecx),%ebx
  800d9b:	84 db                	test   %bl,%bl
  800d9d:	75 ec                	jne    800d8b <strlcpy+0x1c>
  800d9f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800da1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800da4:	29 f0                	sub    %esi,%eax
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800db3:	eb 06                	jmp    800dbb <strcmp+0x11>
		p++, q++;
  800db5:	83 c1 01             	add    $0x1,%ecx
  800db8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800dbb:	0f b6 01             	movzbl (%ecx),%eax
  800dbe:	84 c0                	test   %al,%al
  800dc0:	74 04                	je     800dc6 <strcmp+0x1c>
  800dc2:	3a 02                	cmp    (%edx),%al
  800dc4:	74 ef                	je     800db5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc6:	0f b6 c0             	movzbl %al,%eax
  800dc9:	0f b6 12             	movzbl (%edx),%edx
  800dcc:	29 d0                	sub    %edx,%eax
}
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ddf:	eb 06                	jmp    800de7 <strncmp+0x17>
		n--, p++, q++;
  800de1:	83 c0 01             	add    $0x1,%eax
  800de4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800de7:	39 d8                	cmp    %ebx,%eax
  800de9:	74 18                	je     800e03 <strncmp+0x33>
  800deb:	0f b6 08             	movzbl (%eax),%ecx
  800dee:	84 c9                	test   %cl,%cl
  800df0:	74 04                	je     800df6 <strncmp+0x26>
  800df2:	3a 0a                	cmp    (%edx),%cl
  800df4:	74 eb                	je     800de1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df6:	0f b6 00             	movzbl (%eax),%eax
  800df9:	0f b6 12             	movzbl (%edx),%edx
  800dfc:	29 d0                	sub    %edx,%eax
}
  800dfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    
		return 0;
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
  800e08:	eb f4                	jmp    800dfe <strncmp+0x2e>

00800e0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e14:	eb 03                	jmp    800e19 <strchr+0xf>
  800e16:	83 c0 01             	add    $0x1,%eax
  800e19:	0f b6 10             	movzbl (%eax),%edx
  800e1c:	84 d2                	test   %dl,%dl
  800e1e:	74 06                	je     800e26 <strchr+0x1c>
		if (*s == c)
  800e20:	38 ca                	cmp    %cl,%dl
  800e22:	75 f2                	jne    800e16 <strchr+0xc>
  800e24:	eb 05                	jmp    800e2b <strchr+0x21>
			return (char *) s;
	return 0;
  800e26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e37:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e3a:	38 ca                	cmp    %cl,%dl
  800e3c:	74 09                	je     800e47 <strfind+0x1a>
  800e3e:	84 d2                	test   %dl,%dl
  800e40:	74 05                	je     800e47 <strfind+0x1a>
	for (; *s; s++)
  800e42:	83 c0 01             	add    $0x1,%eax
  800e45:	eb f0                	jmp    800e37 <strfind+0xa>
			break;
	return (char *) s;
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e55:	85 c9                	test   %ecx,%ecx
  800e57:	74 2f                	je     800e88 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e59:	89 f8                	mov    %edi,%eax
  800e5b:	09 c8                	or     %ecx,%eax
  800e5d:	a8 03                	test   $0x3,%al
  800e5f:	75 21                	jne    800e82 <memset+0x39>
		c &= 0xFF;
  800e61:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e65:	89 d0                	mov    %edx,%eax
  800e67:	c1 e0 08             	shl    $0x8,%eax
  800e6a:	89 d3                	mov    %edx,%ebx
  800e6c:	c1 e3 18             	shl    $0x18,%ebx
  800e6f:	89 d6                	mov    %edx,%esi
  800e71:	c1 e6 10             	shl    $0x10,%esi
  800e74:	09 f3                	or     %esi,%ebx
  800e76:	09 da                	or     %ebx,%edx
  800e78:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e7a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800e7d:	fc                   	cld    
  800e7e:	f3 ab                	rep stos %eax,%es:(%edi)
  800e80:	eb 06                	jmp    800e88 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e85:	fc                   	cld    
  800e86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e88:	89 f8                	mov    %edi,%eax
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	57                   	push   %edi
  800e93:	56                   	push   %esi
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e9d:	39 c6                	cmp    %eax,%esi
  800e9f:	73 32                	jae    800ed3 <memmove+0x44>
  800ea1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ea4:	39 c2                	cmp    %eax,%edx
  800ea6:	76 2b                	jbe    800ed3 <memmove+0x44>
		s += n;
		d += n;
  800ea8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800eab:	89 d6                	mov    %edx,%esi
  800ead:	09 fe                	or     %edi,%esi
  800eaf:	09 ce                	or     %ecx,%esi
  800eb1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eb7:	75 0e                	jne    800ec7 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eb9:	83 ef 04             	sub    $0x4,%edi
  800ebc:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ebf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ec2:	fd                   	std    
  800ec3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec5:	eb 09                	jmp    800ed0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ec7:	83 ef 01             	sub    $0x1,%edi
  800eca:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ecd:	fd                   	std    
  800ece:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ed0:	fc                   	cld    
  800ed1:	eb 1a                	jmp    800eed <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed3:	89 f2                	mov    %esi,%edx
  800ed5:	09 c2                	or     %eax,%edx
  800ed7:	09 ca                	or     %ecx,%edx
  800ed9:	f6 c2 03             	test   $0x3,%dl
  800edc:	75 0a                	jne    800ee8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ede:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ee1:	89 c7                	mov    %eax,%edi
  800ee3:	fc                   	cld    
  800ee4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ee6:	eb 05                	jmp    800eed <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ee8:	89 c7                	mov    %eax,%edi
  800eea:	fc                   	cld    
  800eeb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eed:	5e                   	pop    %esi
  800eee:	5f                   	pop    %edi
  800eef:	5d                   	pop    %ebp
  800ef0:	c3                   	ret    

00800ef1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ef7:	ff 75 10             	push   0x10(%ebp)
  800efa:	ff 75 0c             	push   0xc(%ebp)
  800efd:	ff 75 08             	push   0x8(%ebp)
  800f00:	e8 8a ff ff ff       	call   800e8f <memmove>
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f12:	89 c6                	mov    %eax,%esi
  800f14:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f17:	eb 06                	jmp    800f1f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f19:	83 c0 01             	add    $0x1,%eax
  800f1c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800f1f:	39 f0                	cmp    %esi,%eax
  800f21:	74 14                	je     800f37 <memcmp+0x30>
		if (*s1 != *s2)
  800f23:	0f b6 08             	movzbl (%eax),%ecx
  800f26:	0f b6 1a             	movzbl (%edx),%ebx
  800f29:	38 d9                	cmp    %bl,%cl
  800f2b:	74 ec                	je     800f19 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800f2d:	0f b6 c1             	movzbl %cl,%eax
  800f30:	0f b6 db             	movzbl %bl,%ebx
  800f33:	29 d8                	sub    %ebx,%eax
  800f35:	eb 05                	jmp    800f3c <memcmp+0x35>
	}

	return 0;
  800f37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f49:	89 c2                	mov    %eax,%edx
  800f4b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f4e:	eb 03                	jmp    800f53 <memfind+0x13>
  800f50:	83 c0 01             	add    $0x1,%eax
  800f53:	39 d0                	cmp    %edx,%eax
  800f55:	73 04                	jae    800f5b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f57:	38 08                	cmp    %cl,(%eax)
  800f59:	75 f5                	jne    800f50 <memfind+0x10>
			break;
	return (void *) s;
}
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	57                   	push   %edi
  800f61:	56                   	push   %esi
  800f62:	53                   	push   %ebx
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f69:	eb 03                	jmp    800f6e <strtol+0x11>
		s++;
  800f6b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800f6e:	0f b6 02             	movzbl (%edx),%eax
  800f71:	3c 20                	cmp    $0x20,%al
  800f73:	74 f6                	je     800f6b <strtol+0xe>
  800f75:	3c 09                	cmp    $0x9,%al
  800f77:	74 f2                	je     800f6b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800f79:	3c 2b                	cmp    $0x2b,%al
  800f7b:	74 2a                	je     800fa7 <strtol+0x4a>
	int neg = 0;
  800f7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800f82:	3c 2d                	cmp    $0x2d,%al
  800f84:	74 2b                	je     800fb1 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f86:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f8c:	75 0f                	jne    800f9d <strtol+0x40>
  800f8e:	80 3a 30             	cmpb   $0x30,(%edx)
  800f91:	74 28                	je     800fbb <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f93:	85 db                	test   %ebx,%ebx
  800f95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f9a:	0f 44 d8             	cmove  %eax,%ebx
  800f9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800fa5:	eb 46                	jmp    800fed <strtol+0x90>
		s++;
  800fa7:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800faa:	bf 00 00 00 00       	mov    $0x0,%edi
  800faf:	eb d5                	jmp    800f86 <strtol+0x29>
		s++, neg = 1;
  800fb1:	83 c2 01             	add    $0x1,%edx
  800fb4:	bf 01 00 00 00       	mov    $0x1,%edi
  800fb9:	eb cb                	jmp    800f86 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fbb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fbf:	74 0e                	je     800fcf <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800fc1:	85 db                	test   %ebx,%ebx
  800fc3:	75 d8                	jne    800f9d <strtol+0x40>
		s++, base = 8;
  800fc5:	83 c2 01             	add    $0x1,%edx
  800fc8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800fcd:	eb ce                	jmp    800f9d <strtol+0x40>
		s += 2, base = 16;
  800fcf:	83 c2 02             	add    $0x2,%edx
  800fd2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fd7:	eb c4                	jmp    800f9d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800fd9:	0f be c0             	movsbl %al,%eax
  800fdc:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fdf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800fe2:	7d 3a                	jge    80101e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800fe4:	83 c2 01             	add    $0x1,%edx
  800fe7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800feb:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800fed:	0f b6 02             	movzbl (%edx),%eax
  800ff0:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ff3:	89 f3                	mov    %esi,%ebx
  800ff5:	80 fb 09             	cmp    $0x9,%bl
  800ff8:	76 df                	jbe    800fd9 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ffa:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ffd:	89 f3                	mov    %esi,%ebx
  800fff:	80 fb 19             	cmp    $0x19,%bl
  801002:	77 08                	ja     80100c <strtol+0xaf>
			dig = *s - 'a' + 10;
  801004:	0f be c0             	movsbl %al,%eax
  801007:	83 e8 57             	sub    $0x57,%eax
  80100a:	eb d3                	jmp    800fdf <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  80100c:	8d 70 bf             	lea    -0x41(%eax),%esi
  80100f:	89 f3                	mov    %esi,%ebx
  801011:	80 fb 19             	cmp    $0x19,%bl
  801014:	77 08                	ja     80101e <strtol+0xc1>
			dig = *s - 'A' + 10;
  801016:	0f be c0             	movsbl %al,%eax
  801019:	83 e8 37             	sub    $0x37,%eax
  80101c:	eb c1                	jmp    800fdf <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  80101e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801022:	74 05                	je     801029 <strtol+0xcc>
		*endptr = (char *) s;
  801024:	8b 45 0c             	mov    0xc(%ebp),%eax
  801027:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801029:	89 c8                	mov    %ecx,%eax
  80102b:	f7 d8                	neg    %eax
  80102d:	85 ff                	test   %edi,%edi
  80102f:	0f 45 c8             	cmovne %eax,%ecx
}
  801032:	89 c8                	mov    %ecx,%eax
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
  801044:	8b 55 08             	mov    0x8(%ebp),%edx
  801047:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104a:	89 c3                	mov    %eax,%ebx
  80104c:	89 c7                	mov    %eax,%edi
  80104e:	89 c6                	mov    %eax,%esi
  801050:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    

00801057 <sys_cgetc>:

int
sys_cgetc(void)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	57                   	push   %edi
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80105d:	ba 00 00 00 00       	mov    $0x0,%edx
  801062:	b8 01 00 00 00       	mov    $0x1,%eax
  801067:	89 d1                	mov    %edx,%ecx
  801069:	89 d3                	mov    %edx,%ebx
  80106b:	89 d7                	mov    %edx,%edi
  80106d:	89 d6                	mov    %edx,%esi
  80106f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
  80107c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80107f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	b8 03 00 00 00       	mov    $0x3,%eax
  80108c:	89 cb                	mov    %ecx,%ebx
  80108e:	89 cf                	mov    %ecx,%edi
  801090:	89 ce                	mov    %ecx,%esi
  801092:	cd 30                	int    $0x30
	if(check && ret > 0)
  801094:	85 c0                	test   %eax,%eax
  801096:	7f 08                	jg     8010a0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5e                   	pop    %esi
  80109d:	5f                   	pop    %edi
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	50                   	push   %eax
  8010a4:	6a 03                	push   $0x3
  8010a6:	68 bf 2c 80 00       	push   $0x802cbf
  8010ab:	6a 2a                	push   $0x2a
  8010ad:	68 dc 2c 80 00       	push   $0x802cdc
  8010b2:	e8 8d f5 ff ff       	call   800644 <_panic>

008010b7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c2:	b8 02 00 00 00       	mov    $0x2,%eax
  8010c7:	89 d1                	mov    %edx,%ecx
  8010c9:	89 d3                	mov    %edx,%ebx
  8010cb:	89 d7                	mov    %edx,%edi
  8010cd:	89 d6                	mov    %edx,%esi
  8010cf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <sys_yield>:

void
sys_yield(void)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	57                   	push   %edi
  8010da:	56                   	push   %esi
  8010db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010e6:	89 d1                	mov    %edx,%ecx
  8010e8:	89 d3                	mov    %edx,%ebx
  8010ea:	89 d7                	mov    %edx,%edi
  8010ec:	89 d6                	mov    %edx,%esi
  8010ee:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010f0:	5b                   	pop    %ebx
  8010f1:	5e                   	pop    %esi
  8010f2:	5f                   	pop    %edi
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010fe:	be 00 00 00 00       	mov    $0x0,%esi
  801103:	8b 55 08             	mov    0x8(%ebp),%edx
  801106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801109:	b8 04 00 00 00       	mov    $0x4,%eax
  80110e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801111:	89 f7                	mov    %esi,%edi
  801113:	cd 30                	int    $0x30
	if(check && ret > 0)
  801115:	85 c0                	test   %eax,%eax
  801117:	7f 08                	jg     801121 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111c:	5b                   	pop    %ebx
  80111d:	5e                   	pop    %esi
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	50                   	push   %eax
  801125:	6a 04                	push   $0x4
  801127:	68 bf 2c 80 00       	push   $0x802cbf
  80112c:	6a 2a                	push   $0x2a
  80112e:	68 dc 2c 80 00       	push   $0x802cdc
  801133:	e8 0c f5 ff ff       	call   800644 <_panic>

00801138 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
  80113e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801141:	8b 55 08             	mov    0x8(%ebp),%edx
  801144:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801147:	b8 05 00 00 00       	mov    $0x5,%eax
  80114c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801152:	8b 75 18             	mov    0x18(%ebp),%esi
  801155:	cd 30                	int    $0x30
	if(check && ret > 0)
  801157:	85 c0                	test   %eax,%eax
  801159:	7f 08                	jg     801163 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80115b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5e                   	pop    %esi
  801160:	5f                   	pop    %edi
  801161:	5d                   	pop    %ebp
  801162:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	50                   	push   %eax
  801167:	6a 05                	push   $0x5
  801169:	68 bf 2c 80 00       	push   $0x802cbf
  80116e:	6a 2a                	push   $0x2a
  801170:	68 dc 2c 80 00       	push   $0x802cdc
  801175:	e8 ca f4 ff ff       	call   800644 <_panic>

0080117a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801183:	bb 00 00 00 00       	mov    $0x0,%ebx
  801188:	8b 55 08             	mov    0x8(%ebp),%edx
  80118b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118e:	b8 06 00 00 00       	mov    $0x6,%eax
  801193:	89 df                	mov    %ebx,%edi
  801195:	89 de                	mov    %ebx,%esi
  801197:	cd 30                	int    $0x30
	if(check && ret > 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	7f 08                	jg     8011a5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80119d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a5:	83 ec 0c             	sub    $0xc,%esp
  8011a8:	50                   	push   %eax
  8011a9:	6a 06                	push   $0x6
  8011ab:	68 bf 2c 80 00       	push   $0x802cbf
  8011b0:	6a 2a                	push   $0x2a
  8011b2:	68 dc 2c 80 00       	push   $0x802cdc
  8011b7:	e8 88 f4 ff ff       	call   800644 <_panic>

008011bc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	57                   	push   %edi
  8011c0:	56                   	push   %esi
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8011d5:	89 df                	mov    %ebx,%edi
  8011d7:	89 de                	mov    %ebx,%esi
  8011d9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	7f 08                	jg     8011e7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	50                   	push   %eax
  8011eb:	6a 08                	push   $0x8
  8011ed:	68 bf 2c 80 00       	push   $0x802cbf
  8011f2:	6a 2a                	push   $0x2a
  8011f4:	68 dc 2c 80 00       	push   $0x802cdc
  8011f9:	e8 46 f4 ff ff       	call   800644 <_panic>

008011fe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120c:	8b 55 08             	mov    0x8(%ebp),%edx
  80120f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801212:	b8 09 00 00 00       	mov    $0x9,%eax
  801217:	89 df                	mov    %ebx,%edi
  801219:	89 de                	mov    %ebx,%esi
  80121b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80121d:	85 c0                	test   %eax,%eax
  80121f:	7f 08                	jg     801229 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801229:	83 ec 0c             	sub    $0xc,%esp
  80122c:	50                   	push   %eax
  80122d:	6a 09                	push   $0x9
  80122f:	68 bf 2c 80 00       	push   $0x802cbf
  801234:	6a 2a                	push   $0x2a
  801236:	68 dc 2c 80 00       	push   $0x802cdc
  80123b:	e8 04 f4 ff ff       	call   800644 <_panic>

00801240 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124e:	8b 55 08             	mov    0x8(%ebp),%edx
  801251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801254:	b8 0a 00 00 00       	mov    $0xa,%eax
  801259:	89 df                	mov    %ebx,%edi
  80125b:	89 de                	mov    %ebx,%esi
  80125d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80125f:	85 c0                	test   %eax,%eax
  801261:	7f 08                	jg     80126b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5f                   	pop    %edi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80126b:	83 ec 0c             	sub    $0xc,%esp
  80126e:	50                   	push   %eax
  80126f:	6a 0a                	push   $0xa
  801271:	68 bf 2c 80 00       	push   $0x802cbf
  801276:	6a 2a                	push   $0x2a
  801278:	68 dc 2c 80 00       	push   $0x802cdc
  80127d:	e8 c2 f3 ff ff       	call   800644 <_panic>

00801282 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	57                   	push   %edi
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
	asm volatile("int %1\n"
  801288:	8b 55 08             	mov    0x8(%ebp),%edx
  80128b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128e:	b8 0c 00 00 00       	mov    $0xc,%eax
  801293:	be 00 00 00 00       	mov    $0x0,%esi
  801298:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80129b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8012a0:	5b                   	pop    %ebx
  8012a1:	5e                   	pop    %esi
  8012a2:	5f                   	pop    %edi
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	57                   	push   %edi
  8012a9:	56                   	push   %esi
  8012aa:	53                   	push   %ebx
  8012ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b6:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012bb:	89 cb                	mov    %ecx,%ebx
  8012bd:	89 cf                	mov    %ecx,%edi
  8012bf:	89 ce                	mov    %ecx,%esi
  8012c1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	7f 08                	jg     8012cf <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ca:	5b                   	pop    %ebx
  8012cb:	5e                   	pop    %esi
  8012cc:	5f                   	pop    %edi
  8012cd:	5d                   	pop    %ebp
  8012ce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cf:	83 ec 0c             	sub    $0xc,%esp
  8012d2:	50                   	push   %eax
  8012d3:	6a 0d                	push   $0xd
  8012d5:	68 bf 2c 80 00       	push   $0x802cbf
  8012da:	6a 2a                	push   $0x2a
  8012dc:	68 dc 2c 80 00       	push   $0x802cdc
  8012e1:	e8 5e f3 ff ff       	call   800644 <_panic>

008012e6 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	57                   	push   %edi
  8012ea:	56                   	push   %esi
  8012eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f1:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012f6:	89 d1                	mov    %edx,%ecx
  8012f8:	89 d3                	mov    %edx,%ebx
  8012fa:	89 d7                	mov    %edx,%edi
  8012fc:	89 d6                	mov    %edx,%esi
  8012fe:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80130b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801310:	8b 55 08             	mov    0x8(%ebp),%edx
  801313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801316:	b8 0f 00 00 00       	mov    $0xf,%eax
  80131b:	89 df                	mov    %ebx,%edi
  80131d:	89 de                	mov    %ebx,%esi
  80131f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	57                   	push   %edi
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80132c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801331:	8b 55 08             	mov    0x8(%ebp),%edx
  801334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801337:	b8 10 00 00 00       	mov    $0x10,%eax
  80133c:	89 df                	mov    %ebx,%edi
  80133e:	89 de                	mov    %ebx,%esi
  801340:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5f                   	pop    %edi
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80134d:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801354:	74 0a                	je     801360 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	a3 b0 40 80 00       	mov    %eax,0x8040b0
}
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801360:	e8 52 fd ff ff       	call   8010b7 <sys_getenvid>
  801365:	83 ec 04             	sub    $0x4,%esp
  801368:	68 07 0e 00 00       	push   $0xe07
  80136d:	68 00 f0 bf ee       	push   $0xeebff000
  801372:	50                   	push   %eax
  801373:	e8 7d fd ff ff       	call   8010f5 <sys_page_alloc>
		if (r < 0) {
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 2c                	js     8013ab <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80137f:	e8 33 fd ff ff       	call   8010b7 <sys_getenvid>
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	68 bd 13 80 00       	push   $0x8013bd
  80138c:	50                   	push   %eax
  80138d:	e8 ae fe ff ff       	call   801240 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	85 c0                	test   %eax,%eax
  801397:	79 bd                	jns    801356 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801399:	50                   	push   %eax
  80139a:	68 2c 2d 80 00       	push   $0x802d2c
  80139f:	6a 28                	push   $0x28
  8013a1:	68 62 2d 80 00       	push   $0x802d62
  8013a6:	e8 99 f2 ff ff       	call   800644 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8013ab:	50                   	push   %eax
  8013ac:	68 ec 2c 80 00       	push   $0x802cec
  8013b1:	6a 23                	push   $0x23
  8013b3:	68 62 2d 80 00       	push   $0x802d62
  8013b8:	e8 87 f2 ff ff       	call   800644 <_panic>

008013bd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013bd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013be:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	call *%eax
  8013c3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013c5:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8013c8:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8013cc:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8013cf:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8013d3:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8013d7:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8013d9:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8013dc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8013dd:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8013e0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8013e1:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8013e2:	c3                   	ret    

008013e3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8013ee:	c1 e8 0c             	shr    $0xc,%eax
}
  8013f1:	5d                   	pop    %ebp
  8013f2:	c3                   	ret    

008013f3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801403:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801412:	89 c2                	mov    %eax,%edx
  801414:	c1 ea 16             	shr    $0x16,%edx
  801417:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80141e:	f6 c2 01             	test   $0x1,%dl
  801421:	74 29                	je     80144c <fd_alloc+0x42>
  801423:	89 c2                	mov    %eax,%edx
  801425:	c1 ea 0c             	shr    $0xc,%edx
  801428:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142f:	f6 c2 01             	test   $0x1,%dl
  801432:	74 18                	je     80144c <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801434:	05 00 10 00 00       	add    $0x1000,%eax
  801439:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80143e:	75 d2                	jne    801412 <fd_alloc+0x8>
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801445:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80144a:	eb 05                	jmp    801451 <fd_alloc+0x47>
			return 0;
  80144c:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801451:	8b 55 08             	mov    0x8(%ebp),%edx
  801454:	89 02                	mov    %eax,(%edx)
}
  801456:	89 c8                	mov    %ecx,%eax
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801460:	83 f8 1f             	cmp    $0x1f,%eax
  801463:	77 30                	ja     801495 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801465:	c1 e0 0c             	shl    $0xc,%eax
  801468:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80146d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801473:	f6 c2 01             	test   $0x1,%dl
  801476:	74 24                	je     80149c <fd_lookup+0x42>
  801478:	89 c2                	mov    %eax,%edx
  80147a:	c1 ea 0c             	shr    $0xc,%edx
  80147d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801484:	f6 c2 01             	test   $0x1,%dl
  801487:	74 1a                	je     8014a3 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801489:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148c:	89 02                	mov    %eax,(%edx)
	return 0;
  80148e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    
		return -E_INVAL;
  801495:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149a:	eb f7                	jmp    801493 <fd_lookup+0x39>
		return -E_INVAL;
  80149c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a1:	eb f0                	jmp    801493 <fd_lookup+0x39>
  8014a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a8:	eb e9                	jmp    801493 <fd_lookup+0x39>

008014aa <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 04             	sub    $0x4,%esp
  8014b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b9:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8014be:	39 13                	cmp    %edx,(%ebx)
  8014c0:	74 37                	je     8014f9 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8014c2:	83 c0 01             	add    $0x1,%eax
  8014c5:	8b 1c 85 ec 2d 80 00 	mov    0x802dec(,%eax,4),%ebx
  8014cc:	85 db                	test   %ebx,%ebx
  8014ce:	75 ee                	jne    8014be <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014d0:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8014d5:	8b 40 58             	mov    0x58(%eax),%eax
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	52                   	push   %edx
  8014dc:	50                   	push   %eax
  8014dd:	68 70 2d 80 00       	push   $0x802d70
  8014e2:	e8 38 f2 ff ff       	call   80071f <cprintf>
	*dev = 0;
	return -E_INVAL;
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8014ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f2:	89 1a                	mov    %ebx,(%edx)
}
  8014f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    
			return 0;
  8014f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fe:	eb ef                	jmp    8014ef <dev_lookup+0x45>

00801500 <fd_close>:
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	53                   	push   %ebx
  801506:	83 ec 24             	sub    $0x24,%esp
  801509:	8b 75 08             	mov    0x8(%ebp),%esi
  80150c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801512:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801513:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801519:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151c:	50                   	push   %eax
  80151d:	e8 38 ff ff ff       	call   80145a <fd_lookup>
  801522:	89 c3                	mov    %eax,%ebx
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 05                	js     801530 <fd_close+0x30>
	    || fd != fd2)
  80152b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80152e:	74 16                	je     801546 <fd_close+0x46>
		return (must_exist ? r : 0);
  801530:	89 f8                	mov    %edi,%eax
  801532:	84 c0                	test   %al,%al
  801534:	b8 00 00 00 00       	mov    $0x0,%eax
  801539:	0f 44 d8             	cmove  %eax,%ebx
}
  80153c:	89 d8                	mov    %ebx,%eax
  80153e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5f                   	pop    %edi
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	ff 36                	push   (%esi)
  80154f:	e8 56 ff ff ff       	call   8014aa <dev_lookup>
  801554:	89 c3                	mov    %eax,%ebx
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 1a                	js     801577 <fd_close+0x77>
		if (dev->dev_close)
  80155d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801560:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801563:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801568:	85 c0                	test   %eax,%eax
  80156a:	74 0b                	je     801577 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	56                   	push   %esi
  801570:	ff d0                	call   *%eax
  801572:	89 c3                	mov    %eax,%ebx
  801574:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	56                   	push   %esi
  80157b:	6a 00                	push   $0x0
  80157d:	e8 f8 fb ff ff       	call   80117a <sys_page_unmap>
	return r;
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	eb b5                	jmp    80153c <fd_close+0x3c>

00801587 <close>:

int
close(int fdnum)
{
  801587:	55                   	push   %ebp
  801588:	89 e5                	mov    %esp,%ebp
  80158a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	ff 75 08             	push   0x8(%ebp)
  801594:	e8 c1 fe ff ff       	call   80145a <fd_lookup>
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	79 02                	jns    8015a2 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    
		return fd_close(fd, 1);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	6a 01                	push   $0x1
  8015a7:	ff 75 f4             	push   -0xc(%ebp)
  8015aa:	e8 51 ff ff ff       	call   801500 <fd_close>
  8015af:	83 c4 10             	add    $0x10,%esp
  8015b2:	eb ec                	jmp    8015a0 <close+0x19>

008015b4 <close_all>:

void
close_all(void)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	e8 be ff ff ff       	call   801587 <close>
	for (i = 0; i < MAXFD; i++)
  8015c9:	83 c3 01             	add    $0x1,%ebx
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	83 fb 20             	cmp    $0x20,%ebx
  8015d2:	75 ec                	jne    8015c0 <close_all+0xc>
}
  8015d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d7:	c9                   	leave  
  8015d8:	c3                   	ret    

008015d9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	57                   	push   %edi
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
  8015df:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e5:	50                   	push   %eax
  8015e6:	ff 75 08             	push   0x8(%ebp)
  8015e9:	e8 6c fe ff ff       	call   80145a <fd_lookup>
  8015ee:	89 c3                	mov    %eax,%ebx
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 7f                	js     801676 <dup+0x9d>
		return r;
	close(newfdnum);
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	ff 75 0c             	push   0xc(%ebp)
  8015fd:	e8 85 ff ff ff       	call   801587 <close>

	newfd = INDEX2FD(newfdnum);
  801602:	8b 75 0c             	mov    0xc(%ebp),%esi
  801605:	c1 e6 0c             	shl    $0xc,%esi
  801608:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80160e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801611:	89 3c 24             	mov    %edi,(%esp)
  801614:	e8 da fd ff ff       	call   8013f3 <fd2data>
  801619:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80161b:	89 34 24             	mov    %esi,(%esp)
  80161e:	e8 d0 fd ff ff       	call   8013f3 <fd2data>
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801629:	89 d8                	mov    %ebx,%eax
  80162b:	c1 e8 16             	shr    $0x16,%eax
  80162e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801635:	a8 01                	test   $0x1,%al
  801637:	74 11                	je     80164a <dup+0x71>
  801639:	89 d8                	mov    %ebx,%eax
  80163b:	c1 e8 0c             	shr    $0xc,%eax
  80163e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801645:	f6 c2 01             	test   $0x1,%dl
  801648:	75 36                	jne    801680 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80164a:	89 f8                	mov    %edi,%eax
  80164c:	c1 e8 0c             	shr    $0xc,%eax
  80164f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	25 07 0e 00 00       	and    $0xe07,%eax
  80165e:	50                   	push   %eax
  80165f:	56                   	push   %esi
  801660:	6a 00                	push   $0x0
  801662:	57                   	push   %edi
  801663:	6a 00                	push   $0x0
  801665:	e8 ce fa ff ff       	call   801138 <sys_page_map>
  80166a:	89 c3                	mov    %eax,%ebx
  80166c:	83 c4 20             	add    $0x20,%esp
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 33                	js     8016a6 <dup+0xcd>
		goto err;

	return newfdnum;
  801673:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801676:	89 d8                	mov    %ebx,%eax
  801678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5f                   	pop    %edi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801680:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801687:	83 ec 0c             	sub    $0xc,%esp
  80168a:	25 07 0e 00 00       	and    $0xe07,%eax
  80168f:	50                   	push   %eax
  801690:	ff 75 d4             	push   -0x2c(%ebp)
  801693:	6a 00                	push   $0x0
  801695:	53                   	push   %ebx
  801696:	6a 00                	push   $0x0
  801698:	e8 9b fa ff ff       	call   801138 <sys_page_map>
  80169d:	89 c3                	mov    %eax,%ebx
  80169f:	83 c4 20             	add    $0x20,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	79 a4                	jns    80164a <dup+0x71>
	sys_page_unmap(0, newfd);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	56                   	push   %esi
  8016aa:	6a 00                	push   $0x0
  8016ac:	e8 c9 fa ff ff       	call   80117a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	ff 75 d4             	push   -0x2c(%ebp)
  8016b7:	6a 00                	push   $0x0
  8016b9:	e8 bc fa ff ff       	call   80117a <sys_page_unmap>
	return r;
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	eb b3                	jmp    801676 <dup+0x9d>

008016c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 18             	sub    $0x18,%esp
  8016cb:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d1:	50                   	push   %eax
  8016d2:	56                   	push   %esi
  8016d3:	e8 82 fd ff ff       	call   80145a <fd_lookup>
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	78 3c                	js     80171b <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e8:	50                   	push   %eax
  8016e9:	ff 33                	push   (%ebx)
  8016eb:	e8 ba fd ff ff       	call   8014aa <dev_lookup>
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 24                	js     80171b <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f7:	8b 43 08             	mov    0x8(%ebx),%eax
  8016fa:	83 e0 03             	and    $0x3,%eax
  8016fd:	83 f8 01             	cmp    $0x1,%eax
  801700:	74 20                	je     801722 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801705:	8b 40 08             	mov    0x8(%eax),%eax
  801708:	85 c0                	test   %eax,%eax
  80170a:	74 37                	je     801743 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80170c:	83 ec 04             	sub    $0x4,%esp
  80170f:	ff 75 10             	push   0x10(%ebp)
  801712:	ff 75 0c             	push   0xc(%ebp)
  801715:	53                   	push   %ebx
  801716:	ff d0                	call   *%eax
  801718:	83 c4 10             	add    $0x10,%esp
}
  80171b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801722:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801727:	8b 40 58             	mov    0x58(%eax),%eax
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	56                   	push   %esi
  80172e:	50                   	push   %eax
  80172f:	68 b1 2d 80 00       	push   $0x802db1
  801734:	e8 e6 ef ff ff       	call   80071f <cprintf>
		return -E_INVAL;
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801741:	eb d8                	jmp    80171b <read+0x58>
		return -E_NOT_SUPP;
  801743:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801748:	eb d1                	jmp    80171b <read+0x58>

0080174a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	57                   	push   %edi
  80174e:	56                   	push   %esi
  80174f:	53                   	push   %ebx
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	8b 7d 08             	mov    0x8(%ebp),%edi
  801756:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801759:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175e:	eb 02                	jmp    801762 <readn+0x18>
  801760:	01 c3                	add    %eax,%ebx
  801762:	39 f3                	cmp    %esi,%ebx
  801764:	73 21                	jae    801787 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801766:	83 ec 04             	sub    $0x4,%esp
  801769:	89 f0                	mov    %esi,%eax
  80176b:	29 d8                	sub    %ebx,%eax
  80176d:	50                   	push   %eax
  80176e:	89 d8                	mov    %ebx,%eax
  801770:	03 45 0c             	add    0xc(%ebp),%eax
  801773:	50                   	push   %eax
  801774:	57                   	push   %edi
  801775:	e8 49 ff ff ff       	call   8016c3 <read>
		if (m < 0)
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	85 c0                	test   %eax,%eax
  80177f:	78 04                	js     801785 <readn+0x3b>
			return m;
		if (m == 0)
  801781:	75 dd                	jne    801760 <readn+0x16>
  801783:	eb 02                	jmp    801787 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801785:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801787:	89 d8                	mov    %ebx,%eax
  801789:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5f                   	pop    %edi
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 18             	sub    $0x18,%esp
  801799:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179f:	50                   	push   %eax
  8017a0:	53                   	push   %ebx
  8017a1:	e8 b4 fc ff ff       	call   80145a <fd_lookup>
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 37                	js     8017e4 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ad:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b6:	50                   	push   %eax
  8017b7:	ff 36                	push   (%esi)
  8017b9:	e8 ec fc ff ff       	call   8014aa <dev_lookup>
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 1f                	js     8017e4 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8017c9:	74 20                	je     8017eb <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	74 37                	je     80180c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d5:	83 ec 04             	sub    $0x4,%esp
  8017d8:	ff 75 10             	push   0x10(%ebp)
  8017db:	ff 75 0c             	push   0xc(%ebp)
  8017de:	56                   	push   %esi
  8017df:	ff d0                	call   *%eax
  8017e1:	83 c4 10             	add    $0x10,%esp
}
  8017e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017eb:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8017f0:	8b 40 58             	mov    0x58(%eax),%eax
  8017f3:	83 ec 04             	sub    $0x4,%esp
  8017f6:	53                   	push   %ebx
  8017f7:	50                   	push   %eax
  8017f8:	68 cd 2d 80 00       	push   $0x802dcd
  8017fd:	e8 1d ef ff ff       	call   80071f <cprintf>
		return -E_INVAL;
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80180a:	eb d8                	jmp    8017e4 <write+0x53>
		return -E_NOT_SUPP;
  80180c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801811:	eb d1                	jmp    8017e4 <write+0x53>

00801813 <seek>:

int
seek(int fdnum, off_t offset)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	ff 75 08             	push   0x8(%ebp)
  801820:	e8 35 fc ff ff       	call   80145a <fd_lookup>
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 0e                	js     80183a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80182c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801832:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801835:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183a:	c9                   	leave  
  80183b:	c3                   	ret    

0080183c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	56                   	push   %esi
  801840:	53                   	push   %ebx
  801841:	83 ec 18             	sub    $0x18,%esp
  801844:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801847:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	53                   	push   %ebx
  80184c:	e8 09 fc ff ff       	call   80145a <fd_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 34                	js     80188c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801858:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801861:	50                   	push   %eax
  801862:	ff 36                	push   (%esi)
  801864:	e8 41 fc ff ff       	call   8014aa <dev_lookup>
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 1c                	js     80188c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801870:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801874:	74 1d                	je     801893 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801879:	8b 40 18             	mov    0x18(%eax),%eax
  80187c:	85 c0                	test   %eax,%eax
  80187e:	74 34                	je     8018b4 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801880:	83 ec 08             	sub    $0x8,%esp
  801883:	ff 75 0c             	push   0xc(%ebp)
  801886:	56                   	push   %esi
  801887:	ff d0                	call   *%eax
  801889:	83 c4 10             	add    $0x10,%esp
}
  80188c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188f:	5b                   	pop    %ebx
  801890:	5e                   	pop    %esi
  801891:	5d                   	pop    %ebp
  801892:	c3                   	ret    
			thisenv->env_id, fdnum);
  801893:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801898:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	53                   	push   %ebx
  80189f:	50                   	push   %eax
  8018a0:	68 90 2d 80 00       	push   $0x802d90
  8018a5:	e8 75 ee ff ff       	call   80071f <cprintf>
		return -E_INVAL;
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b2:	eb d8                	jmp    80188c <ftruncate+0x50>
		return -E_NOT_SUPP;
  8018b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018b9:	eb d1                	jmp    80188c <ftruncate+0x50>

008018bb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	83 ec 18             	sub    $0x18,%esp
  8018c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c9:	50                   	push   %eax
  8018ca:	ff 75 08             	push   0x8(%ebp)
  8018cd:	e8 88 fb ff ff       	call   80145a <fd_lookup>
  8018d2:	83 c4 10             	add    $0x10,%esp
  8018d5:	85 c0                	test   %eax,%eax
  8018d7:	78 49                	js     801922 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e2:	50                   	push   %eax
  8018e3:	ff 36                	push   (%esi)
  8018e5:	e8 c0 fb ff ff       	call   8014aa <dev_lookup>
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	85 c0                	test   %eax,%eax
  8018ef:	78 31                	js     801922 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8018f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f8:	74 2f                	je     801929 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018fa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018fd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801904:	00 00 00 
	stat->st_isdir = 0;
  801907:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190e:	00 00 00 
	stat->st_dev = dev;
  801911:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	53                   	push   %ebx
  80191b:	56                   	push   %esi
  80191c:	ff 50 14             	call   *0x14(%eax)
  80191f:	83 c4 10             	add    $0x10,%esp
}
  801922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    
		return -E_NOT_SUPP;
  801929:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80192e:	eb f2                	jmp    801922 <fstat+0x67>

00801930 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	56                   	push   %esi
  801934:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801935:	83 ec 08             	sub    $0x8,%esp
  801938:	6a 00                	push   $0x0
  80193a:	ff 75 08             	push   0x8(%ebp)
  80193d:	e8 e4 01 00 00       	call   801b26 <open>
  801942:	89 c3                	mov    %eax,%ebx
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	78 1b                	js     801966 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80194b:	83 ec 08             	sub    $0x8,%esp
  80194e:	ff 75 0c             	push   0xc(%ebp)
  801951:	50                   	push   %eax
  801952:	e8 64 ff ff ff       	call   8018bb <fstat>
  801957:	89 c6                	mov    %eax,%esi
	close(fd);
  801959:	89 1c 24             	mov    %ebx,(%esp)
  80195c:	e8 26 fc ff ff       	call   801587 <close>
	return r;
  801961:	83 c4 10             	add    $0x10,%esp
  801964:	89 f3                	mov    %esi,%ebx
}
  801966:	89 d8                	mov    %ebx,%eax
  801968:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5e                   	pop    %esi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	89 c6                	mov    %eax,%esi
  801976:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801978:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80197f:	74 27                	je     8019a8 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801981:	6a 07                	push   $0x7
  801983:	68 00 50 80 00       	push   $0x805000
  801988:	56                   	push   %esi
  801989:	ff 35 00 60 80 00    	push   0x806000
  80198f:	e8 cd 0b 00 00       	call   802561 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801994:	83 c4 0c             	add    $0xc,%esp
  801997:	6a 00                	push   $0x0
  801999:	53                   	push   %ebx
  80199a:	6a 00                	push   $0x0
  80199c:	e8 50 0b 00 00       	call   8024f1 <ipc_recv>
}
  8019a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019a8:	83 ec 0c             	sub    $0xc,%esp
  8019ab:	6a 01                	push   $0x1
  8019ad:	e8 03 0c 00 00       	call   8025b5 <ipc_find_env>
  8019b2:	a3 00 60 80 00       	mov    %eax,0x806000
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	eb c5                	jmp    801981 <fsipc+0x12>

008019bc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019da:	b8 02 00 00 00       	mov    $0x2,%eax
  8019df:	e8 8b ff ff ff       	call   80196f <fsipc>
}
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <devfile_flush>:
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801a01:	e8 69 ff ff ff       	call   80196f <fsipc>
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <devfile_stat>:
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 04             	sub    $0x4,%esp
  801a0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	8b 40 0c             	mov    0xc(%eax),%eax
  801a18:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a22:	b8 05 00 00 00       	mov    $0x5,%eax
  801a27:	e8 43 ff ff ff       	call   80196f <fsipc>
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 2c                	js     801a5c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	68 00 50 80 00       	push   $0x805000
  801a38:	53                   	push   %ebx
  801a39:	e8 bb f2 ff ff       	call   800cf9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a3e:	a1 80 50 80 00       	mov    0x805080,%eax
  801a43:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a49:	a1 84 50 80 00       	mov    0x805084,%eax
  801a4e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a54:	83 c4 10             	add    $0x10,%esp
  801a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <devfile_write>:
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 0c             	sub    $0xc,%esp
  801a67:	8b 45 10             	mov    0x10(%ebp),%eax
  801a6a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a6f:	39 d0                	cmp    %edx,%eax
  801a71:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a74:	8b 55 08             	mov    0x8(%ebp),%edx
  801a77:	8b 52 0c             	mov    0xc(%edx),%edx
  801a7a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a80:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a85:	50                   	push   %eax
  801a86:	ff 75 0c             	push   0xc(%ebp)
  801a89:	68 08 50 80 00       	push   $0x805008
  801a8e:	e8 fc f3 ff ff       	call   800e8f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801a93:	ba 00 00 00 00       	mov    $0x0,%edx
  801a98:	b8 04 00 00 00       	mov    $0x4,%eax
  801a9d:	e8 cd fe ff ff       	call   80196f <fsipc>
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <devfile_read>:
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aac:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ab7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801abd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac2:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac7:	e8 a3 fe ff ff       	call   80196f <fsipc>
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	78 1f                	js     801af1 <devfile_read+0x4d>
	assert(r <= n);
  801ad2:	39 f0                	cmp    %esi,%eax
  801ad4:	77 24                	ja     801afa <devfile_read+0x56>
	assert(r <= PGSIZE);
  801ad6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801adb:	7f 33                	jg     801b10 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801add:	83 ec 04             	sub    $0x4,%esp
  801ae0:	50                   	push   %eax
  801ae1:	68 00 50 80 00       	push   $0x805000
  801ae6:	ff 75 0c             	push   0xc(%ebp)
  801ae9:	e8 a1 f3 ff ff       	call   800e8f <memmove>
	return r;
  801aee:	83 c4 10             	add    $0x10,%esp
}
  801af1:	89 d8                	mov    %ebx,%eax
  801af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    
	assert(r <= n);
  801afa:	68 00 2e 80 00       	push   $0x802e00
  801aff:	68 07 2e 80 00       	push   $0x802e07
  801b04:	6a 7c                	push   $0x7c
  801b06:	68 1c 2e 80 00       	push   $0x802e1c
  801b0b:	e8 34 eb ff ff       	call   800644 <_panic>
	assert(r <= PGSIZE);
  801b10:	68 27 2e 80 00       	push   $0x802e27
  801b15:	68 07 2e 80 00       	push   $0x802e07
  801b1a:	6a 7d                	push   $0x7d
  801b1c:	68 1c 2e 80 00       	push   $0x802e1c
  801b21:	e8 1e eb ff ff       	call   800644 <_panic>

00801b26 <open>:
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 1c             	sub    $0x1c,%esp
  801b2e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b31:	56                   	push   %esi
  801b32:	e8 87 f1 ff ff       	call   800cbe <strlen>
  801b37:	83 c4 10             	add    $0x10,%esp
  801b3a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b3f:	7f 6c                	jg     801bad <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b47:	50                   	push   %eax
  801b48:	e8 bd f8 ff ff       	call   80140a <fd_alloc>
  801b4d:	89 c3                	mov    %eax,%ebx
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	78 3c                	js     801b92 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	56                   	push   %esi
  801b5a:	68 00 50 80 00       	push   $0x805000
  801b5f:	e8 95 f1 ff ff       	call   800cf9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b67:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b6f:	b8 01 00 00 00       	mov    $0x1,%eax
  801b74:	e8 f6 fd ff ff       	call   80196f <fsipc>
  801b79:	89 c3                	mov    %eax,%ebx
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	85 c0                	test   %eax,%eax
  801b80:	78 19                	js     801b9b <open+0x75>
	return fd2num(fd);
  801b82:	83 ec 0c             	sub    $0xc,%esp
  801b85:	ff 75 f4             	push   -0xc(%ebp)
  801b88:	e8 56 f8 ff ff       	call   8013e3 <fd2num>
  801b8d:	89 c3                	mov    %eax,%ebx
  801b8f:	83 c4 10             	add    $0x10,%esp
}
  801b92:	89 d8                	mov    %ebx,%eax
  801b94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5e                   	pop    %esi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    
		fd_close(fd, 0);
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	6a 00                	push   $0x0
  801ba0:	ff 75 f4             	push   -0xc(%ebp)
  801ba3:	e8 58 f9 ff ff       	call   801500 <fd_close>
		return r;
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	eb e5                	jmp    801b92 <open+0x6c>
		return -E_BAD_PATH;
  801bad:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801bb2:	eb de                	jmp    801b92 <open+0x6c>

00801bb4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bba:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbf:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc4:	e8 a6 fd ff ff       	call   80196f <fsipc>
}
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bd1:	68 33 2e 80 00       	push   $0x802e33
  801bd6:	ff 75 0c             	push   0xc(%ebp)
  801bd9:	e8 1b f1 ff ff       	call   800cf9 <strcpy>
	return 0;
}
  801bde:	b8 00 00 00 00       	mov    $0x0,%eax
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <devsock_close>:
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	53                   	push   %ebx
  801be9:	83 ec 10             	sub    $0x10,%esp
  801bec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bef:	53                   	push   %ebx
  801bf0:	e8 ff 09 00 00       	call   8025f4 <pageref>
  801bf5:	89 c2                	mov    %eax,%edx
  801bf7:	83 c4 10             	add    $0x10,%esp
		return 0;
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801bff:	83 fa 01             	cmp    $0x1,%edx
  801c02:	74 05                	je     801c09 <devsock_close+0x24>
}
  801c04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	ff 73 0c             	push   0xc(%ebx)
  801c0f:	e8 b7 02 00 00       	call   801ecb <nsipc_close>
  801c14:	83 c4 10             	add    $0x10,%esp
  801c17:	eb eb                	jmp    801c04 <devsock_close+0x1f>

00801c19 <devsock_write>:
{
  801c19:	55                   	push   %ebp
  801c1a:	89 e5                	mov    %esp,%ebp
  801c1c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c1f:	6a 00                	push   $0x0
  801c21:	ff 75 10             	push   0x10(%ebp)
  801c24:	ff 75 0c             	push   0xc(%ebp)
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	ff 70 0c             	push   0xc(%eax)
  801c2d:	e8 79 03 00 00       	call   801fab <nsipc_send>
}
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <devsock_read>:
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c3a:	6a 00                	push   $0x0
  801c3c:	ff 75 10             	push   0x10(%ebp)
  801c3f:	ff 75 0c             	push   0xc(%ebp)
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	ff 70 0c             	push   0xc(%eax)
  801c48:	e8 ef 02 00 00       	call   801f3c <nsipc_recv>
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <fd2sockid>:
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c55:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c58:	52                   	push   %edx
  801c59:	50                   	push   %eax
  801c5a:	e8 fb f7 ff ff       	call   80145a <fd_lookup>
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	85 c0                	test   %eax,%eax
  801c64:	78 10                	js     801c76 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c69:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c6f:	39 08                	cmp    %ecx,(%eax)
  801c71:	75 05                	jne    801c78 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801c73:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    
		return -E_NOT_SUPP;
  801c78:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c7d:	eb f7                	jmp    801c76 <fd2sockid+0x27>

00801c7f <alloc_sockfd>:
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c8c:	50                   	push   %eax
  801c8d:	e8 78 f7 ff ff       	call   80140a <fd_alloc>
  801c92:	89 c3                	mov    %eax,%ebx
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 43                	js     801cde <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c9b:	83 ec 04             	sub    $0x4,%esp
  801c9e:	68 07 04 00 00       	push   $0x407
  801ca3:	ff 75 f4             	push   -0xc(%ebp)
  801ca6:	6a 00                	push   $0x0
  801ca8:	e8 48 f4 ff ff       	call   8010f5 <sys_page_alloc>
  801cad:	89 c3                	mov    %eax,%ebx
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	78 28                	js     801cde <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cbf:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ccb:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	50                   	push   %eax
  801cd2:	e8 0c f7 ff ff       	call   8013e3 <fd2num>
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	83 c4 10             	add    $0x10,%esp
  801cdc:	eb 0c                	jmp    801cea <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801cde:	83 ec 0c             	sub    $0xc,%esp
  801ce1:	56                   	push   %esi
  801ce2:	e8 e4 01 00 00       	call   801ecb <nsipc_close>
		return r;
  801ce7:	83 c4 10             	add    $0x10,%esp
}
  801cea:	89 d8                	mov    %ebx,%eax
  801cec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cef:	5b                   	pop    %ebx
  801cf0:	5e                   	pop    %esi
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    

00801cf3 <accept>:
{
  801cf3:	55                   	push   %ebp
  801cf4:	89 e5                	mov    %esp,%ebp
  801cf6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfc:	e8 4e ff ff ff       	call   801c4f <fd2sockid>
  801d01:	85 c0                	test   %eax,%eax
  801d03:	78 1b                	js     801d20 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d05:	83 ec 04             	sub    $0x4,%esp
  801d08:	ff 75 10             	push   0x10(%ebp)
  801d0b:	ff 75 0c             	push   0xc(%ebp)
  801d0e:	50                   	push   %eax
  801d0f:	e8 0e 01 00 00       	call   801e22 <nsipc_accept>
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 05                	js     801d20 <accept+0x2d>
	return alloc_sockfd(r);
  801d1b:	e8 5f ff ff ff       	call   801c7f <alloc_sockfd>
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <bind>:
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d28:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2b:	e8 1f ff ff ff       	call   801c4f <fd2sockid>
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 12                	js     801d46 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801d34:	83 ec 04             	sub    $0x4,%esp
  801d37:	ff 75 10             	push   0x10(%ebp)
  801d3a:	ff 75 0c             	push   0xc(%ebp)
  801d3d:	50                   	push   %eax
  801d3e:	e8 31 01 00 00       	call   801e74 <nsipc_bind>
  801d43:	83 c4 10             	add    $0x10,%esp
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <shutdown>:
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	e8 f9 fe ff ff       	call   801c4f <fd2sockid>
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 0f                	js     801d69 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801d5a:	83 ec 08             	sub    $0x8,%esp
  801d5d:	ff 75 0c             	push   0xc(%ebp)
  801d60:	50                   	push   %eax
  801d61:	e8 43 01 00 00       	call   801ea9 <nsipc_shutdown>
  801d66:	83 c4 10             	add    $0x10,%esp
}
  801d69:	c9                   	leave  
  801d6a:	c3                   	ret    

00801d6b <connect>:
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d71:	8b 45 08             	mov    0x8(%ebp),%eax
  801d74:	e8 d6 fe ff ff       	call   801c4f <fd2sockid>
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	78 12                	js     801d8f <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801d7d:	83 ec 04             	sub    $0x4,%esp
  801d80:	ff 75 10             	push   0x10(%ebp)
  801d83:	ff 75 0c             	push   0xc(%ebp)
  801d86:	50                   	push   %eax
  801d87:	e8 59 01 00 00       	call   801ee5 <nsipc_connect>
  801d8c:	83 c4 10             	add    $0x10,%esp
}
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    

00801d91 <listen>:
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d97:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9a:	e8 b0 fe ff ff       	call   801c4f <fd2sockid>
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 0f                	js     801db2 <listen+0x21>
	return nsipc_listen(r, backlog);
  801da3:	83 ec 08             	sub    $0x8,%esp
  801da6:	ff 75 0c             	push   0xc(%ebp)
  801da9:	50                   	push   %eax
  801daa:	e8 6b 01 00 00       	call   801f1a <nsipc_listen>
  801daf:	83 c4 10             	add    $0x10,%esp
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <socket>:

int
socket(int domain, int type, int protocol)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801dba:	ff 75 10             	push   0x10(%ebp)
  801dbd:	ff 75 0c             	push   0xc(%ebp)
  801dc0:	ff 75 08             	push   0x8(%ebp)
  801dc3:	e8 41 02 00 00       	call   802009 <nsipc_socket>
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 05                	js     801dd4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801dcf:	e8 ab fe ff ff       	call   801c7f <alloc_sockfd>
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 04             	sub    $0x4,%esp
  801ddd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ddf:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801de6:	74 26                	je     801e0e <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801de8:	6a 07                	push   $0x7
  801dea:	68 00 70 80 00       	push   $0x807000
  801def:	53                   	push   %ebx
  801df0:	ff 35 00 80 80 00    	push   0x808000
  801df6:	e8 66 07 00 00       	call   802561 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dfb:	83 c4 0c             	add    $0xc,%esp
  801dfe:	6a 00                	push   $0x0
  801e00:	6a 00                	push   $0x0
  801e02:	6a 00                	push   $0x0
  801e04:	e8 e8 06 00 00       	call   8024f1 <ipc_recv>
}
  801e09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	6a 02                	push   $0x2
  801e13:	e8 9d 07 00 00       	call   8025b5 <ipc_find_env>
  801e18:	a3 00 80 80 00       	mov    %eax,0x808000
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	eb c6                	jmp    801de8 <nsipc+0x12>

00801e22 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	56                   	push   %esi
  801e26:	53                   	push   %ebx
  801e27:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e32:	8b 06                	mov    (%esi),%eax
  801e34:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e39:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3e:	e8 93 ff ff ff       	call   801dd6 <nsipc>
  801e43:	89 c3                	mov    %eax,%ebx
  801e45:	85 c0                	test   %eax,%eax
  801e47:	79 09                	jns    801e52 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801e49:	89 d8                	mov    %ebx,%eax
  801e4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5e                   	pop    %esi
  801e50:	5d                   	pop    %ebp
  801e51:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e52:	83 ec 04             	sub    $0x4,%esp
  801e55:	ff 35 10 70 80 00    	push   0x807010
  801e5b:	68 00 70 80 00       	push   $0x807000
  801e60:	ff 75 0c             	push   0xc(%ebp)
  801e63:	e8 27 f0 ff ff       	call   800e8f <memmove>
		*addrlen = ret->ret_addrlen;
  801e68:	a1 10 70 80 00       	mov    0x807010,%eax
  801e6d:	89 06                	mov    %eax,(%esi)
  801e6f:	83 c4 10             	add    $0x10,%esp
	return r;
  801e72:	eb d5                	jmp    801e49 <nsipc_accept+0x27>

00801e74 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e74:	55                   	push   %ebp
  801e75:	89 e5                	mov    %esp,%ebp
  801e77:	53                   	push   %ebx
  801e78:	83 ec 08             	sub    $0x8,%esp
  801e7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e81:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e86:	53                   	push   %ebx
  801e87:	ff 75 0c             	push   0xc(%ebp)
  801e8a:	68 04 70 80 00       	push   $0x807004
  801e8f:	e8 fb ef ff ff       	call   800e8f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e94:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801e9a:	b8 02 00 00 00       	mov    $0x2,%eax
  801e9f:	e8 32 ff ff ff       	call   801dd6 <nsipc>
}
  801ea4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea7:	c9                   	leave  
  801ea8:	c3                   	ret    

00801ea9 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eba:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ebf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ec4:	e8 0d ff ff ff       	call   801dd6 <nsipc>
}
  801ec9:	c9                   	leave  
  801eca:	c3                   	ret    

00801ecb <nsipc_close>:

int
nsipc_close(int s)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed4:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ed9:	b8 04 00 00 00       	mov    $0x4,%eax
  801ede:	e8 f3 fe ff ff       	call   801dd6 <nsipc>
}
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    

00801ee5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ee5:	55                   	push   %ebp
  801ee6:	89 e5                	mov    %esp,%ebp
  801ee8:	53                   	push   %ebx
  801ee9:	83 ec 08             	sub    $0x8,%esp
  801eec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801eef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef2:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ef7:	53                   	push   %ebx
  801ef8:	ff 75 0c             	push   0xc(%ebp)
  801efb:	68 04 70 80 00       	push   $0x807004
  801f00:	e8 8a ef ff ff       	call   800e8f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f05:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f0b:	b8 05 00 00 00       	mov    $0x5,%eax
  801f10:	e8 c1 fe ff ff       	call   801dd6 <nsipc>
}
  801f15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    

00801f1a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f1a:	55                   	push   %ebp
  801f1b:	89 e5                	mov    %esp,%ebp
  801f1d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f20:	8b 45 08             	mov    0x8(%ebp),%eax
  801f23:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f30:	b8 06 00 00 00       	mov    $0x6,%eax
  801f35:	e8 9c fe ff ff       	call   801dd6 <nsipc>
}
  801f3a:	c9                   	leave  
  801f3b:	c3                   	ret    

00801f3c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801f4c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801f52:	8b 45 14             	mov    0x14(%ebp),%eax
  801f55:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f5a:	b8 07 00 00 00       	mov    $0x7,%eax
  801f5f:	e8 72 fe ff ff       	call   801dd6 <nsipc>
  801f64:	89 c3                	mov    %eax,%ebx
  801f66:	85 c0                	test   %eax,%eax
  801f68:	78 22                	js     801f8c <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801f6a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801f6f:	39 c6                	cmp    %eax,%esi
  801f71:	0f 4e c6             	cmovle %esi,%eax
  801f74:	39 c3                	cmp    %eax,%ebx
  801f76:	7f 1d                	jg     801f95 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f78:	83 ec 04             	sub    $0x4,%esp
  801f7b:	53                   	push   %ebx
  801f7c:	68 00 70 80 00       	push   $0x807000
  801f81:	ff 75 0c             	push   0xc(%ebp)
  801f84:	e8 06 ef ff ff       	call   800e8f <memmove>
  801f89:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f91:	5b                   	pop    %ebx
  801f92:	5e                   	pop    %esi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801f95:	68 3f 2e 80 00       	push   $0x802e3f
  801f9a:	68 07 2e 80 00       	push   $0x802e07
  801f9f:	6a 62                	push   $0x62
  801fa1:	68 54 2e 80 00       	push   $0x802e54
  801fa6:	e8 99 e6 ff ff       	call   800644 <_panic>

00801fab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	53                   	push   %ebx
  801faf:	83 ec 04             	sub    $0x4,%esp
  801fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801fbd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fc3:	7f 2e                	jg     801ff3 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fc5:	83 ec 04             	sub    $0x4,%esp
  801fc8:	53                   	push   %ebx
  801fc9:	ff 75 0c             	push   0xc(%ebp)
  801fcc:	68 0c 70 80 00       	push   $0x80700c
  801fd1:	e8 b9 ee ff ff       	call   800e8f <memmove>
	nsipcbuf.send.req_size = size;
  801fd6:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801fe4:	b8 08 00 00 00       	mov    $0x8,%eax
  801fe9:	e8 e8 fd ff ff       	call   801dd6 <nsipc>
}
  801fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    
	assert(size < 1600);
  801ff3:	68 60 2e 80 00       	push   $0x802e60
  801ff8:	68 07 2e 80 00       	push   $0x802e07
  801ffd:	6a 6d                	push   $0x6d
  801fff:	68 54 2e 80 00       	push   $0x802e54
  802004:	e8 3b e6 ff ff       	call   800644 <_panic>

00802009 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80200f:	8b 45 08             	mov    0x8(%ebp),%eax
  802012:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802017:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201a:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80201f:	8b 45 10             	mov    0x10(%ebp),%eax
  802022:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802027:	b8 09 00 00 00       	mov    $0x9,%eax
  80202c:	e8 a5 fd ff ff       	call   801dd6 <nsipc>
}
  802031:	c9                   	leave  
  802032:	c3                   	ret    

00802033 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80203b:	83 ec 0c             	sub    $0xc,%esp
  80203e:	ff 75 08             	push   0x8(%ebp)
  802041:	e8 ad f3 ff ff       	call   8013f3 <fd2data>
  802046:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802048:	83 c4 08             	add    $0x8,%esp
  80204b:	68 6c 2e 80 00       	push   $0x802e6c
  802050:	53                   	push   %ebx
  802051:	e8 a3 ec ff ff       	call   800cf9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802056:	8b 46 04             	mov    0x4(%esi),%eax
  802059:	2b 06                	sub    (%esi),%eax
  80205b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802061:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802068:	00 00 00 
	stat->st_dev = &devpipe;
  80206b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802072:	30 80 00 
	return 0;
}
  802075:	b8 00 00 00 00       	mov    $0x0,%eax
  80207a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    

00802081 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802081:	55                   	push   %ebp
  802082:	89 e5                	mov    %esp,%ebp
  802084:	53                   	push   %ebx
  802085:	83 ec 0c             	sub    $0xc,%esp
  802088:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80208b:	53                   	push   %ebx
  80208c:	6a 00                	push   $0x0
  80208e:	e8 e7 f0 ff ff       	call   80117a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802093:	89 1c 24             	mov    %ebx,(%esp)
  802096:	e8 58 f3 ff ff       	call   8013f3 <fd2data>
  80209b:	83 c4 08             	add    $0x8,%esp
  80209e:	50                   	push   %eax
  80209f:	6a 00                	push   $0x0
  8020a1:	e8 d4 f0 ff ff       	call   80117a <sys_page_unmap>
}
  8020a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    

008020ab <_pipeisclosed>:
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	57                   	push   %edi
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	83 ec 1c             	sub    $0x1c,%esp
  8020b4:	89 c7                	mov    %eax,%edi
  8020b6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8020b8:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8020bd:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020c0:	83 ec 0c             	sub    $0xc,%esp
  8020c3:	57                   	push   %edi
  8020c4:	e8 2b 05 00 00       	call   8025f4 <pageref>
  8020c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020cc:	89 34 24             	mov    %esi,(%esp)
  8020cf:	e8 20 05 00 00       	call   8025f4 <pageref>
		nn = thisenv->env_runs;
  8020d4:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  8020da:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8020dd:	83 c4 10             	add    $0x10,%esp
  8020e0:	39 cb                	cmp    %ecx,%ebx
  8020e2:	74 1b                	je     8020ff <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8020e4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020e7:	75 cf                	jne    8020b8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020e9:	8b 42 68             	mov    0x68(%edx),%eax
  8020ec:	6a 01                	push   $0x1
  8020ee:	50                   	push   %eax
  8020ef:	53                   	push   %ebx
  8020f0:	68 73 2e 80 00       	push   $0x802e73
  8020f5:	e8 25 e6 ff ff       	call   80071f <cprintf>
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	eb b9                	jmp    8020b8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8020ff:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802102:	0f 94 c0             	sete   %al
  802105:	0f b6 c0             	movzbl %al,%eax
}
  802108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80210b:	5b                   	pop    %ebx
  80210c:	5e                   	pop    %esi
  80210d:	5f                   	pop    %edi
  80210e:	5d                   	pop    %ebp
  80210f:	c3                   	ret    

00802110 <devpipe_write>:
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	57                   	push   %edi
  802114:	56                   	push   %esi
  802115:	53                   	push   %ebx
  802116:	83 ec 28             	sub    $0x28,%esp
  802119:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80211c:	56                   	push   %esi
  80211d:	e8 d1 f2 ff ff       	call   8013f3 <fd2data>
  802122:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802124:	83 c4 10             	add    $0x10,%esp
  802127:	bf 00 00 00 00       	mov    $0x0,%edi
  80212c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80212f:	75 09                	jne    80213a <devpipe_write+0x2a>
	return i;
  802131:	89 f8                	mov    %edi,%eax
  802133:	eb 23                	jmp    802158 <devpipe_write+0x48>
			sys_yield();
  802135:	e8 9c ef ff ff       	call   8010d6 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80213a:	8b 43 04             	mov    0x4(%ebx),%eax
  80213d:	8b 0b                	mov    (%ebx),%ecx
  80213f:	8d 51 20             	lea    0x20(%ecx),%edx
  802142:	39 d0                	cmp    %edx,%eax
  802144:	72 1a                	jb     802160 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802146:	89 da                	mov    %ebx,%edx
  802148:	89 f0                	mov    %esi,%eax
  80214a:	e8 5c ff ff ff       	call   8020ab <_pipeisclosed>
  80214f:	85 c0                	test   %eax,%eax
  802151:	74 e2                	je     802135 <devpipe_write+0x25>
				return 0;
  802153:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215b:	5b                   	pop    %ebx
  80215c:	5e                   	pop    %esi
  80215d:	5f                   	pop    %edi
  80215e:	5d                   	pop    %ebp
  80215f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802163:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802167:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80216a:	89 c2                	mov    %eax,%edx
  80216c:	c1 fa 1f             	sar    $0x1f,%edx
  80216f:	89 d1                	mov    %edx,%ecx
  802171:	c1 e9 1b             	shr    $0x1b,%ecx
  802174:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802177:	83 e2 1f             	and    $0x1f,%edx
  80217a:	29 ca                	sub    %ecx,%edx
  80217c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802180:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802184:	83 c0 01             	add    $0x1,%eax
  802187:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80218a:	83 c7 01             	add    $0x1,%edi
  80218d:	eb 9d                	jmp    80212c <devpipe_write+0x1c>

0080218f <devpipe_read>:
{
  80218f:	55                   	push   %ebp
  802190:	89 e5                	mov    %esp,%ebp
  802192:	57                   	push   %edi
  802193:	56                   	push   %esi
  802194:	53                   	push   %ebx
  802195:	83 ec 18             	sub    $0x18,%esp
  802198:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80219b:	57                   	push   %edi
  80219c:	e8 52 f2 ff ff       	call   8013f3 <fd2data>
  8021a1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	be 00 00 00 00       	mov    $0x0,%esi
  8021ab:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ae:	75 13                	jne    8021c3 <devpipe_read+0x34>
	return i;
  8021b0:	89 f0                	mov    %esi,%eax
  8021b2:	eb 02                	jmp    8021b6 <devpipe_read+0x27>
				return i;
  8021b4:	89 f0                	mov    %esi,%eax
}
  8021b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b9:	5b                   	pop    %ebx
  8021ba:	5e                   	pop    %esi
  8021bb:	5f                   	pop    %edi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    
			sys_yield();
  8021be:	e8 13 ef ff ff       	call   8010d6 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8021c3:	8b 03                	mov    (%ebx),%eax
  8021c5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021c8:	75 18                	jne    8021e2 <devpipe_read+0x53>
			if (i > 0)
  8021ca:	85 f6                	test   %esi,%esi
  8021cc:	75 e6                	jne    8021b4 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8021ce:	89 da                	mov    %ebx,%edx
  8021d0:	89 f8                	mov    %edi,%eax
  8021d2:	e8 d4 fe ff ff       	call   8020ab <_pipeisclosed>
  8021d7:	85 c0                	test   %eax,%eax
  8021d9:	74 e3                	je     8021be <devpipe_read+0x2f>
				return 0;
  8021db:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e0:	eb d4                	jmp    8021b6 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021e2:	99                   	cltd   
  8021e3:	c1 ea 1b             	shr    $0x1b,%edx
  8021e6:	01 d0                	add    %edx,%eax
  8021e8:	83 e0 1f             	and    $0x1f,%eax
  8021eb:	29 d0                	sub    %edx,%eax
  8021ed:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8021f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021f5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8021f8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8021fb:	83 c6 01             	add    $0x1,%esi
  8021fe:	eb ab                	jmp    8021ab <devpipe_read+0x1c>

00802200 <pipe>:
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	56                   	push   %esi
  802204:	53                   	push   %ebx
  802205:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80220b:	50                   	push   %eax
  80220c:	e8 f9 f1 ff ff       	call   80140a <fd_alloc>
  802211:	89 c3                	mov    %eax,%ebx
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	85 c0                	test   %eax,%eax
  802218:	0f 88 23 01 00 00    	js     802341 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80221e:	83 ec 04             	sub    $0x4,%esp
  802221:	68 07 04 00 00       	push   $0x407
  802226:	ff 75 f4             	push   -0xc(%ebp)
  802229:	6a 00                	push   $0x0
  80222b:	e8 c5 ee ff ff       	call   8010f5 <sys_page_alloc>
  802230:	89 c3                	mov    %eax,%ebx
  802232:	83 c4 10             	add    $0x10,%esp
  802235:	85 c0                	test   %eax,%eax
  802237:	0f 88 04 01 00 00    	js     802341 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80223d:	83 ec 0c             	sub    $0xc,%esp
  802240:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802243:	50                   	push   %eax
  802244:	e8 c1 f1 ff ff       	call   80140a <fd_alloc>
  802249:	89 c3                	mov    %eax,%ebx
  80224b:	83 c4 10             	add    $0x10,%esp
  80224e:	85 c0                	test   %eax,%eax
  802250:	0f 88 db 00 00 00    	js     802331 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802256:	83 ec 04             	sub    $0x4,%esp
  802259:	68 07 04 00 00       	push   $0x407
  80225e:	ff 75 f0             	push   -0x10(%ebp)
  802261:	6a 00                	push   $0x0
  802263:	e8 8d ee ff ff       	call   8010f5 <sys_page_alloc>
  802268:	89 c3                	mov    %eax,%ebx
  80226a:	83 c4 10             	add    $0x10,%esp
  80226d:	85 c0                	test   %eax,%eax
  80226f:	0f 88 bc 00 00 00    	js     802331 <pipe+0x131>
	va = fd2data(fd0);
  802275:	83 ec 0c             	sub    $0xc,%esp
  802278:	ff 75 f4             	push   -0xc(%ebp)
  80227b:	e8 73 f1 ff ff       	call   8013f3 <fd2data>
  802280:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802282:	83 c4 0c             	add    $0xc,%esp
  802285:	68 07 04 00 00       	push   $0x407
  80228a:	50                   	push   %eax
  80228b:	6a 00                	push   $0x0
  80228d:	e8 63 ee ff ff       	call   8010f5 <sys_page_alloc>
  802292:	89 c3                	mov    %eax,%ebx
  802294:	83 c4 10             	add    $0x10,%esp
  802297:	85 c0                	test   %eax,%eax
  802299:	0f 88 82 00 00 00    	js     802321 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80229f:	83 ec 0c             	sub    $0xc,%esp
  8022a2:	ff 75 f0             	push   -0x10(%ebp)
  8022a5:	e8 49 f1 ff ff       	call   8013f3 <fd2data>
  8022aa:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022b1:	50                   	push   %eax
  8022b2:	6a 00                	push   $0x0
  8022b4:	56                   	push   %esi
  8022b5:	6a 00                	push   $0x0
  8022b7:	e8 7c ee ff ff       	call   801138 <sys_page_map>
  8022bc:	89 c3                	mov    %eax,%ebx
  8022be:	83 c4 20             	add    $0x20,%esp
  8022c1:	85 c0                	test   %eax,%eax
  8022c3:	78 4e                	js     802313 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8022c5:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8022ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022cd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8022cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022d2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8022d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022dc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8022de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022e1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8022e8:	83 ec 0c             	sub    $0xc,%esp
  8022eb:	ff 75 f4             	push   -0xc(%ebp)
  8022ee:	e8 f0 f0 ff ff       	call   8013e3 <fd2num>
  8022f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022f6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022f8:	83 c4 04             	add    $0x4,%esp
  8022fb:	ff 75 f0             	push   -0x10(%ebp)
  8022fe:	e8 e0 f0 ff ff       	call   8013e3 <fd2num>
  802303:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802306:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802309:	83 c4 10             	add    $0x10,%esp
  80230c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802311:	eb 2e                	jmp    802341 <pipe+0x141>
	sys_page_unmap(0, va);
  802313:	83 ec 08             	sub    $0x8,%esp
  802316:	56                   	push   %esi
  802317:	6a 00                	push   $0x0
  802319:	e8 5c ee ff ff       	call   80117a <sys_page_unmap>
  80231e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802321:	83 ec 08             	sub    $0x8,%esp
  802324:	ff 75 f0             	push   -0x10(%ebp)
  802327:	6a 00                	push   $0x0
  802329:	e8 4c ee ff ff       	call   80117a <sys_page_unmap>
  80232e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802331:	83 ec 08             	sub    $0x8,%esp
  802334:	ff 75 f4             	push   -0xc(%ebp)
  802337:	6a 00                	push   $0x0
  802339:	e8 3c ee ff ff       	call   80117a <sys_page_unmap>
  80233e:	83 c4 10             	add    $0x10,%esp
}
  802341:	89 d8                	mov    %ebx,%eax
  802343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802346:	5b                   	pop    %ebx
  802347:	5e                   	pop    %esi
  802348:	5d                   	pop    %ebp
  802349:	c3                   	ret    

0080234a <pipeisclosed>:
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802353:	50                   	push   %eax
  802354:	ff 75 08             	push   0x8(%ebp)
  802357:	e8 fe f0 ff ff       	call   80145a <fd_lookup>
  80235c:	83 c4 10             	add    $0x10,%esp
  80235f:	85 c0                	test   %eax,%eax
  802361:	78 18                	js     80237b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802363:	83 ec 0c             	sub    $0xc,%esp
  802366:	ff 75 f4             	push   -0xc(%ebp)
  802369:	e8 85 f0 ff ff       	call   8013f3 <fd2data>
  80236e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802370:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802373:	e8 33 fd ff ff       	call   8020ab <_pipeisclosed>
  802378:	83 c4 10             	add    $0x10,%esp
}
  80237b:	c9                   	leave  
  80237c:	c3                   	ret    

0080237d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80237d:	b8 00 00 00 00       	mov    $0x0,%eax
  802382:	c3                   	ret    

00802383 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802389:	68 8b 2e 80 00       	push   $0x802e8b
  80238e:	ff 75 0c             	push   0xc(%ebp)
  802391:	e8 63 e9 ff ff       	call   800cf9 <strcpy>
	return 0;
}
  802396:	b8 00 00 00 00       	mov    $0x0,%eax
  80239b:	c9                   	leave  
  80239c:	c3                   	ret    

0080239d <devcons_write>:
{
  80239d:	55                   	push   %ebp
  80239e:	89 e5                	mov    %esp,%ebp
  8023a0:	57                   	push   %edi
  8023a1:	56                   	push   %esi
  8023a2:	53                   	push   %ebx
  8023a3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8023a9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023ae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8023b4:	eb 2e                	jmp    8023e4 <devcons_write+0x47>
		m = n - tot;
  8023b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023b9:	29 f3                	sub    %esi,%ebx
  8023bb:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8023c0:	39 c3                	cmp    %eax,%ebx
  8023c2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8023c5:	83 ec 04             	sub    $0x4,%esp
  8023c8:	53                   	push   %ebx
  8023c9:	89 f0                	mov    %esi,%eax
  8023cb:	03 45 0c             	add    0xc(%ebp),%eax
  8023ce:	50                   	push   %eax
  8023cf:	57                   	push   %edi
  8023d0:	e8 ba ea ff ff       	call   800e8f <memmove>
		sys_cputs(buf, m);
  8023d5:	83 c4 08             	add    $0x8,%esp
  8023d8:	53                   	push   %ebx
  8023d9:	57                   	push   %edi
  8023da:	e8 5a ec ff ff       	call   801039 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8023df:	01 de                	add    %ebx,%esi
  8023e1:	83 c4 10             	add    $0x10,%esp
  8023e4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023e7:	72 cd                	jb     8023b6 <devcons_write+0x19>
}
  8023e9:	89 f0                	mov    %esi,%eax
  8023eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023ee:	5b                   	pop    %ebx
  8023ef:	5e                   	pop    %esi
  8023f0:	5f                   	pop    %edi
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    

008023f3 <devcons_read>:
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	83 ec 08             	sub    $0x8,%esp
  8023f9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8023fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802402:	75 07                	jne    80240b <devcons_read+0x18>
  802404:	eb 1f                	jmp    802425 <devcons_read+0x32>
		sys_yield();
  802406:	e8 cb ec ff ff       	call   8010d6 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80240b:	e8 47 ec ff ff       	call   801057 <sys_cgetc>
  802410:	85 c0                	test   %eax,%eax
  802412:	74 f2                	je     802406 <devcons_read+0x13>
	if (c < 0)
  802414:	78 0f                	js     802425 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802416:	83 f8 04             	cmp    $0x4,%eax
  802419:	74 0c                	je     802427 <devcons_read+0x34>
	*(char*)vbuf = c;
  80241b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80241e:	88 02                	mov    %al,(%edx)
	return 1;
  802420:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802425:	c9                   	leave  
  802426:	c3                   	ret    
		return 0;
  802427:	b8 00 00 00 00       	mov    $0x0,%eax
  80242c:	eb f7                	jmp    802425 <devcons_read+0x32>

0080242e <cputchar>:
{
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802434:	8b 45 08             	mov    0x8(%ebp),%eax
  802437:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80243a:	6a 01                	push   $0x1
  80243c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80243f:	50                   	push   %eax
  802440:	e8 f4 eb ff ff       	call   801039 <sys_cputs>
}
  802445:	83 c4 10             	add    $0x10,%esp
  802448:	c9                   	leave  
  802449:	c3                   	ret    

0080244a <getchar>:
{
  80244a:	55                   	push   %ebp
  80244b:	89 e5                	mov    %esp,%ebp
  80244d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802450:	6a 01                	push   $0x1
  802452:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802455:	50                   	push   %eax
  802456:	6a 00                	push   $0x0
  802458:	e8 66 f2 ff ff       	call   8016c3 <read>
	if (r < 0)
  80245d:	83 c4 10             	add    $0x10,%esp
  802460:	85 c0                	test   %eax,%eax
  802462:	78 06                	js     80246a <getchar+0x20>
	if (r < 1)
  802464:	74 06                	je     80246c <getchar+0x22>
	return c;
  802466:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80246a:	c9                   	leave  
  80246b:	c3                   	ret    
		return -E_EOF;
  80246c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802471:	eb f7                	jmp    80246a <getchar+0x20>

00802473 <iscons>:
{
  802473:	55                   	push   %ebp
  802474:	89 e5                	mov    %esp,%ebp
  802476:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80247c:	50                   	push   %eax
  80247d:	ff 75 08             	push   0x8(%ebp)
  802480:	e8 d5 ef ff ff       	call   80145a <fd_lookup>
  802485:	83 c4 10             	add    $0x10,%esp
  802488:	85 c0                	test   %eax,%eax
  80248a:	78 11                	js     80249d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80248c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802495:	39 10                	cmp    %edx,(%eax)
  802497:	0f 94 c0             	sete   %al
  80249a:	0f b6 c0             	movzbl %al,%eax
}
  80249d:	c9                   	leave  
  80249e:	c3                   	ret    

0080249f <opencons>:
{
  80249f:	55                   	push   %ebp
  8024a0:	89 e5                	mov    %esp,%ebp
  8024a2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8024a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a8:	50                   	push   %eax
  8024a9:	e8 5c ef ff ff       	call   80140a <fd_alloc>
  8024ae:	83 c4 10             	add    $0x10,%esp
  8024b1:	85 c0                	test   %eax,%eax
  8024b3:	78 3a                	js     8024ef <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b5:	83 ec 04             	sub    $0x4,%esp
  8024b8:	68 07 04 00 00       	push   $0x407
  8024bd:	ff 75 f4             	push   -0xc(%ebp)
  8024c0:	6a 00                	push   $0x0
  8024c2:	e8 2e ec ff ff       	call   8010f5 <sys_page_alloc>
  8024c7:	83 c4 10             	add    $0x10,%esp
  8024ca:	85 c0                	test   %eax,%eax
  8024cc:	78 21                	js     8024ef <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8024ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024d7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024e3:	83 ec 0c             	sub    $0xc,%esp
  8024e6:	50                   	push   %eax
  8024e7:	e8 f7 ee ff ff       	call   8013e3 <fd2num>
  8024ec:	83 c4 10             	add    $0x10,%esp
}
  8024ef:	c9                   	leave  
  8024f0:	c3                   	ret    

008024f1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024f1:	55                   	push   %ebp
  8024f2:	89 e5                	mov    %esp,%ebp
  8024f4:	56                   	push   %esi
  8024f5:	53                   	push   %ebx
  8024f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8024f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8024ff:	85 c0                	test   %eax,%eax
  802501:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802506:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802509:	83 ec 0c             	sub    $0xc,%esp
  80250c:	50                   	push   %eax
  80250d:	e8 93 ed ff ff       	call   8012a5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802512:	83 c4 10             	add    $0x10,%esp
  802515:	85 f6                	test   %esi,%esi
  802517:	74 17                	je     802530 <ipc_recv+0x3f>
  802519:	ba 00 00 00 00       	mov    $0x0,%edx
  80251e:	85 c0                	test   %eax,%eax
  802520:	78 0c                	js     80252e <ipc_recv+0x3d>
  802522:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  802528:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80252e:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802530:	85 db                	test   %ebx,%ebx
  802532:	74 17                	je     80254b <ipc_recv+0x5a>
  802534:	ba 00 00 00 00       	mov    $0x0,%edx
  802539:	85 c0                	test   %eax,%eax
  80253b:	78 0c                	js     802549 <ipc_recv+0x58>
  80253d:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  802543:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802549:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80254b:	85 c0                	test   %eax,%eax
  80254d:	78 0b                	js     80255a <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  80254f:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  802554:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80255a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80255d:	5b                   	pop    %ebx
  80255e:	5e                   	pop    %esi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    

00802561 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	57                   	push   %edi
  802565:	56                   	push   %esi
  802566:	53                   	push   %ebx
  802567:	83 ec 0c             	sub    $0xc,%esp
  80256a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80256d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802570:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802573:	85 db                	test   %ebx,%ebx
  802575:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80257a:	0f 44 d8             	cmove  %eax,%ebx
  80257d:	eb 05                	jmp    802584 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80257f:	e8 52 eb ff ff       	call   8010d6 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802584:	ff 75 14             	push   0x14(%ebp)
  802587:	53                   	push   %ebx
  802588:	56                   	push   %esi
  802589:	57                   	push   %edi
  80258a:	e8 f3 ec ff ff       	call   801282 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  80258f:	83 c4 10             	add    $0x10,%esp
  802592:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802595:	74 e8                	je     80257f <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802597:	85 c0                	test   %eax,%eax
  802599:	78 08                	js     8025a3 <ipc_send+0x42>
	}while (r<0);

}
  80259b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80259e:	5b                   	pop    %ebx
  80259f:	5e                   	pop    %esi
  8025a0:	5f                   	pop    %edi
  8025a1:	5d                   	pop    %ebp
  8025a2:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8025a3:	50                   	push   %eax
  8025a4:	68 97 2e 80 00       	push   $0x802e97
  8025a9:	6a 3d                	push   $0x3d
  8025ab:	68 ab 2e 80 00       	push   $0x802eab
  8025b0:	e8 8f e0 ff ff       	call   800644 <_panic>

008025b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025b5:	55                   	push   %ebp
  8025b6:	89 e5                	mov    %esp,%ebp
  8025b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025c0:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8025c6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025cc:	8b 52 60             	mov    0x60(%edx),%edx
  8025cf:	39 ca                	cmp    %ecx,%edx
  8025d1:	74 11                	je     8025e4 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8025d3:	83 c0 01             	add    $0x1,%eax
  8025d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025db:	75 e3                	jne    8025c0 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8025dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8025e2:	eb 0e                	jmp    8025f2 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8025e4:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8025ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025ef:	8b 40 58             	mov    0x58(%eax),%eax
}
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    

008025f4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025f4:	55                   	push   %ebp
  8025f5:	89 e5                	mov    %esp,%ebp
  8025f7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025fa:	89 c2                	mov    %eax,%edx
  8025fc:	c1 ea 16             	shr    $0x16,%edx
  8025ff:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802606:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80260b:	f6 c1 01             	test   $0x1,%cl
  80260e:	74 1c                	je     80262c <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802610:	c1 e8 0c             	shr    $0xc,%eax
  802613:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80261a:	a8 01                	test   $0x1,%al
  80261c:	74 0e                	je     80262c <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80261e:	c1 e8 0c             	shr    $0xc,%eax
  802621:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802628:	ef 
  802629:	0f b7 d2             	movzwl %dx,%edx
}
  80262c:	89 d0                	mov    %edx,%eax
  80262e:	5d                   	pop    %ebp
  80262f:	c3                   	ret    

00802630 <__udivdi3>:
  802630:	f3 0f 1e fb          	endbr32 
  802634:	55                   	push   %ebp
  802635:	57                   	push   %edi
  802636:	56                   	push   %esi
  802637:	53                   	push   %ebx
  802638:	83 ec 1c             	sub    $0x1c,%esp
  80263b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80263f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802643:	8b 74 24 34          	mov    0x34(%esp),%esi
  802647:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80264b:	85 c0                	test   %eax,%eax
  80264d:	75 19                	jne    802668 <__udivdi3+0x38>
  80264f:	39 f3                	cmp    %esi,%ebx
  802651:	76 4d                	jbe    8026a0 <__udivdi3+0x70>
  802653:	31 ff                	xor    %edi,%edi
  802655:	89 e8                	mov    %ebp,%eax
  802657:	89 f2                	mov    %esi,%edx
  802659:	f7 f3                	div    %ebx
  80265b:	89 fa                	mov    %edi,%edx
  80265d:	83 c4 1c             	add    $0x1c,%esp
  802660:	5b                   	pop    %ebx
  802661:	5e                   	pop    %esi
  802662:	5f                   	pop    %edi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    
  802665:	8d 76 00             	lea    0x0(%esi),%esi
  802668:	39 f0                	cmp    %esi,%eax
  80266a:	76 14                	jbe    802680 <__udivdi3+0x50>
  80266c:	31 ff                	xor    %edi,%edi
  80266e:	31 c0                	xor    %eax,%eax
  802670:	89 fa                	mov    %edi,%edx
  802672:	83 c4 1c             	add    $0x1c,%esp
  802675:	5b                   	pop    %ebx
  802676:	5e                   	pop    %esi
  802677:	5f                   	pop    %edi
  802678:	5d                   	pop    %ebp
  802679:	c3                   	ret    
  80267a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802680:	0f bd f8             	bsr    %eax,%edi
  802683:	83 f7 1f             	xor    $0x1f,%edi
  802686:	75 48                	jne    8026d0 <__udivdi3+0xa0>
  802688:	39 f0                	cmp    %esi,%eax
  80268a:	72 06                	jb     802692 <__udivdi3+0x62>
  80268c:	31 c0                	xor    %eax,%eax
  80268e:	39 eb                	cmp    %ebp,%ebx
  802690:	77 de                	ja     802670 <__udivdi3+0x40>
  802692:	b8 01 00 00 00       	mov    $0x1,%eax
  802697:	eb d7                	jmp    802670 <__udivdi3+0x40>
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 d9                	mov    %ebx,%ecx
  8026a2:	85 db                	test   %ebx,%ebx
  8026a4:	75 0b                	jne    8026b1 <__udivdi3+0x81>
  8026a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ab:	31 d2                	xor    %edx,%edx
  8026ad:	f7 f3                	div    %ebx
  8026af:	89 c1                	mov    %eax,%ecx
  8026b1:	31 d2                	xor    %edx,%edx
  8026b3:	89 f0                	mov    %esi,%eax
  8026b5:	f7 f1                	div    %ecx
  8026b7:	89 c6                	mov    %eax,%esi
  8026b9:	89 e8                	mov    %ebp,%eax
  8026bb:	89 f7                	mov    %esi,%edi
  8026bd:	f7 f1                	div    %ecx
  8026bf:	89 fa                	mov    %edi,%edx
  8026c1:	83 c4 1c             	add    $0x1c,%esp
  8026c4:	5b                   	pop    %ebx
  8026c5:	5e                   	pop    %esi
  8026c6:	5f                   	pop    %edi
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    
  8026c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	89 f9                	mov    %edi,%ecx
  8026d2:	ba 20 00 00 00       	mov    $0x20,%edx
  8026d7:	29 fa                	sub    %edi,%edx
  8026d9:	d3 e0                	shl    %cl,%eax
  8026db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026df:	89 d1                	mov    %edx,%ecx
  8026e1:	89 d8                	mov    %ebx,%eax
  8026e3:	d3 e8                	shr    %cl,%eax
  8026e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026e9:	09 c1                	or     %eax,%ecx
  8026eb:	89 f0                	mov    %esi,%eax
  8026ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026f1:	89 f9                	mov    %edi,%ecx
  8026f3:	d3 e3                	shl    %cl,%ebx
  8026f5:	89 d1                	mov    %edx,%ecx
  8026f7:	d3 e8                	shr    %cl,%eax
  8026f9:	89 f9                	mov    %edi,%ecx
  8026fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026ff:	89 eb                	mov    %ebp,%ebx
  802701:	d3 e6                	shl    %cl,%esi
  802703:	89 d1                	mov    %edx,%ecx
  802705:	d3 eb                	shr    %cl,%ebx
  802707:	09 f3                	or     %esi,%ebx
  802709:	89 c6                	mov    %eax,%esi
  80270b:	89 f2                	mov    %esi,%edx
  80270d:	89 d8                	mov    %ebx,%eax
  80270f:	f7 74 24 08          	divl   0x8(%esp)
  802713:	89 d6                	mov    %edx,%esi
  802715:	89 c3                	mov    %eax,%ebx
  802717:	f7 64 24 0c          	mull   0xc(%esp)
  80271b:	39 d6                	cmp    %edx,%esi
  80271d:	72 19                	jb     802738 <__udivdi3+0x108>
  80271f:	89 f9                	mov    %edi,%ecx
  802721:	d3 e5                	shl    %cl,%ebp
  802723:	39 c5                	cmp    %eax,%ebp
  802725:	73 04                	jae    80272b <__udivdi3+0xfb>
  802727:	39 d6                	cmp    %edx,%esi
  802729:	74 0d                	je     802738 <__udivdi3+0x108>
  80272b:	89 d8                	mov    %ebx,%eax
  80272d:	31 ff                	xor    %edi,%edi
  80272f:	e9 3c ff ff ff       	jmp    802670 <__udivdi3+0x40>
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80273b:	31 ff                	xor    %edi,%edi
  80273d:	e9 2e ff ff ff       	jmp    802670 <__udivdi3+0x40>
  802742:	66 90                	xchg   %ax,%ax
  802744:	66 90                	xchg   %ax,%ax
  802746:	66 90                	xchg   %ax,%ax
  802748:	66 90                	xchg   %ax,%ax
  80274a:	66 90                	xchg   %ax,%ax
  80274c:	66 90                	xchg   %ax,%ax
  80274e:	66 90                	xchg   %ax,%ax

00802750 <__umoddi3>:
  802750:	f3 0f 1e fb          	endbr32 
  802754:	55                   	push   %ebp
  802755:	57                   	push   %edi
  802756:	56                   	push   %esi
  802757:	53                   	push   %ebx
  802758:	83 ec 1c             	sub    $0x1c,%esp
  80275b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80275f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802763:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802767:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80276b:	89 f0                	mov    %esi,%eax
  80276d:	89 da                	mov    %ebx,%edx
  80276f:	85 ff                	test   %edi,%edi
  802771:	75 15                	jne    802788 <__umoddi3+0x38>
  802773:	39 dd                	cmp    %ebx,%ebp
  802775:	76 39                	jbe    8027b0 <__umoddi3+0x60>
  802777:	f7 f5                	div    %ebp
  802779:	89 d0                	mov    %edx,%eax
  80277b:	31 d2                	xor    %edx,%edx
  80277d:	83 c4 1c             	add    $0x1c,%esp
  802780:	5b                   	pop    %ebx
  802781:	5e                   	pop    %esi
  802782:	5f                   	pop    %edi
  802783:	5d                   	pop    %ebp
  802784:	c3                   	ret    
  802785:	8d 76 00             	lea    0x0(%esi),%esi
  802788:	39 df                	cmp    %ebx,%edi
  80278a:	77 f1                	ja     80277d <__umoddi3+0x2d>
  80278c:	0f bd cf             	bsr    %edi,%ecx
  80278f:	83 f1 1f             	xor    $0x1f,%ecx
  802792:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802796:	75 40                	jne    8027d8 <__umoddi3+0x88>
  802798:	39 df                	cmp    %ebx,%edi
  80279a:	72 04                	jb     8027a0 <__umoddi3+0x50>
  80279c:	39 f5                	cmp    %esi,%ebp
  80279e:	77 dd                	ja     80277d <__umoddi3+0x2d>
  8027a0:	89 da                	mov    %ebx,%edx
  8027a2:	89 f0                	mov    %esi,%eax
  8027a4:	29 e8                	sub    %ebp,%eax
  8027a6:	19 fa                	sbb    %edi,%edx
  8027a8:	eb d3                	jmp    80277d <__umoddi3+0x2d>
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	89 e9                	mov    %ebp,%ecx
  8027b2:	85 ed                	test   %ebp,%ebp
  8027b4:	75 0b                	jne    8027c1 <__umoddi3+0x71>
  8027b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027bb:	31 d2                	xor    %edx,%edx
  8027bd:	f7 f5                	div    %ebp
  8027bf:	89 c1                	mov    %eax,%ecx
  8027c1:	89 d8                	mov    %ebx,%eax
  8027c3:	31 d2                	xor    %edx,%edx
  8027c5:	f7 f1                	div    %ecx
  8027c7:	89 f0                	mov    %esi,%eax
  8027c9:	f7 f1                	div    %ecx
  8027cb:	89 d0                	mov    %edx,%eax
  8027cd:	31 d2                	xor    %edx,%edx
  8027cf:	eb ac                	jmp    80277d <__umoddi3+0x2d>
  8027d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027dc:	ba 20 00 00 00       	mov    $0x20,%edx
  8027e1:	29 c2                	sub    %eax,%edx
  8027e3:	89 c1                	mov    %eax,%ecx
  8027e5:	89 e8                	mov    %ebp,%eax
  8027e7:	d3 e7                	shl    %cl,%edi
  8027e9:	89 d1                	mov    %edx,%ecx
  8027eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027ef:	d3 e8                	shr    %cl,%eax
  8027f1:	89 c1                	mov    %eax,%ecx
  8027f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027f7:	09 f9                	or     %edi,%ecx
  8027f9:	89 df                	mov    %ebx,%edi
  8027fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ff:	89 c1                	mov    %eax,%ecx
  802801:	d3 e5                	shl    %cl,%ebp
  802803:	89 d1                	mov    %edx,%ecx
  802805:	d3 ef                	shr    %cl,%edi
  802807:	89 c1                	mov    %eax,%ecx
  802809:	89 f0                	mov    %esi,%eax
  80280b:	d3 e3                	shl    %cl,%ebx
  80280d:	89 d1                	mov    %edx,%ecx
  80280f:	89 fa                	mov    %edi,%edx
  802811:	d3 e8                	shr    %cl,%eax
  802813:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802818:	09 d8                	or     %ebx,%eax
  80281a:	f7 74 24 08          	divl   0x8(%esp)
  80281e:	89 d3                	mov    %edx,%ebx
  802820:	d3 e6                	shl    %cl,%esi
  802822:	f7 e5                	mul    %ebp
  802824:	89 c7                	mov    %eax,%edi
  802826:	89 d1                	mov    %edx,%ecx
  802828:	39 d3                	cmp    %edx,%ebx
  80282a:	72 06                	jb     802832 <__umoddi3+0xe2>
  80282c:	75 0e                	jne    80283c <__umoddi3+0xec>
  80282e:	39 c6                	cmp    %eax,%esi
  802830:	73 0a                	jae    80283c <__umoddi3+0xec>
  802832:	29 e8                	sub    %ebp,%eax
  802834:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802838:	89 d1                	mov    %edx,%ecx
  80283a:	89 c7                	mov    %eax,%edi
  80283c:	89 f5                	mov    %esi,%ebp
  80283e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802842:	29 fd                	sub    %edi,%ebp
  802844:	19 cb                	sbb    %ecx,%ebx
  802846:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80284b:	89 d8                	mov    %ebx,%eax
  80284d:	d3 e0                	shl    %cl,%eax
  80284f:	89 f1                	mov    %esi,%ecx
  802851:	d3 ed                	shr    %cl,%ebp
  802853:	d3 eb                	shr    %cl,%ebx
  802855:	09 e8                	or     %ebp,%eax
  802857:	89 da                	mov    %ebx,%edx
  802859:	83 c4 1c             	add    $0x1c,%esp
  80285c:	5b                   	pop    %ebx
  80285d:	5e                   	pop    %esi
  80285e:	5f                   	pop    %edi
  80285f:	5d                   	pop    %ebp
  802860:	c3                   	ret    
