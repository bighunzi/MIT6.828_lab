
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
  800044:	68 91 28 80 00       	push   $0x802891
  800049:	68 60 28 80 00       	push   $0x802860
  80004e:	e8 c9 06 00 00       	call   80071c <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	push   (%ebx)
  800055:	ff 36                	push   (%esi)
  800057:	68 70 28 80 00       	push   $0x802870
  80005c:	68 74 28 80 00       	push   $0x802874
  800061:	e8 b6 06 00 00       	call   80071c <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 88 28 80 00       	push   $0x802888
  80007b:	e8 9c 06 00 00       	call   80071c <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	push   0x4(%ebx)
  80008b:	ff 76 04             	push   0x4(%esi)
  80008e:	68 92 28 80 00       	push   $0x802892
  800093:	68 74 28 80 00       	push   $0x802874
  800098:	e8 7f 06 00 00       	call   80071c <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 88 28 80 00       	push   $0x802888
  8000b4:	e8 63 06 00 00       	call   80071c <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	push   0x8(%ebx)
  8000c4:	ff 76 08             	push   0x8(%esi)
  8000c7:	68 96 28 80 00       	push   $0x802896
  8000cc:	68 74 28 80 00       	push   $0x802874
  8000d1:	e8 46 06 00 00       	call   80071c <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 88 28 80 00       	push   $0x802888
  8000ed:	e8 2a 06 00 00       	call   80071c <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	push   0x10(%ebx)
  8000fd:	ff 76 10             	push   0x10(%esi)
  800100:	68 9a 28 80 00       	push   $0x80289a
  800105:	68 74 28 80 00       	push   $0x802874
  80010a:	e8 0d 06 00 00       	call   80071c <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 88 28 80 00       	push   $0x802888
  800126:	e8 f1 05 00 00       	call   80071c <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	push   0x14(%ebx)
  800136:	ff 76 14             	push   0x14(%esi)
  800139:	68 9e 28 80 00       	push   $0x80289e
  80013e:	68 74 28 80 00       	push   $0x802874
  800143:	e8 d4 05 00 00       	call   80071c <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 88 28 80 00       	push   $0x802888
  80015f:	e8 b8 05 00 00       	call   80071c <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	push   0x18(%ebx)
  80016f:	ff 76 18             	push   0x18(%esi)
  800172:	68 a2 28 80 00       	push   $0x8028a2
  800177:	68 74 28 80 00       	push   $0x802874
  80017c:	e8 9b 05 00 00       	call   80071c <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 88 28 80 00       	push   $0x802888
  800198:	e8 7f 05 00 00       	call   80071c <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	push   0x1c(%ebx)
  8001a8:	ff 76 1c             	push   0x1c(%esi)
  8001ab:	68 a6 28 80 00       	push   $0x8028a6
  8001b0:	68 74 28 80 00       	push   $0x802874
  8001b5:	e8 62 05 00 00       	call   80071c <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 88 28 80 00       	push   $0x802888
  8001d1:	e8 46 05 00 00       	call   80071c <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	push   0x20(%ebx)
  8001e1:	ff 76 20             	push   0x20(%esi)
  8001e4:	68 aa 28 80 00       	push   $0x8028aa
  8001e9:	68 74 28 80 00       	push   $0x802874
  8001ee:	e8 29 05 00 00       	call   80071c <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 88 28 80 00       	push   $0x802888
  80020a:	e8 0d 05 00 00       	call   80071c <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	push   0x24(%ebx)
  80021a:	ff 76 24             	push   0x24(%esi)
  80021d:	68 ae 28 80 00       	push   $0x8028ae
  800222:	68 74 28 80 00       	push   $0x802874
  800227:	e8 f0 04 00 00       	call   80071c <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 88 28 80 00       	push   $0x802888
  800243:	e8 d4 04 00 00       	call   80071c <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	push   0x28(%ebx)
  80024b:	ff 76 28             	push   0x28(%esi)
  80024e:	68 b5 28 80 00       	push   $0x8028b5
  800253:	68 74 28 80 00       	push   $0x802874
  800258:	e8 bf 04 00 00       	call   80071c <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 88 28 80 00       	push   $0x802888
  800274:	e8 a3 04 00 00       	call   80071c <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	push   0xc(%ebp)
  80027f:	68 b9 28 80 00       	push   $0x8028b9
  800284:	e8 93 04 00 00       	call   80071c <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 88 28 80 00       	push   $0x802888
  800294:	e8 83 04 00 00       	call   80071c <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 84 28 80 00       	push   $0x802884
  8002a9:	e8 6e 04 00 00       	call   80071c <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 84 28 80 00       	push   $0x802884
  8002c3:	e8 54 04 00 00       	call   80071c <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 84 28 80 00       	push   $0x802884
  8002d8:	e8 3f 04 00 00       	call   80071c <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 84 28 80 00       	push   $0x802884
  8002ed:	e8 2a 04 00 00       	call   80071c <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 84 28 80 00       	push   $0x802884
  800302:	e8 15 04 00 00       	call   80071c <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 84 28 80 00       	push   $0x802884
  800317:	e8 00 04 00 00       	call   80071c <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 84 28 80 00       	push   $0x802884
  80032c:	e8 eb 03 00 00       	call   80071c <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 84 28 80 00       	push   $0x802884
  800341:	e8 d6 03 00 00       	call   80071c <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 84 28 80 00       	push   $0x802884
  800356:	e8 c1 03 00 00       	call   80071c <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	push   0x28(%ebx)
  80035e:	ff 76 28             	push   0x28(%esi)
  800361:	68 b5 28 80 00       	push   $0x8028b5
  800366:	68 74 28 80 00       	push   $0x802874
  80036b:	e8 ac 03 00 00       	call   80071c <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 84 28 80 00       	push   $0x802884
  800387:	e8 90 03 00 00       	call   80071c <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	push   0xc(%ebp)
  800392:	68 b9 28 80 00       	push   $0x8028b9
  800397:	e8 80 03 00 00       	call   80071c <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 84 28 80 00       	push   $0x802884
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
  8003c2:	68 84 28 80 00       	push   $0x802884
  8003c7:	e8 50 03 00 00       	call   80071c <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	push   0xc(%ebp)
  8003d2:	68 b9 28 80 00       	push   $0x8028b9
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
  800466:	68 df 28 80 00       	push   $0x8028df
  80046b:	68 ed 28 80 00       	push   $0x8028ed
  800470:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800475:	ba d8 28 80 00       	mov    $0x8028d8,%edx
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
  8004a5:	68 20 29 80 00       	push   $0x802920
  8004aa:	6a 50                	push   $0x50
  8004ac:	68 c7 28 80 00       	push   $0x8028c7
  8004b1:	e8 8b 01 00 00       	call   800641 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 f4 28 80 00       	push   $0x8028f4
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 c7 28 80 00       	push   $0x8028c7
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
  8004d3:	e8 6c 0e 00 00       	call   801344 <set_pgfault_handler>

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
  8005ac:	68 07 29 80 00       	push   $0x802907
  8005b1:	68 18 29 80 00       	push   $0x802918
  8005b6:	b9 00 40 80 00       	mov    $0x804000,%ecx
  8005bb:	ba d8 28 80 00       	mov    $0x8028d8,%edx
  8005c0:	b8 80 40 80 00       	mov    $0x804080,%eax
  8005c5:	e8 69 fa ff ff       	call   800033 <check_regs>
}
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 54 29 80 00       	push   $0x802954
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
  80062d:	e8 7f 0f 00 00       	call   8015b1 <close_all>
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
  80065f:	68 80 29 80 00       	push   $0x802980
  800664:	e8 b3 00 00 00       	call   80071c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800669:	83 c4 18             	add    $0x18,%esp
  80066c:	53                   	push   %ebx
  80066d:	ff 75 10             	push   0x10(%ebp)
  800670:	e8 56 00 00 00       	call   8006cb <vcprintf>
	cprintf("\n");
  800675:	c7 04 24 90 28 80 00 	movl   $0x802890,(%esp)
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
  80077e:	e8 9d 1e 00 00       	call   802620 <__udivdi3>
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
  8007bc:	e8 7f 1f 00 00       	call   802740 <__umoddi3>
  8007c1:	83 c4 14             	add    $0x14,%esp
  8007c4:	0f be 80 a3 29 80 00 	movsbl 0x8029a3(%eax),%eax
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
  80087e:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
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
  80094c:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800953:	85 d2                	test   %edx,%edx
  800955:	74 18                	je     80096f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800957:	52                   	push   %edx
  800958:	68 f9 2d 80 00       	push   $0x802df9
  80095d:	53                   	push   %ebx
  80095e:	56                   	push   %esi
  80095f:	e8 92 fe ff ff       	call   8007f6 <printfmt>
  800964:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800967:	89 7d 14             	mov    %edi,0x14(%ebp)
  80096a:	e9 66 02 00 00       	jmp    800bd5 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80096f:	50                   	push   %eax
  800970:	68 bb 29 80 00       	push   $0x8029bb
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
  800997:	b8 b4 29 80 00       	mov    $0x8029b4,%eax
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
  8010a3:	68 9f 2c 80 00       	push   $0x802c9f
  8010a8:	6a 2a                	push   $0x2a
  8010aa:	68 bc 2c 80 00       	push   $0x802cbc
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
  801124:	68 9f 2c 80 00       	push   $0x802c9f
  801129:	6a 2a                	push   $0x2a
  80112b:	68 bc 2c 80 00       	push   $0x802cbc
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
  801166:	68 9f 2c 80 00       	push   $0x802c9f
  80116b:	6a 2a                	push   $0x2a
  80116d:	68 bc 2c 80 00       	push   $0x802cbc
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
  8011a8:	68 9f 2c 80 00       	push   $0x802c9f
  8011ad:	6a 2a                	push   $0x2a
  8011af:	68 bc 2c 80 00       	push   $0x802cbc
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
  8011ea:	68 9f 2c 80 00       	push   $0x802c9f
  8011ef:	6a 2a                	push   $0x2a
  8011f1:	68 bc 2c 80 00       	push   $0x802cbc
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
  80122c:	68 9f 2c 80 00       	push   $0x802c9f
  801231:	6a 2a                	push   $0x2a
  801233:	68 bc 2c 80 00       	push   $0x802cbc
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
  80126e:	68 9f 2c 80 00       	push   $0x802c9f
  801273:	6a 2a                	push   $0x2a
  801275:	68 bc 2c 80 00       	push   $0x802cbc
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
  8012d2:	68 9f 2c 80 00       	push   $0x802c9f
  8012d7:	6a 2a                	push   $0x2a
  8012d9:	68 bc 2c 80 00       	push   $0x802cbc
  8012de:	e8 5e f3 ff ff       	call   800641 <_panic>

