//用户将要实现的调度器的代码框架
#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle = NULL;

	// Implement simple round-robin scheduling.
	//
	// 1. Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// 2.If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment. Make sure curenv is not null before
	// dereferencing it.
	//
	// 3.Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
#ifdef CONF_MFQ
	int findscope=0;
	if(curenv && curenv->env_status == ENV_RUNNING) findscope=curenv->env_mfq_level;
	else findscope=NMFQ-1;

	for (int i = 0; i <= findscope; i++) {//只在队列中找优先级高于或等于当前运行环境的环境
		if (!queue_empty(&mfqs[i])) {
			idle = (struct Env *) queue_head(&mfqs[i] );
			assert(idle->env_status == ENV_RUNNABLE);
			break;
		}
	}
	if (idle) {
		cprintf("New running environment is %08x\n",idle->env_id);
		env_run(idle);
	} else if (curenv && curenv->env_status == ENV_RUNNING) {
		cprintf("still runs environment %08x\n",curenv->env_id);
		env_run(curenv);
	}
#else
	struct Env * now = curenv;
	//--------------------轮训调度---------------
	int index=-1;//因为这里出错了！！一定是-1！！！
	//1.
	if(now) index= ENVX(now->env_id);//inc/env.h
	for(int i=index+1; i<index+NENV;i++){
		if(envs[i%NENV].env_status == ENV_RUNNABLE){
			env_run(&envs[i%NENV]);
			return;//我试了一下，这块是否返回，测试都会成功 
		}
	}
	//2.
	if(now && now->env_status == ENV_RUNNING){
		env_run(now);
		return;
	}
#endif //CONF_MFQ

	// sched_halt never returns
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

