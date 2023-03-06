
obj/user/faultregs：     文件格式 elf32-i386


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
  800044:	68 b1 15 80 00       	push   $0x8015b1
  800049:	68 80 15 80 00       	push   $0x801580
  80004e:	e8 c1 06 00 00       	call   800714 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	push   (%ebx)
  800055:	ff 36                	push   (%esi)
  800057:	68 90 15 80 00       	push   $0x801590
  80005c:	68 94 15 80 00       	push   $0x801594
  800061:	e8 ae 06 00 00       	call   800714 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 a8 15 80 00       	push   $0x8015a8
  80007b:	e8 94 06 00 00       	call   800714 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	push   0x4(%ebx)
  80008b:	ff 76 04             	push   0x4(%esi)
  80008e:	68 b2 15 80 00       	push   $0x8015b2
  800093:	68 94 15 80 00       	push   $0x801594
  800098:	e8 77 06 00 00       	call   800714 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 a8 15 80 00       	push   $0x8015a8
  8000b4:	e8 5b 06 00 00       	call   800714 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	push   0x8(%ebx)
  8000c4:	ff 76 08             	push   0x8(%esi)
  8000c7:	68 b6 15 80 00       	push   $0x8015b6
  8000cc:	68 94 15 80 00       	push   $0x801594
  8000d1:	e8 3e 06 00 00       	call   800714 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 a8 15 80 00       	push   $0x8015a8
  8000ed:	e8 22 06 00 00       	call   800714 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	push   0x10(%ebx)
  8000fd:	ff 76 10             	push   0x10(%esi)
  800100:	68 ba 15 80 00       	push   $0x8015ba
  800105:	68 94 15 80 00       	push   $0x801594
  80010a:	e8 05 06 00 00       	call   800714 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 a8 15 80 00       	push   $0x8015a8
  800126:	e8 e9 05 00 00       	call   800714 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	push   0x14(%ebx)
  800136:	ff 76 14             	push   0x14(%esi)
  800139:	68 be 15 80 00       	push   $0x8015be
  80013e:	68 94 15 80 00       	push   $0x801594
  800143:	e8 cc 05 00 00       	call   800714 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 a8 15 80 00       	push   $0x8015a8
  80015f:	e8 b0 05 00 00       	call   800714 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	push   0x18(%ebx)
  80016f:	ff 76 18             	push   0x18(%esi)
  800172:	68 c2 15 80 00       	push   $0x8015c2
  800177:	68 94 15 80 00       	push   $0x801594
  80017c:	e8 93 05 00 00       	call   800714 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 a8 15 80 00       	push   $0x8015a8
  800198:	e8 77 05 00 00       	call   800714 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	push   0x1c(%ebx)
  8001a8:	ff 76 1c             	push   0x1c(%esi)
  8001ab:	68 c6 15 80 00       	push   $0x8015c6
  8001b0:	68 94 15 80 00       	push   $0x801594
  8001b5:	e8 5a 05 00 00       	call   800714 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 a8 15 80 00       	push   $0x8015a8
  8001d1:	e8 3e 05 00 00       	call   800714 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	push   0x20(%ebx)
  8001e1:	ff 76 20             	push   0x20(%esi)
  8001e4:	68 ca 15 80 00       	push   $0x8015ca
  8001e9:	68 94 15 80 00       	push   $0x801594
  8001ee:	e8 21 05 00 00       	call   800714 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 a8 15 80 00       	push   $0x8015a8
  80020a:	e8 05 05 00 00       	call   800714 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	push   0x24(%ebx)
  80021a:	ff 76 24             	push   0x24(%esi)
  80021d:	68 ce 15 80 00       	push   $0x8015ce
  800222:	68 94 15 80 00       	push   $0x801594
  800227:	e8 e8 04 00 00       	call   800714 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 a8 15 80 00       	push   $0x8015a8
  800243:	e8 cc 04 00 00       	call   800714 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	push   0x28(%ebx)
  80024b:	ff 76 28             	push   0x28(%esi)
  80024e:	68 d5 15 80 00       	push   $0x8015d5
  800253:	68 94 15 80 00       	push   $0x801594
  800258:	e8 b7 04 00 00       	call   800714 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 a8 15 80 00       	push   $0x8015a8
  800274:	e8 9b 04 00 00       	call   800714 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	push   0xc(%ebp)
  80027f:	68 d9 15 80 00       	push   $0x8015d9
  800284:	e8 8b 04 00 00       	call   800714 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 a8 15 80 00       	push   $0x8015a8
  800294:	e8 7b 04 00 00       	call   800714 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 a4 15 80 00       	push   $0x8015a4
  8002a9:	e8 66 04 00 00       	call   800714 <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 a4 15 80 00       	push   $0x8015a4
  8002c3:	e8 4c 04 00 00       	call   800714 <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 a4 15 80 00       	push   $0x8015a4
  8002d8:	e8 37 04 00 00       	call   800714 <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 a4 15 80 00       	push   $0x8015a4
  8002ed:	e8 22 04 00 00       	call   800714 <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 a4 15 80 00       	push   $0x8015a4
  800302:	e8 0d 04 00 00       	call   800714 <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 a4 15 80 00       	push   $0x8015a4
  800317:	e8 f8 03 00 00       	call   800714 <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 a4 15 80 00       	push   $0x8015a4
  80032c:	e8 e3 03 00 00       	call   800714 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 a4 15 80 00       	push   $0x8015a4
  800341:	e8 ce 03 00 00       	call   800714 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 a4 15 80 00       	push   $0x8015a4
  800356:	e8 b9 03 00 00       	call   800714 <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	push   0x28(%ebx)
  80035e:	ff 76 28             	push   0x28(%esi)
  800361:	68 d5 15 80 00       	push   $0x8015d5
  800366:	68 94 15 80 00       	push   $0x801594
  80036b:	e8 a4 03 00 00       	call   800714 <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 a4 15 80 00       	push   $0x8015a4
  800387:	e8 88 03 00 00       	call   800714 <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	push   0xc(%ebp)
  800392:	68 d9 15 80 00       	push   $0x8015d9
  800397:	e8 78 03 00 00       	call   800714 <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 a4 15 80 00       	push   $0x8015a4
  8003af:	e8 60 03 00 00       	call   800714 <cprintf>
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
  8003c2:	68 a4 15 80 00       	push   $0x8015a4
  8003c7:	e8 48 03 00 00       	call   800714 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	push   0xc(%ebp)
  8003d2:	68 d9 15 80 00       	push   $0x8015d9
  8003d7:	e8 38 03 00 00       	call   800714 <cprintf>
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
  8003fe:	89 15 60 20 80 00    	mov    %edx,0x802060
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 64 20 80 00    	mov    %edx,0x802064
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 68 20 80 00    	mov    %edx,0x802068
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 70 20 80 00    	mov    %edx,0x802070
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 ff 15 80 00       	push   $0x8015ff
  80046b:	68 0d 16 80 00       	push   $0x80160d
  800470:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800475:	ba f8 15 80 00       	mov    $0x8015f8,%edx
  80047a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 55 0c 00 00       	call   8010ea <sys_page_alloc>
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
  8004a5:	68 40 16 80 00       	push   $0x801640
  8004aa:	6a 50                	push   $0x50
  8004ac:	68 e7 15 80 00       	push   $0x8015e7
  8004b1:	e8 83 01 00 00       	call   800639 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 14 16 80 00       	push   $0x801614
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 e7 15 80 00       	push   $0x8015e7
  8004c3:	e8 71 01 00 00       	call   800639 <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 c1 0d 00 00       	call   801299 <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004f9:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004ff:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800505:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80050b:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800511:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  800517:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80051c:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800532:	89 35 24 20 80 00    	mov    %esi,0x802024
  800538:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80053e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800544:	89 15 34 20 80 00    	mov    %edx,0x802034
  80054a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800550:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800555:	89 25 48 20 80 00    	mov    %esp,0x802048
  80055b:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800561:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800567:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80056d:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800573:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800579:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80057f:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800584:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 44 20 80 00       	mov    %eax,0x802044
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
  80059f:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005a4:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	68 27 16 80 00       	push   $0x801627
  8005b1:	68 38 16 80 00       	push   $0x801638
  8005b6:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005bb:	ba f8 15 80 00       	mov    $0x8015f8,%edx
  8005c0:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005c5:	e8 69 fa ff ff       	call   800033 <check_regs>
}
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 74 16 80 00       	push   $0x801674
  8005d7:	e8 38 01 00 00       	call   800714 <cprintf>
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
  8005ec:	e8 bb 0a 00 00       	call   8010ac <sys_getenvid>
  8005f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005fe:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800603:	85 db                	test   %ebx,%ebx
  800605:	7e 07                	jle    80060e <libmain+0x2d>
		binaryname = argv[0];
  800607:	8b 06                	mov    (%esi),%eax
  800609:	a3 00 20 80 00       	mov    %eax,0x802000

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
  80062a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80062d:	6a 00                	push   $0x0
  80062f:	e8 37 0a 00 00       	call   80106b <sys_env_destroy>
}
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	c9                   	leave  
  800638:	c3                   	ret    