008012e3 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	57                   	push   %edi
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8012e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ee:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012f3:	89 d1                	mov    %edx,%ecx
  8012f5:	89 d3                	mov    %edx,%ebx
  8012f7:	89 d7                	mov    %edx,%edi
  8012f9:	89 d6                	mov    %edx,%esi
  8012fb:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	57                   	push   %edi
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
	asm volatile("int %1\n"
  801308:	bb 00 00 00 00       	mov    $0x0,%ebx
  80130d:	8b 55 08             	mov    0x8(%ebp),%edx
  801310:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801313:	b8 0f 00 00 00       	mov    $0xf,%eax
  801318:	89 df                	mov    %ebx,%edi
  80131a:	89 de                	mov    %ebx,%esi
  80131c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5f                   	pop    %edi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
	asm volatile("int %1\n"
  801329:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132e:	8b 55 08             	mov    0x8(%ebp),%edx
  801331:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801334:	b8 10 00 00 00       	mov    $0x10,%eax
  801339:	89 df                	mov    %ebx,%edi
  80133b:	89 de                	mov    %ebx,%esi
  80133d:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5f                   	pop    %edi
  801342:	5d                   	pop    %ebp
  801343:	c3                   	ret    

00801344 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80134a:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801351:	74 0a                	je     80135d <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801353:	8b 45 08             	mov    0x8(%ebp),%eax
  801356:	a3 b0 40 80 00       	mov    %eax,0x8040b0
}
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  80135d:	e8 52 fd ff ff       	call   8010b4 <sys_getenvid>
  801362:	83 ec 04             	sub    $0x4,%esp
  801365:	68 07 0e 00 00       	push   $0xe07
  80136a:	68 00 f0 bf ee       	push   $0xeebff000
  80136f:	50                   	push   %eax
  801370:	e8 7d fd ff ff       	call   8010f2 <sys_page_alloc>
		if (r < 0) {
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 2c                	js     8013a8 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80137c:	e8 33 fd ff ff       	call   8010b4 <sys_getenvid>
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	68 ba 13 80 00       	push   $0x8013ba
  801389:	50                   	push   %eax
  80138a:	e8 ae fe ff ff       	call   80123d <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 c0                	test   %eax,%eax
  801394:	79 bd                	jns    801353 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801396:	50                   	push   %eax
  801397:	68 0c 2d 80 00       	push   $0x802d0c
  80139c:	6a 28                	push   $0x28
  80139e:	68 42 2d 80 00       	push   $0x802d42
  8013a3:	e8 99 f2 ff ff       	call   800641 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8013a8:	50                   	push   %eax
  8013a9:	68 cc 2c 80 00       	push   $0x802ccc
  8013ae:	6a 23                	push   $0x23
  8013b0:	68 42 2d 80 00       	push   $0x802d42
  8013b5:	e8 87 f2 ff ff       	call   800641 <_panic>

008013ba <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013ba:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013bb:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	call *%eax
  8013c0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013c2:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8013c5:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8013c9:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8013cc:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8013d0:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8013d4:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8013d6:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8013d9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8013da:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8013dd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8013de:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8013df:	c3                   	ret    

008013e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013eb:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ee:	5d                   	pop    %ebp
  8013ef:	c3                   	ret    

008013f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f6:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8013fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801400:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801405:	5d                   	pop    %ebp
  801406:	c3                   	ret    

00801407 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80140f:	89 c2                	mov    %eax,%edx
  801411:	c1 ea 16             	shr    $0x16,%edx
  801414:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80141b:	f6 c2 01             	test   $0x1,%dl
  80141e:	74 29                	je     801449 <fd_alloc+0x42>
  801420:	89 c2                	mov    %eax,%edx
  801422:	c1 ea 0c             	shr    $0xc,%edx
  801425:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142c:	f6 c2 01             	test   $0x1,%dl
  80142f:	74 18                	je     801449 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801431:	05 00 10 00 00       	add    $0x1000,%eax
  801436:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80143b:	75 d2                	jne    80140f <fd_alloc+0x8>
  80143d:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801442:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801447:	eb 05                	jmp    80144e <fd_alloc+0x47>
			return 0;
  801449:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80144e:	8b 55 08             	mov    0x8(%ebp),%edx
  801451:	89 02                	mov    %eax,(%edx)
}
  801453:	89 c8                	mov    %ecx,%eax
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80145d:	83 f8 1f             	cmp    $0x1f,%eax
  801460:	77 30                	ja     801492 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801462:	c1 e0 0c             	shl    $0xc,%eax
  801465:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80146a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801470:	f6 c2 01             	test   $0x1,%dl
  801473:	74 24                	je     801499 <fd_lookup+0x42>
  801475:	89 c2                	mov    %eax,%edx
  801477:	c1 ea 0c             	shr    $0xc,%edx
  80147a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801481:	f6 c2 01             	test   $0x1,%dl
  801484:	74 1a                	je     8014a0 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801486:	8b 55 0c             	mov    0xc(%ebp),%edx
  801489:	89 02                	mov    %eax,(%edx)
	return 0;
  80148b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801490:	5d                   	pop    %ebp
  801491:	c3                   	ret    
		return -E_INVAL;
  801492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801497:	eb f7                	jmp    801490 <fd_lookup+0x39>
		return -E_INVAL;
  801499:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80149e:	eb f0                	jmp    801490 <fd_lookup+0x39>
  8014a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a5:	eb e9                	jmp    801490 <fd_lookup+0x39>

008014a7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	53                   	push   %ebx
  8014ab:	83 ec 04             	sub    $0x4,%esp
  8014ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8014b6:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8014bb:	39 13                	cmp    %edx,(%ebx)
  8014bd:	74 37                	je     8014f6 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8014bf:	83 c0 01             	add    $0x1,%eax
  8014c2:	8b 1c 85 cc 2d 80 00 	mov    0x802dcc(,%eax,4),%ebx
  8014c9:	85 db                	test   %ebx,%ebx
  8014cb:	75 ee                	jne    8014bb <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014cd:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8014d2:	8b 40 48             	mov    0x48(%eax),%eax
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	52                   	push   %edx
  8014d9:	50                   	push   %eax
  8014da:	68 50 2d 80 00       	push   $0x802d50
  8014df:	e8 38 f2 ff ff       	call   80071c <cprintf>
	*dev = 0;
	return -E_INVAL;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8014ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ef:	89 1a                	mov    %ebx,(%edx)
}
  8014f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    
			return 0;
  8014f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fb:	eb ef                	jmp    8014ec <dev_lookup+0x45>

008014fd <fd_close>:
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	57                   	push   %edi
  801501:	56                   	push   %esi
  801502:	53                   	push   %ebx
  801503:	83 ec 24             	sub    $0x24,%esp
  801506:	8b 75 08             	mov    0x8(%ebp),%esi
  801509:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80150c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80150f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801510:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801516:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801519:	50                   	push   %eax
  80151a:	e8 38 ff ff ff       	call   801457 <fd_lookup>
  80151f:	89 c3                	mov    %eax,%ebx
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	85 c0                	test   %eax,%eax
  801526:	78 05                	js     80152d <fd_close+0x30>
	    || fd != fd2)
  801528:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80152b:	74 16                	je     801543 <fd_close+0x46>
		return (must_exist ? r : 0);
  80152d:	89 f8                	mov    %edi,%eax
  80152f:	84 c0                	test   %al,%al
  801531:	b8 00 00 00 00       	mov    $0x0,%eax
  801536:	0f 44 d8             	cmove  %eax,%ebx
}
  801539:	89 d8                	mov    %ebx,%eax
  80153b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5f                   	pop    %edi
  801541:	5d                   	pop    %ebp
  801542:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	ff 36                	push   (%esi)
  80154c:	e8 56 ff ff ff       	call   8014a7 <dev_lookup>
  801551:	89 c3                	mov    %eax,%ebx
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 1a                	js     801574 <fd_close+0x77>
		if (dev->dev_close)
  80155a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80155d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801560:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801565:	85 c0                	test   %eax,%eax
  801567:	74 0b                	je     801574 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801569:	83 ec 0c             	sub    $0xc,%esp
  80156c:	56                   	push   %esi
  80156d:	ff d0                	call   *%eax
  80156f:	89 c3                	mov    %eax,%ebx
  801571:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	56                   	push   %esi
  801578:	6a 00                	push   $0x0
  80157a:	e8 f8 fb ff ff       	call   801177 <sys_page_unmap>
	return r;
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	eb b5                	jmp    801539 <fd_close+0x3c>

00801584 <close>:

int
close(int fdnum)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80158a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 75 08             	push   0x8(%ebp)
  801591:	e8 c1 fe ff ff       	call   801457 <fd_lookup>
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	79 02                	jns    80159f <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80159d:	c9                   	leave  
  80159e:	c3                   	ret    
		return fd_close(fd, 1);
  80159f:	83 ec 08             	sub    $0x8,%esp
  8015a2:	6a 01                	push   $0x1
  8015a4:	ff 75 f4             	push   -0xc(%ebp)
  8015a7:	e8 51 ff ff ff       	call   8014fd <fd_close>
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb ec                	jmp    80159d <close+0x19>

008015b1 <close_all>:

void
close_all(void)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	e8 be ff ff ff       	call   801584 <close>
	for (i = 0; i < MAXFD; i++)
  8015c6:	83 c3 01             	add    $0x1,%ebx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	83 fb 20             	cmp    $0x20,%ebx
  8015cf:	75 ec                	jne    8015bd <close_all+0xc>
}
  8015d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	57                   	push   %edi
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e2:	50                   	push   %eax
  8015e3:	ff 75 08             	push   0x8(%ebp)
  8015e6:	e8 6c fe ff ff       	call   801457 <fd_lookup>
  8015eb:	89 c3                	mov    %eax,%ebx
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	85 c0                	test   %eax,%eax
  8015f2:	78 7f                	js     801673 <dup+0x9d>
		return r;
	close(newfdnum);
  8015f4:	83 ec 0c             	sub    $0xc,%esp
  8015f7:	ff 75 0c             	push   0xc(%ebp)
  8015fa:	e8 85 ff ff ff       	call   801584 <close>

	newfd = INDEX2FD(newfdnum);
  8015ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  801602:	c1 e6 0c             	shl    $0xc,%esi
  801605:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80160b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80160e:	89 3c 24             	mov    %edi,(%esp)
  801611:	e8 da fd ff ff       	call   8013f0 <fd2data>
  801616:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801618:	89 34 24             	mov    %esi,(%esp)
  80161b:	e8 d0 fd ff ff       	call   8013f0 <fd2data>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801626:	89 d8                	mov    %ebx,%eax
  801628:	c1 e8 16             	shr    $0x16,%eax
  80162b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801632:	a8 01                	test   $0x1,%al
  801634:	74 11                	je     801647 <dup+0x71>
  801636:	89 d8                	mov    %ebx,%eax
  801638:	c1 e8 0c             	shr    $0xc,%eax
  80163b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801642:	f6 c2 01             	test   $0x1,%dl
  801645:	75 36                	jne    80167d <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801647:	89 f8                	mov    %edi,%eax
  801649:	c1 e8 0c             	shr    $0xc,%eax
  80164c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801653:	83 ec 0c             	sub    $0xc,%esp
  801656:	25 07 0e 00 00       	and    $0xe07,%eax
  80165b:	50                   	push   %eax
  80165c:	56                   	push   %esi
  80165d:	6a 00                	push   $0x0
  80165f:	57                   	push   %edi
  801660:	6a 00                	push   $0x0
  801662:	e8 ce fa ff ff       	call   801135 <sys_page_map>
  801667:	89 c3                	mov    %eax,%ebx
  801669:	83 c4 20             	add    $0x20,%esp
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 33                	js     8016a3 <dup+0xcd>
		goto err;

	return newfdnum;
  801670:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801673:	89 d8                	mov    %ebx,%eax
  801675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5f                   	pop    %edi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80167d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801684:	83 ec 0c             	sub    $0xc,%esp
  801687:	25 07 0e 00 00       	and    $0xe07,%eax
  80168c:	50                   	push   %eax
  80168d:	ff 75 d4             	push   -0x2c(%ebp)
  801690:	6a 00                	push   $0x0
  801692:	53                   	push   %ebx
  801693:	6a 00                	push   $0x0
  801695:	e8 9b fa ff ff       	call   801135 <sys_page_map>
  80169a:	89 c3                	mov    %eax,%ebx
  80169c:	83 c4 20             	add    $0x20,%esp
  80169f:	85 c0                	test   %eax,%eax
  8016a1:	79 a4                	jns    801647 <dup+0x71>
	sys_page_unmap(0, newfd);
  8016a3:	83 ec 08             	sub    $0x8,%esp
  8016a6:	56                   	push   %esi
  8016a7:	6a 00                	push   $0x0
  8016a9:	e8 c9 fa ff ff       	call   801177 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016ae:	83 c4 08             	add    $0x8,%esp
  8016b1:	ff 75 d4             	push   -0x2c(%ebp)
  8016b4:	6a 00                	push   $0x0
  8016b6:	e8 bc fa ff ff       	call   801177 <sys_page_unmap>
	return r;
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	eb b3                	jmp    801673 <dup+0x9d>

