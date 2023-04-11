#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>

static struct Taskstate ts;

/* For debugging, so print_trapframe can distinguish between printing
 * a saved trapframe and printing the current trapframe and print some
 * additional information in the latter case.
 */
static struct Trapframe *last_tf;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
 //struct Gatedesc在inc/mmu.h中定义
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
}


//lab3 声明异常处理函数
void DIVIDE_HANDLER();
void DEBUG_HANDLER();
void NMI_HANDLER();
void BRKPT_HANDLER();
void OFLOW_HANDLER();
void BOUND_HANDLER();
void ILLOP_HANDLER();
void DEVICE_HANDLER();
void DBLFLT_HANDLER();
/* T_COPROC 9 reserved */
void TSS_HANDLER();
void SEGNP_HANDLER();
void STACK_HANDLER();
void GPFLT_HANDLER();
void PGFLT_HANDLER();
/* T_RES 15 reserved */
void FPERR_HANDLER();
void ALIGN_HANDLER();
void MCHK_HANDLER();
void SIMDERR_HANDLER();

//exercise 7 syscall
void SYSCALL_HANDLER();

void
trap_init(void)
{
	extern struct Segdesc gdt[];
	// LAB 3: Your code here.
	//代码段选择子为GD_KT（这在mmu.h中声明了，可以理解） ，代码段偏移为DIVIDE_HANDLER 等函数名。这个我还不太懂，段偏移就是函数名么？（后在网上看到：汇编中变量名本质是一个偏移地址！！！！！！！ 这个应该就是解释。）
	SETGATE(idt[T_DIVIDE], 0, GD_KT, DIVIDE_HANDLER, 0);//GD_KT  kernel text
	SETGATE(idt[T_DEBUG], 0, GD_KT, DEBUG_HANDLER, 0);
	SETGATE(idt[T_NMI], 0, GD_KT, NMI_HANDLER, 0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, BRKPT_HANDLER, 3);//exercise 6在此处需要修改
	SETGATE(idt[T_OFLOW], 0, GD_KT, OFLOW_HANDLER, 0);
	SETGATE(idt[T_BOUND], 0, GD_KT, BOUND_HANDLER, 0);
	SETGATE(idt[T_ILLOP], 0, GD_KT, ILLOP_HANDLER, 0);
	SETGATE(idt[T_DEVICE], 0, GD_KT, DEVICE_HANDLER, 0);
	SETGATE(idt[T_DBLFLT], 0, GD_KT, DBLFLT_HANDLER, 0);
	/* reserved */
	SETGATE(idt[T_TSS], 0, GD_KT, TSS_HANDLER, 0);
	SETGATE(idt[T_SEGNP], 0, GD_KT, SEGNP_HANDLER, 0);
	SETGATE(idt[T_STACK], 0, GD_KT, STACK_HANDLER, 0);
	SETGATE(idt[T_GPFLT], 0, GD_KT, GPFLT_HANDLER, 0);
	SETGATE(idt[T_PGFLT], 0, GD_KT, PGFLT_HANDLER, 0);
	/* reserved */
	SETGATE(idt[T_FPERR], 0, GD_KT, FPERR_HANDLER, 0);
	SETGATE(idt[T_ALIGN], 0, GD_KT, ALIGN_HANDLER, 0);
	SETGATE(idt[T_MCHK], 0, GD_KT, MCHK_HANDLER, 0);
	SETGATE(idt[T_SIMDERR], 0, GD_KT, SIMDERR_HANDLER, 0);
	
	//exercise 7 syscall
	SETGATE(idt[T_SYSCALL], 0, GD_KT, SYSCALL_HANDLER, 3);//需要将dpl设置为3,因为这是用户态下调用的系统调用（中断）
	
	// Per-CPU setup 
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
	ts.ts_ss0 = GD_KD;
	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	//struct Trapframe中的tf_trapno是错误码。所以我们根据tf指针找到这个错误码，然后调用处理函数即可。
	switch(tf->tf_trapno) {
		case(T_PGFLT):
			page_fault_handler(tf);
			break; 
		case(T_BRKPT):
			monitor(tf);
			break;
		case(T_SYSCALL):
			//调用kern/syscall.c中的syscall(),然后将返回值传递回%eax，其将被传递回用户进程。
			int32_t ret=syscall(tf->tf_regs.reg_eax,/*应用程序将在寄存器中传递系统调用编号和系统调用参数。系统调用编号将进入%eax。( 参见lib/syscall.c中syscall() )*/
					tf->tf_regs.reg_edx,
					tf->tf_regs.reg_ecx,
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			tf->tf_regs.reg_eax = ret;//将返回值传递回%eax，其将被传递回用户进程
			break;
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
			if (tf->tf_cs == GD_KT)  panic("unhandled trap in kernel");
			else {
				env_destroy(curenv);
				return;
			}
		}
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		assert(curenv);

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
	env_run(curenv);
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.  CPL为0时，为内核态。
	if(tf->tf_cs && 0x01 == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}

