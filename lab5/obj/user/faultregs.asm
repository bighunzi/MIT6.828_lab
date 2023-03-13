
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
  800044:	68 d1 23 80 00       	push   $0x8023d1
  800049:	68 a0 23 80 00       	push   $0x8023a0
  80004e:	e8 c9 06 00 00       	call   80071c <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	push   (%ebx)
  800055:	ff 36                	push   (%esi)
  800057:	68 b0 23 80 00       	push   $0x8023b0
  80005c:	68 b4 23 80 00       	push   $0x8023b4
  800061:	e8 b6 06 00 00       	call   80071c <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 c8 23 80 00       	push   $0x8023c8
  80007b:	e8 9c 06 00 00       	call   80071c <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	push   0x4(%ebx)
  80008b:	ff 76 04             	push   0x4(%esi)
  80008e:	68 d2 23 80 00       	push   $0x8023d2
  800093:	68 b4 23 80 00       	push   $0x8023b4
  800098:	e8 7f 06 00 00       	call   80071c <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 c8 23 80 00       	push   $0x8023c8
  8000b4:	e8 63 06 00 00       	call   80071c <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	push   0x8(%ebx)
  8000c4:	ff 76 08             	push   0x8(%esi)
  8000c7:	68 d6 23 80 00       	push   $0x8023d6
  8000cc:	68 b4 23 80 00       	push   $0x8023b4
  8000d1:	e8 46 06 00 00       	call   80071c <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 c8 23 80 00       	push   $0x8023c8
  8000ed:	e8 2a 06 00 00       	call   80071c <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	push   0x10(%ebx)
  8000fd:	ff 76 10             	push   0x10(%esi)
  800100:	68 da 23 80 00       	push   $0x8023da
  800105:	68 b4 23 80 00       	push   $0x8023b4
  80010a:	e8 0d 06 00 00       	call   80071c <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 c8 23 80 00       	push   $0x8023c8
  800126:	e8 f1 05 00 00       	call   80071c <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	push   0x14(%ebx)
  800136:	ff 76 14             	push   0x14(%esi)
  800139:	68 de 23 80 00       	push   $0x8023de
  80013e:	68 b4 23 80 00       	push   $0x8023b4
  800143:	e8 d4 05 00 00       	call   80071c <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 c8 23 80 00       	push   $0x8023c8
  80015f:	e8 b8 05 00 00       	call   80071c <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	push   0x18(%ebx)
  80016f:	ff 76 18             	push   0x18(%esi)
  800172:	68 e2 23 80 00       	push   $0x8023e2
  800177:	68 b4 23 80 00       	push   $0x8023b4
  80017c:	e8 9b 05 00 00       	call   80071c <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 c8 23 80 00       	push   $0x8023c8
  800198:	e8 7f 05 00 00       	call   80071c <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	push   0x1c(%ebx)
  8001a8:	ff 76 1c             	push   0x1c(%esi)
  8001ab:	68 e6 23 80 00       	push   $0x8023e6
  8001b0:	68 b4 23 80 00       	push   $0x8023b4
  8001b5:	e8 62 05 00 00       	call   80071c <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 c8 23 80 00       	push   $0x8023c8
  8001d1:	e8 46 05 00 00       	call   80071c <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	push   0x20(%ebx)
  8001e1:	ff 76 20             	push   0x20(%esi)
  8001e4:	68 ea 23 80 00       	push   $0x8023ea
  8001e9:	68 b4 23 80 00       	push   $0x8023b4
  8001ee:	e8 29 05 00 00       	call   80071c <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 c8 23 80 00       	push   $0x8023c8
  80020a:	e8 0d 05 00 00       	call   80071c <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	push   0x24(%ebx)
  80021a:	ff 76 24             	push   0x24(%esi)
  80021d:	68 ee 23 80 00       	push   $0x8023ee
  800222:	68 b4 23 80 00       	push   $0x8023b4
  800227:	e8 f0 04 00 00       	call   80071c <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 c8 23 80 00       	push   $0x8023c8
  800243:	e8 d4 04 00 00       	call   80071c <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	push   0x28(%ebx)
  80024b:	ff 76 28             	push   0x28(%esi)
  80024e:	68 f5 23 80 00       	push   $0x8023f5
  800253:	68 b4 23 80 00       	push   $0x8023b4
  800258:	e8 bf 04 00 00       	call   80071c <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 c8 23 80 00       	push   $0x8023c8
  800274:	e8 a3 04 00 00       	call   80071c <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	push   0xc(%ebp)
  80027f:	68 f9 23 80 00       	push   $0x8023f9
  800284:	e8 93 04 00 00       	call   80071c <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 c8 23 80 00       	push   $0x8023c8
  800294:	e8 83 04 00 00       	call   80071c <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 c4 23 80 00       	push   $0x8023c4
  8002a9:	e8 6e 04 00 00       	call   80071c <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 c4 23 80 00       	push   $0x8023c4
  8002c3:	e8 54 04 00 00       	call   80071c <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 c4 23 80 00       	push   $0x8023c4
  8002d8:	e8 3f 04 00 00       	call   80071c <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 c4 23 80 00       	push   $0x8023c4
  8002ed:	e8 2a 04 00 00       	call   80071c <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 c4 23 80 00       	push   $0x8023c4
  800302:	e8 15 04 00 00       	call   80071c <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 c4 23 80 00       	push   $0x8023c4
  800317:	e8 00 04 00 00       	call   80071c <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 c4 23 80 00       	push   $0x8023c4
  80032c:	e8 eb 03 00 00       	call   80071c <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 c4 23 80 00       	push   $0x8023c4
  800341:	e8 d6 03 00 00       	call   80071c <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 c4 23 80 00       	push   $0x8023c4
  800356:	e8 c1 03 00 00       	call   80071c <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	push   0x28(%ebx)
  80035e:	ff 76 28             	push   0x28(%esi)
  800361:	68 f5 23 80 00       	push   $0x8023f5
  800366:	68 b4 23 80 00       	push   $0x8023b4
  80036b:	e8 ac 03 00 00       	call   80071c <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 c4 23 80 00       	push   $0x8023c4
  800387:	e8 90 03 00 00       	call   80071c <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	push   0xc(%ebp)
  800392:	68 f9 23 80 00       	push   $0x8023f9
  800397:	e8 80 03 00 00       	call   80071c <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 c4 23 80 00       	push   $0x8023c4
  8003af:	e8 68 03 00 00       	call   80071c <cprintf>
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
  8003c2:	68 c4 23 80 00       	push   $0x8023c4
  8003c7:	e8 50 03 00 00       	call   80071c <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	push   0xc(%ebp)
  8003d2:	68 f9 23 80 00       	push   $0x8023f9
  8003d7:	e8 40 03 00 00       	call   80071c <cprintf>
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
  800466:	68 1f 24 80 00       	push   $0x80241f
  80046b:	68 2d 24 80 00       	push   $0x80242d
  800470:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800475:	ba 18 24 80 00       	mov    $0x802418,%edx
  80047a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 5d 0c 00 00       	call   8010f2 <sys_page_alloc>
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
  8004a5:	68 60 24 80 00       	push   $0x802460
  8004aa:	6a 50                	push   $0x50
  8004ac:	68 07 24 80 00       	push   $0x802407
  8004b1:	e8 8b 01 00 00       	call   800641 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 34 24 80 00       	push   $0x802434
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 07 24 80 00       	push   $0x802407
  8004c3:	e8 79 01 00 00       	call   800641 <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 0b 0e 00 00       	call   8012e3 <set_pgfault_handler>

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
  8005ac:	68 47 24 80 00       	push   $0x802447
  8005b1:	68 58 24 80 00       	push   $0x802458
  8005b6:	b9 00 40 80 00       	mov    $0x804000,%ecx
  8005bb:	ba 18 24 80 00       	mov    $0x802418,%edx
  8005c0:	b8 80 40 80 00       	mov    $0x804080,%eax
  8005c5:	e8 69 fa ff ff       	call   800033 <check_regs>
}
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 94 24 80 00       	push   $0x802494
  8005d7:	e8 40 01 00 00       	call   80071c <cprintf>
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
  8005ec:	e8 c3 0a 00 00       	call   8010b4 <sys_getenvid>
  8005f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005fe:	a3 ac 40 80 00       	mov    %eax,0x8040ac

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800603:	85 db                	test   %ebx,%ebx
  800605:	7e 07                	jle    80060e <libmain+0x2d>
		binaryname = argv[0];
  800607:	8b 06                	mov    (%esi),%eax
  800609:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	56                   	push   %esi
  800612:	53                   	push   %ebx
  800613:	e8 b0 fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  800618:	e8 0a 00 00 00       	call   800627 <exit>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80062d:	e8 19 0f 00 00       	call   80154b <close_all>
	sys_env_destroy(0);
  800632:	83 ec 0c             	sub    $0xc,%esp
  800635:	6a 00                	push   $0x0
  800637:	e8 37 0a 00 00       	call   801073 <sys_env_destroy>
}
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	c9                   	leave  
  800640:	c3                   	ret    

00800641 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
  800644:	56                   	push   %esi
  800645:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800646:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800649:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80064f:	e8 60 0a 00 00       	call   8010b4 <sys_getenvid>
  800654:	83 ec 0c             	sub    $0xc,%esp
  800657:	ff 75 0c             	push   0xc(%ebp)
  80065a:	ff 75 08             	push   0x8(%ebp)
  80065d:	56                   	push   %esi
  80065e:	50                   	push   %eax
  80065f:	68 c0 24 80 00       	push   $0x8024c0
  800664:	e8 b3 00 00 00       	call   80071c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800669:	83 c4 18             	add    $0x18,%esp
  80066c:	53                   	push   %ebx
  80066d:	ff 75 10             	push   0x10(%ebp)
  800670:	e8 56 00 00 00       	call   8006cb <vcprintf>
	cprintf("\n");
  800675:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  80067c:	e8 9b 00 00 00       	call   80071c <cprintf>
  800681:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800684:	cc                   	int3   
  800685:	eb fd                	jmp    800684 <_panic+0x43>

00800687 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	53                   	push   %ebx
  80068b:	83 ec 04             	sub    $0x4,%esp
  80068e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800691:	8b 13                	mov    (%ebx),%edx
  800693:	8d 42 01             	lea    0x1(%edx),%eax
  800696:	89 03                	mov    %eax,(%ebx)
  800698:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80069b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80069f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006a4:	74 09                	je     8006af <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006a6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	68 ff 00 00 00       	push   $0xff
  8006b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8006ba:	50                   	push   %eax
  8006bb:	e8 76 09 00 00       	call   801036 <sys_cputs>
		b->idx = 0;
  8006c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb db                	jmp    8006a6 <putch+0x1f>