008016c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 18             	sub    $0x18,%esp
  8016c8:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	56                   	push   %esi
  8016d0:	e8 82 fd ff ff       	call   801457 <fd_lookup>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 3c                	js     801718 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dc:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	ff 33                	push   (%ebx)
  8016e8:	e8 ba fd ff ff       	call   8014a7 <dev_lookup>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 24                	js     801718 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016f4:	8b 43 08             	mov    0x8(%ebx),%eax
  8016f7:	83 e0 03             	and    $0x3,%eax
  8016fa:	83 f8 01             	cmp    $0x1,%eax
  8016fd:	74 20                	je     80171f <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801702:	8b 40 08             	mov    0x8(%eax),%eax
  801705:	85 c0                	test   %eax,%eax
  801707:	74 37                	je     801740 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	ff 75 10             	push   0x10(%ebp)
  80170f:	ff 75 0c             	push   0xc(%ebp)
  801712:	53                   	push   %ebx
  801713:	ff d0                	call   *%eax
  801715:	83 c4 10             	add    $0x10,%esp
}
  801718:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5e                   	pop    %esi
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80171f:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801724:	8b 40 48             	mov    0x48(%eax),%eax
  801727:	83 ec 04             	sub    $0x4,%esp
  80172a:	56                   	push   %esi
  80172b:	50                   	push   %eax
  80172c:	68 91 2d 80 00       	push   $0x802d91
  801731:	e8 e6 ef ff ff       	call   80071c <cprintf>
		return -E_INVAL;
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173e:	eb d8                	jmp    801718 <read+0x58>
		return -E_NOT_SUPP;
  801740:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801745:	eb d1                	jmp    801718 <read+0x58>

00801747 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	57                   	push   %edi
  80174b:	56                   	push   %esi
  80174c:	53                   	push   %ebx
  80174d:	83 ec 0c             	sub    $0xc,%esp
  801750:	8b 7d 08             	mov    0x8(%ebp),%edi
  801753:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801756:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175b:	eb 02                	jmp    80175f <readn+0x18>
  80175d:	01 c3                	add    %eax,%ebx
  80175f:	39 f3                	cmp    %esi,%ebx
  801761:	73 21                	jae    801784 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801763:	83 ec 04             	sub    $0x4,%esp
  801766:	89 f0                	mov    %esi,%eax
  801768:	29 d8                	sub    %ebx,%eax
  80176a:	50                   	push   %eax
  80176b:	89 d8                	mov    %ebx,%eax
  80176d:	03 45 0c             	add    0xc(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	57                   	push   %edi
  801772:	e8 49 ff ff ff       	call   8016c0 <read>
		if (m < 0)
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 04                	js     801782 <readn+0x3b>
			return m;
		if (m == 0)
  80177e:	75 dd                	jne    80175d <readn+0x16>
  801780:	eb 02                	jmp    801784 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801782:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801784:	89 d8                	mov    %ebx,%eax
  801786:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5f                   	pop    %edi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	83 ec 18             	sub    $0x18,%esp
  801796:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801799:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179c:	50                   	push   %eax
  80179d:	53                   	push   %ebx
  80179e:	e8 b4 fc ff ff       	call   801457 <fd_lookup>
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	78 37                	js     8017e1 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017aa:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017ad:	83 ec 08             	sub    $0x8,%esp
  8017b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b3:	50                   	push   %eax
  8017b4:	ff 36                	push   (%esi)
  8017b6:	e8 ec fc ff ff       	call   8014a7 <dev_lookup>
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	85 c0                	test   %eax,%eax
  8017c0:	78 1f                	js     8017e1 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017c2:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8017c6:	74 20                	je     8017e8 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	74 37                	je     801809 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017d2:	83 ec 04             	sub    $0x4,%esp
  8017d5:	ff 75 10             	push   0x10(%ebp)
  8017d8:	ff 75 0c             	push   0xc(%ebp)
  8017db:	56                   	push   %esi
  8017dc:	ff d0                	call   *%eax
  8017de:	83 c4 10             	add    $0x10,%esp
}
  8017e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5e                   	pop    %esi
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e8:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8017ed:	8b 40 48             	mov    0x48(%eax),%eax
  8017f0:	83 ec 04             	sub    $0x4,%esp
  8017f3:	53                   	push   %ebx
  8017f4:	50                   	push   %eax
  8017f5:	68 ad 2d 80 00       	push   $0x802dad
  8017fa:	e8 1d ef ff ff       	call   80071c <cprintf>
		return -E_INVAL;
  8017ff:	83 c4 10             	add    $0x10,%esp
  801802:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801807:	eb d8                	jmp    8017e1 <write+0x53>
		return -E_NOT_SUPP;
  801809:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80180e:	eb d1                	jmp    8017e1 <write+0x53>

00801810 <seek>:

int
seek(int fdnum, off_t offset)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801816:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	ff 75 08             	push   0x8(%ebp)
  80181d:	e8 35 fc ff ff       	call   801457 <fd_lookup>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 0e                	js     801837 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801829:	8b 55 0c             	mov    0xc(%ebp),%edx
  80182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801832:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801837:	c9                   	leave  
  801838:	c3                   	ret    

00801839 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	83 ec 18             	sub    $0x18,%esp
  801841:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801847:	50                   	push   %eax
  801848:	53                   	push   %ebx
  801849:	e8 09 fc ff ff       	call   801457 <fd_lookup>
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	85 c0                	test   %eax,%eax
  801853:	78 34                	js     801889 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801855:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80185e:	50                   	push   %eax
  80185f:	ff 36                	push   (%esi)
  801861:	e8 41 fc ff ff       	call   8014a7 <dev_lookup>
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 1c                	js     801889 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80186d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801871:	74 1d                	je     801890 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801876:	8b 40 18             	mov    0x18(%eax),%eax
  801879:	85 c0                	test   %eax,%eax
  80187b:	74 34                	je     8018b1 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	ff 75 0c             	push   0xc(%ebp)
  801883:	56                   	push   %esi
  801884:	ff d0                	call   *%eax
  801886:	83 c4 10             	add    $0x10,%esp
}
  801889:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80188c:	5b                   	pop    %ebx
  80188d:	5e                   	pop    %esi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801890:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801895:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801898:	83 ec 04             	sub    $0x4,%esp
  80189b:	53                   	push   %ebx
  80189c:	50                   	push   %eax
  80189d:	68 70 2d 80 00       	push   $0x802d70
  8018a2:	e8 75 ee ff ff       	call   80071c <cprintf>
		return -E_INVAL;
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018af:	eb d8                	jmp    801889 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8018b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018b6:	eb d1                	jmp    801889 <ftruncate+0x50>

008018b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	56                   	push   %esi
  8018bc:	53                   	push   %ebx
  8018bd:	83 ec 18             	sub    $0x18,%esp
  8018c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c6:	50                   	push   %eax
  8018c7:	ff 75 08             	push   0x8(%ebp)
  8018ca:	e8 88 fb ff ff       	call   801457 <fd_lookup>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 49                	js     80191f <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018df:	50                   	push   %eax
  8018e0:	ff 36                	push   (%esi)
  8018e2:	e8 c0 fb ff ff       	call   8014a7 <dev_lookup>
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 31                	js     80191f <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8018ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018f5:	74 2f                	je     801926 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018f7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018fa:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801901:	00 00 00 
	stat->st_isdir = 0;
  801904:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80190b:	00 00 00 
	stat->st_dev = dev;
  80190e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	53                   	push   %ebx
  801918:	56                   	push   %esi
  801919:	ff 50 14             	call   *0x14(%eax)
  80191c:	83 c4 10             	add    $0x10,%esp
}
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    
		return -E_NOT_SUPP;
  801926:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80192b:	eb f2                	jmp    80191f <fstat+0x67>

0080192d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	6a 00                	push   $0x0
  801937:	ff 75 08             	push   0x8(%ebp)
  80193a:	e8 e4 01 00 00       	call   801b23 <open>
  80193f:	89 c3                	mov    %eax,%ebx
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	78 1b                	js     801963 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801948:	83 ec 08             	sub    $0x8,%esp
  80194b:	ff 75 0c             	push   0xc(%ebp)
  80194e:	50                   	push   %eax
  80194f:	e8 64 ff ff ff       	call   8018b8 <fstat>
  801954:	89 c6                	mov    %eax,%esi
	close(fd);
  801956:	89 1c 24             	mov    %ebx,(%esp)
  801959:	e8 26 fc ff ff       	call   801584 <close>
	return r;
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	89 f3                	mov    %esi,%ebx
}
  801963:	89 d8                	mov    %ebx,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	89 c6                	mov    %eax,%esi
  801973:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801975:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80197c:	74 27                	je     8019a5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80197e:	6a 07                	push   $0x7
  801980:	68 00 50 80 00       	push   $0x805000
  801985:	56                   	push   %esi
  801986:	ff 35 00 60 80 00    	push   0x806000
  80198c:	e8 c4 0b 00 00       	call   802555 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801991:	83 c4 0c             	add    $0xc,%esp
  801994:	6a 00                	push   $0x0
  801996:	53                   	push   %ebx
  801997:	6a 00                	push   $0x0
  801999:	e8 50 0b 00 00       	call   8024ee <ipc_recv>
}
  80199e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5e                   	pop    %esi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019a5:	83 ec 0c             	sub    $0xc,%esp
  8019a8:	6a 01                	push   $0x1
  8019aa:	e8 fa 0b 00 00       	call   8025a9 <ipc_find_env>
  8019af:	a3 00 60 80 00       	mov    %eax,0x806000
  8019b4:	83 c4 10             	add    $0x10,%esp
  8019b7:	eb c5                	jmp    80197e <fsipc+0x12>

008019b9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8019dc:	e8 8b ff ff ff       	call   80196c <fsipc>
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <devfile_flush>:
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ef:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8019fe:	e8 69 ff ff ff       	call   80196c <fsipc>
}
  801a03:	c9                   	leave  
  801a04:	c3                   	ret    