00800639 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	56                   	push   %esi
  80063d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80063e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800641:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800647:	e8 60 0a 00 00       	call   8010ac <sys_getenvid>
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	ff 75 0c             	push   0xc(%ebp)
  800652:	ff 75 08             	push   0x8(%ebp)
  800655:	56                   	push   %esi
  800656:	50                   	push   %eax
  800657:	68 a0 16 80 00       	push   $0x8016a0
  80065c:	e8 b3 00 00 00       	call   800714 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800661:	83 c4 18             	add    $0x18,%esp
  800664:	53                   	push   %ebx
  800665:	ff 75 10             	push   0x10(%ebp)
  800668:	e8 56 00 00 00       	call   8006c3 <vcprintf>
	cprintf("\n");
  80066d:	c7 04 24 b0 15 80 00 	movl   $0x8015b0,(%esp)
  800674:	e8 9b 00 00 00       	call   800714 <cprintf>
  800679:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80067c:	cc                   	int3   
  80067d:	eb fd                	jmp    80067c <_panic+0x43>

0080067f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	53                   	push   %ebx
  800683:	83 ec 04             	sub    $0x4,%esp
  800686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800689:	8b 13                	mov    (%ebx),%edx
  80068b:	8d 42 01             	lea    0x1(%edx),%eax
  80068e:	89 03                	mov    %eax,(%ebx)
  800690:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800693:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800697:	3d ff 00 00 00       	cmp    $0xff,%eax
  80069c:	74 09                	je     8006a7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80069e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	68 ff 00 00 00       	push   $0xff
  8006af:	8d 43 08             	lea    0x8(%ebx),%eax
  8006b2:	50                   	push   %eax
  8006b3:	e8 76 09 00 00       	call   80102e <sys_cputs>
		b->idx = 0;
  8006b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb db                	jmp    80069e <putch+0x1f>

008006c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006d3:	00 00 00 
	b.cnt = 0;
  8006d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e0:	ff 75 0c             	push   0xc(%ebp)
  8006e3:	ff 75 08             	push   0x8(%ebp)
  8006e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ec:	50                   	push   %eax
  8006ed:	68 7f 06 80 00       	push   $0x80067f
  8006f2:	e8 14 01 00 00       	call   80080b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006f7:	83 c4 08             	add    $0x8,%esp
  8006fa:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800700:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	e8 22 09 00 00       	call   80102e <sys_cputs>

	return b.cnt;
}
  80070c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80071a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80071d:	50                   	push   %eax
  80071e:	ff 75 08             	push   0x8(%ebp)
  800721:	e8 9d ff ff ff       	call   8006c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	57                   	push   %edi
  80072c:	56                   	push   %esi
  80072d:	53                   	push   %ebx
  80072e:	83 ec 1c             	sub    $0x1c,%esp
  800731:	89 c7                	mov    %eax,%edi
  800733:	89 d6                	mov    %edx,%esi
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
  80073b:	89 d1                	mov    %edx,%ecx
  80073d:	89 c2                	mov    %eax,%edx
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800742:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800745:	8b 45 10             	mov    0x10(%ebp),%eax
  800748:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80074b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80074e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800755:	39 c2                	cmp    %eax,%edx
  800757:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80075a:	72 3e                	jb     80079a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80075c:	83 ec 0c             	sub    $0xc,%esp
  80075f:	ff 75 18             	push   0x18(%ebp)
  800762:	83 eb 01             	sub    $0x1,%ebx
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	ff 75 e4             	push   -0x1c(%ebp)
  80076d:	ff 75 e0             	push   -0x20(%ebp)
  800770:	ff 75 dc             	push   -0x24(%ebp)
  800773:	ff 75 d8             	push   -0x28(%ebp)
  800776:	e8 c5 0b 00 00       	call   801340 <__udivdi3>
  80077b:	83 c4 18             	add    $0x18,%esp
  80077e:	52                   	push   %edx
  80077f:	50                   	push   %eax
  800780:	89 f2                	mov    %esi,%edx
  800782:	89 f8                	mov    %edi,%eax
  800784:	e8 9f ff ff ff       	call   800728 <printnum>
  800789:	83 c4 20             	add    $0x20,%esp
  80078c:	eb 13                	jmp    8007a1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	56                   	push   %esi
  800792:	ff 75 18             	push   0x18(%ebp)
  800795:	ff d7                	call   *%edi
  800797:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80079a:	83 eb 01             	sub    $0x1,%ebx
  80079d:	85 db                	test   %ebx,%ebx
  80079f:	7f ed                	jg     80078e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007a1:	83 ec 08             	sub    $0x8,%esp
  8007a4:	56                   	push   %esi
  8007a5:	83 ec 04             	sub    $0x4,%esp
  8007a8:	ff 75 e4             	push   -0x1c(%ebp)
  8007ab:	ff 75 e0             	push   -0x20(%ebp)
  8007ae:	ff 75 dc             	push   -0x24(%ebp)
  8007b1:	ff 75 d8             	push   -0x28(%ebp)
  8007b4:	e8 a7 0c 00 00       	call   801460 <__umoddi3>
  8007b9:	83 c4 14             	add    $0x14,%esp
  8007bc:	0f be 80 c3 16 80 00 	movsbl 0x8016c3(%eax),%eax
  8007c3:	50                   	push   %eax
  8007c4:	ff d7                	call   *%edi
}
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cc:	5b                   	pop    %ebx
  8007cd:	5e                   	pop    %esi
  8007ce:	5f                   	pop    %edi
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007db:	8b 10                	mov    (%eax),%edx
  8007dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8007e0:	73 0a                	jae    8007ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8007e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	88 02                	mov    %al,(%edx)
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <printfmt>:
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8007f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007f7:	50                   	push   %eax
  8007f8:	ff 75 10             	push   0x10(%ebp)
  8007fb:	ff 75 0c             	push   0xc(%ebp)
  8007fe:	ff 75 08             	push   0x8(%ebp)
  800801:	e8 05 00 00 00       	call   80080b <vprintfmt>
}
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	c9                   	leave  
  80080a:	c3                   	ret    