008006cb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006db:	00 00 00 
	b.cnt = 0;
  8006de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e8:	ff 75 0c             	push   0xc(%ebp)
  8006eb:	ff 75 08             	push   0x8(%ebp)
  8006ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006f4:	50                   	push   %eax
  8006f5:	68 87 06 80 00       	push   $0x800687
  8006fa:	e8 14 01 00 00       	call   800813 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ff:	83 c4 08             	add    $0x8,%esp
  800702:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800708:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	e8 22 09 00 00       	call   801036 <sys_cputs>

	return b.cnt;
}
  800714:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800722:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800725:	50                   	push   %eax
  800726:	ff 75 08             	push   0x8(%ebp)
  800729:	e8 9d ff ff ff       	call   8006cb <vcprintf>
	va_end(ap);

	return cnt;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	57                   	push   %edi
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	83 ec 1c             	sub    $0x1c,%esp
  800739:	89 c7                	mov    %eax,%edi
  80073b:	89 d6                	mov    %edx,%esi
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
  800743:	89 d1                	mov    %edx,%ecx
  800745:	89 c2                	mov    %eax,%edx
  800747:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80074d:	8b 45 10             	mov    0x10(%ebp),%eax
  800750:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800753:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800756:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80075d:	39 c2                	cmp    %eax,%edx
  80075f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800762:	72 3e                	jb     8007a2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800764:	83 ec 0c             	sub    $0xc,%esp
  800767:	ff 75 18             	push   0x18(%ebp)
  80076a:	83 eb 01             	sub    $0x1,%ebx
  80076d:	53                   	push   %ebx
  80076e:	50                   	push   %eax
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	ff 75 e4             	push   -0x1c(%ebp)
  800775:	ff 75 e0             	push   -0x20(%ebp)
  800778:	ff 75 dc             	push   -0x24(%ebp)
  80077b:	ff 75 d8             	push   -0x28(%ebp)
  80077e:	e8 cd 19 00 00       	call   802150 <__udivdi3>
  800783:	83 c4 18             	add    $0x18,%esp
  800786:	52                   	push   %edx
  800787:	50                   	push   %eax
  800788:	89 f2                	mov    %esi,%edx
  80078a:	89 f8                	mov    %edi,%eax
  80078c:	e8 9f ff ff ff       	call   800730 <printnum>
  800791:	83 c4 20             	add    $0x20,%esp
  800794:	eb 13                	jmp    8007a9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	56                   	push   %esi
  80079a:	ff 75 18             	push   0x18(%ebp)
  80079d:	ff d7                	call   *%edi
  80079f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007a2:	83 eb 01             	sub    $0x1,%ebx
  8007a5:	85 db                	test   %ebx,%ebx
  8007a7:	7f ed                	jg     800796 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	56                   	push   %esi
  8007ad:	83 ec 04             	sub    $0x4,%esp
  8007b0:	ff 75 e4             	push   -0x1c(%ebp)
  8007b3:	ff 75 e0             	push   -0x20(%ebp)
  8007b6:	ff 75 dc             	push   -0x24(%ebp)
  8007b9:	ff 75 d8             	push   -0x28(%ebp)
  8007bc:	e8 af 1a 00 00       	call   802270 <__umoddi3>
  8007c1:	83 c4 14             	add    $0x14,%esp
  8007c4:	0f be 80 e3 24 80 00 	movsbl 0x8024e3(%eax),%eax
  8007cb:	50                   	push   %eax
  8007cc:	ff d7                	call   *%edi
}
  8007ce:	83 c4 10             	add    $0x10,%esp
  8007d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007d4:	5b                   	pop    %ebx
  8007d5:	5e                   	pop    %esi
  8007d6:	5f                   	pop    %edi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007df:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007e3:	8b 10                	mov    (%eax),%edx
  8007e5:	3b 50 04             	cmp    0x4(%eax),%edx
  8007e8:	73 0a                	jae    8007f4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007ea:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007ed:	89 08                	mov    %ecx,(%eax)
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	88 02                	mov    %al,(%edx)
}
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <printfmt>:
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8007fc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ff:	50                   	push   %eax
  800800:	ff 75 10             	push   0x10(%ebp)
  800803:	ff 75 0c             	push   0xc(%ebp)
  800806:	ff 75 08             	push   0x8(%ebp)
  800809:	e8 05 00 00 00       	call   800813 <vprintfmt>
}
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <vprintfmt>:
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	57                   	push   %edi
  800817:	56                   	push   %esi
  800818:	53                   	push   %ebx
  800819:	83 ec 3c             	sub    $0x3c,%esp
  80081c:	8b 75 08             	mov    0x8(%ebp),%esi
  80081f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800822:	8b 7d 10             	mov    0x10(%ebp),%edi
  800825:	eb 0a                	jmp    800831 <vprintfmt+0x1e>
			putch(ch, putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	53                   	push   %ebx
  80082b:	50                   	push   %eax
  80082c:	ff d6                	call   *%esi
  80082e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800831:	83 c7 01             	add    $0x1,%edi
  800834:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800838:	83 f8 25             	cmp    $0x25,%eax
  80083b:	74 0c                	je     800849 <vprintfmt+0x36>
			if (ch == '\0')
  80083d:	85 c0                	test   %eax,%eax
  80083f:	75 e6                	jne    800827 <vprintfmt+0x14>
}
  800841:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5f                   	pop    %edi
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    
		padc = ' ';
  800849:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80084d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800854:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80085b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800862:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800867:	8d 47 01             	lea    0x1(%edi),%eax
  80086a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80086d:	0f b6 17             	movzbl (%edi),%edx
  800870:	8d 42 dd             	lea    -0x23(%edx),%eax
  800873:	3c 55                	cmp    $0x55,%al
  800875:	0f 87 bb 03 00 00    	ja     800c36 <vprintfmt+0x423>
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  800885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800888:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80088c:	eb d9                	jmp    800867 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800891:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800895:	eb d0                	jmp    800867 <vprintfmt+0x54>
  800897:	0f b6 d2             	movzbl %dl,%edx
  80089a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008a5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008a8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008ac:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008af:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008b2:	83 f9 09             	cmp    $0x9,%ecx
  8008b5:	77 55                	ja     80090c <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8008b7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008ba:	eb e9                	jmp    8008a5 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8b 00                	mov    (%eax),%eax
  8008c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ca:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008d4:	79 91                	jns    800867 <vprintfmt+0x54>
				width = precision, precision = -1;
  8008d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008dc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008e3:	eb 82                	jmp    800867 <vprintfmt+0x54>
  8008e5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008e8:	85 d2                	test   %edx,%edx
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	0f 49 c2             	cmovns %edx,%eax
  8008f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8008f8:	e9 6a ff ff ff       	jmp    800867 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8008fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800900:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800907:	e9 5b ff ff ff       	jmp    800867 <vprintfmt+0x54>
  80090c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80090f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800912:	eb bc                	jmp    8008d0 <vprintfmt+0xbd>
			lflag++;
  800914:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800917:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80091a:	e9 48 ff ff ff       	jmp    800867 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8d 78 04             	lea    0x4(%eax),%edi
  800925:	83 ec 08             	sub    $0x8,%esp
  800928:	53                   	push   %ebx
  800929:	ff 30                	push   (%eax)
  80092b:	ff d6                	call   *%esi
			break;
  80092d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800930:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800933:	e9 9d 02 00 00       	jmp    800bd5 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800938:	8b 45 14             	mov    0x14(%ebp),%eax
  80093b:	8d 78 04             	lea    0x4(%eax),%edi
  80093e:	8b 10                	mov    (%eax),%edx
  800940:	89 d0                	mov    %edx,%eax
  800942:	f7 d8                	neg    %eax
  800944:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800947:	83 f8 0f             	cmp    $0xf,%eax
  80094a:	7f 23                	jg     80096f <vprintfmt+0x15c>
  80094c:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800953:	85 d2                	test   %edx,%edx
  800955:	74 18                	je     80096f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800957:	52                   	push   %edx
  800958:	68 35 29 80 00       	push   $0x802935
  80095d:	53                   	push   %ebx
  80095e:	56                   	push   %esi
  80095f:	e8 92 fe ff ff       	call   8007f6 <printfmt>
  800964:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800967:	89 7d 14             	mov    %edi,0x14(%ebp)
  80096a:	e9 66 02 00 00       	jmp    800bd5 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80096f:	50                   	push   %eax
  800970:	68 fb 24 80 00       	push   $0x8024fb
  800975:	53                   	push   %ebx
  800976:	56                   	push   %esi
  800977:	e8 7a fe ff ff       	call   8007f6 <printfmt>
  80097c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80097f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800982:	e9 4e 02 00 00       	jmp    800bd5 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800987:	8b 45 14             	mov    0x14(%ebp),%eax
  80098a:	83 c0 04             	add    $0x4,%eax
  80098d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800990:	8b 45 14             	mov    0x14(%ebp),%eax
  800993:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800995:	85 d2                	test   %edx,%edx
  800997:	b8 f4 24 80 00       	mov    $0x8024f4,%eax
  80099c:	0f 45 c2             	cmovne %edx,%eax
  80099f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009a6:	7e 06                	jle    8009ae <vprintfmt+0x19b>
  8009a8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009ac:	75 0d                	jne    8009bb <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ae:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	03 45 e0             	add    -0x20(%ebp),%eax
  8009b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b9:	eb 55                	jmp    800a10 <vprintfmt+0x1fd>
  8009bb:	83 ec 08             	sub    $0x8,%esp
  8009be:	ff 75 d8             	push   -0x28(%ebp)
  8009c1:	ff 75 cc             	push   -0x34(%ebp)
  8009c4:	e8 0a 03 00 00       	call   800cd3 <strnlen>
  8009c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009cc:	29 c1                	sub    %eax,%ecx
  8009ce:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8009d1:	83 c4 10             	add    $0x10,%esp
  8009d4:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8009d6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009da:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009dd:	eb 0f                	jmp    8009ee <vprintfmt+0x1db>
					putch(padc, putdat);
  8009df:	83 ec 08             	sub    $0x8,%esp
  8009e2:	53                   	push   %ebx
  8009e3:	ff 75 e0             	push   -0x20(%ebp)
  8009e6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e8:	83 ef 01             	sub    $0x1,%edi
  8009eb:	83 c4 10             	add    $0x10,%esp
  8009ee:	85 ff                	test   %edi,%edi
  8009f0:	7f ed                	jg     8009df <vprintfmt+0x1cc>
  8009f2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009f5:	85 d2                	test   %edx,%edx
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	0f 49 c2             	cmovns %edx,%eax
  8009ff:	29 c2                	sub    %eax,%edx
  800a01:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a04:	eb a8                	jmp    8009ae <vprintfmt+0x19b>
					putch(ch, putdat);
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	53                   	push   %ebx
  800a0a:	52                   	push   %edx
  800a0b:	ff d6                	call   *%esi
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a13:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a15:	83 c7 01             	add    $0x1,%edi
  800a18:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a1c:	0f be d0             	movsbl %al,%edx
  800a1f:	85 d2                	test   %edx,%edx
  800a21:	74 4b                	je     800a6e <vprintfmt+0x25b>
  800a23:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a27:	78 06                	js     800a2f <vprintfmt+0x21c>
  800a29:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a2d:	78 1e                	js     800a4d <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800a2f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a33:	74 d1                	je     800a06 <vprintfmt+0x1f3>
  800a35:	0f be c0             	movsbl %al,%eax
  800a38:	83 e8 20             	sub    $0x20,%eax
  800a3b:	83 f8 5e             	cmp    $0x5e,%eax
  800a3e:	76 c6                	jbe    800a06 <vprintfmt+0x1f3>
					putch('?', putdat);
  800a40:	83 ec 08             	sub    $0x8,%esp
  800a43:	53                   	push   %ebx
  800a44:	6a 3f                	push   $0x3f
  800a46:	ff d6                	call   *%esi
  800a48:	83 c4 10             	add    $0x10,%esp
  800a4b:	eb c3                	jmp    800a10 <vprintfmt+0x1fd>
  800a4d:	89 cf                	mov    %ecx,%edi
  800a4f:	eb 0e                	jmp    800a5f <vprintfmt+0x24c>
				putch(' ', putdat);
  800a51:	83 ec 08             	sub    $0x8,%esp
  800a54:	53                   	push   %ebx
  800a55:	6a 20                	push   $0x20
  800a57:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a59:	83 ef 01             	sub    $0x1,%edi
  800a5c:	83 c4 10             	add    $0x10,%esp
  800a5f:	85 ff                	test   %edi,%edi
  800a61:	7f ee                	jg     800a51 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800a63:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a66:	89 45 14             	mov    %eax,0x14(%ebp)
  800a69:	e9 67 01 00 00       	jmp    800bd5 <vprintfmt+0x3c2>
  800a6e:	89 cf                	mov    %ecx,%edi
  800a70:	eb ed                	jmp    800a5f <vprintfmt+0x24c>
	if (lflag >= 2)
  800a72:	83 f9 01             	cmp    $0x1,%ecx
  800a75:	7f 1b                	jg     800a92 <vprintfmt+0x27f>
	else if (lflag)
  800a77:	85 c9                	test   %ecx,%ecx
  800a79:	74 63                	je     800ade <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7e:	8b 00                	mov    (%eax),%eax
  800a80:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a83:	99                   	cltd   
  800a84:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a87:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8a:	8d 40 04             	lea    0x4(%eax),%eax
  800a8d:	89 45 14             	mov    %eax,0x14(%ebp)
  800a90:	eb 17                	jmp    800aa9 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800a92:	8b 45 14             	mov    0x14(%ebp),%eax
  800a95:	8b 50 04             	mov    0x4(%eax),%edx
  800a98:	8b 00                	mov    (%eax),%eax
  800a9a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8d 40 08             	lea    0x8(%eax),%eax
  800aa6:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800aa9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800aaf:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800ab4:	85 c9                	test   %ecx,%ecx
  800ab6:	0f 89 ff 00 00 00    	jns    800bbb <vprintfmt+0x3a8>
				putch('-', putdat);
  800abc:	83 ec 08             	sub    $0x8,%esp
  800abf:	53                   	push   %ebx
  800ac0:	6a 2d                	push   $0x2d
  800ac2:	ff d6                	call   *%esi
				num = -(long long) num;
  800ac4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ac7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800aca:	f7 da                	neg    %edx
  800acc:	83 d1 00             	adc    $0x0,%ecx
  800acf:	f7 d9                	neg    %ecx
  800ad1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ad4:	bf 0a 00 00 00       	mov    $0xa,%edi
  800ad9:	e9 dd 00 00 00       	jmp    800bbb <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800ade:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae1:	8b 00                	mov    (%eax),%eax
  800ae3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae6:	99                   	cltd   
  800ae7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aea:	8b 45 14             	mov    0x14(%ebp),%eax
  800aed:	8d 40 04             	lea    0x4(%eax),%eax
  800af0:	89 45 14             	mov    %eax,0x14(%ebp)
  800af3:	eb b4                	jmp    800aa9 <vprintfmt+0x296>
	if (lflag >= 2)
  800af5:	83 f9 01             	cmp    $0x1,%ecx
  800af8:	7f 1e                	jg     800b18 <vprintfmt+0x305>
	else if (lflag)
  800afa:	85 c9                	test   %ecx,%ecx
  800afc:	74 32                	je     800b30 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800afe:	8b 45 14             	mov    0x14(%ebp),%eax
  800b01:	8b 10                	mov    (%eax),%edx
  800b03:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b08:	8d 40 04             	lea    0x4(%eax),%eax
  800b0b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b0e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800b13:	e9 a3 00 00 00       	jmp    800bbb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800b18:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1b:	8b 10                	mov    (%eax),%edx
  800b1d:	8b 48 04             	mov    0x4(%eax),%ecx
  800b20:	8d 40 08             	lea    0x8(%eax),%eax
  800b23:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b26:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800b2b:	e9 8b 00 00 00       	jmp    800bbb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800b30:	8b 45 14             	mov    0x14(%ebp),%eax
  800b33:	8b 10                	mov    (%eax),%edx
  800b35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3a:	8d 40 04             	lea    0x4(%eax),%eax
  800b3d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b40:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800b45:	eb 74                	jmp    800bbb <vprintfmt+0x3a8>
	if (lflag >= 2)
  800b47:	83 f9 01             	cmp    $0x1,%ecx
  800b4a:	7f 1b                	jg     800b67 <vprintfmt+0x354>
	else if (lflag)
  800b4c:	85 c9                	test   %ecx,%ecx
  800b4e:	74 2c                	je     800b7c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800b50:	8b 45 14             	mov    0x14(%ebp),%eax
  800b53:	8b 10                	mov    (%eax),%edx
  800b55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5a:	8d 40 04             	lea    0x4(%eax),%eax
  800b5d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b60:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800b65:	eb 54                	jmp    800bbb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800b67:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6a:	8b 10                	mov    (%eax),%edx
  800b6c:	8b 48 04             	mov    0x4(%eax),%ecx
  800b6f:	8d 40 08             	lea    0x8(%eax),%eax
  800b72:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b75:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800b7a:	eb 3f                	jmp    800bbb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800b7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7f:	8b 10                	mov    (%eax),%edx
  800b81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b86:	8d 40 04             	lea    0x4(%eax),%eax
  800b89:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b8c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800b91:	eb 28                	jmp    800bbb <vprintfmt+0x3a8>
			putch('0', putdat);
  800b93:	83 ec 08             	sub    $0x8,%esp
  800b96:	53                   	push   %ebx
  800b97:	6a 30                	push   $0x30
  800b99:	ff d6                	call   *%esi
			putch('x', putdat);
  800b9b:	83 c4 08             	add    $0x8,%esp
  800b9e:	53                   	push   %ebx
  800b9f:	6a 78                	push   $0x78
  800ba1:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ba3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba6:	8b 10                	mov    (%eax),%edx
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bad:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bb0:	8d 40 04             	lea    0x4(%eax),%eax
  800bb3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bb6:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800bc2:	50                   	push   %eax
  800bc3:	ff 75 e0             	push   -0x20(%ebp)
  800bc6:	57                   	push   %edi
  800bc7:	51                   	push   %ecx
  800bc8:	52                   	push   %edx
  800bc9:	89 da                	mov    %ebx,%edx
  800bcb:	89 f0                	mov    %esi,%eax
  800bcd:	e8 5e fb ff ff       	call   800730 <printnum>
			break;
  800bd2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800bd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bd8:	e9 54 fc ff ff       	jmp    800831 <vprintfmt+0x1e>
	if (lflag >= 2)
  800bdd:	83 f9 01             	cmp    $0x1,%ecx
  800be0:	7f 1b                	jg     800bfd <vprintfmt+0x3ea>
	else if (lflag)
  800be2:	85 c9                	test   %ecx,%ecx
  800be4:	74 2c                	je     800c12 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800be6:	8b 45 14             	mov    0x14(%ebp),%eax
  800be9:	8b 10                	mov    (%eax),%edx
  800beb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf0:	8d 40 04             	lea    0x4(%eax),%eax
  800bf3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bf6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800bfb:	eb be                	jmp    800bbb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800bfd:	8b 45 14             	mov    0x14(%ebp),%eax
  800c00:	8b 10                	mov    (%eax),%edx
  800c02:	8b 48 04             	mov    0x4(%eax),%ecx
  800c05:	8d 40 08             	lea    0x8(%eax),%eax
  800c08:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c0b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800c10:	eb a9                	jmp    800bbb <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800c12:	8b 45 14             	mov    0x14(%ebp),%eax
  800c15:	8b 10                	mov    (%eax),%edx
  800c17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c1c:	8d 40 04             	lea    0x4(%eax),%eax
  800c1f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c22:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800c27:	eb 92                	jmp    800bbb <vprintfmt+0x3a8>
			putch(ch, putdat);
  800c29:	83 ec 08             	sub    $0x8,%esp
  800c2c:	53                   	push   %ebx
  800c2d:	6a 25                	push   $0x25
  800c2f:	ff d6                	call   *%esi
			break;
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	eb 9f                	jmp    800bd5 <vprintfmt+0x3c2>
			putch('%', putdat);
  800c36:	83 ec 08             	sub    $0x8,%esp
  800c39:	53                   	push   %ebx
  800c3a:	6a 25                	push   $0x25
  800c3c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c3e:	83 c4 10             	add    $0x10,%esp
  800c41:	89 f8                	mov    %edi,%eax
  800c43:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c47:	74 05                	je     800c4e <vprintfmt+0x43b>
  800c49:	83 e8 01             	sub    $0x1,%eax
  800c4c:	eb f5                	jmp    800c43 <vprintfmt+0x430>
  800c4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c51:	eb 82                	jmp    800bd5 <vprintfmt+0x3c2>