00801a05 <devfile_stat>:
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	53                   	push   %ebx
  801a09:	83 ec 04             	sub    $0x4,%esp
  801a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a12:	8b 40 0c             	mov    0xc(%eax),%eax
  801a15:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1f:	b8 05 00 00 00       	mov    $0x5,%eax
  801a24:	e8 43 ff ff ff       	call   80196c <fsipc>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 2c                	js     801a59 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a2d:	83 ec 08             	sub    $0x8,%esp
  801a30:	68 00 50 80 00       	push   $0x805000
  801a35:	53                   	push   %ebx
  801a36:	e8 bb f2 ff ff       	call   800cf6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a3b:	a1 80 50 80 00       	mov    0x805080,%eax
  801a40:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a46:	a1 84 50 80 00       	mov    0x805084,%eax
  801a4b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a59:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <devfile_write>:
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	8b 45 10             	mov    0x10(%ebp),%eax
  801a67:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a6c:	39 d0                	cmp    %edx,%eax
  801a6e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a71:	8b 55 08             	mov    0x8(%ebp),%edx
  801a74:	8b 52 0c             	mov    0xc(%edx),%edx
  801a77:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a7d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a82:	50                   	push   %eax
  801a83:	ff 75 0c             	push   0xc(%ebp)
  801a86:	68 08 50 80 00       	push   $0x805008
  801a8b:	e8 fc f3 ff ff       	call   800e8c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801a90:	ba 00 00 00 00       	mov    $0x0,%edx
  801a95:	b8 04 00 00 00       	mov    $0x4,%eax
  801a9a:	e8 cd fe ff ff       	call   80196c <fsipc>
}
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <devfile_read>:
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801aa9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aac:	8b 40 0c             	mov    0xc(%eax),%eax
  801aaf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ab4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aba:	ba 00 00 00 00       	mov    $0x0,%edx
  801abf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ac4:	e8 a3 fe ff ff       	call   80196c <fsipc>
  801ac9:	89 c3                	mov    %eax,%ebx
  801acb:	85 c0                	test   %eax,%eax
  801acd:	78 1f                	js     801aee <devfile_read+0x4d>
	assert(r <= n);
  801acf:	39 f0                	cmp    %esi,%eax
  801ad1:	77 24                	ja     801af7 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801ad3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ad8:	7f 33                	jg     801b0d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ada:	83 ec 04             	sub    $0x4,%esp
  801add:	50                   	push   %eax
  801ade:	68 00 50 80 00       	push   $0x805000
  801ae3:	ff 75 0c             	push   0xc(%ebp)
  801ae6:	e8 a1 f3 ff ff       	call   800e8c <memmove>
	return r;
  801aeb:	83 c4 10             	add    $0x10,%esp
}
  801aee:	89 d8                	mov    %ebx,%eax
  801af0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5e                   	pop    %esi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    
	assert(r <= n);
  801af7:	68 e0 2d 80 00       	push   $0x802de0
  801afc:	68 e7 2d 80 00       	push   $0x802de7
  801b01:	6a 7c                	push   $0x7c
  801b03:	68 fc 2d 80 00       	push   $0x802dfc
  801b08:	e8 34 eb ff ff       	call   800641 <_panic>
	assert(r <= PGSIZE);
  801b0d:	68 07 2e 80 00       	push   $0x802e07
  801b12:	68 e7 2d 80 00       	push   $0x802de7
  801b17:	6a 7d                	push   $0x7d
  801b19:	68 fc 2d 80 00       	push   $0x802dfc
  801b1e:	e8 1e eb ff ff       	call   800641 <_panic>

00801b23 <open>:
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 1c             	sub    $0x1c,%esp
  801b2b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b2e:	56                   	push   %esi
  801b2f:	e8 87 f1 ff ff       	call   800cbb <strlen>
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b3c:	7f 6c                	jg     801baa <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b44:	50                   	push   %eax
  801b45:	e8 bd f8 ff ff       	call   801407 <fd_alloc>
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 3c                	js     801b8f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	56                   	push   %esi
  801b57:	68 00 50 80 00       	push   $0x805000
  801b5c:	e8 95 f1 ff ff       	call   800cf6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b64:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b69:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801b71:	e8 f6 fd ff ff       	call   80196c <fsipc>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	83 c4 10             	add    $0x10,%esp
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 19                	js     801b98 <open+0x75>
	return fd2num(fd);
  801b7f:	83 ec 0c             	sub    $0xc,%esp
  801b82:	ff 75 f4             	push   -0xc(%ebp)
  801b85:	e8 56 f8 ff ff       	call   8013e0 <fd2num>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	83 c4 10             	add    $0x10,%esp
}
  801b8f:	89 d8                	mov    %ebx,%eax
  801b91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b94:	5b                   	pop    %ebx
  801b95:	5e                   	pop    %esi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
		fd_close(fd, 0);
  801b98:	83 ec 08             	sub    $0x8,%esp
  801b9b:	6a 00                	push   $0x0
  801b9d:	ff 75 f4             	push   -0xc(%ebp)
  801ba0:	e8 58 f9 ff ff       	call   8014fd <fd_close>
		return r;
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	eb e5                	jmp    801b8f <open+0x6c>
		return -E_BAD_PATH;
  801baa:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801baf:	eb de                	jmp    801b8f <open+0x6c>

00801bb1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bbc:	b8 08 00 00 00       	mov    $0x8,%eax
  801bc1:	e8 a6 fd ff ff       	call   80196c <fsipc>
}
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bce:	68 13 2e 80 00       	push   $0x802e13
  801bd3:	ff 75 0c             	push   0xc(%ebp)
  801bd6:	e8 1b f1 ff ff       	call   800cf6 <strcpy>
	return 0;
}
  801bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <devsock_close>:
{
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	53                   	push   %ebx
  801be6:	83 ec 10             	sub    $0x10,%esp
  801be9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bec:	53                   	push   %ebx
  801bed:	e8 f0 09 00 00       	call   8025e2 <pageref>
  801bf2:	89 c2                	mov    %eax,%edx
  801bf4:	83 c4 10             	add    $0x10,%esp
		return 0;
  801bf7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801bfc:	83 fa 01             	cmp    $0x1,%edx
  801bff:	74 05                	je     801c06 <devsock_close+0x24>
}
  801c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801c06:	83 ec 0c             	sub    $0xc,%esp
  801c09:	ff 73 0c             	push   0xc(%ebx)
  801c0c:	e8 b7 02 00 00       	call   801ec8 <nsipc_close>
  801c11:	83 c4 10             	add    $0x10,%esp
  801c14:	eb eb                	jmp    801c01 <devsock_close+0x1f>

00801c16 <devsock_write>:
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c1c:	6a 00                	push   $0x0
  801c1e:	ff 75 10             	push   0x10(%ebp)
  801c21:	ff 75 0c             	push   0xc(%ebp)
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	ff 70 0c             	push   0xc(%eax)
  801c2a:	e8 79 03 00 00       	call   801fa8 <nsipc_send>
}
  801c2f:	c9                   	leave  
  801c30:	c3                   	ret    

00801c31 <devsock_read>:
{
  801c31:	55                   	push   %ebp
  801c32:	89 e5                	mov    %esp,%ebp
  801c34:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c37:	6a 00                	push   $0x0
  801c39:	ff 75 10             	push   0x10(%ebp)
  801c3c:	ff 75 0c             	push   0xc(%ebp)
  801c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c42:	ff 70 0c             	push   0xc(%eax)
  801c45:	e8 ef 02 00 00       	call   801f39 <nsipc_recv>
}
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <fd2sockid>:
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c55:	52                   	push   %edx
  801c56:	50                   	push   %eax
  801c57:	e8 fb f7 ff ff       	call   801457 <fd_lookup>
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	78 10                	js     801c73 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c66:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c6c:	39 08                	cmp    %ecx,(%eax)
  801c6e:	75 05                	jne    801c75 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801c70:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    
		return -E_NOT_SUPP;
  801c75:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c7a:	eb f7                	jmp    801c73 <fd2sockid+0x27>

00801c7c <alloc_sockfd>:
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	56                   	push   %esi
  801c80:	53                   	push   %ebx
  801c81:	83 ec 1c             	sub    $0x1c,%esp
  801c84:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801c86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c89:	50                   	push   %eax
  801c8a:	e8 78 f7 ff ff       	call   801407 <fd_alloc>
  801c8f:	89 c3                	mov    %eax,%ebx
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 43                	js     801cdb <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	68 07 04 00 00       	push   $0x407
  801ca0:	ff 75 f4             	push   -0xc(%ebp)
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 48 f4 ff ff       	call   8010f2 <sys_page_alloc>
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	83 c4 10             	add    $0x10,%esp
  801caf:	85 c0                	test   %eax,%eax
  801cb1:	78 28                	js     801cdb <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cbc:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801cc8:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ccb:	83 ec 0c             	sub    $0xc,%esp
  801cce:	50                   	push   %eax
  801ccf:	e8 0c f7 ff ff       	call   8013e0 <fd2num>
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	83 c4 10             	add    $0x10,%esp
  801cd9:	eb 0c                	jmp    801ce7 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801cdb:	83 ec 0c             	sub    $0xc,%esp
  801cde:	56                   	push   %esi
  801cdf:	e8 e4 01 00 00       	call   801ec8 <nsipc_close>
		return r;
  801ce4:	83 c4 10             	add    $0x10,%esp
}
  801ce7:	89 d8                	mov    %ebx,%eax
  801ce9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5e                   	pop    %esi
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <accept>:
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf9:	e8 4e ff ff ff       	call   801c4c <fd2sockid>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 1b                	js     801d1d <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d02:	83 ec 04             	sub    $0x4,%esp
  801d05:	ff 75 10             	push   0x10(%ebp)
  801d08:	ff 75 0c             	push   0xc(%ebp)
  801d0b:	50                   	push   %eax
  801d0c:	e8 0e 01 00 00       	call   801e1f <nsipc_accept>
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	78 05                	js     801d1d <accept+0x2d>
	return alloc_sockfd(r);
  801d18:	e8 5f ff ff ff       	call   801c7c <alloc_sockfd>
}
  801d1d:	c9                   	leave  
  801d1e:	c3                   	ret    

00801d1f <bind>:
{
  801d1f:	55                   	push   %ebp
  801d20:	89 e5                	mov    %esp,%ebp
  801d22:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d25:	8b 45 08             	mov    0x8(%ebp),%eax
  801d28:	e8 1f ff ff ff       	call   801c4c <fd2sockid>
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	78 12                	js     801d43 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801d31:	83 ec 04             	sub    $0x4,%esp
  801d34:	ff 75 10             	push   0x10(%ebp)
  801d37:	ff 75 0c             	push   0xc(%ebp)
  801d3a:	50                   	push   %eax
  801d3b:	e8 31 01 00 00       	call   801e71 <nsipc_bind>
  801d40:	83 c4 10             	add    $0x10,%esp
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <shutdown>:
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	e8 f9 fe ff ff       	call   801c4c <fd2sockid>
  801d53:	85 c0                	test   %eax,%eax
  801d55:	78 0f                	js     801d66 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801d57:	83 ec 08             	sub    $0x8,%esp
  801d5a:	ff 75 0c             	push   0xc(%ebp)
  801d5d:	50                   	push   %eax
  801d5e:	e8 43 01 00 00       	call   801ea6 <nsipc_shutdown>
  801d63:	83 c4 10             	add    $0x10,%esp
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <connect>:
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	e8 d6 fe ff ff       	call   801c4c <fd2sockid>
  801d76:	85 c0                	test   %eax,%eax
  801d78:	78 12                	js     801d8c <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801d7a:	83 ec 04             	sub    $0x4,%esp
  801d7d:	ff 75 10             	push   0x10(%ebp)
  801d80:	ff 75 0c             	push   0xc(%ebp)
  801d83:	50                   	push   %eax
  801d84:	e8 59 01 00 00       	call   801ee2 <nsipc_connect>
  801d89:	83 c4 10             	add    $0x10,%esp
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <listen>:
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801d94:	8b 45 08             	mov    0x8(%ebp),%eax
  801d97:	e8 b0 fe ff ff       	call   801c4c <fd2sockid>
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	78 0f                	js     801daf <listen+0x21>
	return nsipc_listen(r, backlog);
  801da0:	83 ec 08             	sub    $0x8,%esp
  801da3:	ff 75 0c             	push   0xc(%ebp)
  801da6:	50                   	push   %eax
  801da7:	e8 6b 01 00 00       	call   801f17 <nsipc_listen>
  801dac:	83 c4 10             	add    $0x10,%esp
}
  801daf:	c9                   	leave  
  801db0:	c3                   	ret    