0080080b <vprintfmt>:
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	57                   	push   %edi
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	83 ec 3c             	sub    $0x3c,%esp
  800814:	8b 75 08             	mov    0x8(%ebp),%esi
  800817:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80081a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80081d:	eb 0a                	jmp    800829 <vprintfmt+0x1e>
			putch(ch, putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	50                   	push   %eax
  800824:	ff d6                	call   *%esi
  800826:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800829:	83 c7 01             	add    $0x1,%edi
  80082c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800830:	83 f8 25             	cmp    $0x25,%eax
  800833:	74 0c                	je     800841 <vprintfmt+0x36>
			if (ch == '\0')
  800835:	85 c0                	test   %eax,%eax
  800837:	75 e6                	jne    80081f <vprintfmt+0x14>
}
  800839:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5f                   	pop    %edi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    
		padc = ' ';
  800841:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800845:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80084c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800853:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80085a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80085f:	8d 47 01             	lea    0x1(%edi),%eax
  800862:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800865:	0f b6 17             	movzbl (%edi),%edx
  800868:	8d 42 dd             	lea    -0x23(%edx),%eax
  80086b:	3c 55                	cmp    $0x55,%al
  80086d:	0f 87 bb 03 00 00    	ja     800c2e <vprintfmt+0x423>
  800873:	0f b6 c0             	movzbl %al,%eax
  800876:	ff 24 85 80 17 80 00 	jmp    *0x801780(,%eax,4)
  80087d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800880:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800884:	eb d9                	jmp    80085f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800889:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80088d:	eb d0                	jmp    80085f <vprintfmt+0x54>
  80088f:	0f b6 d2             	movzbl %dl,%edx
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80089d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008a0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008a4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008a7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008aa:	83 f9 09             	cmp    $0x9,%ecx
  8008ad:	77 55                	ja     800904 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8008af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008b2:	eb e9                	jmp    80089d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8b 00                	mov    (%eax),%eax
  8008b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 40 04             	lea    0x4(%eax),%eax
  8008c2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008cc:	79 91                	jns    80085f <vprintfmt+0x54>
				width = precision, precision = -1;
  8008ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008d4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008db:	eb 82                	jmp    80085f <vprintfmt+0x54>
  8008dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008e0:	85 d2                	test   %edx,%edx
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e7:	0f 49 c2             	cmovns %edx,%eax
  8008ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8008f0:	e9 6a ff ff ff       	jmp    80085f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8008f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8008f8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8008ff:	e9 5b ff ff ff       	jmp    80085f <vprintfmt+0x54>
  800904:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800907:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80090a:	eb bc                	jmp    8008c8 <vprintfmt+0xbd>
			lflag++;
  80090c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80090f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800912:	e9 48 ff ff ff       	jmp    80085f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8d 78 04             	lea    0x4(%eax),%edi
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	53                   	push   %ebx
  800921:	ff 30                	push   (%eax)
  800923:	ff d6                	call   *%esi
			break;
  800925:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800928:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80092b:	e9 9d 02 00 00       	jmp    800bcd <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800930:	8b 45 14             	mov    0x14(%ebp),%eax
  800933:	8d 78 04             	lea    0x4(%eax),%edi
  800936:	8b 10                	mov    (%eax),%edx
  800938:	89 d0                	mov    %edx,%eax
  80093a:	f7 d8                	neg    %eax
  80093c:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80093f:	83 f8 08             	cmp    $0x8,%eax
  800942:	7f 23                	jg     800967 <vprintfmt+0x15c>
  800944:	8b 14 85 e0 18 80 00 	mov    0x8018e0(,%eax,4),%edx
  80094b:	85 d2                	test   %edx,%edx
  80094d:	74 18                	je     800967 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80094f:	52                   	push   %edx
  800950:	68 e4 16 80 00       	push   $0x8016e4
  800955:	53                   	push   %ebx
  800956:	56                   	push   %esi
  800957:	e8 92 fe ff ff       	call   8007ee <printfmt>
  80095c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80095f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800962:	e9 66 02 00 00       	jmp    800bcd <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800967:	50                   	push   %eax
  800968:	68 db 16 80 00       	push   $0x8016db
  80096d:	53                   	push   %ebx
  80096e:	56                   	push   %esi
  80096f:	e8 7a fe ff ff       	call   8007ee <printfmt>
  800974:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800977:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80097a:	e9 4e 02 00 00       	jmp    800bcd <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80097f:	8b 45 14             	mov    0x14(%ebp),%eax
  800982:	83 c0 04             	add    $0x4,%eax
  800985:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800988:	8b 45 14             	mov    0x14(%ebp),%eax
  80098b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80098d:	85 d2                	test   %edx,%edx
  80098f:	b8 d4 16 80 00       	mov    $0x8016d4,%eax
  800994:	0f 45 c2             	cmovne %edx,%eax
  800997:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80099a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80099e:	7e 06                	jle    8009a6 <vprintfmt+0x19b>
  8009a0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009a4:	75 0d                	jne    8009b3 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	03 45 e0             	add    -0x20(%ebp),%eax
  8009ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b1:	eb 55                	jmp    800a08 <vprintfmt+0x1fd>
  8009b3:	83 ec 08             	sub    $0x8,%esp
  8009b6:	ff 75 d8             	push   -0x28(%ebp)
  8009b9:	ff 75 cc             	push   -0x34(%ebp)
  8009bc:	e8 0a 03 00 00       	call   800ccb <strnlen>
  8009c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009c4:	29 c1                	sub    %eax,%ecx
  8009c6:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8009c9:	83 c4 10             	add    $0x10,%esp
  8009cc:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8009ce:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009d5:	eb 0f                	jmp    8009e6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8009d7:	83 ec 08             	sub    $0x8,%esp
  8009da:	53                   	push   %ebx
  8009db:	ff 75 e0             	push   -0x20(%ebp)
  8009de:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e0:	83 ef 01             	sub    $0x1,%edi
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	85 ff                	test   %edi,%edi
  8009e8:	7f ed                	jg     8009d7 <vprintfmt+0x1cc>
  8009ea:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009ed:	85 d2                	test   %edx,%edx
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	0f 49 c2             	cmovns %edx,%eax
  8009f7:	29 c2                	sub    %eax,%edx
  8009f9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8009fc:	eb a8                	jmp    8009a6 <vprintfmt+0x19b>
					putch(ch, putdat);
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	53                   	push   %ebx
  800a02:	52                   	push   %edx
  800a03:	ff d6                	call   *%esi
  800a05:	83 c4 10             	add    $0x10,%esp
  800a08:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a0b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a0d:	83 c7 01             	add    $0x1,%edi
  800a10:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a14:	0f be d0             	movsbl %al,%edx
  800a17:	85 d2                	test   %edx,%edx
  800a19:	74 4b                	je     800a66 <vprintfmt+0x25b>
  800a1b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a1f:	78 06                	js     800a27 <vprintfmt+0x21c>
  800a21:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a25:	78 1e                	js     800a45 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800a27:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a2b:	74 d1                	je     8009fe <vprintfmt+0x1f3>
  800a2d:	0f be c0             	movsbl %al,%eax
  800a30:	83 e8 20             	sub    $0x20,%eax
  800a33:	83 f8 5e             	cmp    $0x5e,%eax
  800a36:	76 c6                	jbe    8009fe <vprintfmt+0x1f3>
					putch('?', putdat);
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	53                   	push   %ebx
  800a3c:	6a 3f                	push   $0x3f
  800a3e:	ff d6                	call   *%esi
  800a40:	83 c4 10             	add    $0x10,%esp
  800a43:	eb c3                	jmp    800a08 <vprintfmt+0x1fd>
  800a45:	89 cf                	mov    %ecx,%edi
  800a47:	eb 0e                	jmp    800a57 <vprintfmt+0x24c>
				putch(' ', putdat);
  800a49:	83 ec 08             	sub    $0x8,%esp
  800a4c:	53                   	push   %ebx
  800a4d:	6a 20                	push   $0x20
  800a4f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a51:	83 ef 01             	sub    $0x1,%edi
  800a54:	83 c4 10             	add    $0x10,%esp
  800a57:	85 ff                	test   %edi,%edi
  800a59:	7f ee                	jg     800a49 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800a5b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a5e:	89 45 14             	mov    %eax,0x14(%ebp)
  800a61:	e9 67 01 00 00       	jmp    800bcd <vprintfmt+0x3c2>
  800a66:	89 cf                	mov    %ecx,%edi
  800a68:	eb ed                	jmp    800a57 <vprintfmt+0x24c>
	if (lflag >= 2)
  800a6a:	83 f9 01             	cmp    $0x1,%ecx
  800a6d:	7f 1b                	jg     800a8a <vprintfmt+0x27f>
	else if (lflag)
  800a6f:	85 c9                	test   %ecx,%ecx
  800a71:	74 63                	je     800ad6 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800a73:	8b 45 14             	mov    0x14(%ebp),%eax
  800a76:	8b 00                	mov    (%eax),%eax
  800a78:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a7b:	99                   	cltd   
  800a7c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  800a82:	8d 40 04             	lea    0x4(%eax),%eax
  800a85:	89 45 14             	mov    %eax,0x14(%ebp)
  800a88:	eb 17                	jmp    800aa1 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8b 50 04             	mov    0x4(%eax),%edx
  800a90:	8b 00                	mov    (%eax),%eax
  800a92:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a95:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a98:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9b:	8d 40 08             	lea    0x8(%eax),%eax
  800a9e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800aa1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aa4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800aa7:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800aac:	85 c9                	test   %ecx,%ecx
  800aae:	0f 89 ff 00 00 00    	jns    800bb3 <vprintfmt+0x3a8>
				putch('-', putdat);
  800ab4:	83 ec 08             	sub    $0x8,%esp
  800ab7:	53                   	push   %ebx
  800ab8:	6a 2d                	push   $0x2d
  800aba:	ff d6                	call   *%esi
				num = -(long long) num;
  800abc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800abf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ac2:	f7 da                	neg    %edx
  800ac4:	83 d1 00             	adc    $0x0,%ecx
  800ac7:	f7 d9                	neg    %ecx
  800ac9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800acc:	bf 0a 00 00 00       	mov    $0xa,%edi
  800ad1:	e9 dd 00 00 00       	jmp    800bb3 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800ad6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad9:	8b 00                	mov    (%eax),%eax
  800adb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ade:	99                   	cltd   
  800adf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae5:	8d 40 04             	lea    0x4(%eax),%eax
  800ae8:	89 45 14             	mov    %eax,0x14(%ebp)
  800aeb:	eb b4                	jmp    800aa1 <vprintfmt+0x296>
	if (lflag >= 2)
  800aed:	83 f9 01             	cmp    $0x1,%ecx
  800af0:	7f 1e                	jg     800b10 <vprintfmt+0x305>
	else if (lflag)
  800af2:	85 c9                	test   %ecx,%ecx
  800af4:	74 32                	je     800b28 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800af6:	8b 45 14             	mov    0x14(%ebp),%eax
  800af9:	8b 10                	mov    (%eax),%edx
  800afb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b00:	8d 40 04             	lea    0x4(%eax),%eax
  800b03:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b06:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800b0b:	e9 a3 00 00 00       	jmp    800bb3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800b10:	8b 45 14             	mov    0x14(%ebp),%eax
  800b13:	8b 10                	mov    (%eax),%edx
  800b15:	8b 48 04             	mov    0x4(%eax),%ecx
  800b18:	8d 40 08             	lea    0x8(%eax),%eax
  800b1b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b1e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800b23:	e9 8b 00 00 00       	jmp    800bb3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800b28:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2b:	8b 10                	mov    (%eax),%edx
  800b2d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b32:	8d 40 04             	lea    0x4(%eax),%eax
  800b35:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b38:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800b3d:	eb 74                	jmp    800bb3 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800b3f:	83 f9 01             	cmp    $0x1,%ecx
  800b42:	7f 1b                	jg     800b5f <vprintfmt+0x354>
	else if (lflag)
  800b44:	85 c9                	test   %ecx,%ecx
  800b46:	74 2c                	je     800b74 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800b48:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4b:	8b 10                	mov    (%eax),%edx
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	8d 40 04             	lea    0x4(%eax),%eax
  800b55:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b58:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800b5d:	eb 54                	jmp    800bb3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b62:	8b 10                	mov    (%eax),%edx
  800b64:	8b 48 04             	mov    0x4(%eax),%ecx
  800b67:	8d 40 08             	lea    0x8(%eax),%eax
  800b6a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b6d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800b72:	eb 3f                	jmp    800bb3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800b74:	8b 45 14             	mov    0x14(%ebp),%eax
  800b77:	8b 10                	mov    (%eax),%edx
  800b79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7e:	8d 40 04             	lea    0x4(%eax),%eax
  800b81:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b84:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800b89:	eb 28                	jmp    800bb3 <vprintfmt+0x3a8>
			putch('0', putdat);
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	53                   	push   %ebx
  800b8f:	6a 30                	push   $0x30
  800b91:	ff d6                	call   *%esi
			putch('x', putdat);
  800b93:	83 c4 08             	add    $0x8,%esp
  800b96:	53                   	push   %ebx
  800b97:	6a 78                	push   $0x78
  800b99:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b9b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9e:	8b 10                	mov    (%eax),%edx
  800ba0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800ba5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800ba8:	8d 40 04             	lea    0x4(%eax),%eax
  800bab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bae:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800bba:	50                   	push   %eax
  800bbb:	ff 75 e0             	push   -0x20(%ebp)
  800bbe:	57                   	push   %edi
  800bbf:	51                   	push   %ecx
  800bc0:	52                   	push   %edx
  800bc1:	89 da                	mov    %ebx,%edx
  800bc3:	89 f0                	mov    %esi,%eax
  800bc5:	e8 5e fb ff ff       	call   800728 <printnum>
			break;
  800bca:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800bcd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bd0:	e9 54 fc ff ff       	jmp    800829 <vprintfmt+0x1e>
	if (lflag >= 2)
  800bd5:	83 f9 01             	cmp    $0x1,%ecx
  800bd8:	7f 1b                	jg     800bf5 <vprintfmt+0x3ea>
	else if (lflag)
  800bda:	85 c9                	test   %ecx,%ecx
  800bdc:	74 2c                	je     800c0a <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800bde:	8b 45 14             	mov    0x14(%ebp),%eax
  800be1:	8b 10                	mov    (%eax),%edx
  800be3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be8:	8d 40 04             	lea    0x4(%eax),%eax
  800beb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bee:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800bf3:	eb be                	jmp    800bb3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800bf5:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf8:	8b 10                	mov    (%eax),%edx
  800bfa:	8b 48 04             	mov    0x4(%eax),%ecx
  800bfd:	8d 40 08             	lea    0x8(%eax),%eax
  800c00:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c03:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800c08:	eb a9                	jmp    800bb3 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800c0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0d:	8b 10                	mov    (%eax),%edx
  800c0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c14:	8d 40 04             	lea    0x4(%eax),%eax
  800c17:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c1a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800c1f:	eb 92                	jmp    800bb3 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800c21:	83 ec 08             	sub    $0x8,%esp
  800c24:	53                   	push   %ebx
  800c25:	6a 25                	push   $0x25
  800c27:	ff d6                	call   *%esi
			break;
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	eb 9f                	jmp    800bcd <vprintfmt+0x3c2>
			putch('%', putdat);
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	53                   	push   %ebx
  800c32:	6a 25                	push   $0x25
  800c34:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	89 f8                	mov    %edi,%eax
  800c3b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c3f:	74 05                	je     800c46 <vprintfmt+0x43b>
  800c41:	83 e8 01             	sub    $0x1,%eax
  800c44:	eb f5                	jmp    800c3b <vprintfmt+0x430>
  800c46:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c49:	eb 82                	jmp    800bcd <vprintfmt+0x3c2>