00800c53 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 18             	sub    $0x18,%esp
  800c59:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c62:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c66:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	74 26                	je     800c9a <vsnprintf+0x47>
  800c74:	85 d2                	test   %edx,%edx
  800c76:	7e 22                	jle    800c9a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c78:	ff 75 14             	push   0x14(%ebp)
  800c7b:	ff 75 10             	push   0x10(%ebp)
  800c7e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c81:	50                   	push   %eax
  800c82:	68 d9 07 80 00       	push   $0x8007d9
  800c87:	e8 87 fb ff ff       	call   800813 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c8f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c95:	83 c4 10             	add    $0x10,%esp
}
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    
		return -E_INVAL;
  800c9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c9f:	eb f7                	jmp    800c98 <vsnprintf+0x45>

00800ca1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ca7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800caa:	50                   	push   %eax
  800cab:	ff 75 10             	push   0x10(%ebp)
  800cae:	ff 75 0c             	push   0xc(%ebp)
  800cb1:	ff 75 08             	push   0x8(%ebp)
  800cb4:	e8 9a ff ff ff       	call   800c53 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cb9:	c9                   	leave  
  800cba:	c3                   	ret    

00800cbb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc6:	eb 03                	jmp    800ccb <strlen+0x10>
		n++;
  800cc8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ccb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ccf:	75 f7                	jne    800cc8 <strlen+0xd>
	return n;
}
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce1:	eb 03                	jmp    800ce6 <strnlen+0x13>
		n++;
  800ce3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ce6:	39 d0                	cmp    %edx,%eax
  800ce8:	74 08                	je     800cf2 <strnlen+0x1f>
  800cea:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800cee:	75 f3                	jne    800ce3 <strnlen+0x10>
  800cf0:	89 c2                	mov    %eax,%edx
	return n;
}
  800cf2:	89 d0                	mov    %edx,%eax
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	53                   	push   %ebx
  800cfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d00:	b8 00 00 00 00       	mov    $0x0,%eax
  800d05:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d09:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d0c:	83 c0 01             	add    $0x1,%eax
  800d0f:	84 d2                	test   %dl,%dl
  800d11:	75 f2                	jne    800d05 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d13:	89 c8                	mov    %ecx,%eax
  800d15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 10             	sub    $0x10,%esp
  800d21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d24:	53                   	push   %ebx
  800d25:	e8 91 ff ff ff       	call   800cbb <strlen>
  800d2a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d2d:	ff 75 0c             	push   0xc(%ebp)
  800d30:	01 d8                	add    %ebx,%eax
  800d32:	50                   	push   %eax
  800d33:	e8 be ff ff ff       	call   800cf6 <strcpy>
	return dst;
}
  800d38:	89 d8                	mov    %ebx,%eax
  800d3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	8b 75 08             	mov    0x8(%ebp),%esi
  800d47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d4a:	89 f3                	mov    %esi,%ebx
  800d4c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d4f:	89 f0                	mov    %esi,%eax
  800d51:	eb 0f                	jmp    800d62 <strncpy+0x23>
		*dst++ = *src;
  800d53:	83 c0 01             	add    $0x1,%eax
  800d56:	0f b6 0a             	movzbl (%edx),%ecx
  800d59:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d5c:	80 f9 01             	cmp    $0x1,%cl
  800d5f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800d62:	39 d8                	cmp    %ebx,%eax
  800d64:	75 ed                	jne    800d53 <strncpy+0x14>
	}
	return ret;
}
  800d66:	89 f0                	mov    %esi,%eax
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	8b 75 08             	mov    0x8(%ebp),%esi
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 10             	mov    0x10(%ebp),%edx
  800d7a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d7c:	85 d2                	test   %edx,%edx
  800d7e:	74 21                	je     800da1 <strlcpy+0x35>
  800d80:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d84:	89 f2                	mov    %esi,%edx
  800d86:	eb 09                	jmp    800d91 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d88:	83 c1 01             	add    $0x1,%ecx
  800d8b:	83 c2 01             	add    $0x1,%edx
  800d8e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800d91:	39 c2                	cmp    %eax,%edx
  800d93:	74 09                	je     800d9e <strlcpy+0x32>
  800d95:	0f b6 19             	movzbl (%ecx),%ebx
  800d98:	84 db                	test   %bl,%bl
  800d9a:	75 ec                	jne    800d88 <strlcpy+0x1c>
  800d9c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800d9e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800da1:	29 f0                	sub    %esi,%eax
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800db0:	eb 06                	jmp    800db8 <strcmp+0x11>
		p++, q++;
  800db2:	83 c1 01             	add    $0x1,%ecx
  800db5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800db8:	0f b6 01             	movzbl (%ecx),%eax
  800dbb:	84 c0                	test   %al,%al
  800dbd:	74 04                	je     800dc3 <strcmp+0x1c>
  800dbf:	3a 02                	cmp    (%edx),%al
  800dc1:	74 ef                	je     800db2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc3:	0f b6 c0             	movzbl %al,%eax
  800dc6:	0f b6 12             	movzbl (%edx),%edx
  800dc9:	29 d0                	sub    %edx,%eax
}
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	53                   	push   %ebx
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ddc:	eb 06                	jmp    800de4 <strncmp+0x17>
		n--, p++, q++;
  800dde:	83 c0 01             	add    $0x1,%eax
  800de1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800de4:	39 d8                	cmp    %ebx,%eax
  800de6:	74 18                	je     800e00 <strncmp+0x33>
  800de8:	0f b6 08             	movzbl (%eax),%ecx
  800deb:	84 c9                	test   %cl,%cl
  800ded:	74 04                	je     800df3 <strncmp+0x26>
  800def:	3a 0a                	cmp    (%edx),%cl
  800df1:	74 eb                	je     800dde <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	0f b6 12             	movzbl (%edx),%edx
  800df9:	29 d0                	sub    %edx,%eax
}
  800dfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    
		return 0;
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	eb f4                	jmp    800dfb <strncmp+0x2e>

00800e07 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e11:	eb 03                	jmp    800e16 <strchr+0xf>
  800e13:	83 c0 01             	add    $0x1,%eax
  800e16:	0f b6 10             	movzbl (%eax),%edx
  800e19:	84 d2                	test   %dl,%dl
  800e1b:	74 06                	je     800e23 <strchr+0x1c>
		if (*s == c)
  800e1d:	38 ca                	cmp    %cl,%dl
  800e1f:	75 f2                	jne    800e13 <strchr+0xc>
  800e21:	eb 05                	jmp    800e28 <strchr+0x21>
			return (char *) s;
	return 0;
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e34:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e37:	38 ca                	cmp    %cl,%dl
  800e39:	74 09                	je     800e44 <strfind+0x1a>
  800e3b:	84 d2                	test   %dl,%dl
  800e3d:	74 05                	je     800e44 <strfind+0x1a>
	for (; *s; s++)
  800e3f:	83 c0 01             	add    $0x1,%eax
  800e42:	eb f0                	jmp    800e34 <strfind+0xa>
			break;
	return (char *) s;
}
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	57                   	push   %edi
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e52:	85 c9                	test   %ecx,%ecx
  800e54:	74 2f                	je     800e85 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e56:	89 f8                	mov    %edi,%eax
  800e58:	09 c8                	or     %ecx,%eax
  800e5a:	a8 03                	test   $0x3,%al
  800e5c:	75 21                	jne    800e7f <memset+0x39>
		c &= 0xFF;
  800e5e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e62:	89 d0                	mov    %edx,%eax
  800e64:	c1 e0 08             	shl    $0x8,%eax
  800e67:	89 d3                	mov    %edx,%ebx
  800e69:	c1 e3 18             	shl    $0x18,%ebx
  800e6c:	89 d6                	mov    %edx,%esi
  800e6e:	c1 e6 10             	shl    $0x10,%esi
  800e71:	09 f3                	or     %esi,%ebx
  800e73:	09 da                	or     %ebx,%edx
  800e75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e77:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800e7a:	fc                   	cld    
  800e7b:	f3 ab                	rep stos %eax,%es:(%edi)
  800e7d:	eb 06                	jmp    800e85 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	fc                   	cld    
  800e83:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e85:	89 f8                	mov    %edi,%eax
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e97:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e9a:	39 c6                	cmp    %eax,%esi
  800e9c:	73 32                	jae    800ed0 <memmove+0x44>
  800e9e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ea1:	39 c2                	cmp    %eax,%edx
  800ea3:	76 2b                	jbe    800ed0 <memmove+0x44>
		s += n;
		d += n;
  800ea5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea8:	89 d6                	mov    %edx,%esi
  800eaa:	09 fe                	or     %edi,%esi
  800eac:	09 ce                	or     %ecx,%esi
  800eae:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eb4:	75 0e                	jne    800ec4 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eb6:	83 ef 04             	sub    $0x4,%edi
  800eb9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ebc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ebf:	fd                   	std    
  800ec0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec2:	eb 09                	jmp    800ecd <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ec4:	83 ef 01             	sub    $0x1,%edi
  800ec7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800eca:	fd                   	std    
  800ecb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ecd:	fc                   	cld    
  800ece:	eb 1a                	jmp    800eea <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed0:	89 f2                	mov    %esi,%edx
  800ed2:	09 c2                	or     %eax,%edx
  800ed4:	09 ca                	or     %ecx,%edx
  800ed6:	f6 c2 03             	test   $0x3,%dl
  800ed9:	75 0a                	jne    800ee5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800edb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ede:	89 c7                	mov    %eax,%edi
  800ee0:	fc                   	cld    
  800ee1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ee3:	eb 05                	jmp    800eea <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ee5:	89 c7                	mov    %eax,%edi
  800ee7:	fc                   	cld    
  800ee8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ef4:	ff 75 10             	push   0x10(%ebp)
  800ef7:	ff 75 0c             	push   0xc(%ebp)
  800efa:	ff 75 08             	push   0x8(%ebp)
  800efd:	e8 8a ff ff ff       	call   800e8c <memmove>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f0f:	89 c6                	mov    %eax,%esi
  800f11:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f14:	eb 06                	jmp    800f1c <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f16:	83 c0 01             	add    $0x1,%eax
  800f19:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800f1c:	39 f0                	cmp    %esi,%eax
  800f1e:	74 14                	je     800f34 <memcmp+0x30>
		if (*s1 != *s2)
  800f20:	0f b6 08             	movzbl (%eax),%ecx
  800f23:	0f b6 1a             	movzbl (%edx),%ebx
  800f26:	38 d9                	cmp    %bl,%cl
  800f28:	74 ec                	je     800f16 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800f2a:	0f b6 c1             	movzbl %cl,%eax
  800f2d:	0f b6 db             	movzbl %bl,%ebx
  800f30:	29 d8                	sub    %ebx,%eax
  800f32:	eb 05                	jmp    800f39 <memcmp+0x35>
	}

	return 0;
  800f34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f4b:	eb 03                	jmp    800f50 <memfind+0x13>
  800f4d:	83 c0 01             	add    $0x1,%eax
  800f50:	39 d0                	cmp    %edx,%eax
  800f52:	73 04                	jae    800f58 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f54:	38 08                	cmp    %cl,(%eax)
  800f56:	75 f5                	jne    800f4d <memfind+0x10>
			break;
	return (void *) s;
}
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	57                   	push   %edi
  800f5e:	56                   	push   %esi
  800f5f:	53                   	push   %ebx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f66:	eb 03                	jmp    800f6b <strtol+0x11>
		s++;
  800f68:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800f6b:	0f b6 02             	movzbl (%edx),%eax
  800f6e:	3c 20                	cmp    $0x20,%al
  800f70:	74 f6                	je     800f68 <strtol+0xe>
  800f72:	3c 09                	cmp    $0x9,%al
  800f74:	74 f2                	je     800f68 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800f76:	3c 2b                	cmp    $0x2b,%al
  800f78:	74 2a                	je     800fa4 <strtol+0x4a>
	int neg = 0;
  800f7a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800f7f:	3c 2d                	cmp    $0x2d,%al
  800f81:	74 2b                	je     800fae <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f83:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f89:	75 0f                	jne    800f9a <strtol+0x40>
  800f8b:	80 3a 30             	cmpb   $0x30,(%edx)
  800f8e:	74 28                	je     800fb8 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f90:	85 db                	test   %ebx,%ebx
  800f92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f97:	0f 44 d8             	cmove  %eax,%ebx
  800f9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800fa2:	eb 46                	jmp    800fea <strtol+0x90>
		s++;
  800fa4:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800fa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800fac:	eb d5                	jmp    800f83 <strtol+0x29>
		s++, neg = 1;
  800fae:	83 c2 01             	add    $0x1,%edx
  800fb1:	bf 01 00 00 00       	mov    $0x1,%edi
  800fb6:	eb cb                	jmp    800f83 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fb8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fbc:	74 0e                	je     800fcc <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800fbe:	85 db                	test   %ebx,%ebx
  800fc0:	75 d8                	jne    800f9a <strtol+0x40>
		s++, base = 8;
  800fc2:	83 c2 01             	add    $0x1,%edx
  800fc5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800fca:	eb ce                	jmp    800f9a <strtol+0x40>
		s += 2, base = 16;
  800fcc:	83 c2 02             	add    $0x2,%edx
  800fcf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fd4:	eb c4                	jmp    800f9a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800fd6:	0f be c0             	movsbl %al,%eax
  800fd9:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fdc:	3b 45 10             	cmp    0x10(%ebp),%eax
  800fdf:	7d 3a                	jge    80101b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800fe1:	83 c2 01             	add    $0x1,%edx
  800fe4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800fe8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800fea:	0f b6 02             	movzbl (%edx),%eax
  800fed:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ff0:	89 f3                	mov    %esi,%ebx
  800ff2:	80 fb 09             	cmp    $0x9,%bl
  800ff5:	76 df                	jbe    800fd6 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ff7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ffa:	89 f3                	mov    %esi,%ebx
  800ffc:	80 fb 19             	cmp    $0x19,%bl
  800fff:	77 08                	ja     801009 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801001:	0f be c0             	movsbl %al,%eax
  801004:	83 e8 57             	sub    $0x57,%eax
  801007:	eb d3                	jmp    800fdc <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801009:	8d 70 bf             	lea    -0x41(%eax),%esi
  80100c:	89 f3                	mov    %esi,%ebx
  80100e:	80 fb 19             	cmp    $0x19,%bl
  801011:	77 08                	ja     80101b <strtol+0xc1>
			dig = *s - 'A' + 10;
  801013:	0f be c0             	movsbl %al,%eax
  801016:	83 e8 37             	sub    $0x37,%eax
  801019:	eb c1                	jmp    800fdc <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  80101b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80101f:	74 05                	je     801026 <strtol+0xcc>
		*endptr = (char *) s;
  801021:	8b 45 0c             	mov    0xc(%ebp),%eax
  801024:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801026:	89 c8                	mov    %ecx,%eax
  801028:	f7 d8                	neg    %eax
  80102a:	85 ff                	test   %edi,%edi
  80102c:	0f 45 c8             	cmovne %eax,%ecx
}
  80102f:	89 c8                	mov    %ecx,%eax
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	8b 55 08             	mov    0x8(%ebp),%edx
  801044:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801047:	89 c3                	mov    %eax,%ebx
  801049:	89 c7                	mov    %eax,%edi
  80104b:	89 c6                	mov    %eax,%esi
  80104d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <sys_cgetc>:

int
sys_cgetc(void)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	asm volatile("int %1\n"
  80105a:	ba 00 00 00 00       	mov    $0x0,%edx
  80105f:	b8 01 00 00 00       	mov    $0x1,%eax
  801064:	89 d1                	mov    %edx,%ecx
  801066:	89 d3                	mov    %edx,%ebx
  801068:	89 d7                	mov    %edx,%edi
  80106a:	89 d6                	mov    %edx,%esi
  80106c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80107c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	b8 03 00 00 00       	mov    $0x3,%eax
  801089:	89 cb                	mov    %ecx,%ebx
  80108b:	89 cf                	mov    %ecx,%edi
  80108d:	89 ce                	mov    %ecx,%esi
  80108f:	cd 30                	int    $0x30
	if(check && ret > 0)
  801091:	85 c0                	test   %eax,%eax
  801093:	7f 08                	jg     80109d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	50                   	push   %eax
  8010a1:	6a 03                	push   $0x3
  8010a3:	68 df 27 80 00       	push   $0x8027df
  8010a8:	6a 2a                	push   $0x2a
  8010aa:	68 fc 27 80 00       	push   $0x8027fc
  8010af:	e8 8d f5 ff ff       	call   800641 <_panic>

008010b4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8010c4:	89 d1                	mov    %edx,%ecx
  8010c6:	89 d3                	mov    %edx,%ebx
  8010c8:	89 d7                	mov    %edx,%edi
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <sys_yield>:

void
sys_yield(void)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010de:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010e3:	89 d1                	mov    %edx,%ecx
  8010e5:	89 d3                	mov    %edx,%ebx
  8010e7:	89 d7                	mov    %edx,%edi
  8010e9:	89 d6                	mov    %edx,%esi
  8010eb:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	57                   	push   %edi
  8010f6:	56                   	push   %esi
  8010f7:	53                   	push   %ebx
  8010f8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010fb:	be 00 00 00 00       	mov    $0x0,%esi
  801100:	8b 55 08             	mov    0x8(%ebp),%edx
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	b8 04 00 00 00       	mov    $0x4,%eax
  80110b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110e:	89 f7                	mov    %esi,%edi
  801110:	cd 30                	int    $0x30
	if(check && ret > 0)
  801112:	85 c0                	test   %eax,%eax
  801114:	7f 08                	jg     80111e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	50                   	push   %eax
  801122:	6a 04                	push   $0x4
  801124:	68 df 27 80 00       	push   $0x8027df
  801129:	6a 2a                	push   $0x2a
  80112b:	68 fc 27 80 00       	push   $0x8027fc
  801130:	e8 0c f5 ff ff       	call   800641 <_panic>

00801135 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80113e:	8b 55 08             	mov    0x8(%ebp),%edx
  801141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801144:	b8 05 00 00 00       	mov    $0x5,%eax
  801149:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114f:	8b 75 18             	mov    0x18(%ebp),%esi
  801152:	cd 30                	int    $0x30
	if(check && ret > 0)
  801154:	85 c0                	test   %eax,%eax
  801156:	7f 08                	jg     801160 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801160:	83 ec 0c             	sub    $0xc,%esp
  801163:	50                   	push   %eax
  801164:	6a 05                	push   $0x5
  801166:	68 df 27 80 00       	push   $0x8027df
  80116b:	6a 2a                	push   $0x2a
  80116d:	68 fc 27 80 00       	push   $0x8027fc
  801172:	e8 ca f4 ff ff       	call   800641 <_panic>

00801177 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	57                   	push   %edi
  80117b:	56                   	push   %esi
  80117c:	53                   	push   %ebx
  80117d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	8b 55 08             	mov    0x8(%ebp),%edx
  801188:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118b:	b8 06 00 00 00       	mov    $0x6,%eax
  801190:	89 df                	mov    %ebx,%edi
  801192:	89 de                	mov    %ebx,%esi
  801194:	cd 30                	int    $0x30
	if(check && ret > 0)
  801196:	85 c0                	test   %eax,%eax
  801198:	7f 08                	jg     8011a2 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80119a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	50                   	push   %eax
  8011a6:	6a 06                	push   $0x6
  8011a8:	68 df 27 80 00       	push   $0x8027df
  8011ad:	6a 2a                	push   $0x2a
  8011af:	68 fc 27 80 00       	push   $0x8027fc
  8011b4:	e8 88 f4 ff ff       	call   800641 <_panic>

008011b9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cd:	b8 08 00 00 00       	mov    $0x8,%eax
  8011d2:	89 df                	mov    %ebx,%edi
  8011d4:	89 de                	mov    %ebx,%esi
  8011d6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	7f 08                	jg     8011e4 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e4:	83 ec 0c             	sub    $0xc,%esp
  8011e7:	50                   	push   %eax
  8011e8:	6a 08                	push   $0x8
  8011ea:	68 df 27 80 00       	push   $0x8027df
  8011ef:	6a 2a                	push   $0x2a
  8011f1:	68 fc 27 80 00       	push   $0x8027fc
  8011f6:	e8 46 f4 ff ff       	call   800641 <_panic>

008011fb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	57                   	push   %edi
  8011ff:	56                   	push   %esi
  801200:	53                   	push   %ebx
  801201:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
  801209:	8b 55 08             	mov    0x8(%ebp),%edx
  80120c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120f:	b8 09 00 00 00       	mov    $0x9,%eax
  801214:	89 df                	mov    %ebx,%edi
  801216:	89 de                	mov    %ebx,%esi
  801218:	cd 30                	int    $0x30
	if(check && ret > 0)
  80121a:	85 c0                	test   %eax,%eax
  80121c:	7f 08                	jg     801226 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80121e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801221:	5b                   	pop    %ebx
  801222:	5e                   	pop    %esi
  801223:	5f                   	pop    %edi
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	50                   	push   %eax
  80122a:	6a 09                	push   $0x9
  80122c:	68 df 27 80 00       	push   $0x8027df
  801231:	6a 2a                	push   $0x2a
  801233:	68 fc 27 80 00       	push   $0x8027fc
  801238:	e8 04 f4 ff ff       	call   800641 <_panic>

0080123d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	57                   	push   %edi
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
  801243:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124b:	8b 55 08             	mov    0x8(%ebp),%edx
  80124e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801251:	b8 0a 00 00 00       	mov    $0xa,%eax
  801256:	89 df                	mov    %ebx,%edi
  801258:	89 de                	mov    %ebx,%esi
  80125a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80125c:	85 c0                	test   %eax,%eax
  80125e:	7f 08                	jg     801268 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	50                   	push   %eax
  80126c:	6a 0a                	push   $0xa
  80126e:	68 df 27 80 00       	push   $0x8027df
  801273:	6a 2a                	push   $0x2a
  801275:	68 fc 27 80 00       	push   $0x8027fc
  80127a:	e8 c2 f3 ff ff       	call   800641 <_panic>

0080127f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	57                   	push   %edi
  801283:	56                   	push   %esi
  801284:	53                   	push   %ebx
	asm volatile("int %1\n"
  801285:	8b 55 08             	mov    0x8(%ebp),%edx
  801288:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801290:	be 00 00 00 00       	mov    $0x0,%esi
  801295:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801298:	8b 7d 14             	mov    0x14(%ebp),%edi
  80129b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5f                   	pop    %edi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012b8:	89 cb                	mov    %ecx,%ebx
  8012ba:	89 cf                	mov    %ecx,%edi
  8012bc:	89 ce                	mov    %ecx,%esi
  8012be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	7f 08                	jg     8012cc <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c7:	5b                   	pop    %ebx
  8012c8:	5e                   	pop    %esi
  8012c9:	5f                   	pop    %edi
  8012ca:	5d                   	pop    %ebp
  8012cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cc:	83 ec 0c             	sub    $0xc,%esp
  8012cf:	50                   	push   %eax
  8012d0:	6a 0d                	push   $0xd
  8012d2:	68 df 27 80 00       	push   $0x8027df
  8012d7:	6a 2a                	push   $0x2a
  8012d9:	68 fc 27 80 00       	push   $0x8027fc
  8012de:	e8 5e f3 ff ff       	call   800641 <_panic>

008012e3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8012e9:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  8012f0:	74 0a                	je     8012fc <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f5:	a3 b0 40 80 00       	mov    %eax,0x8040b0
}
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8012fc:	e8 b3 fd ff ff       	call   8010b4 <sys_getenvid>
  801301:	83 ec 04             	sub    $0x4,%esp
  801304:	68 07 0e 00 00       	push   $0xe07
  801309:	68 00 f0 bf ee       	push   $0xeebff000
  80130e:	50                   	push   %eax
  80130f:	e8 de fd ff ff       	call   8010f2 <sys_page_alloc>
		if (r < 0) {
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 2c                	js     801347 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80131b:	e8 94 fd ff ff       	call   8010b4 <sys_getenvid>
  801320:	83 ec 08             	sub    $0x8,%esp
  801323:	68 59 13 80 00       	push   $0x801359
  801328:	50                   	push   %eax
  801329:	e8 0f ff ff ff       	call   80123d <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	79 bd                	jns    8012f2 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801335:	50                   	push   %eax
  801336:	68 4c 28 80 00       	push   $0x80284c
  80133b:	6a 28                	push   $0x28
  80133d:	68 82 28 80 00       	push   $0x802882
  801342:	e8 fa f2 ff ff       	call   800641 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801347:	50                   	push   %eax
  801348:	68 0c 28 80 00       	push   $0x80280c
  80134d:	6a 23                	push   $0x23
  80134f:	68 82 28 80 00       	push   $0x802882
  801354:	e8 e8 f2 ff ff       	call   800641 <_panic>

00801359 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801359:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80135a:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	call *%eax
  80135f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801361:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801364:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801368:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80136b:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80136f:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801373:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801375:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801378:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801379:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80137c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80137d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80137e:	c3                   	ret    

0080137f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	05 00 00 00 30       	add    $0x30000000,%eax
  80138a:	c1 e8 0c             	shr    $0xc,%eax
}
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80139a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80139f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013ae:	89 c2                	mov    %eax,%edx
  8013b0:	c1 ea 16             	shr    $0x16,%edx
  8013b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013ba:	f6 c2 01             	test   $0x1,%dl
  8013bd:	74 29                	je     8013e8 <fd_alloc+0x42>
  8013bf:	89 c2                	mov    %eax,%edx
  8013c1:	c1 ea 0c             	shr    $0xc,%edx
  8013c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013cb:	f6 c2 01             	test   $0x1,%dl
  8013ce:	74 18                	je     8013e8 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8013d0:	05 00 10 00 00       	add    $0x1000,%eax
  8013d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013da:	75 d2                	jne    8013ae <fd_alloc+0x8>
  8013dc:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8013e1:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8013e6:	eb 05                	jmp    8013ed <fd_alloc+0x47>
			return 0;
  8013e8:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8013ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f0:	89 02                	mov    %eax,(%edx)
}
  8013f2:	89 c8                	mov    %ecx,%eax
  8013f4:	5d                   	pop    %ebp
  8013f5:	c3                   	ret    