00801db1 <socket>:

int
socket(int domain, int type, int protocol)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801db7:	ff 75 10             	push   0x10(%ebp)
  801dba:	ff 75 0c             	push   0xc(%ebp)
  801dbd:	ff 75 08             	push   0x8(%ebp)
  801dc0:	e8 41 02 00 00       	call   802006 <nsipc_socket>
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	78 05                	js     801dd1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801dcc:	e8 ab fe ff ff       	call   801c7c <alloc_sockfd>
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	53                   	push   %ebx
  801dd7:	83 ec 04             	sub    $0x4,%esp
  801dda:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ddc:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801de3:	74 26                	je     801e0b <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801de5:	6a 07                	push   $0x7
  801de7:	68 00 70 80 00       	push   $0x807000
  801dec:	53                   	push   %ebx
  801ded:	ff 35 00 80 80 00    	push   0x808000
  801df3:	e8 5d 07 00 00       	call   802555 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801df8:	83 c4 0c             	add    $0xc,%esp
  801dfb:	6a 00                	push   $0x0
  801dfd:	6a 00                	push   $0x0
  801dff:	6a 00                	push   $0x0
  801e01:	e8 e8 06 00 00       	call   8024ee <ipc_recv>
}
  801e06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e09:	c9                   	leave  
  801e0a:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e0b:	83 ec 0c             	sub    $0xc,%esp
  801e0e:	6a 02                	push   $0x2
  801e10:	e8 94 07 00 00       	call   8025a9 <ipc_find_env>
  801e15:	a3 00 80 80 00       	mov    %eax,0x808000
  801e1a:	83 c4 10             	add    $0x10,%esp
  801e1d:	eb c6                	jmp    801de5 <nsipc+0x12>

00801e1f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	56                   	push   %esi
  801e23:	53                   	push   %ebx
  801e24:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e27:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e2f:	8b 06                	mov    (%esi),%eax
  801e31:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	e8 93 ff ff ff       	call   801dd3 <nsipc>
  801e40:	89 c3                	mov    %eax,%ebx
  801e42:	85 c0                	test   %eax,%eax
  801e44:	79 09                	jns    801e4f <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801e46:	89 d8                	mov    %ebx,%eax
  801e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	ff 35 10 70 80 00    	push   0x807010
  801e58:	68 00 70 80 00       	push   $0x807000
  801e5d:	ff 75 0c             	push   0xc(%ebp)
  801e60:	e8 27 f0 ff ff       	call   800e8c <memmove>
		*addrlen = ret->ret_addrlen;
  801e65:	a1 10 70 80 00       	mov    0x807010,%eax
  801e6a:	89 06                	mov    %eax,(%esi)
  801e6c:	83 c4 10             	add    $0x10,%esp
	return r;
  801e6f:	eb d5                	jmp    801e46 <nsipc_accept+0x27>

00801e71 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	53                   	push   %ebx
  801e75:	83 ec 08             	sub    $0x8,%esp
  801e78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e83:	53                   	push   %ebx
  801e84:	ff 75 0c             	push   0xc(%ebp)
  801e87:	68 04 70 80 00       	push   $0x807004
  801e8c:	e8 fb ef ff ff       	call   800e8c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e91:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801e97:	b8 02 00 00 00       	mov    $0x2,%eax
  801e9c:	e8 32 ff ff ff       	call   801dd3 <nsipc>
}
  801ea1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ea4:	c9                   	leave  
  801ea5:	c3                   	ret    

00801ea6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801eac:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb7:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801ebc:	b8 03 00 00 00       	mov    $0x3,%eax
  801ec1:	e8 0d ff ff ff       	call   801dd3 <nsipc>
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <nsipc_close>:

int
nsipc_close(int s)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
  801ecb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ece:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed1:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801ed6:	b8 04 00 00 00       	mov    $0x4,%eax
  801edb:	e8 f3 fe ff ff       	call   801dd3 <nsipc>
}
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ef4:	53                   	push   %ebx
  801ef5:	ff 75 0c             	push   0xc(%ebp)
  801ef8:	68 04 70 80 00       	push   $0x807004
  801efd:	e8 8a ef ff ff       	call   800e8c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f02:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801f08:	b8 05 00 00 00       	mov    $0x5,%eax
  801f0d:	e8 c1 fe ff ff       	call   801dd3 <nsipc>
}
  801f12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f20:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f28:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f2d:	b8 06 00 00 00       	mov    $0x6,%eax
  801f32:	e8 9c fe ff ff       	call   801dd3 <nsipc>
}
  801f37:	c9                   	leave  
  801f38:	c3                   	ret    

00801f39 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	56                   	push   %esi
  801f3d:	53                   	push   %ebx
  801f3e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f41:	8b 45 08             	mov    0x8(%ebp),%eax
  801f44:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801f49:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801f4f:	8b 45 14             	mov    0x14(%ebp),%eax
  801f52:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f57:	b8 07 00 00 00       	mov    $0x7,%eax
  801f5c:	e8 72 fe ff ff       	call   801dd3 <nsipc>
  801f61:	89 c3                	mov    %eax,%ebx
  801f63:	85 c0                	test   %eax,%eax
  801f65:	78 22                	js     801f89 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801f67:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801f6c:	39 c6                	cmp    %eax,%esi
  801f6e:	0f 4e c6             	cmovle %esi,%eax
  801f71:	39 c3                	cmp    %eax,%ebx
  801f73:	7f 1d                	jg     801f92 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f75:	83 ec 04             	sub    $0x4,%esp
  801f78:	53                   	push   %ebx
  801f79:	68 00 70 80 00       	push   $0x807000
  801f7e:	ff 75 0c             	push   0xc(%ebp)
  801f81:	e8 06 ef ff ff       	call   800e8c <memmove>
  801f86:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f89:	89 d8                	mov    %ebx,%eax
  801f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801f92:	68 1f 2e 80 00       	push   $0x802e1f
  801f97:	68 e7 2d 80 00       	push   $0x802de7
  801f9c:	6a 62                	push   $0x62
  801f9e:	68 34 2e 80 00       	push   $0x802e34
  801fa3:	e8 99 e6 ff ff       	call   800641 <_panic>

00801fa8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	53                   	push   %ebx
  801fac:	83 ec 04             	sub    $0x4,%esp
  801faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb5:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801fba:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fc0:	7f 2e                	jg     801ff0 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fc2:	83 ec 04             	sub    $0x4,%esp
  801fc5:	53                   	push   %ebx
  801fc6:	ff 75 0c             	push   0xc(%ebp)
  801fc9:	68 0c 70 80 00       	push   $0x80700c
  801fce:	e8 b9 ee ff ff       	call   800e8c <memmove>
	nsipcbuf.send.req_size = size;
  801fd3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801fd9:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801fe1:	b8 08 00 00 00       	mov    $0x8,%eax
  801fe6:	e8 e8 fd ff ff       	call   801dd3 <nsipc>
}
  801feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    
	assert(size < 1600);
  801ff0:	68 40 2e 80 00       	push   $0x802e40
  801ff5:	68 e7 2d 80 00       	push   $0x802de7
  801ffa:	6a 6d                	push   $0x6d
  801ffc:	68 34 2e 80 00       	push   $0x802e34
  802001:	e8 3b e6 ff ff       	call   800641 <_panic>

00802006 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80200c:	8b 45 08             	mov    0x8(%ebp),%eax
  80200f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802014:	8b 45 0c             	mov    0xc(%ebp),%eax
  802017:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80201c:	8b 45 10             	mov    0x10(%ebp),%eax
  80201f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802024:	b8 09 00 00 00       	mov    $0x9,%eax
  802029:	e8 a5 fd ff ff       	call   801dd3 <nsipc>
}
  80202e:	c9                   	leave  
  80202f:	c3                   	ret    

00802030 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
  802035:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	ff 75 08             	push   0x8(%ebp)
  80203e:	e8 ad f3 ff ff       	call   8013f0 <fd2data>
  802043:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802045:	83 c4 08             	add    $0x8,%esp
  802048:	68 4c 2e 80 00       	push   $0x802e4c
  80204d:	53                   	push   %ebx
  80204e:	e8 a3 ec ff ff       	call   800cf6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802053:	8b 46 04             	mov    0x4(%esi),%eax
  802056:	2b 06                	sub    (%esi),%eax
  802058:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80205e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802065:	00 00 00 
	stat->st_dev = &devpipe;
  802068:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80206f:	30 80 00 
	return 0;
}
  802072:	b8 00 00 00 00       	mov    $0x0,%eax
  802077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80207a:	5b                   	pop    %ebx
  80207b:	5e                   	pop    %esi
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	53                   	push   %ebx
  802082:	83 ec 0c             	sub    $0xc,%esp
  802085:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802088:	53                   	push   %ebx
  802089:	6a 00                	push   $0x0
  80208b:	e8 e7 f0 ff ff       	call   801177 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802090:	89 1c 24             	mov    %ebx,(%esp)
  802093:	e8 58 f3 ff ff       	call   8013f0 <fd2data>
  802098:	83 c4 08             	add    $0x8,%esp
  80209b:	50                   	push   %eax
  80209c:	6a 00                	push   $0x0
  80209e:	e8 d4 f0 ff ff       	call   801177 <sys_page_unmap>
}
  8020a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <_pipeisclosed>:
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	57                   	push   %edi
  8020ac:	56                   	push   %esi
  8020ad:	53                   	push   %ebx
  8020ae:	83 ec 1c             	sub    $0x1c,%esp
  8020b1:	89 c7                	mov    %eax,%edi
  8020b3:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8020b5:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8020ba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020bd:	83 ec 0c             	sub    $0xc,%esp
  8020c0:	57                   	push   %edi
  8020c1:	e8 1c 05 00 00       	call   8025e2 <pageref>
  8020c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8020c9:	89 34 24             	mov    %esi,(%esp)
  8020cc:	e8 11 05 00 00       	call   8025e2 <pageref>
		nn = thisenv->env_runs;
  8020d1:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  8020d7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	39 cb                	cmp    %ecx,%ebx
  8020df:	74 1b                	je     8020fc <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8020e1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020e4:	75 cf                	jne    8020b5 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020e6:	8b 42 58             	mov    0x58(%edx),%eax
  8020e9:	6a 01                	push   $0x1
  8020eb:	50                   	push   %eax
  8020ec:	53                   	push   %ebx
  8020ed:	68 53 2e 80 00       	push   $0x802e53
  8020f2:	e8 25 e6 ff ff       	call   80071c <cprintf>
  8020f7:	83 c4 10             	add    $0x10,%esp
  8020fa:	eb b9                	jmp    8020b5 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8020fc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8020ff:	0f 94 c0             	sete   %al
  802102:	0f b6 c0             	movzbl %al,%eax
}
  802105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802108:	5b                   	pop    %ebx
  802109:	5e                   	pop    %esi
  80210a:	5f                   	pop    %edi
  80210b:	5d                   	pop    %ebp
  80210c:	c3                   	ret    