00800c4b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 18             	sub    $0x18,%esp
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c57:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c5a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c5e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	74 26                	je     800c92 <vsnprintf+0x47>
  800c6c:	85 d2                	test   %edx,%edx
  800c6e:	7e 22                	jle    800c92 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c70:	ff 75 14             	push   0x14(%ebp)
  800c73:	ff 75 10             	push   0x10(%ebp)
  800c76:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c79:	50                   	push   %eax
  800c7a:	68 d1 07 80 00       	push   $0x8007d1
  800c7f:	e8 87 fb ff ff       	call   80080b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c87:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8d:	83 c4 10             	add    $0x10,%esp
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    
		return -E_INVAL;
  800c92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c97:	eb f7                	jmp    800c90 <vsnprintf+0x45>

00800c99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c9f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ca2:	50                   	push   %eax
  800ca3:	ff 75 10             	push   0x10(%ebp)
  800ca6:	ff 75 0c             	push   0xc(%ebp)
  800ca9:	ff 75 08             	push   0x8(%ebp)
  800cac:	e8 9a ff ff ff       	call   800c4b <vsnprintf>
	va_end(ap);

	return rc;
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbe:	eb 03                	jmp    800cc3 <strlen+0x10>
		n++;
  800cc0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800cc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cc7:	75 f7                	jne    800cc0 <strlen+0xd>
	return n;
}
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd9:	eb 03                	jmp    800cde <strnlen+0x13>
		n++;
  800cdb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cde:	39 d0                	cmp    %edx,%eax
  800ce0:	74 08                	je     800cea <strnlen+0x1f>
  800ce2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ce6:	75 f3                	jne    800cdb <strnlen+0x10>
  800ce8:	89 c2                	mov    %eax,%edx
	return n;
}
  800cea:	89 d0                	mov    %edx,%eax
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	53                   	push   %ebx
  800cf2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d01:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d04:	83 c0 01             	add    $0x1,%eax
  800d07:	84 d2                	test   %dl,%dl
  800d09:	75 f2                	jne    800cfd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d0b:	89 c8                	mov    %ecx,%eax
  800d0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	53                   	push   %ebx
  800d16:	83 ec 10             	sub    $0x10,%esp
  800d19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d1c:	53                   	push   %ebx
  800d1d:	e8 91 ff ff ff       	call   800cb3 <strlen>
  800d22:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d25:	ff 75 0c             	push   0xc(%ebp)
  800d28:	01 d8                	add    %ebx,%eax
  800d2a:	50                   	push   %eax
  800d2b:	e8 be ff ff ff       	call   800cee <strcpy>
	return dst;
}
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d42:	89 f3                	mov    %esi,%ebx
  800d44:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d47:	89 f0                	mov    %esi,%eax
  800d49:	eb 0f                	jmp    800d5a <strncpy+0x23>
		*dst++ = *src;
  800d4b:	83 c0 01             	add    $0x1,%eax
  800d4e:	0f b6 0a             	movzbl (%edx),%ecx
  800d51:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d54:	80 f9 01             	cmp    $0x1,%cl
  800d57:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800d5a:	39 d8                	cmp    %ebx,%eax
  800d5c:	75 ed                	jne    800d4b <strncpy+0x14>
	}
	return ret;
}
  800d5e:	89 f0                	mov    %esi,%eax
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	8b 75 08             	mov    0x8(%ebp),%esi
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 10             	mov    0x10(%ebp),%edx
  800d72:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d74:	85 d2                	test   %edx,%edx
  800d76:	74 21                	je     800d99 <strlcpy+0x35>
  800d78:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d7c:	89 f2                	mov    %esi,%edx
  800d7e:	eb 09                	jmp    800d89 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d80:	83 c1 01             	add    $0x1,%ecx
  800d83:	83 c2 01             	add    $0x1,%edx
  800d86:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800d89:	39 c2                	cmp    %eax,%edx
  800d8b:	74 09                	je     800d96 <strlcpy+0x32>
  800d8d:	0f b6 19             	movzbl (%ecx),%ebx
  800d90:	84 db                	test   %bl,%bl
  800d92:	75 ec                	jne    800d80 <strlcpy+0x1c>
  800d94:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800d96:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d99:	29 f0                	sub    %esi,%eax
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800da8:	eb 06                	jmp    800db0 <strcmp+0x11>
		p++, q++;
  800daa:	83 c1 01             	add    $0x1,%ecx
  800dad:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800db0:	0f b6 01             	movzbl (%ecx),%eax
  800db3:	84 c0                	test   %al,%al
  800db5:	74 04                	je     800dbb <strcmp+0x1c>
  800db7:	3a 02                	cmp    (%edx),%al
  800db9:	74 ef                	je     800daa <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbb:	0f b6 c0             	movzbl %al,%eax
  800dbe:	0f b6 12             	movzbl (%edx),%edx
  800dc1:	29 d0                	sub    %edx,%eax
}
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	53                   	push   %ebx
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcf:	89 c3                	mov    %eax,%ebx
  800dd1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dd4:	eb 06                	jmp    800ddc <strncmp+0x17>
		n--, p++, q++;
  800dd6:	83 c0 01             	add    $0x1,%eax
  800dd9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ddc:	39 d8                	cmp    %ebx,%eax
  800dde:	74 18                	je     800df8 <strncmp+0x33>
  800de0:	0f b6 08             	movzbl (%eax),%ecx
  800de3:	84 c9                	test   %cl,%cl
  800de5:	74 04                	je     800deb <strncmp+0x26>
  800de7:	3a 0a                	cmp    (%edx),%cl
  800de9:	74 eb                	je     800dd6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800deb:	0f b6 00             	movzbl (%eax),%eax
  800dee:	0f b6 12             	movzbl (%edx),%edx
  800df1:	29 d0                	sub    %edx,%eax
}
  800df3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    
		return 0;
  800df8:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfd:	eb f4                	jmp    800df3 <strncmp+0x2e>