008013f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013fc:	83 f8 1f             	cmp    $0x1f,%eax
  8013ff:	77 30                	ja     801431 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801401:	c1 e0 0c             	shl    $0xc,%eax
  801404:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801409:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80140f:	f6 c2 01             	test   $0x1,%dl
  801412:	74 24                	je     801438 <fd_lookup+0x42>
  801414:	89 c2                	mov    %eax,%edx
  801416:	c1 ea 0c             	shr    $0xc,%edx
  801419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801420:	f6 c2 01             	test   $0x1,%dl
  801423:	74 1a                	je     80143f <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801425:	8b 55 0c             	mov    0xc(%ebp),%edx
  801428:	89 02                	mov    %eax,(%edx)
	return 0;
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    
		return -E_INVAL;
  801431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801436:	eb f7                	jmp    80142f <fd_lookup+0x39>
		return -E_INVAL;
  801438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143d:	eb f0                	jmp    80142f <fd_lookup+0x39>
  80143f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801444:	eb e9                	jmp    80142f <fd_lookup+0x39>

00801446 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	53                   	push   %ebx
  80144a:	83 ec 04             	sub    $0x4,%esp
  80144d:	8b 55 08             	mov    0x8(%ebp),%edx
  801450:	b8 0c 29 80 00       	mov    $0x80290c,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801455:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80145a:	39 13                	cmp    %edx,(%ebx)
  80145c:	74 32                	je     801490 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  80145e:	83 c0 04             	add    $0x4,%eax
  801461:	8b 18                	mov    (%eax),%ebx
  801463:	85 db                	test   %ebx,%ebx
  801465:	75 f3                	jne    80145a <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801467:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  80146c:	8b 40 48             	mov    0x48(%eax),%eax
  80146f:	83 ec 04             	sub    $0x4,%esp
  801472:	52                   	push   %edx
  801473:	50                   	push   %eax
  801474:	68 90 28 80 00       	push   $0x802890
  801479:	e8 9e f2 ff ff       	call   80071c <cprintf>
	*dev = 0;
	return -E_INVAL;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801486:	8b 55 0c             	mov    0xc(%ebp),%edx
  801489:	89 1a                	mov    %ebx,(%edx)
}
  80148b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    
			return 0;
  801490:	b8 00 00 00 00       	mov    $0x0,%eax
  801495:	eb ef                	jmp    801486 <dev_lookup+0x40>

00801497 <fd_close>:
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	57                   	push   %edi
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 24             	sub    $0x24,%esp
  8014a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014aa:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014b0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b3:	50                   	push   %eax
  8014b4:	e8 3d ff ff ff       	call   8013f6 <fd_lookup>
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 05                	js     8014c7 <fd_close+0x30>
	    || fd != fd2)
  8014c2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014c5:	74 16                	je     8014dd <fd_close+0x46>
		return (must_exist ? r : 0);
  8014c7:	89 f8                	mov    %edi,%eax
  8014c9:	84 c0                	test   %al,%al
  8014cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8014d0:	0f 44 d8             	cmove  %eax,%ebx
}
  8014d3:	89 d8                	mov    %ebx,%eax
  8014d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5f                   	pop    %edi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	ff 36                	push   (%esi)
  8014e6:	e8 5b ff ff ff       	call   801446 <dev_lookup>
  8014eb:	89 c3                	mov    %eax,%ebx
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	78 1a                	js     80150e <fd_close+0x77>
		if (dev->dev_close)
  8014f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014fa:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014ff:	85 c0                	test   %eax,%eax
  801501:	74 0b                	je     80150e <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801503:	83 ec 0c             	sub    $0xc,%esp
  801506:	56                   	push   %esi
  801507:	ff d0                	call   *%eax
  801509:	89 c3                	mov    %eax,%ebx
  80150b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	56                   	push   %esi
  801512:	6a 00                	push   $0x0
  801514:	e8 5e fc ff ff       	call   801177 <sys_page_unmap>
	return r;
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	eb b5                	jmp    8014d3 <fd_close+0x3c>

0080151e <close>:

int
close(int fdnum)
{
  80151e:	55                   	push   %ebp
  80151f:	89 e5                	mov    %esp,%ebp
  801521:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801524:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	ff 75 08             	push   0x8(%ebp)
  80152b:	e8 c6 fe ff ff       	call   8013f6 <fd_lookup>
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	79 02                	jns    801539 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801537:	c9                   	leave  
  801538:	c3                   	ret    
		return fd_close(fd, 1);
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	6a 01                	push   $0x1
  80153e:	ff 75 f4             	push   -0xc(%ebp)
  801541:	e8 51 ff ff ff       	call   801497 <fd_close>
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	eb ec                	jmp    801537 <close+0x19>

0080154b <close_all>:

void
close_all(void)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	53                   	push   %ebx
  80154f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801552:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	53                   	push   %ebx
  80155b:	e8 be ff ff ff       	call   80151e <close>
	for (i = 0; i < MAXFD; i++)
  801560:	83 c3 01             	add    $0x1,%ebx
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	83 fb 20             	cmp    $0x20,%ebx
  801569:	75 ec                	jne    801557 <close_all+0xc>
}
  80156b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	57                   	push   %edi
  801574:	56                   	push   %esi
  801575:	53                   	push   %ebx
  801576:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801579:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	ff 75 08             	push   0x8(%ebp)
  801580:	e8 71 fe ff ff       	call   8013f6 <fd_lookup>
  801585:	89 c3                	mov    %eax,%ebx
  801587:	83 c4 10             	add    $0x10,%esp
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 7f                	js     80160d <dup+0x9d>
		return r;
	close(newfdnum);
  80158e:	83 ec 0c             	sub    $0xc,%esp
  801591:	ff 75 0c             	push   0xc(%ebp)
  801594:	e8 85 ff ff ff       	call   80151e <close>

	newfd = INDEX2FD(newfdnum);
  801599:	8b 75 0c             	mov    0xc(%ebp),%esi
  80159c:	c1 e6 0c             	shl    $0xc,%esi
  80159f:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015a8:	89 3c 24             	mov    %edi,(%esp)
  8015ab:	e8 df fd ff ff       	call   80138f <fd2data>
  8015b0:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015b2:	89 34 24             	mov    %esi,(%esp)
  8015b5:	e8 d5 fd ff ff       	call   80138f <fd2data>
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015c0:	89 d8                	mov    %ebx,%eax
  8015c2:	c1 e8 16             	shr    $0x16,%eax
  8015c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015cc:	a8 01                	test   $0x1,%al
  8015ce:	74 11                	je     8015e1 <dup+0x71>
  8015d0:	89 d8                	mov    %ebx,%eax
  8015d2:	c1 e8 0c             	shr    $0xc,%eax
  8015d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015dc:	f6 c2 01             	test   $0x1,%dl
  8015df:	75 36                	jne    801617 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e1:	89 f8                	mov    %edi,%eax
  8015e3:	c1 e8 0c             	shr    $0xc,%eax
  8015e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8015f5:	50                   	push   %eax
  8015f6:	56                   	push   %esi
  8015f7:	6a 00                	push   $0x0
  8015f9:	57                   	push   %edi
  8015fa:	6a 00                	push   $0x0
  8015fc:	e8 34 fb ff ff       	call   801135 <sys_page_map>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	83 c4 20             	add    $0x20,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	78 33                	js     80163d <dup+0xcd>
		goto err;

	return newfdnum;
  80160a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80160d:	89 d8                	mov    %ebx,%eax
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801617:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	25 07 0e 00 00       	and    $0xe07,%eax
  801626:	50                   	push   %eax
  801627:	ff 75 d4             	push   -0x2c(%ebp)
  80162a:	6a 00                	push   $0x0
  80162c:	53                   	push   %ebx
  80162d:	6a 00                	push   $0x0
  80162f:	e8 01 fb ff ff       	call   801135 <sys_page_map>
  801634:	89 c3                	mov    %eax,%ebx
  801636:	83 c4 20             	add    $0x20,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	79 a4                	jns    8015e1 <dup+0x71>
	sys_page_unmap(0, newfd);
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	56                   	push   %esi
  801641:	6a 00                	push   $0x0
  801643:	e8 2f fb ff ff       	call   801177 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801648:	83 c4 08             	add    $0x8,%esp
  80164b:	ff 75 d4             	push   -0x2c(%ebp)
  80164e:	6a 00                	push   $0x0
  801650:	e8 22 fb ff ff       	call   801177 <sys_page_unmap>
	return r;
  801655:	83 c4 10             	add    $0x10,%esp
  801658:	eb b3                	jmp    80160d <dup+0x9d>

0080165a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 18             	sub    $0x18,%esp
  801662:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801665:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	56                   	push   %esi
  80166a:	e8 87 fd ff ff       	call   8013f6 <fd_lookup>
  80166f:	83 c4 10             	add    $0x10,%esp
  801672:	85 c0                	test   %eax,%eax
  801674:	78 3c                	js     8016b2 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801676:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167f:	50                   	push   %eax
  801680:	ff 33                	push   (%ebx)
  801682:	e8 bf fd ff ff       	call   801446 <dev_lookup>
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 24                	js     8016b2 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80168e:	8b 43 08             	mov    0x8(%ebx),%eax
  801691:	83 e0 03             	and    $0x3,%eax
  801694:	83 f8 01             	cmp    $0x1,%eax
  801697:	74 20                	je     8016b9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169c:	8b 40 08             	mov    0x8(%eax),%eax
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	74 37                	je     8016da <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016a3:	83 ec 04             	sub    $0x4,%esp
  8016a6:	ff 75 10             	push   0x10(%ebp)
  8016a9:	ff 75 0c             	push   0xc(%ebp)
  8016ac:	53                   	push   %ebx
  8016ad:	ff d0                	call   *%eax
  8016af:	83 c4 10             	add    $0x10,%esp
}
  8016b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b9:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8016be:	8b 40 48             	mov    0x48(%eax),%eax
  8016c1:	83 ec 04             	sub    $0x4,%esp
  8016c4:	56                   	push   %esi
  8016c5:	50                   	push   %eax
  8016c6:	68 d1 28 80 00       	push   $0x8028d1
  8016cb:	e8 4c f0 ff ff       	call   80071c <cprintf>
		return -E_INVAL;
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d8:	eb d8                	jmp    8016b2 <read+0x58>
		return -E_NOT_SUPP;
  8016da:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016df:	eb d1                	jmp    8016b2 <read+0x58>

008016e1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	57                   	push   %edi
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 0c             	sub    $0xc,%esp
  8016ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f5:	eb 02                	jmp    8016f9 <readn+0x18>
  8016f7:	01 c3                	add    %eax,%ebx
  8016f9:	39 f3                	cmp    %esi,%ebx
  8016fb:	73 21                	jae    80171e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016fd:	83 ec 04             	sub    $0x4,%esp
  801700:	89 f0                	mov    %esi,%eax
  801702:	29 d8                	sub    %ebx,%eax
  801704:	50                   	push   %eax
  801705:	89 d8                	mov    %ebx,%eax
  801707:	03 45 0c             	add    0xc(%ebp),%eax
  80170a:	50                   	push   %eax
  80170b:	57                   	push   %edi
  80170c:	e8 49 ff ff ff       	call   80165a <read>
		if (m < 0)
  801711:	83 c4 10             	add    $0x10,%esp
  801714:	85 c0                	test   %eax,%eax
  801716:	78 04                	js     80171c <readn+0x3b>
			return m;
		if (m == 0)
  801718:	75 dd                	jne    8016f7 <readn+0x16>
  80171a:	eb 02                	jmp    80171e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80171c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80171e:	89 d8                	mov    %ebx,%eax
  801720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5f                   	pop    %edi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	83 ec 18             	sub    $0x18,%esp
  801730:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801733:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801736:	50                   	push   %eax
  801737:	53                   	push   %ebx
  801738:	e8 b9 fc ff ff       	call   8013f6 <fd_lookup>
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	85 c0                	test   %eax,%eax
  801742:	78 37                	js     80177b <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801744:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801747:	83 ec 08             	sub    $0x8,%esp
  80174a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174d:	50                   	push   %eax
  80174e:	ff 36                	push   (%esi)
  801750:	e8 f1 fc ff ff       	call   801446 <dev_lookup>
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 1f                	js     80177b <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801760:	74 20                	je     801782 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	85 c0                	test   %eax,%eax
  80176a:	74 37                	je     8017a3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	ff 75 10             	push   0x10(%ebp)
  801772:	ff 75 0c             	push   0xc(%ebp)
  801775:	56                   	push   %esi
  801776:	ff d0                	call   *%eax
  801778:	83 c4 10             	add    $0x10,%esp
}
  80177b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5e                   	pop    %esi
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801782:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801787:	8b 40 48             	mov    0x48(%eax),%eax
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	53                   	push   %ebx
  80178e:	50                   	push   %eax
  80178f:	68 ed 28 80 00       	push   $0x8028ed
  801794:	e8 83 ef ff ff       	call   80071c <cprintf>
		return -E_INVAL;
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a1:	eb d8                	jmp    80177b <write+0x53>
		return -E_NOT_SUPP;
  8017a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017a8:	eb d1                	jmp    80177b <write+0x53>