0080210d <devpipe_write>:
{
  80210d:	55                   	push   %ebp
  80210e:	89 e5                	mov    %esp,%ebp
  802110:	57                   	push   %edi
  802111:	56                   	push   %esi
  802112:	53                   	push   %ebx
  802113:	83 ec 28             	sub    $0x28,%esp
  802116:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802119:	56                   	push   %esi
  80211a:	e8 d1 f2 ff ff       	call   8013f0 <fd2data>
  80211f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	bf 00 00 00 00       	mov    $0x0,%edi
  802129:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80212c:	75 09                	jne    802137 <devpipe_write+0x2a>
	return i;
  80212e:	89 f8                	mov    %edi,%eax
  802130:	eb 23                	jmp    802155 <devpipe_write+0x48>
			sys_yield();
  802132:	e8 9c ef ff ff       	call   8010d3 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802137:	8b 43 04             	mov    0x4(%ebx),%eax
  80213a:	8b 0b                	mov    (%ebx),%ecx
  80213c:	8d 51 20             	lea    0x20(%ecx),%edx
  80213f:	39 d0                	cmp    %edx,%eax
  802141:	72 1a                	jb     80215d <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802143:	89 da                	mov    %ebx,%edx
  802145:	89 f0                	mov    %esi,%eax
  802147:	e8 5c ff ff ff       	call   8020a8 <_pipeisclosed>
  80214c:	85 c0                	test   %eax,%eax
  80214e:	74 e2                	je     802132 <devpipe_write+0x25>
				return 0;
  802150:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802155:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5f                   	pop    %edi
  80215b:	5d                   	pop    %ebp
  80215c:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80215d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802160:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802164:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802167:	89 c2                	mov    %eax,%edx
  802169:	c1 fa 1f             	sar    $0x1f,%edx
  80216c:	89 d1                	mov    %edx,%ecx
  80216e:	c1 e9 1b             	shr    $0x1b,%ecx
  802171:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802174:	83 e2 1f             	and    $0x1f,%edx
  802177:	29 ca                	sub    %ecx,%edx
  802179:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80217d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802181:	83 c0 01             	add    $0x1,%eax
  802184:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802187:	83 c7 01             	add    $0x1,%edi
  80218a:	eb 9d                	jmp    802129 <devpipe_write+0x1c>

0080218c <devpipe_read>:
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	57                   	push   %edi
  802190:	56                   	push   %esi
  802191:	53                   	push   %ebx
  802192:	83 ec 18             	sub    $0x18,%esp
  802195:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802198:	57                   	push   %edi
  802199:	e8 52 f2 ff ff       	call   8013f0 <fd2data>
  80219e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	be 00 00 00 00       	mov    $0x0,%esi
  8021a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ab:	75 13                	jne    8021c0 <devpipe_read+0x34>
	return i;
  8021ad:	89 f0                	mov    %esi,%eax
  8021af:	eb 02                	jmp    8021b3 <devpipe_read+0x27>
				return i;
  8021b1:	89 f0                	mov    %esi,%eax
}
  8021b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b6:	5b                   	pop    %ebx
  8021b7:	5e                   	pop    %esi
  8021b8:	5f                   	pop    %edi
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    
			sys_yield();
  8021bb:	e8 13 ef ff ff       	call   8010d3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8021c0:	8b 03                	mov    (%ebx),%eax
  8021c2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021c5:	75 18                	jne    8021df <devpipe_read+0x53>
			if (i > 0)
  8021c7:	85 f6                	test   %esi,%esi
  8021c9:	75 e6                	jne    8021b1 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8021cb:	89 da                	mov    %ebx,%edx
  8021cd:	89 f8                	mov    %edi,%eax
  8021cf:	e8 d4 fe ff ff       	call   8020a8 <_pipeisclosed>
  8021d4:	85 c0                	test   %eax,%eax
  8021d6:	74 e3                	je     8021bb <devpipe_read+0x2f>
				return 0;
  8021d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021dd:	eb d4                	jmp    8021b3 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021df:	99                   	cltd   
  8021e0:	c1 ea 1b             	shr    $0x1b,%edx
  8021e3:	01 d0                	add    %edx,%eax
  8021e5:	83 e0 1f             	and    $0x1f,%eax
  8021e8:	29 d0                	sub    %edx,%eax
  8021ea:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8021ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021f2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8021f5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8021f8:	83 c6 01             	add    $0x1,%esi
  8021fb:	eb ab                	jmp    8021a8 <devpipe_read+0x1c>

008021fd <pipe>:
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	56                   	push   %esi
  802201:	53                   	push   %ebx
  802202:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802205:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802208:	50                   	push   %eax
  802209:	e8 f9 f1 ff ff       	call   801407 <fd_alloc>
  80220e:	89 c3                	mov    %eax,%ebx
  802210:	83 c4 10             	add    $0x10,%esp
  802213:	85 c0                	test   %eax,%eax
  802215:	0f 88 23 01 00 00    	js     80233e <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80221b:	83 ec 04             	sub    $0x4,%esp
  80221e:	68 07 04 00 00       	push   $0x407
  802223:	ff 75 f4             	push   -0xc(%ebp)
  802226:	6a 00                	push   $0x0
  802228:	e8 c5 ee ff ff       	call   8010f2 <sys_page_alloc>
  80222d:	89 c3                	mov    %eax,%ebx
  80222f:	83 c4 10             	add    $0x10,%esp
  802232:	85 c0                	test   %eax,%eax
  802234:	0f 88 04 01 00 00    	js     80233e <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80223a:	83 ec 0c             	sub    $0xc,%esp
  80223d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802240:	50                   	push   %eax
  802241:	e8 c1 f1 ff ff       	call   801407 <fd_alloc>
  802246:	89 c3                	mov    %eax,%ebx
  802248:	83 c4 10             	add    $0x10,%esp
  80224b:	85 c0                	test   %eax,%eax
  80224d:	0f 88 db 00 00 00    	js     80232e <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802253:	83 ec 04             	sub    $0x4,%esp
  802256:	68 07 04 00 00       	push   $0x407
  80225b:	ff 75 f0             	push   -0x10(%ebp)
  80225e:	6a 00                	push   $0x0
  802260:	e8 8d ee ff ff       	call   8010f2 <sys_page_alloc>
  802265:	89 c3                	mov    %eax,%ebx
  802267:	83 c4 10             	add    $0x10,%esp
  80226a:	85 c0                	test   %eax,%eax
  80226c:	0f 88 bc 00 00 00    	js     80232e <pipe+0x131>
	va = fd2data(fd0);
  802272:	83 ec 0c             	sub    $0xc,%esp
  802275:	ff 75 f4             	push   -0xc(%ebp)
  802278:	e8 73 f1 ff ff       	call   8013f0 <fd2data>
  80227d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80227f:	83 c4 0c             	add    $0xc,%esp
  802282:	68 07 04 00 00       	push   $0x407
  802287:	50                   	push   %eax
  802288:	6a 00                	push   $0x0
  80228a:	e8 63 ee ff ff       	call   8010f2 <sys_page_alloc>
  80228f:	89 c3                	mov    %eax,%ebx
  802291:	83 c4 10             	add    $0x10,%esp
  802294:	85 c0                	test   %eax,%eax
  802296:	0f 88 82 00 00 00    	js     80231e <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80229c:	83 ec 0c             	sub    $0xc,%esp
  80229f:	ff 75 f0             	push   -0x10(%ebp)
  8022a2:	e8 49 f1 ff ff       	call   8013f0 <fd2data>
  8022a7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022ae:	50                   	push   %eax
  8022af:	6a 00                	push   $0x0
  8022b1:	56                   	push   %esi
  8022b2:	6a 00                	push   $0x0
  8022b4:	e8 7c ee ff ff       	call   801135 <sys_page_map>
  8022b9:	89 c3                	mov    %eax,%ebx
  8022bb:	83 c4 20             	add    $0x20,%esp
  8022be:	85 c0                	test   %eax,%eax
  8022c0:	78 4e                	js     802310 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8022c2:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8022c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022ca:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8022cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022cf:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8022d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022d9:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8022db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022de:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8022e5:	83 ec 0c             	sub    $0xc,%esp
  8022e8:	ff 75 f4             	push   -0xc(%ebp)
  8022eb:	e8 f0 f0 ff ff       	call   8013e0 <fd2num>
  8022f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022f3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022f5:	83 c4 04             	add    $0x4,%esp
  8022f8:	ff 75 f0             	push   -0x10(%ebp)
  8022fb:	e8 e0 f0 ff ff       	call   8013e0 <fd2num>
  802300:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802303:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802306:	83 c4 10             	add    $0x10,%esp
  802309:	bb 00 00 00 00       	mov    $0x0,%ebx
  80230e:	eb 2e                	jmp    80233e <pipe+0x141>
	sys_page_unmap(0, va);
  802310:	83 ec 08             	sub    $0x8,%esp
  802313:	56                   	push   %esi
  802314:	6a 00                	push   $0x0
  802316:	e8 5c ee ff ff       	call   801177 <sys_page_unmap>
  80231b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80231e:	83 ec 08             	sub    $0x8,%esp
  802321:	ff 75 f0             	push   -0x10(%ebp)
  802324:	6a 00                	push   $0x0
  802326:	e8 4c ee ff ff       	call   801177 <sys_page_unmap>
  80232b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80232e:	83 ec 08             	sub    $0x8,%esp
  802331:	ff 75 f4             	push   -0xc(%ebp)
  802334:	6a 00                	push   $0x0
  802336:	e8 3c ee ff ff       	call   801177 <sys_page_unmap>
  80233b:	83 c4 10             	add    $0x10,%esp
}
  80233e:	89 d8                	mov    %ebx,%eax
  802340:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802343:	5b                   	pop    %ebx
  802344:	5e                   	pop    %esi
  802345:	5d                   	pop    %ebp
  802346:	c3                   	ret    

00802347 <pipeisclosed>:
{
  802347:	55                   	push   %ebp
  802348:	89 e5                	mov    %esp,%ebp
  80234a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80234d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802350:	50                   	push   %eax
  802351:	ff 75 08             	push   0x8(%ebp)
  802354:	e8 fe f0 ff ff       	call   801457 <fd_lookup>
  802359:	83 c4 10             	add    $0x10,%esp
  80235c:	85 c0                	test   %eax,%eax
  80235e:	78 18                	js     802378 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802360:	83 ec 0c             	sub    $0xc,%esp
  802363:	ff 75 f4             	push   -0xc(%ebp)
  802366:	e8 85 f0 ff ff       	call   8013f0 <fd2data>
  80236b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80236d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802370:	e8 33 fd ff ff       	call   8020a8 <_pipeisclosed>
  802375:	83 c4 10             	add    $0x10,%esp
}
  802378:	c9                   	leave  
  802379:	c3                   	ret    

0080237a <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80237a:	b8 00 00 00 00       	mov    $0x0,%eax
  80237f:	c3                   	ret    

00802380 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802386:	68 6b 2e 80 00       	push   $0x802e6b
  80238b:	ff 75 0c             	push   0xc(%ebp)
  80238e:	e8 63 e9 ff ff       	call   800cf6 <strcpy>
	return 0;
}
  802393:	b8 00 00 00 00       	mov    $0x0,%eax
  802398:	c9                   	leave  
  802399:	c3                   	ret    

