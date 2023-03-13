#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>

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
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
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

//lab4 exercise 13
//IRQS 
void timer_handler();
void kbd_handler();
void serial_handler();
void spurious_handler();
void ide_handler();
void error_handler();

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
	
	//exercise 7 syscall  lab4中我个人对此istrap参数有异议，但实验验证确实应该设置成0，，不懂。。。
	SETGATE(idt[T_SYSCALL], 0 , GD_KT, SYSCALL_HANDLER, 3);//需要将dpl设置为3,因为这是用户态下调用的系统调用（中断）
	
	//lab4 exercise 13
	//IRQS  
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, timer_handler,   0);//中断是让内核抢占控制权，所以dpl应该设置为0。
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, kbd_handler,     0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, serial_handler,  0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, spurious_handler,0);
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, ide_handler,     0);
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],    0, GD_KT, error_handler,   0);
	
	// Per-CPU setup 
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
	// The example code here sets up the Task State Segment (TSS) and
	// the TSS descriptor for CPU 0. But it is incorrect if we are
	// running on other CPUs because each CPU has its own kernel stack.
	// Fix the code so that it works for all CPUs.
	//
	// Hints:
	//   - The macro "thiscpu" always refers to the current CPU's
	//     struct CpuInfo;
	//   - The ID of the current CPU is given by cpunum() or
	//     thiscpu->cpu_id;
	//   - Use "thiscpu->cpu_ts" as the TSS for the current CPU,
	//     rather than the global "ts" variable;
	//   - Use gdt[(GD_TSS0 >> 3) + i] for CPU i's TSS descriptor;
	//   - You mapped the per-CPU kernel stacks in mem_init_mp()
	//   - Initialize cpu_ts.ts_iomb to prevent unauthorized environments
	//     from doing IO (0 is not the correct value!) (什么意思??)
	//
	// ltr sets a 'busy' flag in the TSS selector, so if you
	// accidentally load the same TSS on more than one CPU, you'll
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	//依照注释hints修改即可
	size_t i =thiscpu->cpu_id;

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i*(KSTKSIZE + KSTKGAP);
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);//这行不懂，直接较原来程序保持不变

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (i << 3));//相应的TSS选择子也要修改

	// Load the IDT
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
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


//lab4与lab3合并时发生了冲突， 因此写到此处时，参考了下别人的代码进行修改！！！！！！！！！！！！！
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	//struct Trapframe中的tf_trapno是错误码。所以我们根据tf指针找到这个错误码，然后调用处理函数即可。
	switch(tf->tf_trapno) 
	{
		case(T_PGFLT):
			page_fault_handler(tf);
			break; 
		case(T_BRKPT):
			monitor(tf);
			break;
		case(T_SYSCALL):
			//调用kern/syscall.c中的syscall(),然后将返回值传递回%eax，其将被传递回用户进程。
			int32_t ret=syscall(tf->tf_regs.reg_eax, /*lab的文档中说应用程序将在寄存器中传递系统调用编号和系统调用参数。这样，内核就不需要遍历用户环境的栈或指令流。系统调用编号将进入%eax。但是在哪里实现的我也不清楚。*/
					tf->tf_regs.reg_edx,
					tf->tf_regs.reg_ecx,
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			tf->tf_regs.reg_eax = ret;//将返回值传递回%eax，其将被传递回用户进程
			break;
		// Handle spurious interrupts
		// The hardware sometimes raises these because of noise on the
		// IRQ line or other reasons. We don't care.
		case (IRQ_OFFSET + IRQ_SPURIOUS):
			cprintf("Spurious interrupt on irq 7\n");
			print_trapframe(tf);
			break;
		// Handle clock interrupts. Don't forget to acknowledge the
		// interrupt using lapic_eoi() before calling the scheduler!
		// LAB 4: Your code here.
		case (IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();
			sched_yield();
			break;
		// Handle keyboard and serial interrupts.
		// LAB 5: Your code here.
		case (IRQ_OFFSET + IRQ_KBD):
			lapic_eoi();
			kbd_intr();
			break;
		case (IRQ_OFFSET + IRQ_SERIAL):
			lapic_eoi();
			serial_intr();
			break;
		//
		default:
			// Unexpected trap: The user process or the kernel has a bug.
			print_trapframe(tf);
			if (tf->tf_cs == GD_KT)
				panic("unhandled trap in kernel");
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

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
		asm volatile("hlt");

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
	
		assert(curenv);

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
			env_free(curenv);
			curenv = NULL;
			sched_yield();
		}

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

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv);
	else
		sched_yield();
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.  CPL为0时，为内核态。
	if( (tf->tf_cs & 3) == 0) panic("page_fault in kernel mode, fault address %u\n", fault_va);

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// It is convenient for our code which returns from a page fault
	// (lib/pfentry.S) to have one word of scratch space at the top of the
	// trap-time stack; it allows us to more easily restore the eip/esp. In
	// the non-recursive case, we don't have to worry about this because
	// the top of the regular user stack is free.  In the recursive case,
	// this means we have to leave an extra word between the current top of
	// the exception stack and the new stack frame because the exception
	// stack _is_ the trap-time stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack or can't write to it, or the exception
	// stack overflows, then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.
	//注意， 其实并没有切换环境！！
	if (curenv->env_pgfault_upcall){
		struct UTrapframe *utf;
		if(UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1) // 发生异常时陷入。
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);//要求的32位空字。
		else    
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));

		// 检查异常栈是否溢出，权限是否正确
		user_mem_assert(curenv, (const void *) utf, sizeof(struct UTrapframe), PTE_P|PTE_W);

		//UTrapframe
		utf->utf_fault_va = fault_va;
		utf->utf_err      = tf->tf_trapno;
		utf->utf_regs     = tf->tf_regs;
		utf->utf_eflags   = tf->tf_eflags;
		// 保存陷入时现场，用于返回
		utf->utf_eip      = tf->tf_eip;
		utf->utf_esp      = tf->tf_esp;

		// 转向执行
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
		// 切换到异常栈
		curenv->env_tf.tf_esp        = (uint32_t) utf;

		env_run(curenv);
	}else{
		// Destroy the environment that caused the fault.
		cprintf("[%08x] user fault va %08x ip %08x\n",
			curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);	
	}
}