008017aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	ff 75 08             	push   0x8(%ebp)
  8017b7:	e8 3a fc ff ff       	call   8013f6 <fd_lookup>
  8017bc:	83 c4 10             	add    $0x10,%esp
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	78 0e                	js     8017d1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 18             	sub    $0x18,%esp
  8017db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e1:	50                   	push   %eax
  8017e2:	53                   	push   %ebx
  8017e3:	e8 0e fc ff ff       	call   8013f6 <fd_lookup>
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 34                	js     801823 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ef:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	ff 36                	push   (%esi)
  8017fb:	e8 46 fc ff ff       	call   801446 <dev_lookup>
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 1c                	js     801823 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801807:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80180b:	74 1d                	je     80182a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80180d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801810:	8b 40 18             	mov    0x18(%eax),%eax
  801813:	85 c0                	test   %eax,%eax
  801815:	74 34                	je     80184b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	ff 75 0c             	push   0xc(%ebp)
  80181d:	56                   	push   %esi
  80181e:	ff d0                	call   *%eax
  801820:	83 c4 10             	add    $0x10,%esp
}
  801823:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801826:	5b                   	pop    %ebx
  801827:	5e                   	pop    %esi
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    
			thisenv->env_id, fdnum);
  80182a:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  80182f:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801832:	83 ec 04             	sub    $0x4,%esp
  801835:	53                   	push   %ebx
  801836:	50                   	push   %eax
  801837:	68 b0 28 80 00       	push   $0x8028b0
  80183c:	e8 db ee ff ff       	call   80071c <cprintf>
		return -E_INVAL;
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801849:	eb d8                	jmp    801823 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80184b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801850:	eb d1                	jmp    801823 <ftruncate+0x50>

00801852 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
  801857:	83 ec 18             	sub    $0x18,%esp
  80185a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80185d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801860:	50                   	push   %eax
  801861:	ff 75 08             	push   0x8(%ebp)
  801864:	e8 8d fb ff ff       	call   8013f6 <fd_lookup>
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	85 c0                	test   %eax,%eax
  80186e:	78 49                	js     8018b9 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801870:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801879:	50                   	push   %eax
  80187a:	ff 36                	push   (%esi)
  80187c:	e8 c5 fb ff ff       	call   801446 <dev_lookup>
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	78 31                	js     8018b9 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80188f:	74 2f                	je     8018c0 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801891:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801894:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80189b:	00 00 00 
	stat->st_isdir = 0;
  80189e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018a5:	00 00 00 
	stat->st_dev = dev;
  8018a8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	53                   	push   %ebx
  8018b2:	56                   	push   %esi
  8018b3:	ff 50 14             	call   *0x14(%eax)
  8018b6:	83 c4 10             	add    $0x10,%esp
}
  8018b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018bc:	5b                   	pop    %ebx
  8018bd:	5e                   	pop    %esi
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    
		return -E_NOT_SUPP;
  8018c0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018c5:	eb f2                	jmp    8018b9 <fstat+0x67>

008018c7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	56                   	push   %esi
  8018cb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	6a 00                	push   $0x0
  8018d1:	ff 75 08             	push   0x8(%ebp)
  8018d4:	e8 e4 01 00 00       	call   801abd <open>
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	78 1b                	js     8018fd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	ff 75 0c             	push   0xc(%ebp)
  8018e8:	50                   	push   %eax
  8018e9:	e8 64 ff ff ff       	call   801852 <fstat>
  8018ee:	89 c6                	mov    %eax,%esi
	close(fd);
  8018f0:	89 1c 24             	mov    %ebx,(%esp)
  8018f3:	e8 26 fc ff ff       	call   80151e <close>
	return r;
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	89 f3                	mov    %esi,%ebx
}
  8018fd:	89 d8                	mov    %ebx,%eax
  8018ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	89 c6                	mov    %eax,%esi
  80190d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80190f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801916:	74 27                	je     80193f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801918:	6a 07                	push   $0x7
  80191a:	68 00 50 80 00       	push   $0x805000
  80191f:	56                   	push   %esi
  801920:	ff 35 00 60 80 00    	push   0x806000
  801926:	e8 5c 07 00 00       	call   802087 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80192b:	83 c4 0c             	add    $0xc,%esp
  80192e:	6a 00                	push   $0x0
  801930:	53                   	push   %ebx
  801931:	6a 00                	push   $0x0
  801933:	e8 e8 06 00 00       	call   802020 <ipc_recv>
}
  801938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5e                   	pop    %esi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	6a 01                	push   $0x1
  801944:	e8 92 07 00 00       	call   8020db <ipc_find_env>
  801949:	a3 00 60 80 00       	mov    %eax,0x806000
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	eb c5                	jmp    801918 <fsipc+0x12>

00801953 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801959:	8b 45 08             	mov    0x8(%ebp),%eax
  80195c:	8b 40 0c             	mov    0xc(%eax),%eax
  80195f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801964:	8b 45 0c             	mov    0xc(%ebp),%eax
  801967:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80196c:	ba 00 00 00 00       	mov    $0x0,%edx
  801971:	b8 02 00 00 00       	mov    $0x2,%eax
  801976:	e8 8b ff ff ff       	call   801906 <fsipc>
}
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devfile_flush>:
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
  801986:	8b 40 0c             	mov    0xc(%eax),%eax
  801989:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80198e:	ba 00 00 00 00       	mov    $0x0,%edx
  801993:	b8 06 00 00 00       	mov    $0x6,%eax
  801998:	e8 69 ff ff ff       	call   801906 <fsipc>
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <devfile_stat>:
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	53                   	push   %ebx
  8019a3:	83 ec 04             	sub    $0x4,%esp
  8019a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8019af:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b9:	b8 05 00 00 00       	mov    $0x5,%eax
  8019be:	e8 43 ff ff ff       	call   801906 <fsipc>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 2c                	js     8019f3 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	68 00 50 80 00       	push   $0x805000
  8019cf:	53                   	push   %ebx
  8019d0:	e8 21 f3 ff ff       	call   800cf6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d5:	a1 80 50 80 00       	mov    0x805080,%eax
  8019da:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019e0:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <devfile_write>:
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	8b 45 10             	mov    0x10(%ebp),%eax
  801a01:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a06:	39 d0                	cmp    %edx,%eax
  801a08:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a0b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a0e:	8b 52 0c             	mov    0xc(%edx),%edx
  801a11:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a17:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a1c:	50                   	push   %eax
  801a1d:	ff 75 0c             	push   0xc(%ebp)
  801a20:	68 08 50 80 00       	push   $0x805008
  801a25:	e8 62 f4 ff ff       	call   800e8c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2f:	b8 04 00 00 00       	mov    $0x4,%eax
  801a34:	e8 cd fe ff ff       	call   801906 <fsipc>
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <devfile_read>:
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
  801a3e:	56                   	push   %esi
  801a3f:	53                   	push   %ebx
  801a40:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a43:	8b 45 08             	mov    0x8(%ebp),%eax
  801a46:	8b 40 0c             	mov    0xc(%eax),%eax
  801a49:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a4e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
  801a59:	b8 03 00 00 00       	mov    $0x3,%eax
  801a5e:	e8 a3 fe ff ff       	call   801906 <fsipc>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	85 c0                	test   %eax,%eax
  801a67:	78 1f                	js     801a88 <devfile_read+0x4d>
	assert(r <= n);
  801a69:	39 f0                	cmp    %esi,%eax
  801a6b:	77 24                	ja     801a91 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a6d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a72:	7f 33                	jg     801aa7 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a74:	83 ec 04             	sub    $0x4,%esp
  801a77:	50                   	push   %eax
  801a78:	68 00 50 80 00       	push   $0x805000
  801a7d:	ff 75 0c             	push   0xc(%ebp)
  801a80:	e8 07 f4 ff ff       	call   800e8c <memmove>
	return r;
  801a85:	83 c4 10             	add    $0x10,%esp
}
  801a88:	89 d8                	mov    %ebx,%eax
  801a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    
	assert(r <= n);
  801a91:	68 1c 29 80 00       	push   $0x80291c
  801a96:	68 23 29 80 00       	push   $0x802923
  801a9b:	6a 7c                	push   $0x7c
  801a9d:	68 38 29 80 00       	push   $0x802938
  801aa2:	e8 9a eb ff ff       	call   800641 <_panic>
	assert(r <= PGSIZE);
  801aa7:	68 43 29 80 00       	push   $0x802943
  801aac:	68 23 29 80 00       	push   $0x802923
  801ab1:	6a 7d                	push   $0x7d
  801ab3:	68 38 29 80 00       	push   $0x802938
  801ab8:	e8 84 eb ff ff       	call   800641 <_panic>

00801abd <open>:
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	83 ec 1c             	sub    $0x1c,%esp
  801ac5:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801ac8:	56                   	push   %esi
  801ac9:	e8 ed f1 ff ff       	call   800cbb <strlen>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801ad6:	7f 6c                	jg     801b44 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ade:	50                   	push   %eax
  801adf:	e8 c2 f8 ff ff       	call   8013a6 <fd_alloc>
  801ae4:	89 c3                	mov    %eax,%ebx
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 3c                	js     801b29 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801aed:	83 ec 08             	sub    $0x8,%esp
  801af0:	56                   	push   %esi
  801af1:	68 00 50 80 00       	push   $0x805000
  801af6:	e8 fb f1 ff ff       	call   800cf6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afe:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b06:	b8 01 00 00 00       	mov    $0x1,%eax
  801b0b:	e8 f6 fd ff ff       	call   801906 <fsipc>
  801b10:	89 c3                	mov    %eax,%ebx
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 19                	js     801b32 <open+0x75>
	return fd2num(fd);
  801b19:	83 ec 0c             	sub    $0xc,%esp
  801b1c:	ff 75 f4             	push   -0xc(%ebp)
  801b1f:	e8 5b f8 ff ff       	call   80137f <fd2num>
  801b24:	89 c3                	mov    %eax,%ebx
  801b26:	83 c4 10             	add    $0x10,%esp
}
  801b29:	89 d8                	mov    %ebx,%eax
  801b2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2e:	5b                   	pop    %ebx
  801b2f:	5e                   	pop    %esi
  801b30:	5d                   	pop    %ebp
  801b31:	c3                   	ret    
		fd_close(fd, 0);
  801b32:	83 ec 08             	sub    $0x8,%esp
  801b35:	6a 00                	push   $0x0
  801b37:	ff 75 f4             	push   -0xc(%ebp)
  801b3a:	e8 58 f9 ff ff       	call   801497 <fd_close>
		return r;
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	eb e5                	jmp    801b29 <open+0x6c>
		return -E_BAD_PATH;
  801b44:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b49:	eb de                	jmp    801b29 <open+0x6c>

00801b4b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b51:	ba 00 00 00 00       	mov    $0x0,%edx
  801b56:	b8 08 00 00 00       	mov    $0x8,%eax
  801b5b:	e8 a6 fd ff ff       	call   801906 <fsipc>
}
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	56                   	push   %esi
  801b66:	53                   	push   %ebx
  801b67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b6a:	83 ec 0c             	sub    $0xc,%esp
  801b6d:	ff 75 08             	push   0x8(%ebp)
  801b70:	e8 1a f8 ff ff       	call   80138f <fd2data>
  801b75:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b77:	83 c4 08             	add    $0x8,%esp
  801b7a:	68 4f 29 80 00       	push   $0x80294f
  801b7f:	53                   	push   %ebx
  801b80:	e8 71 f1 ff ff       	call   800cf6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b85:	8b 46 04             	mov    0x4(%esi),%eax
  801b88:	2b 06                	sub    (%esi),%eax
  801b8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b97:	00 00 00 
	stat->st_dev = &devpipe;
  801b9a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ba1:	30 80 00 
	return 0;
}
  801ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bac:	5b                   	pop    %ebx
  801bad:	5e                   	pop    %esi
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bba:	53                   	push   %ebx
  801bbb:	6a 00                	push   $0x0
  801bbd:	e8 b5 f5 ff ff       	call   801177 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bc2:	89 1c 24             	mov    %ebx,(%esp)
  801bc5:	e8 c5 f7 ff ff       	call   80138f <fd2data>
  801bca:	83 c4 08             	add    $0x8,%esp
  801bcd:	50                   	push   %eax
  801bce:	6a 00                	push   $0x0
  801bd0:	e8 a2 f5 ff ff       	call   801177 <sys_page_unmap>
}
  801bd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <_pipeisclosed>:
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 1c             	sub    $0x1c,%esp
  801be3:	89 c7                	mov    %eax,%edi
  801be5:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801be7:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801bec:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bef:	83 ec 0c             	sub    $0xc,%esp
  801bf2:	57                   	push   %edi
  801bf3:	e8 1c 05 00 00       	call   802114 <pageref>
  801bf8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bfb:	89 34 24             	mov    %esi,(%esp)
  801bfe:	e8 11 05 00 00       	call   802114 <pageref>
		nn = thisenv->env_runs;
  801c03:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  801c09:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c0c:	83 c4 10             	add    $0x10,%esp
  801c0f:	39 cb                	cmp    %ecx,%ebx
  801c11:	74 1b                	je     801c2e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c13:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c16:	75 cf                	jne    801be7 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c18:	8b 42 58             	mov    0x58(%edx),%eax
  801c1b:	6a 01                	push   $0x1
  801c1d:	50                   	push   %eax
  801c1e:	53                   	push   %ebx
  801c1f:	68 56 29 80 00       	push   $0x802956
  801c24:	e8 f3 ea ff ff       	call   80071c <cprintf>
  801c29:	83 c4 10             	add    $0x10,%esp
  801c2c:	eb b9                	jmp    801be7 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c2e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c31:	0f 94 c0             	sete   %al
  801c34:	0f b6 c0             	movzbl %al,%eax
}
  801c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3a:	5b                   	pop    %ebx
  801c3b:	5e                   	pop    %esi
  801c3c:	5f                   	pop    %edi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    