0080239a <devcons_write>:
{
  80239a:	55                   	push   %ebp
  80239b:	89 e5                	mov    %esp,%ebp
  80239d:	57                   	push   %edi
  80239e:	56                   	push   %esi
  80239f:	53                   	push   %ebx
  8023a0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8023a6:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8023b1:	eb 2e                	jmp    8023e1 <devcons_write+0x47>
		m = n - tot;
  8023b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023b6:	29 f3                	sub    %esi,%ebx
  8023b8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8023bd:	39 c3                	cmp    %eax,%ebx
  8023bf:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8023c2:	83 ec 04             	sub    $0x4,%esp
  8023c5:	53                   	push   %ebx
  8023c6:	89 f0                	mov    %esi,%eax
  8023c8:	03 45 0c             	add    0xc(%ebp),%eax
  8023cb:	50                   	push   %eax
  8023cc:	57                   	push   %edi
  8023cd:	e8 ba ea ff ff       	call   800e8c <memmove>
		sys_cputs(buf, m);
  8023d2:	83 c4 08             	add    $0x8,%esp
  8023d5:	53                   	push   %ebx
  8023d6:	57                   	push   %edi
  8023d7:	e8 5a ec ff ff       	call   801036 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8023dc:	01 de                	add    %ebx,%esi
  8023de:	83 c4 10             	add    $0x10,%esp
  8023e1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023e4:	72 cd                	jb     8023b3 <devcons_write+0x19>
}
  8023e6:	89 f0                	mov    %esi,%eax
  8023e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023eb:	5b                   	pop    %ebx
  8023ec:	5e                   	pop    %esi
  8023ed:	5f                   	pop    %edi
  8023ee:	5d                   	pop    %ebp
  8023ef:	c3                   	ret    

008023f0 <devcons_read>:
{
  8023f0:	55                   	push   %ebp
  8023f1:	89 e5                	mov    %esp,%ebp
  8023f3:	83 ec 08             	sub    $0x8,%esp
  8023f6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8023fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023ff:	75 07                	jne    802408 <devcons_read+0x18>
  802401:	eb 1f                	jmp    802422 <devcons_read+0x32>
		sys_yield();
  802403:	e8 cb ec ff ff       	call   8010d3 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802408:	e8 47 ec ff ff       	call   801054 <sys_cgetc>
  80240d:	85 c0                	test   %eax,%eax
  80240f:	74 f2                	je     802403 <devcons_read+0x13>
	if (c < 0)
  802411:	78 0f                	js     802422 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802413:	83 f8 04             	cmp    $0x4,%eax
  802416:	74 0c                	je     802424 <devcons_read+0x34>
	*(char*)vbuf = c;
  802418:	8b 55 0c             	mov    0xc(%ebp),%edx
  80241b:	88 02                	mov    %al,(%edx)
	return 1;
  80241d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802422:	c9                   	leave  
  802423:	c3                   	ret    
		return 0;
  802424:	b8 00 00 00 00       	mov    $0x0,%eax
  802429:	eb f7                	jmp    802422 <devcons_read+0x32>

0080242b <cputchar>:
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802431:	8b 45 08             	mov    0x8(%ebp),%eax
  802434:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802437:	6a 01                	push   $0x1
  802439:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80243c:	50                   	push   %eax
  80243d:	e8 f4 eb ff ff       	call   801036 <sys_cputs>
}
  802442:	83 c4 10             	add    $0x10,%esp
  802445:	c9                   	leave  
  802446:	c3                   	ret    

00802447 <getchar>:
{
  802447:	55                   	push   %ebp
  802448:	89 e5                	mov    %esp,%ebp
  80244a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80244d:	6a 01                	push   $0x1
  80244f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802452:	50                   	push   %eax
  802453:	6a 00                	push   $0x0
  802455:	e8 66 f2 ff ff       	call   8016c0 <read>
	if (r < 0)
  80245a:	83 c4 10             	add    $0x10,%esp
  80245d:	85 c0                	test   %eax,%eax
  80245f:	78 06                	js     802467 <getchar+0x20>
	if (r < 1)
  802461:	74 06                	je     802469 <getchar+0x22>
	return c;
  802463:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802467:	c9                   	leave  
  802468:	c3                   	ret    
		return -E_EOF;
  802469:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80246e:	eb f7                	jmp    802467 <getchar+0x20>

00802470 <iscons>:
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802476:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802479:	50                   	push   %eax
  80247a:	ff 75 08             	push   0x8(%ebp)
  80247d:	e8 d5 ef ff ff       	call   801457 <fd_lookup>
  802482:	83 c4 10             	add    $0x10,%esp
  802485:	85 c0                	test   %eax,%eax
  802487:	78 11                	js     80249a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802492:	39 10                	cmp    %edx,(%eax)
  802494:	0f 94 c0             	sete   %al
  802497:	0f b6 c0             	movzbl %al,%eax
}
  80249a:	c9                   	leave  
  80249b:	c3                   	ret    

0080249c <opencons>:
{
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8024a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024a5:	50                   	push   %eax
  8024a6:	e8 5c ef ff ff       	call   801407 <fd_alloc>
  8024ab:	83 c4 10             	add    $0x10,%esp
  8024ae:	85 c0                	test   %eax,%eax
  8024b0:	78 3a                	js     8024ec <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b2:	83 ec 04             	sub    $0x4,%esp
  8024b5:	68 07 04 00 00       	push   $0x407
  8024ba:	ff 75 f4             	push   -0xc(%ebp)
  8024bd:	6a 00                	push   $0x0
  8024bf:	e8 2e ec ff ff       	call   8010f2 <sys_page_alloc>
  8024c4:	83 c4 10             	add    $0x10,%esp
  8024c7:	85 c0                	test   %eax,%eax
  8024c9:	78 21                	js     8024ec <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8024cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ce:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024d4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024e0:	83 ec 0c             	sub    $0xc,%esp
  8024e3:	50                   	push   %eax
  8024e4:	e8 f7 ee ff ff       	call   8013e0 <fd2num>
  8024e9:	83 c4 10             	add    $0x10,%esp
}
  8024ec:	c9                   	leave  
  8024ed:	c3                   	ret    

008024ee <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024ee:	55                   	push   %ebp
  8024ef:	89 e5                	mov    %esp,%ebp
  8024f1:	56                   	push   %esi
  8024f2:	53                   	push   %ebx
  8024f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8024f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8024fc:	85 c0                	test   %eax,%eax
  8024fe:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802503:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802506:	83 ec 0c             	sub    $0xc,%esp
  802509:	50                   	push   %eax
  80250a:	e8 93 ed ff ff       	call   8012a2 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80250f:	83 c4 10             	add    $0x10,%esp
  802512:	85 f6                	test   %esi,%esi
  802514:	74 14                	je     80252a <ipc_recv+0x3c>
  802516:	ba 00 00 00 00       	mov    $0x0,%edx
  80251b:	85 c0                	test   %eax,%eax
  80251d:	78 09                	js     802528 <ipc_recv+0x3a>
  80251f:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  802525:	8b 52 74             	mov    0x74(%edx),%edx
  802528:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80252a:	85 db                	test   %ebx,%ebx
  80252c:	74 14                	je     802542 <ipc_recv+0x54>
  80252e:	ba 00 00 00 00       	mov    $0x0,%edx
  802533:	85 c0                	test   %eax,%eax
  802535:	78 09                	js     802540 <ipc_recv+0x52>
  802537:	8b 15 ac 40 80 00    	mov    0x8040ac,%edx
  80253d:	8b 52 78             	mov    0x78(%edx),%edx
  802540:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802542:	85 c0                	test   %eax,%eax
  802544:	78 08                	js     80254e <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802546:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  80254b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80254e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802551:	5b                   	pop    %ebx
  802552:	5e                   	pop    %esi
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    

00802555 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802555:	55                   	push   %ebp
  802556:	89 e5                	mov    %esp,%ebp
  802558:	57                   	push   %edi
  802559:	56                   	push   %esi
  80255a:	53                   	push   %ebx
  80255b:	83 ec 0c             	sub    $0xc,%esp
  80255e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802561:	8b 75 0c             	mov    0xc(%ebp),%esi
  802564:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802567:	85 db                	test   %ebx,%ebx
  802569:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80256e:	0f 44 d8             	cmove  %eax,%ebx
  802571:	eb 05                	jmp    802578 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802573:	e8 5b eb ff ff       	call   8010d3 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802578:	ff 75 14             	push   0x14(%ebp)
  80257b:	53                   	push   %ebx
  80257c:	56                   	push   %esi
  80257d:	57                   	push   %edi
  80257e:	e8 fc ec ff ff       	call   80127f <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802583:	83 c4 10             	add    $0x10,%esp
  802586:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802589:	74 e8                	je     802573 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80258b:	85 c0                	test   %eax,%eax
  80258d:	78 08                	js     802597 <ipc_send+0x42>
	}while (r<0);

}
  80258f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802592:	5b                   	pop    %ebx
  802593:	5e                   	pop    %esi
  802594:	5f                   	pop    %edi
  802595:	5d                   	pop    %ebp
  802596:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802597:	50                   	push   %eax
  802598:	68 77 2e 80 00       	push   $0x802e77
  80259d:	6a 3d                	push   $0x3d
  80259f:	68 8b 2e 80 00       	push   $0x802e8b
  8025a4:	e8 98 e0 ff ff       	call   800641 <_panic>

008025a9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
  8025ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025af:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025b4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025b7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025bd:	8b 52 50             	mov    0x50(%edx),%edx
  8025c0:	39 ca                	cmp    %ecx,%edx
  8025c2:	74 11                	je     8025d5 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8025c4:	83 c0 01             	add    $0x1,%eax
  8025c7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025cc:	75 e6                	jne    8025b4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8025ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8025d3:	eb 0b                	jmp    8025e0 <ipc_find_env+0x37>
			return envs[i].env_id;
  8025d5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025dd:	8b 40 48             	mov    0x48(%eax),%eax
}
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025e8:	89 c2                	mov    %eax,%edx
  8025ea:	c1 ea 16             	shr    $0x16,%edx
  8025ed:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8025f4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8025f9:	f6 c1 01             	test   $0x1,%cl
  8025fc:	74 1c                	je     80261a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8025fe:	c1 e8 0c             	shr    $0xc,%eax
  802601:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802608:	a8 01                	test   $0x1,%al
  80260a:	74 0e                	je     80261a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80260c:	c1 e8 0c             	shr    $0xc,%eax
  80260f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802616:	ef 
  802617:	0f b7 d2             	movzwl %dx,%edx
}
  80261a:	89 d0                	mov    %edx,%eax
  80261c:	5d                   	pop    %ebp
  80261d:	c3                   	ret    
  80261e:	66 90                	xchg   %ax,%ax