00800dff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e09:	eb 03                	jmp    800e0e <strchr+0xf>
  800e0b:	83 c0 01             	add    $0x1,%eax
  800e0e:	0f b6 10             	movzbl (%eax),%edx
  800e11:	84 d2                	test   %dl,%dl
  800e13:	74 06                	je     800e1b <strchr+0x1c>
		if (*s == c)
  800e15:	38 ca                	cmp    %cl,%dl
  800e17:	75 f2                	jne    800e0b <strchr+0xc>
  800e19:	eb 05                	jmp    800e20 <strchr+0x21>
			return (char *) s;
	return 0;
  800e1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e2c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e2f:	38 ca                	cmp    %cl,%dl
  800e31:	74 09                	je     800e3c <strfind+0x1a>
  800e33:	84 d2                	test   %dl,%dl
  800e35:	74 05                	je     800e3c <strfind+0x1a>
	for (; *s; s++)
  800e37:	83 c0 01             	add    $0x1,%eax
  800e3a:	eb f0                	jmp    800e2c <strfind+0xa>
			break;
	return (char *) s;
}
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    

00800e3e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e4a:	85 c9                	test   %ecx,%ecx
  800e4c:	74 2f                	je     800e7d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e4e:	89 f8                	mov    %edi,%eax
  800e50:	09 c8                	or     %ecx,%eax
  800e52:	a8 03                	test   $0x3,%al
  800e54:	75 21                	jne    800e77 <memset+0x39>
		c &= 0xFF;
  800e56:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e5a:	89 d0                	mov    %edx,%eax
  800e5c:	c1 e0 08             	shl    $0x8,%eax
  800e5f:	89 d3                	mov    %edx,%ebx
  800e61:	c1 e3 18             	shl    $0x18,%ebx
  800e64:	89 d6                	mov    %edx,%esi
  800e66:	c1 e6 10             	shl    $0x10,%esi
  800e69:	09 f3                	or     %esi,%ebx
  800e6b:	09 da                	or     %ebx,%edx
  800e6d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e6f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800e72:	fc                   	cld    
  800e73:	f3 ab                	rep stos %eax,%es:(%edi)
  800e75:	eb 06                	jmp    800e7d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	fc                   	cld    
  800e7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e7d:	89 f8                	mov    %edi,%eax
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e92:	39 c6                	cmp    %eax,%esi
  800e94:	73 32                	jae    800ec8 <memmove+0x44>
  800e96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e99:	39 c2                	cmp    %eax,%edx
  800e9b:	76 2b                	jbe    800ec8 <memmove+0x44>
		s += n;
		d += n;
  800e9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ea0:	89 d6                	mov    %edx,%esi
  800ea2:	09 fe                	or     %edi,%esi
  800ea4:	09 ce                	or     %ecx,%esi
  800ea6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eac:	75 0e                	jne    800ebc <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eae:	83 ef 04             	sub    $0x4,%edi
  800eb1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800eb4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800eb7:	fd                   	std    
  800eb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eba:	eb 09                	jmp    800ec5 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ebc:	83 ef 01             	sub    $0x1,%edi
  800ebf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ec2:	fd                   	std    
  800ec3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ec5:	fc                   	cld    
  800ec6:	eb 1a                	jmp    800ee2 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ec8:	89 f2                	mov    %esi,%edx
  800eca:	09 c2                	or     %eax,%edx
  800ecc:	09 ca                	or     %ecx,%edx
  800ece:	f6 c2 03             	test   $0x3,%dl
  800ed1:	75 0a                	jne    800edd <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ed3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ed6:	89 c7                	mov    %eax,%edi
  800ed8:	fc                   	cld    
  800ed9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800edb:	eb 05                	jmp    800ee2 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800edd:	89 c7                	mov    %eax,%edi
  800edf:	fc                   	cld    
  800ee0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800eec:	ff 75 10             	push   0x10(%ebp)
  800eef:	ff 75 0c             	push   0xc(%ebp)
  800ef2:	ff 75 08             	push   0x8(%ebp)
  800ef5:	e8 8a ff ff ff       	call   800e84 <memmove>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	8b 45 08             	mov    0x8(%ebp),%eax
  800f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f07:	89 c6                	mov    %eax,%esi
  800f09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f0c:	eb 06                	jmp    800f14 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f0e:	83 c0 01             	add    $0x1,%eax
  800f11:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800f14:	39 f0                	cmp    %esi,%eax
  800f16:	74 14                	je     800f2c <memcmp+0x30>
		if (*s1 != *s2)
  800f18:	0f b6 08             	movzbl (%eax),%ecx
  800f1b:	0f b6 1a             	movzbl (%edx),%ebx
  800f1e:	38 d9                	cmp    %bl,%cl
  800f20:	74 ec                	je     800f0e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800f22:	0f b6 c1             	movzbl %cl,%eax
  800f25:	0f b6 db             	movzbl %bl,%ebx
  800f28:	29 d8                	sub    %ebx,%eax
  800f2a:	eb 05                	jmp    800f31 <memcmp+0x35>
	}

	return 0;
  800f2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f43:	eb 03                	jmp    800f48 <memfind+0x13>
  800f45:	83 c0 01             	add    $0x1,%eax
  800f48:	39 d0                	cmp    %edx,%eax
  800f4a:	73 04                	jae    800f50 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f4c:	38 08                	cmp    %cl,(%eax)
  800f4e:	75 f5                	jne    800f45 <memfind+0x10>
			break;
	return (void *) s;
}
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f5e:	eb 03                	jmp    800f63 <strtol+0x11>
		s++;
  800f60:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800f63:	0f b6 02             	movzbl (%edx),%eax
  800f66:	3c 20                	cmp    $0x20,%al
  800f68:	74 f6                	je     800f60 <strtol+0xe>
  800f6a:	3c 09                	cmp    $0x9,%al
  800f6c:	74 f2                	je     800f60 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800f6e:	3c 2b                	cmp    $0x2b,%al
  800f70:	74 2a                	je     800f9c <strtol+0x4a>
	int neg = 0;
  800f72:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800f77:	3c 2d                	cmp    $0x2d,%al
  800f79:	74 2b                	je     800fa6 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f7b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f81:	75 0f                	jne    800f92 <strtol+0x40>
  800f83:	80 3a 30             	cmpb   $0x30,(%edx)
  800f86:	74 28                	je     800fb0 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f88:	85 db                	test   %ebx,%ebx
  800f8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f8f:	0f 44 d8             	cmove  %eax,%ebx
  800f92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f97:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800f9a:	eb 46                	jmp    800fe2 <strtol+0x90>
		s++;
  800f9c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800f9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa4:	eb d5                	jmp    800f7b <strtol+0x29>
		s++, neg = 1;
  800fa6:	83 c2 01             	add    $0x1,%edx
  800fa9:	bf 01 00 00 00       	mov    $0x1,%edi
  800fae:	eb cb                	jmp    800f7b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fb0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800fb4:	74 0e                	je     800fc4 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800fb6:	85 db                	test   %ebx,%ebx
  800fb8:	75 d8                	jne    800f92 <strtol+0x40>
		s++, base = 8;
  800fba:	83 c2 01             	add    $0x1,%edx
  800fbd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800fc2:	eb ce                	jmp    800f92 <strtol+0x40>
		s += 2, base = 16;
  800fc4:	83 c2 02             	add    $0x2,%edx
  800fc7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fcc:	eb c4                	jmp    800f92 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800fce:	0f be c0             	movsbl %al,%eax
  800fd1:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800fd4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800fd7:	7d 3a                	jge    801013 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800fd9:	83 c2 01             	add    $0x1,%edx
  800fdc:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800fe0:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800fe2:	0f b6 02             	movzbl (%edx),%eax
  800fe5:	8d 70 d0             	lea    -0x30(%eax),%esi
  800fe8:	89 f3                	mov    %esi,%ebx
  800fea:	80 fb 09             	cmp    $0x9,%bl
  800fed:	76 df                	jbe    800fce <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800fef:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ff2:	89 f3                	mov    %esi,%ebx
  800ff4:	80 fb 19             	cmp    $0x19,%bl
  800ff7:	77 08                	ja     801001 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ff9:	0f be c0             	movsbl %al,%eax
  800ffc:	83 e8 57             	sub    $0x57,%eax
  800fff:	eb d3                	jmp    800fd4 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801001:	8d 70 bf             	lea    -0x41(%eax),%esi
  801004:	89 f3                	mov    %esi,%ebx
  801006:	80 fb 19             	cmp    $0x19,%bl
  801009:	77 08                	ja     801013 <strtol+0xc1>
			dig = *s - 'A' + 10;
  80100b:	0f be c0             	movsbl %al,%eax
  80100e:	83 e8 37             	sub    $0x37,%eax
  801011:	eb c1                	jmp    800fd4 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801013:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801017:	74 05                	je     80101e <strtol+0xcc>
		*endptr = (char *) s;
  801019:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80101e:	89 c8                	mov    %ecx,%eax
  801020:	f7 d8                	neg    %eax
  801022:	85 ff                	test   %edi,%edi
  801024:	0f 45 c8             	cmovne %eax,%ecx
}
  801027:	89 c8                	mov    %ecx,%eax
  801029:	5b                   	pop    %ebx
  80102a:	5e                   	pop    %esi
  80102b:	5f                   	pop    %edi
  80102c:	5d                   	pop    %ebp
  80102d:	c3                   	ret    