00801c3f <devpipe_write>:
{
  801c3f:	55                   	push   %ebp
  801c40:	89 e5                	mov    %esp,%ebp
  801c42:	57                   	push   %edi
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 28             	sub    $0x28,%esp
  801c48:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c4b:	56                   	push   %esi
  801c4c:	e8 3e f7 ff ff       	call   80138f <fd2data>
  801c51:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c53:	83 c4 10             	add    $0x10,%esp
  801c56:	bf 00 00 00 00       	mov    $0x0,%edi
  801c5b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c5e:	75 09                	jne    801c69 <devpipe_write+0x2a>
	return i;
  801c60:	89 f8                	mov    %edi,%eax
  801c62:	eb 23                	jmp    801c87 <devpipe_write+0x48>
			sys_yield();
  801c64:	e8 6a f4 ff ff       	call   8010d3 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c69:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6c:	8b 0b                	mov    (%ebx),%ecx
  801c6e:	8d 51 20             	lea    0x20(%ecx),%edx
  801c71:	39 d0                	cmp    %edx,%eax
  801c73:	72 1a                	jb     801c8f <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c75:	89 da                	mov    %ebx,%edx
  801c77:	89 f0                	mov    %esi,%eax
  801c79:	e8 5c ff ff ff       	call   801bda <_pipeisclosed>
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	74 e2                	je     801c64 <devpipe_write+0x25>
				return 0;
  801c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8a:	5b                   	pop    %ebx
  801c8b:	5e                   	pop    %esi
  801c8c:	5f                   	pop    %edi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c92:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c96:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c99:	89 c2                	mov    %eax,%edx
  801c9b:	c1 fa 1f             	sar    $0x1f,%edx
  801c9e:	89 d1                	mov    %edx,%ecx
  801ca0:	c1 e9 1b             	shr    $0x1b,%ecx
  801ca3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801ca6:	83 e2 1f             	and    $0x1f,%edx
  801ca9:	29 ca                	sub    %ecx,%edx
  801cab:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801caf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cb3:	83 c0 01             	add    $0x1,%eax
  801cb6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cb9:	83 c7 01             	add    $0x1,%edi
  801cbc:	eb 9d                	jmp    801c5b <devpipe_write+0x1c>

00801cbe <devpipe_read>:
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 18             	sub    $0x18,%esp
  801cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cca:	57                   	push   %edi
  801ccb:	e8 bf f6 ff ff       	call   80138f <fd2data>
  801cd0:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	be 00 00 00 00       	mov    $0x0,%esi
  801cda:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cdd:	75 13                	jne    801cf2 <devpipe_read+0x34>
	return i;
  801cdf:	89 f0                	mov    %esi,%eax
  801ce1:	eb 02                	jmp    801ce5 <devpipe_read+0x27>
				return i;
  801ce3:	89 f0                	mov    %esi,%eax
}
  801ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ce8:	5b                   	pop    %ebx
  801ce9:	5e                   	pop    %esi
  801cea:	5f                   	pop    %edi
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    
			sys_yield();
  801ced:	e8 e1 f3 ff ff       	call   8010d3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801cf2:	8b 03                	mov    (%ebx),%eax
  801cf4:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cf7:	75 18                	jne    801d11 <devpipe_read+0x53>
			if (i > 0)
  801cf9:	85 f6                	test   %esi,%esi
  801cfb:	75 e6                	jne    801ce3 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801cfd:	89 da                	mov    %ebx,%edx
  801cff:	89 f8                	mov    %edi,%eax
  801d01:	e8 d4 fe ff ff       	call   801bda <_pipeisclosed>
  801d06:	85 c0                	test   %eax,%eax
  801d08:	74 e3                	je     801ced <devpipe_read+0x2f>
				return 0;
  801d0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0f:	eb d4                	jmp    801ce5 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d11:	99                   	cltd   
  801d12:	c1 ea 1b             	shr    $0x1b,%edx
  801d15:	01 d0                	add    %edx,%eax
  801d17:	83 e0 1f             	and    $0x1f,%eax
  801d1a:	29 d0                	sub    %edx,%eax
  801d1c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d24:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d27:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d2a:	83 c6 01             	add    $0x1,%esi
  801d2d:	eb ab                	jmp    801cda <devpipe_read+0x1c>

00801d2f <pipe>:
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3a:	50                   	push   %eax
  801d3b:	e8 66 f6 ff ff       	call   8013a6 <fd_alloc>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	85 c0                	test   %eax,%eax
  801d47:	0f 88 23 01 00 00    	js     801e70 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4d:	83 ec 04             	sub    $0x4,%esp
  801d50:	68 07 04 00 00       	push   $0x407
  801d55:	ff 75 f4             	push   -0xc(%ebp)
  801d58:	6a 00                	push   $0x0
  801d5a:	e8 93 f3 ff ff       	call   8010f2 <sys_page_alloc>
  801d5f:	89 c3                	mov    %eax,%ebx
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	85 c0                	test   %eax,%eax
  801d66:	0f 88 04 01 00 00    	js     801e70 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d6c:	83 ec 0c             	sub    $0xc,%esp
  801d6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d72:	50                   	push   %eax
  801d73:	e8 2e f6 ff ff       	call   8013a6 <fd_alloc>
  801d78:	89 c3                	mov    %eax,%ebx
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	0f 88 db 00 00 00    	js     801e60 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d85:	83 ec 04             	sub    $0x4,%esp
  801d88:	68 07 04 00 00       	push   $0x407
  801d8d:	ff 75 f0             	push   -0x10(%ebp)
  801d90:	6a 00                	push   $0x0
  801d92:	e8 5b f3 ff ff       	call   8010f2 <sys_page_alloc>
  801d97:	89 c3                	mov    %eax,%ebx
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	0f 88 bc 00 00 00    	js     801e60 <pipe+0x131>
	va = fd2data(fd0);
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	ff 75 f4             	push   -0xc(%ebp)
  801daa:	e8 e0 f5 ff ff       	call   80138f <fd2data>
  801daf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db1:	83 c4 0c             	add    $0xc,%esp
  801db4:	68 07 04 00 00       	push   $0x407
  801db9:	50                   	push   %eax
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 31 f3 ff ff       	call   8010f2 <sys_page_alloc>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	83 c4 10             	add    $0x10,%esp
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	0f 88 82 00 00 00    	js     801e50 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	ff 75 f0             	push   -0x10(%ebp)
  801dd4:	e8 b6 f5 ff ff       	call   80138f <fd2data>
  801dd9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801de0:	50                   	push   %eax
  801de1:	6a 00                	push   $0x0
  801de3:	56                   	push   %esi
  801de4:	6a 00                	push   $0x0
  801de6:	e8 4a f3 ff ff       	call   801135 <sys_page_map>
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	83 c4 20             	add    $0x20,%esp
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 4e                	js     801e42 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801df4:	a1 20 30 80 00       	mov    0x803020,%eax
  801df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dfc:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801dfe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e01:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e0b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e10:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e17:	83 ec 0c             	sub    $0xc,%esp
  801e1a:	ff 75 f4             	push   -0xc(%ebp)
  801e1d:	e8 5d f5 ff ff       	call   80137f <fd2num>
  801e22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e25:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e27:	83 c4 04             	add    $0x4,%esp
  801e2a:	ff 75 f0             	push   -0x10(%ebp)
  801e2d:	e8 4d f5 ff ff       	call   80137f <fd2num>
  801e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e35:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e40:	eb 2e                	jmp    801e70 <pipe+0x141>
	sys_page_unmap(0, va);
  801e42:	83 ec 08             	sub    $0x8,%esp
  801e45:	56                   	push   %esi
  801e46:	6a 00                	push   $0x0
  801e48:	e8 2a f3 ff ff       	call   801177 <sys_page_unmap>
  801e4d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e50:	83 ec 08             	sub    $0x8,%esp
  801e53:	ff 75 f0             	push   -0x10(%ebp)
  801e56:	6a 00                	push   $0x0
  801e58:	e8 1a f3 ff ff       	call   801177 <sys_page_unmap>
  801e5d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e60:	83 ec 08             	sub    $0x8,%esp
  801e63:	ff 75 f4             	push   -0xc(%ebp)
  801e66:	6a 00                	push   $0x0
  801e68:	e8 0a f3 ff ff       	call   801177 <sys_page_unmap>
  801e6d:	83 c4 10             	add    $0x10,%esp
}
  801e70:	89 d8                	mov    %ebx,%eax
  801e72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e75:	5b                   	pop    %ebx
  801e76:	5e                   	pop    %esi
  801e77:	5d                   	pop    %ebp
  801e78:	c3                   	ret    

00801e79 <pipeisclosed>:
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e82:	50                   	push   %eax
  801e83:	ff 75 08             	push   0x8(%ebp)
  801e86:	e8 6b f5 ff ff       	call   8013f6 <fd_lookup>
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 18                	js     801eaa <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e92:	83 ec 0c             	sub    $0xc,%esp
  801e95:	ff 75 f4             	push   -0xc(%ebp)
  801e98:	e8 f2 f4 ff ff       	call   80138f <fd2data>
  801e9d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea2:	e8 33 fd ff ff       	call   801bda <_pipeisclosed>
  801ea7:	83 c4 10             	add    $0x10,%esp
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801eac:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb1:	c3                   	ret    

00801eb2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eb8:	68 6e 29 80 00       	push   $0x80296e
  801ebd:	ff 75 0c             	push   0xc(%ebp)
  801ec0:	e8 31 ee ff ff       	call   800cf6 <strcpy>
	return 0;
}
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eca:	c9                   	leave  
  801ecb:	c3                   	ret    

00801ecc <devcons_write>:
{
  801ecc:	55                   	push   %ebp
  801ecd:	89 e5                	mov    %esp,%ebp
  801ecf:	57                   	push   %edi
  801ed0:	56                   	push   %esi
  801ed1:	53                   	push   %ebx
  801ed2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ed8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801edd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ee3:	eb 2e                	jmp    801f13 <devcons_write+0x47>
		m = n - tot;
  801ee5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ee8:	29 f3                	sub    %esi,%ebx
  801eea:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801eef:	39 c3                	cmp    %eax,%ebx
  801ef1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ef4:	83 ec 04             	sub    $0x4,%esp
  801ef7:	53                   	push   %ebx
  801ef8:	89 f0                	mov    %esi,%eax
  801efa:	03 45 0c             	add    0xc(%ebp),%eax
  801efd:	50                   	push   %eax
  801efe:	57                   	push   %edi
  801eff:	e8 88 ef ff ff       	call   800e8c <memmove>
		sys_cputs(buf, m);
  801f04:	83 c4 08             	add    $0x8,%esp
  801f07:	53                   	push   %ebx
  801f08:	57                   	push   %edi
  801f09:	e8 28 f1 ff ff       	call   801036 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f0e:	01 de                	add    %ebx,%esi
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f16:	72 cd                	jb     801ee5 <devcons_write+0x19>
}
  801f18:	89 f0                	mov    %esi,%eax
  801f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5f                   	pop    %edi
  801f20:	5d                   	pop    %ebp
  801f21:	c3                   	ret    

00801f22 <devcons_read>:
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	83 ec 08             	sub    $0x8,%esp
  801f28:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f31:	75 07                	jne    801f3a <devcons_read+0x18>
  801f33:	eb 1f                	jmp    801f54 <devcons_read+0x32>
		sys_yield();
  801f35:	e8 99 f1 ff ff       	call   8010d3 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f3a:	e8 15 f1 ff ff       	call   801054 <sys_cgetc>
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	74 f2                	je     801f35 <devcons_read+0x13>
	if (c < 0)
  801f43:	78 0f                	js     801f54 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801f45:	83 f8 04             	cmp    $0x4,%eax
  801f48:	74 0c                	je     801f56 <devcons_read+0x34>
	*(char*)vbuf = c;
  801f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f4d:	88 02                	mov    %al,(%edx)
	return 1;
  801f4f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f54:	c9                   	leave  
  801f55:	c3                   	ret    
		return 0;
  801f56:	b8 00 00 00 00       	mov    $0x0,%eax
  801f5b:	eb f7                	jmp    801f54 <devcons_read+0x32>

00801f5d <cputchar>:
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f63:	8b 45 08             	mov    0x8(%ebp),%eax
  801f66:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f69:	6a 01                	push   $0x1
  801f6b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6e:	50                   	push   %eax
  801f6f:	e8 c2 f0 ff ff       	call   801036 <sys_cputs>
}
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	c9                   	leave  
  801f78:	c3                   	ret    

00801f79 <getchar>:
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f7f:	6a 01                	push   $0x1
  801f81:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f84:	50                   	push   %eax
  801f85:	6a 00                	push   $0x0
  801f87:	e8 ce f6 ff ff       	call   80165a <read>
	if (r < 0)
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	78 06                	js     801f99 <getchar+0x20>
	if (r < 1)
  801f93:	74 06                	je     801f9b <getchar+0x22>
	return c;
  801f95:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    
		return -E_EOF;
  801f9b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fa0:	eb f7                	jmp    801f99 <getchar+0x20>

00801fa2 <iscons>:
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fab:	50                   	push   %eax
  801fac:	ff 75 08             	push   0x8(%ebp)
  801faf:	e8 42 f4 ff ff       	call   8013f6 <fd_lookup>
  801fb4:	83 c4 10             	add    $0x10,%esp
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	78 11                	js     801fcc <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc4:	39 10                	cmp    %edx,(%eax)
  801fc6:	0f 94 c0             	sete   %al
  801fc9:	0f b6 c0             	movzbl %al,%eax
}
  801fcc:	c9                   	leave  
  801fcd:	c3                   	ret    

00801fce <opencons>:
{
  801fce:	55                   	push   %ebp
  801fcf:	89 e5                	mov    %esp,%ebp
  801fd1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd7:	50                   	push   %eax
  801fd8:	e8 c9 f3 ff ff       	call   8013a6 <fd_alloc>
  801fdd:	83 c4 10             	add    $0x10,%esp
  801fe0:	85 c0                	test   %eax,%eax
  801fe2:	78 3a                	js     80201e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe4:	83 ec 04             	sub    $0x4,%esp
  801fe7:	68 07 04 00 00       	push   $0x407
  801fec:	ff 75 f4             	push   -0xc(%ebp)
  801fef:	6a 00                	push   $0x0
  801ff1:	e8 fc f0 ff ff       	call   8010f2 <sys_page_alloc>
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	78 21                	js     80201e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802000:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802006:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802012:	83 ec 0c             	sub    $0xc,%esp
  802015:	50                   	push   %eax
  802016:	e8 64 f3 ff ff       	call   80137f <fd2num>
  80201b:	83 c4 10             	add    $0x10,%esp
}
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	8b 75 08             	mov    0x8(%ebp),%esi
  802028:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80202e:	85 c0                	test   %eax,%eax
  802030:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802035:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	50                   	push   %eax
  80203c:	e8 61 f2 ff ff       	call   8012a2 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	85 f6                	test   %esi,%esi
  802046:	74 14                	je     80205c <ipc_recv+0x3c>
  802048:	ba 00 00 00 00       	mov    $0x0,%edx
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 09                	js     80205a <ipc_recv+0x3a>
  802051:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  802057:	8b 52 74             	mov    0x74(%edx),%edx
  80205a:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80205c:	85 db                	test   %ebx,%ebx
  80205e:	74 14                	je     802074 <ipc_recv+0x54>
  802060:	ba 00 00 00 00       	mov    $0x0,%edx
  802065:	85 c0                	test   %eax,%eax
  802067:	78 09                	js     802072 <ipc_recv+0x52>
  802069:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  80206f:	8b 52 78             	mov    0x78(%edx),%edx
  802072:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802074:	85 c0                	test   %eax,%eax
  802076:	78 08                	js     802080 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802078:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  80207d:	8b 40 70             	mov    0x70(%eax),%eax
}
  802080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    