00802620 <__udivdi3>:
  802620:	f3 0f 1e fb          	endbr32 
  802624:	55                   	push   %ebp
  802625:	57                   	push   %edi
  802626:	56                   	push   %esi
  802627:	53                   	push   %ebx
  802628:	83 ec 1c             	sub    $0x1c,%esp
  80262b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80262f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802633:	8b 74 24 34          	mov    0x34(%esp),%esi
  802637:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80263b:	85 c0                	test   %eax,%eax
  80263d:	75 19                	jne    802658 <__udivdi3+0x38>
  80263f:	39 f3                	cmp    %esi,%ebx
  802641:	76 4d                	jbe    802690 <__udivdi3+0x70>
  802643:	31 ff                	xor    %edi,%edi
  802645:	89 e8                	mov    %ebp,%eax
  802647:	89 f2                	mov    %esi,%edx
  802649:	f7 f3                	div    %ebx
  80264b:	89 fa                	mov    %edi,%edx
  80264d:	83 c4 1c             	add    $0x1c,%esp
  802650:	5b                   	pop    %ebx
  802651:	5e                   	pop    %esi
  802652:	5f                   	pop    %edi
  802653:	5d                   	pop    %ebp
  802654:	c3                   	ret    
  802655:	8d 76 00             	lea    0x0(%esi),%esi
  802658:	39 f0                	cmp    %esi,%eax
  80265a:	76 14                	jbe    802670 <__udivdi3+0x50>
  80265c:	31 ff                	xor    %edi,%edi
  80265e:	31 c0                	xor    %eax,%eax
  802660:	89 fa                	mov    %edi,%edx
  802662:	83 c4 1c             	add    $0x1c,%esp
  802665:	5b                   	pop    %ebx
  802666:	5e                   	pop    %esi
  802667:	5f                   	pop    %edi
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    
  80266a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802670:	0f bd f8             	bsr    %eax,%edi
  802673:	83 f7 1f             	xor    $0x1f,%edi
  802676:	75 48                	jne    8026c0 <__udivdi3+0xa0>
  802678:	39 f0                	cmp    %esi,%eax
  80267a:	72 06                	jb     802682 <__udivdi3+0x62>
  80267c:	31 c0                	xor    %eax,%eax
  80267e:	39 eb                	cmp    %ebp,%ebx
  802680:	77 de                	ja     802660 <__udivdi3+0x40>
  802682:	b8 01 00 00 00       	mov    $0x1,%eax
  802687:	eb d7                	jmp    802660 <__udivdi3+0x40>
  802689:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802690:	89 d9                	mov    %ebx,%ecx
  802692:	85 db                	test   %ebx,%ebx
  802694:	75 0b                	jne    8026a1 <__udivdi3+0x81>
  802696:	b8 01 00 00 00       	mov    $0x1,%eax
  80269b:	31 d2                	xor    %edx,%edx
  80269d:	f7 f3                	div    %ebx
  80269f:	89 c1                	mov    %eax,%ecx
  8026a1:	31 d2                	xor    %edx,%edx
  8026a3:	89 f0                	mov    %esi,%eax
  8026a5:	f7 f1                	div    %ecx
  8026a7:	89 c6                	mov    %eax,%esi
  8026a9:	89 e8                	mov    %ebp,%eax
  8026ab:	89 f7                	mov    %esi,%edi
  8026ad:	f7 f1                	div    %ecx
  8026af:	89 fa                	mov    %edi,%edx
  8026b1:	83 c4 1c             	add    $0x1c,%esp
  8026b4:	5b                   	pop    %ebx
  8026b5:	5e                   	pop    %esi
  8026b6:	5f                   	pop    %edi
  8026b7:	5d                   	pop    %ebp
  8026b8:	c3                   	ret    
  8026b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	89 f9                	mov    %edi,%ecx
  8026c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8026c7:	29 fa                	sub    %edi,%edx
  8026c9:	d3 e0                	shl    %cl,%eax
  8026cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026cf:	89 d1                	mov    %edx,%ecx
  8026d1:	89 d8                	mov    %ebx,%eax
  8026d3:	d3 e8                	shr    %cl,%eax
  8026d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026d9:	09 c1                	or     %eax,%ecx
  8026db:	89 f0                	mov    %esi,%eax
  8026dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026e1:	89 f9                	mov    %edi,%ecx
  8026e3:	d3 e3                	shl    %cl,%ebx
  8026e5:	89 d1                	mov    %edx,%ecx
  8026e7:	d3 e8                	shr    %cl,%eax
  8026e9:	89 f9                	mov    %edi,%ecx
  8026eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026ef:	89 eb                	mov    %ebp,%ebx
  8026f1:	d3 e6                	shl    %cl,%esi
  8026f3:	89 d1                	mov    %edx,%ecx
  8026f5:	d3 eb                	shr    %cl,%ebx
  8026f7:	09 f3                	or     %esi,%ebx
  8026f9:	89 c6                	mov    %eax,%esi
  8026fb:	89 f2                	mov    %esi,%edx
  8026fd:	89 d8                	mov    %ebx,%eax
  8026ff:	f7 74 24 08          	divl   0x8(%esp)
  802703:	89 d6                	mov    %edx,%esi
  802705:	89 c3                	mov    %eax,%ebx
  802707:	f7 64 24 0c          	mull   0xc(%esp)
  80270b:	39 d6                	cmp    %edx,%esi
  80270d:	72 19                	jb     802728 <__udivdi3+0x108>
  80270f:	89 f9                	mov    %edi,%ecx
  802711:	d3 e5                	shl    %cl,%ebp
  802713:	39 c5                	cmp    %eax,%ebp
  802715:	73 04                	jae    80271b <__udivdi3+0xfb>
  802717:	39 d6                	cmp    %edx,%esi
  802719:	74 0d                	je     802728 <__udivdi3+0x108>
  80271b:	89 d8                	mov    %ebx,%eax
  80271d:	31 ff                	xor    %edi,%edi
  80271f:	e9 3c ff ff ff       	jmp    802660 <__udivdi3+0x40>
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80272b:	31 ff                	xor    %edi,%edi
  80272d:	e9 2e ff ff ff       	jmp    802660 <__udivdi3+0x40>
  802732:	66 90                	xchg   %ax,%ax
  802734:	66 90                	xchg   %ax,%ax
  802736:	66 90                	xchg   %ax,%ax
  802738:	66 90                	xchg   %ax,%ax
  80273a:	66 90                	xchg   %ax,%ax
  80273c:	66 90                	xchg   %ax,%ax
  80273e:	66 90                	xchg   %ax,%ax

00802740 <__umoddi3>:
  802740:	f3 0f 1e fb          	endbr32 
  802744:	55                   	push   %ebp
  802745:	57                   	push   %edi
  802746:	56                   	push   %esi
  802747:	53                   	push   %ebx
  802748:	83 ec 1c             	sub    $0x1c,%esp
  80274b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80274f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802753:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802757:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80275b:	89 f0                	mov    %esi,%eax
  80275d:	89 da                	mov    %ebx,%edx
  80275f:	85 ff                	test   %edi,%edi
  802761:	75 15                	jne    802778 <__umoddi3+0x38>
  802763:	39 dd                	cmp    %ebx,%ebp
  802765:	76 39                	jbe    8027a0 <__umoddi3+0x60>
  802767:	f7 f5                	div    %ebp
  802769:	89 d0                	mov    %edx,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	83 c4 1c             	add    $0x1c,%esp
  802770:	5b                   	pop    %ebx
  802771:	5e                   	pop    %esi
  802772:	5f                   	pop    %edi
  802773:	5d                   	pop    %ebp
  802774:	c3                   	ret    
  802775:	8d 76 00             	lea    0x0(%esi),%esi
  802778:	39 df                	cmp    %ebx,%edi
  80277a:	77 f1                	ja     80276d <__umoddi3+0x2d>
  80277c:	0f bd cf             	bsr    %edi,%ecx
  80277f:	83 f1 1f             	xor    $0x1f,%ecx
  802782:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802786:	75 40                	jne    8027c8 <__umoddi3+0x88>
  802788:	39 df                	cmp    %ebx,%edi
  80278a:	72 04                	jb     802790 <__umoddi3+0x50>
  80278c:	39 f5                	cmp    %esi,%ebp
  80278e:	77 dd                	ja     80276d <__umoddi3+0x2d>
  802790:	89 da                	mov    %ebx,%edx
  802792:	89 f0                	mov    %esi,%eax
  802794:	29 e8                	sub    %ebp,%eax
  802796:	19 fa                	sbb    %edi,%edx
  802798:	eb d3                	jmp    80276d <__umoddi3+0x2d>
  80279a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a0:	89 e9                	mov    %ebp,%ecx
  8027a2:	85 ed                	test   %ebp,%ebp
  8027a4:	75 0b                	jne    8027b1 <__umoddi3+0x71>
  8027a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ab:	31 d2                	xor    %edx,%edx
  8027ad:	f7 f5                	div    %ebp
  8027af:	89 c1                	mov    %eax,%ecx
  8027b1:	89 d8                	mov    %ebx,%eax
  8027b3:	31 d2                	xor    %edx,%edx
  8027b5:	f7 f1                	div    %ecx
  8027b7:	89 f0                	mov    %esi,%eax
  8027b9:	f7 f1                	div    %ecx
  8027bb:	89 d0                	mov    %edx,%eax
  8027bd:	31 d2                	xor    %edx,%edx
  8027bf:	eb ac                	jmp    80276d <__umoddi3+0x2d>
  8027c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8027d1:	29 c2                	sub    %eax,%edx
  8027d3:	89 c1                	mov    %eax,%ecx
  8027d5:	89 e8                	mov    %ebp,%eax
  8027d7:	d3 e7                	shl    %cl,%edi
  8027d9:	89 d1                	mov    %edx,%ecx
  8027db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027df:	d3 e8                	shr    %cl,%eax
  8027e1:	89 c1                	mov    %eax,%ecx
  8027e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027e7:	09 f9                	or     %edi,%ecx
  8027e9:	89 df                	mov    %ebx,%edi
  8027eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027ef:	89 c1                	mov    %eax,%ecx
  8027f1:	d3 e5                	shl    %cl,%ebp
  8027f3:	89 d1                	mov    %edx,%ecx
  8027f5:	d3 ef                	shr    %cl,%edi
  8027f7:	89 c1                	mov    %eax,%ecx
  8027f9:	89 f0                	mov    %esi,%eax
  8027fb:	d3 e3                	shl    %cl,%ebx
  8027fd:	89 d1                	mov    %edx,%ecx
  8027ff:	89 fa                	mov    %edi,%edx
  802801:	d3 e8                	shr    %cl,%eax
  802803:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802808:	09 d8                	or     %ebx,%eax
  80280a:	f7 74 24 08          	divl   0x8(%esp)
  80280e:	89 d3                	mov    %edx,%ebx
  802810:	d3 e6                	shl    %cl,%esi
  802812:	f7 e5                	mul    %ebp
  802814:	89 c7                	mov    %eax,%edi
  802816:	89 d1                	mov    %edx,%ecx
  802818:	39 d3                	cmp    %edx,%ebx
  80281a:	72 06                	jb     802822 <__umoddi3+0xe2>
  80281c:	75 0e                	jne    80282c <__umoddi3+0xec>
  80281e:	39 c6                	cmp    %eax,%esi
  802820:	73 0a                	jae    80282c <__umoddi3+0xec>
  802822:	29 e8                	sub    %ebp,%eax
  802824:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802828:	89 d1                	mov    %edx,%ecx
  80282a:	89 c7                	mov    %eax,%edi
  80282c:	89 f5                	mov    %esi,%ebp
  80282e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802832:	29 fd                	sub    %edi,%ebp
  802834:	19 cb                	sbb    %ecx,%ebx
  802836:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80283b:	89 d8                	mov    %ebx,%eax
  80283d:	d3 e0                	shl    %cl,%eax
  80283f:	89 f1                	mov    %esi,%ecx
  802841:	d3 ed                	shr    %cl,%ebp
  802843:	d3 eb                	shr    %cl,%ebx
  802845:	09 e8                	or     %ebp,%eax
  802847:	89 da                	mov    %ebx,%edx
  802849:	83 c4 1c             	add    $0x1c,%esp
  80284c:	5b                   	pop    %ebx
  80284d:	5e                   	pop    %esi
  80284e:	5f                   	pop    %edi
  80284f:	5d                   	pop    %ebp
  802850:	c3                   	ret    
