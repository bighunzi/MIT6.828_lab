/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 * TRAPHANDLER宏定义了一个处理trap的函数，它将一个trap number压栈，然后跳转到_alltraps。在CPU自动将错误码压栈时使用它。
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)	/* name是一个函数 */			\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 * 在CPU不自动将错误码压栈时使用它。 它将在错误码的地方0压栈，所以trap frame有相同格式
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 //参见练习3中的 9.1 、9.10中的表，以及inc/trap.h 来完成这一部分。
TRAPHANDLER_NOEC(DIVIDE_HANDLER, T_DIVIDE);
TRAPHANDLER_NOEC(DEBUG_HANDLER, T_DEBUG);
TRAPHANDLER_NOEC(NMI_HANDLER, T_NMI);
TRAPHANDLER_NOEC(BRKPT_HANDLER, T_BRKPT);
TRAPHANDLER_NOEC(OFLOW_HANDLER, T_OFLOW);
TRAPHANDLER_NOEC(BOUND_HANDLER, T_BOUND);
TRAPHANDLER_NOEC(ILLOP_HANDLER, T_ILLOP);
TRAPHANDLER_NOEC(DEVICE_HANDLER, T_DEVICE);
TRAPHANDLER(DBLFLT_HANDLER, T_DBLFLT);
/* reserved */
TRAPHANDLER(TSS_HANDLER, T_TSS);
TRAPHANDLER(SEGNP_HANDLER, T_SEGNP);
TRAPHANDLER(STACK_HANDLER, T_STACK);
TRAPHANDLER(GPFLT_HANDLER, T_GPFLT);
TRAPHANDLER(PGFLT_HANDLER, T_PGFLT);
/* reserved */
TRAPHANDLER_NOEC(FPERR_HANDLER, T_FPERR);
TRAPHANDLER(ALIGN_HANDLER, T_ALIGN);
TRAPHANDLER_NOEC(MCHK_HANDLER, T_MCHK);
TRAPHANDLER_NOEC(SIMDERR_HANDLER, T_SIMDERR);

//exercise 7 syscall
TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL);

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
 	//别忘了栈由高地址向低地址生长，于是Trapframe顺序变为tf_trapno（上面两个宏已经把num压栈了），ds，es，PushRegs的反向
	pushl %ds
	pushl %es
	pushal
	//
	movw $GD_KD, %ax 
	movw %ax, %ds
	movw %ax, %es
	/*为什么不这么写？ 见笔记！
	movw GD_KD, %ds
	movw GD_KD, %es
	*/
	
	//这是作为trap(struct Trapframe *tf)的参数的
	pushl %esp
	//调用trap
	call trap