00802087 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802087:	55                   	push   %ebp
  802088:	89 e5                	mov    %esp,%ebp
  80208a:	57                   	push   %edi
  80208b:	56                   	push   %esi
  80208c:	53                   	push   %ebx
  80208d:	83 ec 0c             	sub    $0xc,%esp
  802090:	8b 7d 08             	mov    0x8(%ebp),%edi
  802093:	8b 75 0c             	mov    0xc(%ebp),%esi
  802096:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802099:	85 db                	test   %ebx,%ebx
  80209b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020a0:	0f 44 d8             	cmove  %eax,%ebx
  8020a3:	eb 05                	jmp    8020aa <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020a5:	e8 29 f0 ff ff       	call   8010d3 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8020aa:	ff 75 14             	push   0x14(%ebp)
  8020ad:	53                   	push   %ebx
  8020ae:	56                   	push   %esi
  8020af:	57                   	push   %edi
  8020b0:	e8 ca f1 ff ff       	call   80127f <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020b5:	83 c4 10             	add    $0x10,%esp
  8020b8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020bb:	74 e8                	je     8020a5 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 08                	js     8020c9 <ipc_send+0x42>
	}while (r<0);

}
  8020c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020c9:	50                   	push   %eax
  8020ca:	68 7a 29 80 00       	push   $0x80297a
  8020cf:	6a 3d                	push   $0x3d
  8020d1:	68 8e 29 80 00       	push   $0x80298e
  8020d6:	e8 66 e5 ff ff       	call   800641 <_panic>

008020db <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020e1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020e6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020e9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ef:	8b 52 50             	mov    0x50(%edx),%edx
  8020f2:	39 ca                	cmp    %ecx,%edx
  8020f4:	74 11                	je     802107 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8020f6:	83 c0 01             	add    $0x1,%eax
  8020f9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020fe:	75 e6                	jne    8020e6 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802100:	b8 00 00 00 00       	mov    $0x0,%eax
  802105:	eb 0b                	jmp    802112 <ipc_find_env+0x37>
			return envs[i].env_id;
  802107:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80210a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80210f:	8b 40 48             	mov    0x48(%eax),%eax
}
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    

00802114 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211a:	89 c2                	mov    %eax,%edx
  80211c:	c1 ea 16             	shr    $0x16,%edx
  80211f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802126:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80212b:	f6 c1 01             	test   $0x1,%cl
  80212e:	74 1c                	je     80214c <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802130:	c1 e8 0c             	shr    $0xc,%eax
  802133:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80213a:	a8 01                	test   $0x1,%al
  80213c:	74 0e                	je     80214c <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80213e:	c1 e8 0c             	shr    $0xc,%eax
  802141:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802148:	ef 
  802149:	0f b7 d2             	movzwl %dx,%edx
}
  80214c:	89 d0                	mov    %edx,%eax
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    

00802150 <__udivdi3>:
  802150:	f3 0f 1e fb          	endbr32 
  802154:	55                   	push   %ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	53                   	push   %ebx
  802158:	83 ec 1c             	sub    $0x1c,%esp
  80215b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80215f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802163:	8b 74 24 34          	mov    0x34(%esp),%esi
  802167:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80216b:	85 c0                	test   %eax,%eax
  80216d:	75 19                	jne    802188 <__udivdi3+0x38>
  80216f:	39 f3                	cmp    %esi,%ebx
  802171:	76 4d                	jbe    8021c0 <__udivdi3+0x70>
  802173:	31 ff                	xor    %edi,%edi
  802175:	89 e8                	mov    %ebp,%eax
  802177:	89 f2                	mov    %esi,%edx
  802179:	f7 f3                	div    %ebx
  80217b:	89 fa                	mov    %edi,%edx
  80217d:	83 c4 1c             	add    $0x1c,%esp
  802180:	5b                   	pop    %ebx
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	39 f0                	cmp    %esi,%eax
  80218a:	76 14                	jbe    8021a0 <__udivdi3+0x50>
  80218c:	31 ff                	xor    %edi,%edi
  80218e:	31 c0                	xor    %eax,%eax
  802190:	89 fa                	mov    %edi,%edx
  802192:	83 c4 1c             	add    $0x1c,%esp
  802195:	5b                   	pop    %ebx
  802196:	5e                   	pop    %esi
  802197:	5f                   	pop    %edi
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    
  80219a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a0:	0f bd f8             	bsr    %eax,%edi
  8021a3:	83 f7 1f             	xor    $0x1f,%edi
  8021a6:	75 48                	jne    8021f0 <__udivdi3+0xa0>
  8021a8:	39 f0                	cmp    %esi,%eax
  8021aa:	72 06                	jb     8021b2 <__udivdi3+0x62>
  8021ac:	31 c0                	xor    %eax,%eax
  8021ae:	39 eb                	cmp    %ebp,%ebx
  8021b0:	77 de                	ja     802190 <__udivdi3+0x40>
  8021b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b7:	eb d7                	jmp    802190 <__udivdi3+0x40>
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d9                	mov    %ebx,%ecx
  8021c2:	85 db                	test   %ebx,%ebx
  8021c4:	75 0b                	jne    8021d1 <__udivdi3+0x81>
  8021c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021cb:	31 d2                	xor    %edx,%edx
  8021cd:	f7 f3                	div    %ebx
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	89 f0                	mov    %esi,%eax
  8021d5:	f7 f1                	div    %ecx
  8021d7:	89 c6                	mov    %eax,%esi
  8021d9:	89 e8                	mov    %ebp,%eax
  8021db:	89 f7                	mov    %esi,%edi
  8021dd:	f7 f1                	div    %ecx
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 f9                	mov    %edi,%ecx
  8021f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8021f7:	29 fa                	sub    %edi,%edx
  8021f9:	d3 e0                	shl    %cl,%eax
  8021fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021ff:	89 d1                	mov    %edx,%ecx
  802201:	89 d8                	mov    %ebx,%eax
  802203:	d3 e8                	shr    %cl,%eax
  802205:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802209:	09 c1                	or     %eax,%ecx
  80220b:	89 f0                	mov    %esi,%eax
  80220d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802211:	89 f9                	mov    %edi,%ecx
  802213:	d3 e3                	shl    %cl,%ebx
  802215:	89 d1                	mov    %edx,%ecx
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 f9                	mov    %edi,%ecx
  80221b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80221f:	89 eb                	mov    %ebp,%ebx
  802221:	d3 e6                	shl    %cl,%esi
  802223:	89 d1                	mov    %edx,%ecx
  802225:	d3 eb                	shr    %cl,%ebx
  802227:	09 f3                	or     %esi,%ebx
  802229:	89 c6                	mov    %eax,%esi
  80222b:	89 f2                	mov    %esi,%edx
  80222d:	89 d8                	mov    %ebx,%eax
  80222f:	f7 74 24 08          	divl   0x8(%esp)
  802233:	89 d6                	mov    %edx,%esi
  802235:	89 c3                	mov    %eax,%ebx
  802237:	f7 64 24 0c          	mull   0xc(%esp)
  80223b:	39 d6                	cmp    %edx,%esi
  80223d:	72 19                	jb     802258 <__udivdi3+0x108>
  80223f:	89 f9                	mov    %edi,%ecx
  802241:	d3 e5                	shl    %cl,%ebp
  802243:	39 c5                	cmp    %eax,%ebp
  802245:	73 04                	jae    80224b <__udivdi3+0xfb>
  802247:	39 d6                	cmp    %edx,%esi
  802249:	74 0d                	je     802258 <__udivdi3+0x108>
  80224b:	89 d8                	mov    %ebx,%eax
  80224d:	31 ff                	xor    %edi,%edi
  80224f:	e9 3c ff ff ff       	jmp    802190 <__udivdi3+0x40>
  802254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802258:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80225b:	31 ff                	xor    %edi,%edi
  80225d:	e9 2e ff ff ff       	jmp    802190 <__udivdi3+0x40>
  802262:	66 90                	xchg   %ax,%ax
  802264:	66 90                	xchg   %ax,%ax
  802266:	66 90                	xchg   %ax,%ax
  802268:	66 90                	xchg   %ax,%ax
  80226a:	66 90                	xchg   %ax,%ax
  80226c:	66 90                	xchg   %ax,%ax
  80226e:	66 90                	xchg   %ax,%ax

00802270 <__umoddi3>:
  802270:	f3 0f 1e fb          	endbr32 
  802274:	55                   	push   %ebp
  802275:	57                   	push   %edi
  802276:	56                   	push   %esi
  802277:	53                   	push   %ebx
  802278:	83 ec 1c             	sub    $0x1c,%esp
  80227b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80227f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802283:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802287:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80228b:	89 f0                	mov    %esi,%eax
  80228d:	89 da                	mov    %ebx,%edx
  80228f:	85 ff                	test   %edi,%edi
  802291:	75 15                	jne    8022a8 <__umoddi3+0x38>
  802293:	39 dd                	cmp    %ebx,%ebp
  802295:	76 39                	jbe    8022d0 <__umoddi3+0x60>
  802297:	f7 f5                	div    %ebp
  802299:	89 d0                	mov    %edx,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	83 c4 1c             	add    $0x1c,%esp
  8022a0:	5b                   	pop    %ebx
  8022a1:	5e                   	pop    %esi
  8022a2:	5f                   	pop    %edi
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    
  8022a5:	8d 76 00             	lea    0x0(%esi),%esi
  8022a8:	39 df                	cmp    %ebx,%edi
  8022aa:	77 f1                	ja     80229d <__umoddi3+0x2d>
  8022ac:	0f bd cf             	bsr    %edi,%ecx
  8022af:	83 f1 1f             	xor    $0x1f,%ecx
  8022b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022b6:	75 40                	jne    8022f8 <__umoddi3+0x88>
  8022b8:	39 df                	cmp    %ebx,%edi
  8022ba:	72 04                	jb     8022c0 <__umoddi3+0x50>
  8022bc:	39 f5                	cmp    %esi,%ebp
  8022be:	77 dd                	ja     80229d <__umoddi3+0x2d>
  8022c0:	89 da                	mov    %ebx,%edx
  8022c2:	89 f0                	mov    %esi,%eax
  8022c4:	29 e8                	sub    %ebp,%eax
  8022c6:	19 fa                	sbb    %edi,%edx
  8022c8:	eb d3                	jmp    80229d <__umoddi3+0x2d>
  8022ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d0:	89 e9                	mov    %ebp,%ecx
  8022d2:	85 ed                	test   %ebp,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x71>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f5                	div    %ebp
  8022df:	89 c1                	mov    %eax,%ecx
  8022e1:	89 d8                	mov    %ebx,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f1                	div    %ecx
  8022e7:	89 f0                	mov    %esi,%eax
  8022e9:	f7 f1                	div    %ecx
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	31 d2                	xor    %edx,%edx
  8022ef:	eb ac                	jmp    80229d <__umoddi3+0x2d>
  8022f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022fc:	ba 20 00 00 00       	mov    $0x20,%edx
  802301:	29 c2                	sub    %eax,%edx
  802303:	89 c1                	mov    %eax,%ecx
  802305:	89 e8                	mov    %ebp,%eax
  802307:	d3 e7                	shl    %cl,%edi
  802309:	89 d1                	mov    %edx,%ecx
  80230b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80230f:	d3 e8                	shr    %cl,%eax
  802311:	89 c1                	mov    %eax,%ecx
  802313:	8b 44 24 04          	mov    0x4(%esp),%eax
  802317:	09 f9                	or     %edi,%ecx
  802319:	89 df                	mov    %ebx,%edi
  80231b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231f:	89 c1                	mov    %eax,%ecx
  802321:	d3 e5                	shl    %cl,%ebp
  802323:	89 d1                	mov    %edx,%ecx
  802325:	d3 ef                	shr    %cl,%edi
  802327:	89 c1                	mov    %eax,%ecx
  802329:	89 f0                	mov    %esi,%eax
  80232b:	d3 e3                	shl    %cl,%ebx
  80232d:	89 d1                	mov    %edx,%ecx
  80232f:	89 fa                	mov    %edi,%edx
  802331:	d3 e8                	shr    %cl,%eax
  802333:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802338:	09 d8                	or     %ebx,%eax
  80233a:	f7 74 24 08          	divl   0x8(%esp)
  80233e:	89 d3                	mov    %edx,%ebx
  802340:	d3 e6                	shl    %cl,%esi
  802342:	f7 e5                	mul    %ebp
  802344:	89 c7                	mov    %eax,%edi
  802346:	89 d1                	mov    %edx,%ecx
  802348:	39 d3                	cmp    %edx,%ebx
  80234a:	72 06                	jb     802352 <__umoddi3+0xe2>
  80234c:	75 0e                	jne    80235c <__umoddi3+0xec>
  80234e:	39 c6                	cmp    %eax,%esi
  802350:	73 0a                	jae    80235c <__umoddi3+0xec>
  802352:	29 e8                	sub    %ebp,%eax
  802354:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802358:	89 d1                	mov    %edx,%ecx
  80235a:	89 c7                	mov    %eax,%edi
  80235c:	89 f5                	mov    %esi,%ebp
  80235e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802362:	29 fd                	sub    %edi,%ebp
  802364:	19 cb                	sbb    %ecx,%ebx
  802366:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80236b:	89 d8                	mov    %ebx,%eax
  80236d:	d3 e0                	shl    %cl,%eax
  80236f:	89 f1                	mov    %esi,%ecx
  802371:	d3 ed                	shr    %cl,%ebp
  802373:	d3 eb                	shr    %cl,%ebx
  802375:	09 e8                	or     %ebp,%eax
  802377:	89 da                	mov    %ebx,%edx
  802379:	83 c4 1c             	add    $0x1c,%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5e                   	pop    %esi
  80237e:	5f                   	pop    %edi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    