0080102e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	53                   	push   %ebx
	asm volatile("int %1\n"
  801034:	b8 00 00 00 00       	mov    $0x0,%eax
  801039:	8b 55 08             	mov    0x8(%ebp),%edx
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	89 c3                	mov    %eax,%ebx
  801041:	89 c7                	mov    %eax,%edi
  801043:	89 c6                	mov    %eax,%esi
  801045:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <sys_cgetc>:

int
sys_cgetc(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	57                   	push   %edi
  801050:	56                   	push   %esi
  801051:	53                   	push   %ebx
	asm volatile("int %1\n"
  801052:	ba 00 00 00 00       	mov    $0x0,%edx
  801057:	b8 01 00 00 00       	mov    $0x1,%eax
  80105c:	89 d1                	mov    %edx,%ecx
  80105e:	89 d3                	mov    %edx,%ebx
  801060:	89 d7                	mov    %edx,%edi
  801062:	89 d6                	mov    %edx,%esi
  801064:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801074:	b9 00 00 00 00       	mov    $0x0,%ecx
  801079:	8b 55 08             	mov    0x8(%ebp),%edx
  80107c:	b8 03 00 00 00       	mov    $0x3,%eax
  801081:	89 cb                	mov    %ecx,%ebx
  801083:	89 cf                	mov    %ecx,%edi
  801085:	89 ce                	mov    %ecx,%esi
  801087:	cd 30                	int    $0x30
	if(check && ret > 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	7f 08                	jg     801095 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	50                   	push   %eax
  801099:	6a 03                	push   $0x3
  80109b:	68 04 19 80 00       	push   $0x801904
  8010a0:	6a 2a                	push   $0x2a
  8010a2:	68 21 19 80 00       	push   $0x801921
  8010a7:	e8 8d f5 ff ff       	call   800639 <_panic>

008010ac <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8010bc:	89 d1                	mov    %edx,%ecx
  8010be:	89 d3                	mov    %edx,%ebx
  8010c0:	89 d7                	mov    %edx,%edi
  8010c2:	89 d6                	mov    %edx,%esi
  8010c4:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <sys_yield>:

void
sys_yield(void)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	57                   	push   %edi
  8010cf:	56                   	push   %esi
  8010d0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010db:	89 d1                	mov    %edx,%ecx
  8010dd:	89 d3                	mov    %edx,%ebx
  8010df:	89 d7                	mov    %edx,%edi
  8010e1:	89 d6                	mov    %edx,%esi
  8010e3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    

008010ea <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	57                   	push   %edi
  8010ee:	56                   	push   %esi
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010f3:	be 00 00 00 00       	mov    $0x0,%esi
  8010f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801103:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801106:	89 f7                	mov    %esi,%edi
  801108:	cd 30                	int    $0x30
	if(check && ret > 0)
  80110a:	85 c0                	test   %eax,%eax
  80110c:	7f 08                	jg     801116 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80110e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	50                   	push   %eax
  80111a:	6a 04                	push   $0x4
  80111c:	68 04 19 80 00       	push   $0x801904
  801121:	6a 2a                	push   $0x2a
  801123:	68 21 19 80 00       	push   $0x801921
  801128:	e8 0c f5 ff ff       	call   800639 <_panic>

0080112d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	57                   	push   %edi
  801131:	56                   	push   %esi
  801132:	53                   	push   %ebx
  801133:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801136:	8b 55 08             	mov    0x8(%ebp),%edx
  801139:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113c:	b8 05 00 00 00       	mov    $0x5,%eax
  801141:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801144:	8b 7d 14             	mov    0x14(%ebp),%edi
  801147:	8b 75 18             	mov    0x18(%ebp),%esi
  80114a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80114c:	85 c0                	test   %eax,%eax
  80114e:	7f 08                	jg     801158 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	50                   	push   %eax
  80115c:	6a 05                	push   $0x5
  80115e:	68 04 19 80 00       	push   $0x801904
  801163:	6a 2a                	push   $0x2a
  801165:	68 21 19 80 00       	push   $0x801921
  80116a:	e8 ca f4 ff ff       	call   800639 <_panic>

0080116f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	57                   	push   %edi
  801173:	56                   	push   %esi
  801174:	53                   	push   %ebx
  801175:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801178:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801183:	b8 06 00 00 00       	mov    $0x6,%eax
  801188:	89 df                	mov    %ebx,%edi
  80118a:	89 de                	mov    %ebx,%esi
  80118c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80118e:	85 c0                	test   %eax,%eax
  801190:	7f 08                	jg     80119a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80119a:	83 ec 0c             	sub    $0xc,%esp
  80119d:	50                   	push   %eax
  80119e:	6a 06                	push   $0x6
  8011a0:	68 04 19 80 00       	push   $0x801904
  8011a5:	6a 2a                	push   $0x2a
  8011a7:	68 21 19 80 00       	push   $0x801921
  8011ac:	e8 88 f4 ff ff       	call   800639 <_panic>

008011b1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	57                   	push   %edi
  8011b5:	56                   	push   %esi
  8011b6:	53                   	push   %ebx
  8011b7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c5:	b8 08 00 00 00       	mov    $0x8,%eax
  8011ca:	89 df                	mov    %ebx,%edi
  8011cc:	89 de                	mov    %ebx,%esi
  8011ce:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	7f 08                	jg     8011dc <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011dc:	83 ec 0c             	sub    $0xc,%esp
  8011df:	50                   	push   %eax
  8011e0:	6a 08                	push   $0x8
  8011e2:	68 04 19 80 00       	push   $0x801904
  8011e7:	6a 2a                	push   $0x2a
  8011e9:	68 21 19 80 00       	push   $0x801921
  8011ee:	e8 46 f4 ff ff       	call   800639 <_panic>

008011f3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	57                   	push   %edi
  8011f7:	56                   	push   %esi
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801201:	8b 55 08             	mov    0x8(%ebp),%edx
  801204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801207:	b8 09 00 00 00       	mov    $0x9,%eax
  80120c:	89 df                	mov    %ebx,%edi
  80120e:	89 de                	mov    %ebx,%esi
  801210:	cd 30                	int    $0x30
	if(check && ret > 0)
  801212:	85 c0                	test   %eax,%eax
  801214:	7f 08                	jg     80121e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5f                   	pop    %edi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80121e:	83 ec 0c             	sub    $0xc,%esp
  801221:	50                   	push   %eax
  801222:	6a 09                	push   $0x9
  801224:	68 04 19 80 00       	push   $0x801904
  801229:	6a 2a                	push   $0x2a
  80122b:	68 21 19 80 00       	push   $0x801921
  801230:	e8 04 f4 ff ff       	call   800639 <_panic>

00801235 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	57                   	push   %edi
  801239:	56                   	push   %esi
  80123a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80123b:	8b 55 08             	mov    0x8(%ebp),%edx
  80123e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801241:	b8 0b 00 00 00       	mov    $0xb,%eax
  801246:	be 00 00 00 00       	mov    $0x0,%esi
  80124b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801251:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801253:	5b                   	pop    %ebx
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	57                   	push   %edi
  80125c:	56                   	push   %esi
  80125d:	53                   	push   %ebx
  80125e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801261:	b9 00 00 00 00       	mov    $0x0,%ecx
  801266:	8b 55 08             	mov    0x8(%ebp),%edx
  801269:	b8 0c 00 00 00       	mov    $0xc,%eax
  80126e:	89 cb                	mov    %ecx,%ebx
  801270:	89 cf                	mov    %ecx,%edi
  801272:	89 ce                	mov    %ecx,%esi
  801274:	cd 30                	int    $0x30
	if(check && ret > 0)
  801276:	85 c0                	test   %eax,%eax
  801278:	7f 08                	jg     801282 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801282:	83 ec 0c             	sub    $0xc,%esp
  801285:	50                   	push   %eax
  801286:	6a 0c                	push   $0xc
  801288:	68 04 19 80 00       	push   $0x801904
  80128d:	6a 2a                	push   $0x2a
  80128f:	68 21 19 80 00       	push   $0x801921
  801294:	e8 a0 f3 ff ff       	call   800639 <_panic>

00801299 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80129f:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8012a6:	74 0a                	je     8012b2 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ab:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8012b2:	e8 f5 fd ff ff       	call   8010ac <sys_getenvid>
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	68 07 0e 00 00       	push   $0xe07
  8012bf:	68 00 f0 bf ee       	push   $0xeebff000
  8012c4:	50                   	push   %eax
  8012c5:	e8 20 fe ff ff       	call   8010ea <sys_page_alloc>
		if (r < 0) {
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 2c                	js     8012fd <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8012d1:	e8 d6 fd ff ff       	call   8010ac <sys_getenvid>
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	68 0f 13 80 00       	push   $0x80130f
  8012de:	50                   	push   %eax
  8012df:	e8 0f ff ff ff       	call   8011f3 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	79 bd                	jns    8012a8 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  8012eb:	50                   	push   %eax
  8012ec:	68 70 19 80 00       	push   $0x801970
  8012f1:	6a 28                	push   $0x28
  8012f3:	68 a6 19 80 00       	push   $0x8019a6
  8012f8:	e8 3c f3 ff ff       	call   800639 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  8012fd:	50                   	push   %eax
  8012fe:	68 30 19 80 00       	push   $0x801930
  801303:	6a 23                	push   $0x23
  801305:	68 a6 19 80 00       	push   $0x8019a6
  80130a:	e8 2a f3 ff ff       	call   800639 <_panic>

0080130f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80130f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801310:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801315:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801317:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80131a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80131e:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801321:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801325:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801329:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80132b:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80132e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80132f:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801332:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801333:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801334:	c3                   	ret    
  801335:	66 90                	xchg   %ax,%ax
  801337:	66 90                	xchg   %ax,%ax
  801339:	66 90                	xchg   %ax,%ax
  80133b:	66 90                	xchg   %ax,%ax
  80133d:	66 90                	xchg   %ax,%ax
  80133f:	90                   	nop

00801340 <__udivdi3>:
  801340:	f3 0f 1e fb          	endbr32 
  801344:	55                   	push   %ebp
  801345:	57                   	push   %edi
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	83 ec 1c             	sub    $0x1c,%esp
  80134b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80134f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801353:	8b 74 24 34          	mov    0x34(%esp),%esi
  801357:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80135b:	85 c0                	test   %eax,%eax
  80135d:	75 19                	jne    801378 <__udivdi3+0x38>
  80135f:	39 f3                	cmp    %esi,%ebx
  801361:	76 4d                	jbe    8013b0 <__udivdi3+0x70>
  801363:	31 ff                	xor    %edi,%edi
  801365:	89 e8                	mov    %ebp,%eax
  801367:	89 f2                	mov    %esi,%edx
  801369:	f7 f3                	div    %ebx
  80136b:	89 fa                	mov    %edi,%edx
  80136d:	83 c4 1c             	add    $0x1c,%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	8d 76 00             	lea    0x0(%esi),%esi
  801378:	39 f0                	cmp    %esi,%eax
  80137a:	76 14                	jbe    801390 <__udivdi3+0x50>
  80137c:	31 ff                	xor    %edi,%edi
  80137e:	31 c0                	xor    %eax,%eax
  801380:	89 fa                	mov    %edi,%edx
  801382:	83 c4 1c             	add    $0x1c,%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5f                   	pop    %edi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    
  80138a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801390:	0f bd f8             	bsr    %eax,%edi
  801393:	83 f7 1f             	xor    $0x1f,%edi
  801396:	75 48                	jne    8013e0 <__udivdi3+0xa0>
  801398:	39 f0                	cmp    %esi,%eax
  80139a:	72 06                	jb     8013a2 <__udivdi3+0x62>
  80139c:	31 c0                	xor    %eax,%eax
  80139e:	39 eb                	cmp    %ebp,%ebx
  8013a0:	77 de                	ja     801380 <__udivdi3+0x40>
  8013a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a7:	eb d7                	jmp    801380 <__udivdi3+0x40>
  8013a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	89 d9                	mov    %ebx,%ecx
  8013b2:	85 db                	test   %ebx,%ebx
  8013b4:	75 0b                	jne    8013c1 <__udivdi3+0x81>
  8013b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	f7 f3                	div    %ebx
  8013bf:	89 c1                	mov    %eax,%ecx
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	89 f0                	mov    %esi,%eax
  8013c5:	f7 f1                	div    %ecx
  8013c7:	89 c6                	mov    %eax,%esi
  8013c9:	89 e8                	mov    %ebp,%eax
  8013cb:	89 f7                	mov    %esi,%edi
  8013cd:	f7 f1                	div    %ecx
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	83 c4 1c             	add    $0x1c,%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
  8013d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	89 f9                	mov    %edi,%ecx
  8013e2:	ba 20 00 00 00       	mov    $0x20,%edx
  8013e7:	29 fa                	sub    %edi,%edx
  8013e9:	d3 e0                	shl    %cl,%eax
  8013eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ef:	89 d1                	mov    %edx,%ecx
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	d3 e8                	shr    %cl,%eax
  8013f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013f9:	09 c1                	or     %eax,%ecx
  8013fb:	89 f0                	mov    %esi,%eax
  8013fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801401:	89 f9                	mov    %edi,%ecx
  801403:	d3 e3                	shl    %cl,%ebx
  801405:	89 d1                	mov    %edx,%ecx
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 f9                	mov    %edi,%ecx
  80140b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80140f:	89 eb                	mov    %ebp,%ebx
  801411:	d3 e6                	shl    %cl,%esi
  801413:	89 d1                	mov    %edx,%ecx
  801415:	d3 eb                	shr    %cl,%ebx
  801417:	09 f3                	or     %esi,%ebx
  801419:	89 c6                	mov    %eax,%esi
  80141b:	89 f2                	mov    %esi,%edx
  80141d:	89 d8                	mov    %ebx,%eax
  80141f:	f7 74 24 08          	divl   0x8(%esp)
  801423:	89 d6                	mov    %edx,%esi
  801425:	89 c3                	mov    %eax,%ebx
  801427:	f7 64 24 0c          	mull   0xc(%esp)
  80142b:	39 d6                	cmp    %edx,%esi
  80142d:	72 19                	jb     801448 <__udivdi3+0x108>
  80142f:	89 f9                	mov    %edi,%ecx
  801431:	d3 e5                	shl    %cl,%ebp
  801433:	39 c5                	cmp    %eax,%ebp
  801435:	73 04                	jae    80143b <__udivdi3+0xfb>
  801437:	39 d6                	cmp    %edx,%esi
  801439:	74 0d                	je     801448 <__udivdi3+0x108>
  80143b:	89 d8                	mov    %ebx,%eax
  80143d:	31 ff                	xor    %edi,%edi
  80143f:	e9 3c ff ff ff       	jmp    801380 <__udivdi3+0x40>
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80144b:	31 ff                	xor    %edi,%edi
  80144d:	e9 2e ff ff ff       	jmp    801380 <__udivdi3+0x40>
  801452:	66 90                	xchg   %ax,%ax
  801454:	66 90                	xchg   %ax,%ax
  801456:	66 90                	xchg   %ax,%ax
  801458:	66 90                	xchg   %ax,%ax
  80145a:	66 90                	xchg   %ax,%ax
  80145c:	66 90                	xchg   %ax,%ax
  80145e:	66 90                	xchg   %ax,%ax

00801460 <__umoddi3>:
  801460:	f3 0f 1e fb          	endbr32 
  801464:	55                   	push   %ebp
  801465:	57                   	push   %edi
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
  801468:	83 ec 1c             	sub    $0x1c,%esp
  80146b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80146f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801473:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801477:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80147b:	89 f0                	mov    %esi,%eax
  80147d:	89 da                	mov    %ebx,%edx
  80147f:	85 ff                	test   %edi,%edi
  801481:	75 15                	jne    801498 <__umoddi3+0x38>
  801483:	39 dd                	cmp    %ebx,%ebp
  801485:	76 39                	jbe    8014c0 <__umoddi3+0x60>
  801487:	f7 f5                	div    %ebp
  801489:	89 d0                	mov    %edx,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	83 c4 1c             	add    $0x1c,%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	5f                   	pop    %edi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    
  801495:	8d 76 00             	lea    0x0(%esi),%esi
  801498:	39 df                	cmp    %ebx,%edi
  80149a:	77 f1                	ja     80148d <__umoddi3+0x2d>
  80149c:	0f bd cf             	bsr    %edi,%ecx
  80149f:	83 f1 1f             	xor    $0x1f,%ecx
  8014a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014a6:	75 40                	jne    8014e8 <__umoddi3+0x88>
  8014a8:	39 df                	cmp    %ebx,%edi
  8014aa:	72 04                	jb     8014b0 <__umoddi3+0x50>
  8014ac:	39 f5                	cmp    %esi,%ebp
  8014ae:	77 dd                	ja     80148d <__umoddi3+0x2d>
  8014b0:	89 da                	mov    %ebx,%edx
  8014b2:	89 f0                	mov    %esi,%eax
  8014b4:	29 e8                	sub    %ebp,%eax
  8014b6:	19 fa                	sbb    %edi,%edx
  8014b8:	eb d3                	jmp    80148d <__umoddi3+0x2d>
  8014ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014c0:	89 e9                	mov    %ebp,%ecx
  8014c2:	85 ed                	test   %ebp,%ebp
  8014c4:	75 0b                	jne    8014d1 <__umoddi3+0x71>
  8014c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	f7 f5                	div    %ebp
  8014cf:	89 c1                	mov    %eax,%ecx
  8014d1:	89 d8                	mov    %ebx,%eax
  8014d3:	31 d2                	xor    %edx,%edx
  8014d5:	f7 f1                	div    %ecx
  8014d7:	89 f0                	mov    %esi,%eax
  8014d9:	f7 f1                	div    %ecx
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	31 d2                	xor    %edx,%edx
  8014df:	eb ac                	jmp    80148d <__umoddi3+0x2d>
  8014e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014ec:	ba 20 00 00 00       	mov    $0x20,%edx
  8014f1:	29 c2                	sub    %eax,%edx
  8014f3:	89 c1                	mov    %eax,%ecx
  8014f5:	89 e8                	mov    %ebp,%eax
  8014f7:	d3 e7                	shl    %cl,%edi
  8014f9:	89 d1                	mov    %edx,%ecx
  8014fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014ff:	d3 e8                	shr    %cl,%eax
  801501:	89 c1                	mov    %eax,%ecx
  801503:	8b 44 24 04          	mov    0x4(%esp),%eax
  801507:	09 f9                	or     %edi,%ecx
  801509:	89 df                	mov    %ebx,%edi
  80150b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80150f:	89 c1                	mov    %eax,%ecx
  801511:	d3 e5                	shl    %cl,%ebp
  801513:	89 d1                	mov    %edx,%ecx
  801515:	d3 ef                	shr    %cl,%edi
  801517:	89 c1                	mov    %eax,%ecx
  801519:	89 f0                	mov    %esi,%eax
  80151b:	d3 e3                	shl    %cl,%ebx
  80151d:	89 d1                	mov    %edx,%ecx
  80151f:	89 fa                	mov    %edi,%edx
  801521:	d3 e8                	shr    %cl,%eax
  801523:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801528:	09 d8                	or     %ebx,%eax
  80152a:	f7 74 24 08          	divl   0x8(%esp)
  80152e:	89 d3                	mov    %edx,%ebx
  801530:	d3 e6                	shl    %cl,%esi
  801532:	f7 e5                	mul    %ebp
  801534:	89 c7                	mov    %eax,%edi
  801536:	89 d1                	mov    %edx,%ecx
  801538:	39 d3                	cmp    %edx,%ebx
  80153a:	72 06                	jb     801542 <__umoddi3+0xe2>
  80153c:	75 0e                	jne    80154c <__umoddi3+0xec>
  80153e:	39 c6                	cmp    %eax,%esi
  801540:	73 0a                	jae    80154c <__umoddi3+0xec>
  801542:	29 e8                	sub    %ebp,%eax
  801544:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801548:	89 d1                	mov    %edx,%ecx
  80154a:	89 c7                	mov    %eax,%edi
  80154c:	89 f5                	mov    %esi,%ebp
  80154e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801552:	29 fd                	sub    %edi,%ebp
  801554:	19 cb                	sbb    %ecx,%ebx
  801556:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80155b:	89 d8                	mov    %ebx,%eax
  80155d:	d3 e0                	shl    %cl,%eax
  80155f:	89 f1                	mov    %esi,%ecx
  801561:	d3 ed                	shr    %cl,%ebp
  801563:	d3 eb                	shr    %cl,%ebx
  801565:	09 e8                	or     %ebp,%eax
  801567:	89 da                	mov    %ebx,%edx
  801569:	83 c4 1c             	add    $0x1c,%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5e                   	pop    %esi
  80156e:	5f                   	pop    %edi
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    
