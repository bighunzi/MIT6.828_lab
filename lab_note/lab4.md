# lab4

## 介绍
在本实验中，您将在多个同时活动的用户模式环境中实现抢占式多任务处理。

在part A中，我们将为JOS添加多处理器支持，实现轮询调度，并添加基本的环境管理系统调用(创建和销毁环境的调用，以及分配/映射内存的调用)。

在part B中，我们将实现一个类unix fork()，它允许用户态环境创建自身的副本。

最后，在part C中，你将添加对进程间通信(IPC)的支持，允许不同的用户模式环境显式地相互通信和同步。您还将添加对硬件时钟中断和抢占的支持。

### 准备开始
获取最新版本的课程存储库，然后基于我们的lab4分支origin/lab4创建一个名为lab4的本地分支:
```
git add .
git commit -am 'changes to lab2 after handin'
git pull
git checkout -b lab4 origin/lab4
git merge lab3
```
我这次合并过程中 trap.c中的trap_dispatch()函数发生了冲突，解决方案见于 [解决合并文件冲突办法](https://blog.csdn.net/yeruby/article/details/41040727)
我按照 [所用的一篇知乎参考笔记](https://github.com/SmallPond/MIT6.828_OS/blob/master/lab/kern/trap.c)与[主要参考](https://github.com/librabyte/6.828/blob/master/lab4/code/kern/trap.c) 修改合并后 ，我` make qemu `成功。 应该就没问题了。

实验4包含许多新的源文件，其中一些你应该在开始之前浏览一下:
* kern/cpu.h  内核私有的支持多处理器的定义
* kern/mpconfig.c 读取多处理器配置的代码
* kern/lapic.c 在每个处理器中驱动本地APIC单元的内核代码
* kern/mpentry.S 用于non-boot cpu的汇编语言入口代码
* kern/spinlock.h 自旋锁的内核私有定义，包括大内核锁
* kern/spinlock.c 实现自旋锁的内核代码
* kern/sched.c 用户将要实现的调度器的代码框架

## Part A: Multiprocessor Support and Cooperative Multitasking
在本实验的第一部分中，您将首先扩展JOS以在多处理器系统上运行，然后实现一些新的JOS内核系统调用，以允许用户级环境创建额外的新环境。还将实现协作式轮询调度，允许内核在当前环境主动放弃CPU(或退出)时从一个环境切换到另一个环境。在part C后面的内容中，将实现抢占式调度，它允许内核在一段时间后从环境重新获得对CPU的控制权，即使那个环境不配合。

### 多处理器支持
我们将使JOS支持**对称多处理(symmetric multiprocessing, SMP)**，这是一种多处理器模型，在这种模型中，所有cpu对系统资源(如内存和I/O总线)具有相同的访问权限。虽然在SMP中所有cpu的功能都是相同的，但在启动过程中，cpu可以分为两类:**引导处理器**(bootstrap processor, BSP)负责初始化系统和引导操作系统;只有在操作系统启动并运行之后，BSP才会激活**应用程序处理器**(application processors,APs)。哪个处理器是BSP是由硬件和BIOS决定的。**到目前为止，所有现有的JOS代码都在BSP上运行。**

在SMP系统中，每个CPU都有一个相应的本地APIC (LAPIC)单元。LAPIC单元负责在整个系统中交付中断。LAPIC还为其连接的CPU提供一个唯一的标识符。在本实验中，我们利用了以下LAPIC单元的基本功能(在kern/lapic.c中):
* 读取LAPIC标识符(APIC ID)来判断代码当前运行在哪个CPU上(参见cpunum())。
* 从BSP向ap发送启动处理器间中断(STARTUP interprocessor interrupt, IPI)，以启动其他cpu(参见lapic_startap())。
* 在part C中，我们编写了LAPIC的内置定时器来触发时钟中断，以支持抢占式多任务(参见apic_init())。

处理器使用内存映射I/O (memory-mapped I/O, MMIO)访问它的LAPIC。在MMIO中，物理内存的一部分硬连接到一些I/O设备的寄存器，因此通常用于访问内存的相同的加载/存储指令可以用于访问设备寄存器。你已经在物理地址0xA0000处看到了一个IO空洞(我们用它来写入VGA显示缓冲区)。LAPIC位于一个从物理地址0xFE000000开始的空洞中(比4GB少32MB)，因此对于我们在KERNBASE上使用通常的直接映射来访问它来说太高了。JOS虚拟内存映射在MMIOBASE中留下了4MB的空白，因此我们有一个地方可以像这样映射设备。由于后面的实验引入了更多的MMIO区域，因此我们将编写一个简单的函数来从该区域分配空间并将设备内存映射到该区域。

### Exercise 1
>练习1
在kern/pmap.c中实现mmio_map_region。要了解如何使用它，请查看kern/lapic.c中lapic_init的开头部分。在运行mmio_map_region的测试之前，你还必须完成下一个练习。

```c
void *
mmio_map_region(physaddr_t pa, size_t size)
{
    static uintptr_t base = MMIOBASE;

    // Your code here:
	void *ret =(void*) base;
	size=ROUNDUP(size,PGSIZE);
	if(base + size > MMIOLIM || base + size < base /*unsigned 越界*/)  panic("mmio_map_region reservation overflow");
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
	
	base += size;
	return ret;
	//panic("mmio_map_region not implemented");
}
```

### 应用程序处理器引导
在启动APs之前，BSP应该首先收集有关多处理器系统的信息，例如cpu的总数、APIC id和LAPIC单元的MMIO地址。kern/mpconfig.c（mp就是multiprocessing的缩写）中的mp_init()函数通过读取位于BIOS内存区域中的MP配置表来获取该信息。

boot_aps()函数(在kern/init.c中)驱动AP引导进程。APs在实模式(real mode)中启动，就像引导加载程序在boot/boot.s中启动一样，因此，boot_aps()将AP入口代码(kern/mpentry.S)复制到实模式下可寻址的内存位置。与引导加载程序不同，我们对AP开始执行代码的位置有一定的控制;我们将条目代码复制到0x7000 (MPENTRY_PADDR)，但是任何低于640KB的未使用的、按页对齐的物理地址都可以工作。

之后，boot_aps()将STARTUP IPIs，以及初始的CS:IP地址发送到对应AP的LAPIC单元，AP将在该地址开始运行其入口代码(在我们的例子中是MPENTRY_PADDR)，从而逐个激活AP。kern/mpentry.s中的入口代码和boot/boot.S非常相似。经过一些简短的设置后，它将AP置于保护模式并启用分页，然后调用C设置例程mp_main()(也在kern/init.c中)。boot_aps()等待AP在其struct CpuInfo的cpu_status字段中发出CPU_STARTED标志，然后继续唤醒下一个AP。

### Exercise 2
>练习2
阅读kern/init.c中的boot_aps()和mp_main()，以及kern/mpentry.S中的汇编代码。确保你理解APs引导过程中的控制流转移。然后修改kern/pmap.c中对page_init()的实现，从而避免将MPENTRY_PADDR中的页添加到未使用内存列表中，这样我们就可以安全地复制并在该物理地址上运行AP引导代码。你的代码应该能通过更新后的check_page_free_list()测试(但更新后的check_kern_pgdir()测试可能会失败，我们很快就会修复这个问题)。

```c
//函数做出如下修改即可
// LAB 4: code
extern unsigned char mpentry_start[], mpentry_end[];//见于kern/init.c 中boot_aps() 对这两个函数的声明，   记住extern声明的作用！！！
size_t size = mpentry_end - mpentry_start;
size = ROUNDUP(size, PGSIZE);

for (size_t i = 0; i < npages; i++) {
    if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)/* 3,4条*/ ||  (i>=MPENTRY_PADDR/PGSIZE && i<(MPENTRY_PADDR+size)/PGSIZE) /*lab4*/){//不标记为free的页
        pages[i].pp_ref = 1;
    }else{//标记为free的页
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];	
    }
}
```

测试成功！


>问题：
1.将kern/mpentry.s和boot/boot.s并排比较。记住kern/mpentry.s被编译并链接到KERNBASE之上运行，就像内核中的其他所有东西一样。宏MPBOOTPHYS(见于kern/mpentry.s)的目的是什么?为什么它在kern/mpentry.s中是必要的，而在boot/boot.s中不是？换句话说，如果在kern/mpentry.S中省略了它，会发生什么问题?
提示:回想一下我们在实验1中讨论过的链接地址和加载地址之间的差异。

答：boot.S中，由于尚处于实模式（boot.s中才启用保护模式），所以我们能够指定程序开始执行的地方以及程序加载的地址(即加载地址)；但是，在mpentry.S的时候，由于当前CPU(即BSP)已经处于保护模式下了，因此是不能直接指定程序的物理地址的。所以通过这个宏我们通过当前地址s 计算出这段汇编代码所在的真实地址。
(见于mpentry.S注释：it uses MPBOOTPHYS to calculate absolute addresses of its symbols, rather than relying on the linker to fill them)

### Per-CPU状态及其初始化
在编写多处理器操作系统时，区分每个处理器私有的per-CPU状态和整个系统共享的全局状态是很重要的。kern/cpu.h定义了大多数Per-CPU状态，包括存储Per-CPU变量的struct CpuInfo。cpunum()总是返回调用它的CPU的ID，可以用作cpus等数组的索引。或者，宏thiscpu是当前CPU的struct CpuInfo的简写。

以下是你应该知道的per-CPU状态:
* Per-CPU内核栈。
  因为多个cpu可能同时进入内核，我们需要为每个处理器提供一个单独的内核栈，以防止它们干扰彼此的执行。数组percpu_kstacks[NCPU][KSTKSIZE]为内核栈的保留空间。
  引导堆栈将一部分物理内存称为BSP内核堆栈，在实验2中我们把这部分物理内存映射到KSTACKTOP下面。同样，在本实验中，您将把每个CPU的内核堆栈映射到这个区域，并使用保护页作为它们之间的缓冲区。CPU 0的堆栈仍然会从KSTACKTOP向下增长;CPU 1的堆栈将从CPU 0的堆栈底部以下的KSTKGAP字节开始，依此类推。inc/memlayout.h显示了映射布局。
* Per-CPU的TSS和TSS描述符.
  还需要一个per-CPU任务状态段(task state segment, TSS)，用于指定每个CPU的内核栈所在的位置。CPU i的TSS存储在cpus[i].cpu_ts中，对应的TSS描述符定义在GDT项gdt[(GD_TSS0 >> 3) + i]中。在kern/trap.c中定义的全局ts变量将不再有用。
* Per-CPU当前环境指针
  由于每个CPU可以同时运行不同的用户进程，我们重新定义了符号curenv，表示cpus[cpunum()].cpu_env(或thiscpu->cpu_env)，指向当前CPU(代码运行所在的CPU)上当前执行的环境。
* Per-CPU系统寄存器。
  所有寄存器(包括系统寄存器)都是CPU私有的。因此，初始化这些寄存器的指令，如lcr3()、ltr()、lgdt()、lidt()等，必须在每个CPU上执行一次。函数env_init_percpu()和trap_init_percpu()就是为此定义的。
  除此之外，如果您在解决方案中添加了任何额外的per-CPU状态或执行了任何额外的特定于CPU的初始化(例如，在CPU寄存器中设置新的位)以解决早期实验中的challenge问题，请务必在这里的每个CPU上复制它们!

### Exercise 3
修改mem_init_mp()(在kern/pmap.c中)以映射从KSTACKTOP开始的 per-CPU 栈，如inc/memlayout.h所示。每个栈的长度是KSTKSIZE字节加上未映射保护页的KSTKGAP字节。你的代码应该通过check_kern_pgdir()中的新检查。

```c
static void
mem_init_mp(void)
{
	// LAB 4: Your code here:
	for(size_t i = 0; i < NCPU; i++) {
		size_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, 
				kstacktop_i - KSTKSIZE, 
				KSTKSIZE,
				PADDR(&percpu_kstacks[i]), /* kern/cpu.h中定义 */
				PTE_W );
	}
```

测试成功！

### Exercise 4
>练习4
trap_init_percpu() (kern/trap.c)中的代码初始化BSP的TSS和TSS描述符。它在实验3中正常工作，但在其他cpu上运行时不正确。修改代码，使其可以在所有cpu上工作。(注意:您的新代码不应再使用全局ts变量。)
```c
void
trap_init_percpu(void)
{
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
```

完成上述练习后，使用`make qemu CPUS=4`(或`make qemu-nox CPUS=4`)在QEMU中运行JOS，你应该看到如下输出:
```
Physical memory: 66556K available, base = 640K, extended = 65532K
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 4 CPU(s)
enabled interrupts: 1 2
SMP: CPU 1 starting
SMP: CPU 2 starting
SMP: CPU 3 starting
```

测试成功！！！

### 锁
我们当前的代码在mp_main()中初始化AP后自旋。在让AP更进一步之前，我们需要首先解决多个cpu同时运行内核代码时的竞争情况。实现该目标的最简单方法是使用一个大的内核锁。大内核锁是一个全局锁，在环境进入内核态时持有，在环境返回用户态时释放。在该模型中，用户态环境可以在任何可用的cpu上并发运行，但内核态环境只能运行一个;任何其他试图进入核心态的环境都必须等待。

kern/spinlock.h声明了大内核锁，即kernel_lock。它还提供了lock_kernel()和unlock_kernel()，这是获取和释放锁的快捷方式。应该在4个位置应用大内核锁：
* 在i386_init()中，在BSP唤醒其他cpu之前获取锁。
* 在mp_main()中，在初始化AP后获得锁，然后调用sched_yield()在该AP上开始运行环境。
* 在trap()中，当从用户模式trap时获取锁。要确定trap是发生在用户态还是核心态，可以检查tf_cs的低位。
* 在env_run()中，在切换到用户模式之前释放锁。做这个不要太早或太晚，否则你会经历竞争或死锁。

### Exercise 5
>练习5
如上文所述，通过在适当的位置调用lock_kernel()和unlock_kernel()应用大内核锁。

```c
//init.c/i386_init()
// Acquire the big kernel lock before waking up APs
// Your code here:
lock_kernel();

//init.c/mp_main()
// Now that we have finished some basic setup, call sched_yield()
// to start running processes on this CPU.  But make sure that
// only one CPU can enter the scheduler at a time!
//
// Your code here:
lock_kernel();

//trap.c/trap()
if ((tf->tf_cs & 3) == 3) {
	// Trapped from user mode.
	// Acquire the big kernel lock before doing any
	// serious kernel work.
	// LAB 4: Your code here.
	lock_kernel();

//env.c/env_run()
//lab4:切换到用户模式之前释放锁
unlock_kernel();

// Step 2
env_pop_tf( &(curenv->env_tf) );
```

在下一个练习中实现调度器后，就能测试锁是否正确。

>问题
2.似乎使用大内核锁可以保证同一时间只有一个CPU可以运行内核代码。为什么我们仍然需要为每个CPU提供单独的内核栈?描述一个使用共享内核栈将出错的场景，即使有大内核锁的保护。

答：内核锁的获取是在陷入内核之后进行的，释放也是在返回用户态之前进行的。如果共享内核栈的话，在多个CPU同时陷入内核时，就会造成内核栈上保存的内容不一致。

网上另一个比较细致的回答：
因为在_alltraps到 trap()函数中调用lock_kernel()的过程中，进程已经切换到了内核态，但并没有上内核锁，此时如果有其他CPU进入内核，如果用同一个内核栈，则_alltraps中保存的上下文信息会被破坏，所以即使有大内核栈，CPU也不能用用同一个内核栈。同样的，解锁也是在内核态内解锁，在解锁到真正返回用户态这段过程中，也存在上述这种情况。

### 循环调度
本实验的下一个任务是更改JOS内核，以便它能够以“循环”方式在多个环境之间交替。JOS中的循环调度原理如下:
* 新kern/sched.c中的函数sched_yield()负责选择要运行的新环境。它以循环方式顺序搜索envs[]数组，从之前运行的环境之后开始(如果没有之前运行的环境，则从数组的开头开始)，选择它找到的第一个状态为 ENV_RUNNABLE 的环境(参见inc/env.h)，并调用env_run()以跳转到该环境。
* sched_yield()绝对不能在两个cpu上同时运行同一个环境。它可以判断当前环境正在某个CPU上运行(可能是当前CPU)，因为该环境的状态将是ENV_RUNNING。
* 我们为大家实现了一个新的系统调用sys_yield()，用户环境可以调用它来调用内核的sched_yield()函数，从而主动将CPU让与另一个环境。

### Exercise 6
>练习6
在sched_yield()中实现如上所述的轮询调度。别忘了修改syscall()，让它dispatch sys_yield()。
确保在mp_main中调用sched_yield()。
修改kern/init.c，创建三个(或者更多!)运行user/yield.c程序的环境。
运行` make qemu `命令。您应该看到环境在彼此之间来回切换五次，然后终止，如下所示。
也用几个cpu进行测试:`make qemu CPUS=2`。
在yield程序退出后，系统中将没有可运行环境，调度器应该调用JOS内核监视器。如果上述情况没有发生，请先修复代码再继续。


```c
//sched_yield() 
void
sched_yield(void)
{
	struct Env *idle;
	// LAB 4: Your code here.
	struct Env * now = curenv;

	int index=-1;//因为这里出错了！！一定是-1！！！
	//1.
	if(now/*定义于kern/env.h。可以看到其已经在lab4中被修改，适应多核*/) index= ENVX(now->env_id);//inc/env.h
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
	
	// sched_halt never returns
	sched_halt();
}

//syscall()
	case (SYS_yield)://别的最终调用lib/syscall()的函数都返回0,所以此处手动返回个0
		sys_yield();
		return 0;

//kern/init.c   mp_main()
	// Now that we have finished some basic setup, call sched_yield()
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();

//kern/init.c  i386_init()
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);

#else
	// Touch all you want.
	//ENV_CREATE(user_primes, ENV_TYPE_USER);

	//只是为了自己测试
	//调用user/yield.c 
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);

#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
```

测试效果与下面所示相同！ 测试成功！！！！
```
Hello, I am environment 00001000.
Hello, I am environment 00001001.
Hello, I am environment 00001002.
Back in environment 00001000, iteration 0.
Back in environment 00001001, iteration 0.
Back in environment 00001002, iteration 0.
Back in environment 00001000, iteration 1.
Back in environment 00001001, iteration 1.
Back in environment 00001002, iteration 1.
```

>问题3
在env_run()的实现中，你应该已经调用了lcr3()。在调用lcr3()之前和之后，代码都会引用变量e(至少应该这样)，它是env_run的参数。加载%cr3寄存器后，MMU使用的寻址上下文立即改变。但是，相对于给定的地址上下文，虚拟地址(即e)具有意义——地址上下文指定了虚拟地址映射到的物理地址。为什么在寻址开关前后都可以解引指针e？

答：因为当前是运行在系统内核中的，而每个进程的页表中都是存在内核映射的。lab3中我们使用env_setup_vm()为新环境分配页目录，并初始化了新环境地址空间的内核部分。从中我们得知，每个进程页表中虚拟地址高于UTOP之上的地方，只有UVPT不一样，其余的都是一样的。指针e指向的UENVS区域也是这部分，e自然也是相同的。

>问题4
每当内核从一个环境切换到另一个环境时，它必须确保保存旧环境的寄存器，以便稍后可以正常恢复。为什么?这发生在哪里？

答：lab3中我们知道我们将 struct TrapFrame压入栈中以保存环境寄存器。
保存过程发生在我们写的kern/trapentry.S。
恢复过程发生在kern/env.c env_pop_tf()。

### 用于创建环境的系统调用
尽管您的内核现在能够在多个用户级环境之间运行和切换，但仍然限于内核最初设置的运行环境。现在将实现必要的JOS系统调用，以允许用户环境创建和启动其他新用户环境。

Unix提供了fork()系统调用作为创建进程的原语。Unix fork()复制调用进程(父进程)的整个地址空间，以创建一个新进程(子进程)。从用户空间观察到的唯一区别是它们的进程id和父进程id(由getpid和getppid返回)。在父进程中，fork()返回子进程的进程ID，而在子进程中，fork()返回0。默认情况下，每个进程都有自己的私有地址空间，两个进程对内存的修改对另一个进程都不可见。

您将提供一组不同的、更原始的JOS系统调用，用于创建新的用户模式环境。通过这些系统调用，您将能够完全在用户空间中实现类unix的fork()，以及其他创建环境的风格。为JOS编写的新系统调用如下：
* sys_exofork: 该系统调用创建了一个几乎是空白的新环境:没有任何东西映射到其地址空间的用户部分，环境是不可运行的。在sys_exofork调用时，新环境将具有与父环境相同的寄存器状态。在父进程中，sys_exofork将返回新创建环境的envid_t(如果环境分配失败，则返回负的错误码)。然而，在子进程中，它将返回0。(由于子进程一开始被标记为不可运行，**sys_exofork实际上不会在子进程中返回，直到父进程通过使用...标记子进程可运行来明确允许。**）
* sys_env_set_status: 将指定环境的状态设置为ENV_RUNNABLE或ENV_NOT_RUNNABLE。该系统调用通常用于标记一个新环境，在其地址空间和寄存器状态完全初始化之后，该环境就可以运行了。
* sys_page_alloc: 分配一页物理内存，并将其映射到给定环境的地址空间中的给定虚拟地址。
* sys_page_map: 将页映射(而不是页的内容)从一个环境的地址空间复制到另一个环境的地址空间，保持内存共享，使得新映射和旧映射都指向物理内存的同一页。
* sys_page_unmap: 解除映射到给定环境中给定虚拟地址的页。
  
对于上述所有接受环境IDs的系统调用，JOS内核支持这样一种约定，即值0表示“当前环境”。kern/env.c中的envid2env()实现了这个约定。

我们在测试程序user/dumbfork.c中提供了类unix的fork()的非常原始的实现。这个测试程序使用上述系统调用创建并运行一个子环境，该子环境具有自己的地址空间的副本。这两个环境接下来使用sys_yield来回切换，如前一个练习所示。父进程在迭代10次后退出，而子进程在迭代20次后退出。

### Exercise 7
在kern/syscall.c中实现上述系统调用，并确保syscall()调用它们。你需要使用kern/pmap.c和kern/env.c中的各种函数，特别是envid2env()。现在，每当调用envid2env()时，都将checkperm参数传入1。请确保检查了所有无效的系统调用参数，在这种情况下返回-E_INVAL。使用user/dumbfork测试你的JOS内核，确保它能正常工作。

```c
//sys_exofork
static envid_t
sys_exofork(void)
{
	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");
	struct Env *e=NULL;

	int error_ret=env_alloc( &e , curenv->env_id);
	if(error_ret<0 ) return error_ret;
	
	e->env_status = ENV_NOT_RUNNABLE;
	e->env_tf = curenv->env_tf;
	// 子进程（环境）的返回值为0（在lib/syscall.c中，我们已经知道 其返回值位于%eax中）
	e->env_tf.tf_regs.reg_eax = 0;
	
	return e->env_id;
}

//sys_env_set_status
static int
sys_env_set_status(envid_t envid, int status)
{
	// LAB 4: Your code here.
	//panic("sys_env_set_status not implemented");
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;  
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
	e->env_status = status;
	return 0;	
}

//sys_page_alloc
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// LAB 4: Your code here.  先别考虑这么多异常值，先写主体！！
	//panic("sys_page_alloc not implemented");
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
	if ( (perm | PTE_SYSCALL) != PTE_SYSCALL  ) return -E_INVAL;
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 

	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if( pp==NULL ) return -E_NO_MEM;

	struct Env *e;
	int error_ret=envid2env(envid, &e, 1);
	if( error_ret <0 ) return error_ret;//error_ret 其实就是我们调用函数发生错误时的返回值， 这不同函数之间都是一致的。

	error_ret=page_insert(e->env_pgdir, pp, va, perm);
	if(error_ret <0){
		page_free(pp);
		return error_ret;
	}

	return 0;		
}

//sys_page_map
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// LAB 4: Your code here.
	//panic("sys_page_map not implemented");
	//4.
	if ( (perm & (PTE_U|PTE_P))  !=  (PTE_U|PTE_P)  ) return -E_INVAL;
	if ( (perm | PTE_SYSCALL) != PTE_SYSCALL  ) return -E_INVAL;
	//2.
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;

	struct Env *src_e, *dst_e;
	//1.
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;

	pte_t *src_pte;  
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_pte);
	//3.
	if( pp==NULL ) return -E_INVAL;
	//5.
	if ( ( ( *src_pte & PTE_W ) == 0 ) && ( (perm & PTE_W) == PTE_W ) ) return -E_INVAL;
	//6.
	int error_ret =page_insert(dst_e->env_pgdir, pp, dstva, perm);
	if( error_ret < 0  ) return error_ret;

	return 0;
}

//sys_page_unmap
static int
sys_page_unmap(envid_t envid, void *va)
{
	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");
	if ((uintptr_t) va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 

	struct Env *e ;
	int error_ret=envid2env(envid, &e, 1);
	if( error_ret <0 ) return error_ret;

	page_remove(e->env_pgdir, va);

	return 0;
}

//syscall
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1,a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1,(void *)a2, (int)a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
//i386_init()  无所谓，只是为了自己测试
#else
	// Touch all you want.
	//ENV_CREATE(user_primes, ENV_TYPE_USER);
	//只是为了自己测试
	//调用user/yield.c 为什么要用user_yield这个符号名，不太懂
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
```
很奇怪，我使用`make qemu` 出现了练习7中要求的效果，但`make grade`不通过，改改！！！！
（是之前Exercise 6 sched_yield()函数出了错，以后每一步一定要仔细检查！！！）

这就完成了实验的A部分;运行`make grade`时，请确保它通过了所有A部分的测试。如果您试图弄清楚为什么特定的测试用例失败，请运行`./grade-lab4 -v`，它将向您显示内核构建的输出，并为每个测试运行QEMU，直到测试失败。当测试失败时，脚本将停止，然后您可以检查jos.out去看看内核实际上打印了什么。

OK 测试通过！！！


## Part B: Copy-on-Write Fork
如前所述，Unix提供fork()系统调用作为其主要的进程创建原语。fork()系统调用复制调用进程(父进程)的地址空间以创建一个新进程(子进程)。 

xv6 Unix实现fork()的方法是将父节点页面中的所有数据复制到分配给子节点的新页面中。这本质上与dumbfork()采用的方法相同。将父进程的地址空间复制到子进程中是fork()操作中开销最大的部分。

然而，在调用fork()之后，经常会立即在子进程中调用exec()，用新程序替换子进程的内存。例如，这就是shell通常做的事情。在这种情况下，花在复制父进程地址空间上的时间基本上被浪费了，因为子进程在调用exec()之前只会使用很少的内存。

因此，较晚版本的Unix利用虚拟内存硬件，允许父进程和子进程共享映射到各自地址空间中的内存，直到其中一个进程实际修改为止。这种技术称为写时复制(copy-on-write)。为此，在fork()上，内核将地址空间映射从父进程复制到子进程，而不是映射页的内容，同时将现在共享的页标记为只读。当两个进程中的一个试图写入这些共享页时，该进程将发生页错误(page fault)。在这一点上，Unix内核意识到该页实际上是一个“虚拟”或“写时复制”副本，因此它为出错的进程创建了一个新的、私有的、可写的该页副本。这样，在实际写入各个页之前，各个页的内容实际上不会被复制。这种优化使得子进程中fork()和exec()的代价要小得多:子进程在调用exec()之前可能只需要复制一页(栈的当前页)。

在本实验的下一部分中，你将实现一个“正确的”类unix的fork()，它具有写时复制功能，就像一个用户空间库例程。在用户空间实现fork()和写时复制支持的好处是，内核仍然简单得多，因而更可能是正确的。它还允许各个用户态程序为fork()定义自己的语义。如果一个程序想要稍微不同的实现(例如，像dumbfork()这样代价昂贵的总是复制(always-copy)版本，或者父进程和子进程之后共享内存)，可以很容易地提供它自己的实现。

### 用户级页面故障处理
用户级写时复制fork()需要知道写保护页上的页错误，因此我们首先要实现它。写时复制只是用户级页错误处理的众多可能用途之一。

通常需要设置一个地址空间，以便在需要执行某些操作时指定页错误。例如，大多数Unix内核最初只映射新进程栈区域中的一个页，之后随着进程栈消耗的增加，“按需”分配和映射额外的栈页，并在尚未映射的栈地址上导致页错误。典型的Unix内核必须跟踪在进程空间的每个区域发生页错误时应采取的行动。例如，栈区域中的错误通常会分配和映射物理内存的新页。程序BSS区域（用于存放程序中未初始化的全局变量、静态变量）的错误通常会分配一个新页，用0填充它，然后映射它。在具有按需分页可执行程序的系统中，文本区域中的一个错误将从磁盘读取二进制文件的相应页，然后映射它。

这是内核需要跟踪的大量信息。您将决定如何处理用户空间中的每个页错误，而不是采用传统的Unix方法，在用户空间中，bug的破坏性较小。这种设计还有一个额外的好处，即允许程序在定义内存区域时具有极大的灵活性。稍后，您将使用用户级页错误处理来映射和访问基于磁盘的文件系统上的文件。

### 设置页错误处理程序
为了处理自己的页错误，用户环境需要向JOS内核注册一个页错误处理程序入口点。用户环境通过新的sys_env_set_pgfault_upcall系统调用注册其页错误入口点。我们已经向Env结构(inc/env.h)添加了一个新成员，env_pgfault_upcall，以记录此信息。

### Exercise 8
>练习8
实现sys_env_set_pgfault_upcall系统调用。在查找目标环境的环境ID时，请确保启用权限检查，因为这是一个“危险”的系统调用。

```c
//sys_env_set_pgfault_upcall
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *e;
	int error_ret= envid2env(envid, &e, 1);
	if(error_ret < 0 ) return error_ret;

	e->env_pgfault_upcall = func;
	return 0;
}

//syscall() 别忘了这个！！！ 以前练习都提示把这块补上， 这个练习没有提示，别忘了！！！！
	case (SYS_env_set_pgfault_upcall):
		return sys_env_set_pgfault_upcall(a1, (void*) a2);
```

### 用户环境中的正常和异常堆栈
在正常执行期间，JOS中的用户环境将运行在普通用户栈上:它的ESP寄存器开始指向USTACKTOP，它压入的栈数据位于USTACKTOP- pgsize和USTACKTOP-1(包括USTACKTOP-1)之间的页面。但在用户态发生页错误时，内核将在不同的栈(即用户异常栈)上运行指定的用户级页错误处理程序，重启用户环境。本质上，我们将让JOS内核代表用户环境实现自动“堆栈切换”，其方式与x86处理器在从用户态转换到核心态时代表JOS实现堆栈切换的方式非常相似!

JOS用户异常栈的大小也是一页，其顶部被定义为虚拟地址UXSTACKTOP，因此用户异常栈的有效字节是从UXSTACKTOP- pgsize到UXSTACKTOP-1(包括UXSTACKTOP-1)。在此异常堆栈上运行时，用户级页错误处理程序可以使用JOS的常规系统调用来映射新页或调整映射，以便修复最初导致页错误的任何问题。然后，用户级的页错误处理程序通过汇编语言存根返回到原始堆栈上的错误代码。

每个希望支持用户级页异常处理的用户环境都需要使用A部分引入的sys_page_alloc()系统调用为自己的异常栈分配内存。

### 调用用户页错误处理程序
现在需要修改kern/trap.c中的页错误处理代码，以便在用户状态下处理页错误，如下所示。我们将发生故障时的用户环境状态称为trap-time state。

如果没有注册页错误处理程序，JOS内核会像以前一样用一条消息销毁用户环境。否则，内核在异常栈上建立一个trap frame，看起来像inc/trap.h中的struct UTrapframe（不截图了，看文档中的图吧）:

内核接下来安排用户环境使用该栈帧(stack frame)恢复异常栈上运行的页错误处理程序的执行。你必须想办法让这一切发生。fault_va是导致页错误的虚拟地址。

如果在发生异常时，用户环境已经在用户异常堆栈上运行，那么页错误处理程序本身就发生了异常。在这种情况下，您应该在当前tf->tf_esp下启动新的堆栈帧，而不是在UXSTACKTOP上。你应该首先推送一个32位的空字（原因代码注释中有讲），然后是一个struct UTrapframe。

要测试tf -> tf_esp是否已经在用户异常堆栈上，请检查它是否在UXSTACKTOP-PGSIZE和UXSTACKTOP-1之间(包括UXSTACKTOP-1)。

### Exercise 9
>练习9
在kern/trap.c中实现page_fault_handler中的代码，用于将页错误分派给用户态处理程序。在写入异常栈时，请确保采取适当的预防措施。(如果用户环境耗尽异常栈上的空间会发生什么?)

答：
在 inc/memlayout.h 中可以看到 UXSTACKTOP 页的下一页是空白的，所以访问就会报错。

```c
//page_fault_handler

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

```

### 用户模式页面故障入口点
接下来，您需要实现汇编例程，该例程将负责调用C页异常处理程序，并在原始异常指令处恢复执行。该汇编例程是使用sys_env_set_pgfault_upcall()注册到内核的处理程序。

### Exercise 10
>练习10
在lib/pfentry.S中实现_pgfault_upcall例程。有趣的是返回到导致页错误的用户代码的原点。您将直接返回到那里，而无需返回到内核。困难的部分是同时切换栈和重新加载EIP。
```c
//_pgfault_upcall

	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
	subl $4, %eax 
	movl %eax, 48(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
	movl %edx, (%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
	popfl//弹出utf_eflags

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
```
最后，需要实现用户级缺页处理机制的C用户库端。

### Exercise 11
>练习11
在lib/pgfault.c中完成set_pgfault_handler()。

```c
//set_pgfault_handler()
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
		if (r < 0) {
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
		}

		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
		if (r < 0) {
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
```

此处要区分清楚：  _pgfault_handler和_pgfault_upcall。 _pgfault_upcall是入口点，它调用_pgfault_handler，处理完成后，它再通过汇编还原回用户进程发生异常的状态。

最后总结一下：
三个练习的调用顺序为：11（设置handler）->9（切换到异常栈）->10（运行handler，切换回正常栈）
用户级别的页错误处理的步骤是：
进程A(正常栈) -> 内核 -> 进程A(异常栈) -> 进程A(正常栈)

### 测试
运行user/faultread (`make run-faultread`) 测试成功（ip会不同）。
运行user/faultdie 失败 运行结果同faultread
运行user/faultalloc 失败 运行结果同faultread
运行user/faultallocbad 运行成功。

然后开始查找错误：
可以找到`user fault va 00000000 ip 0080003a` 是trap.c中的page_fault_handler()中 curenv->env_pgfault_upcall 为空的输出。也就是说我们的程序并没有成功设置curenv->env_pgfault_upcall。

最后发现是忘记在syscall()中加入 `case`代码了。（之前笔记已经补上了）


>问题
请务必理解为什么user/faultalloc和user/faultallocbad表现不同。

答：两者的 page fault handler 一样，但是一个使用 cprintf() 输出，另一个使用 sys_cput() 输出。sys_cput()检查了内存，直接panic()，因此不触发页错误。而 cprintf()在调用 sys_cputs() 之前，首先在用户态执行了 vprintfmt() 将要输出的字符串存入结构体 b 中。在此过程中试图访问 0xdeadbeef 地址，触发并处理了页错误。

测试成功！！！

### 实现Copy-on-Write Fork
大家现在已经有了完全在用户空间中实现写时复制fork()的内核设施。

我们已经在lib/fork.c中提供了fork()的框架。与dumbfork()类似，fork()应该创建一个新环境，然后遍历父环境的整个地址空间，并在子环境中建立相应的页映射。关键的区别在于，dumbfork()复制页面，而fork()最初只复制页面映射。fork()只会在其中一个环境试图写入每个页面时复制它。

fork()的基本控制流程如下:
* 1.父进程使用之前实现的set_pgfault_handler()函数，将pgfault()安装为c级别的页面错误处理程序。
* 2.父进程调用sys_exofork()创建子环境。
* 3.对于位于UTOP下的地址空间中的每个可写页或写时复制页，父进程都会调用	duppage，该函数会将页的写时复制映射到子进程的地址空间中，然后在自己的地址空间中重新映射页的写时复制。【注意:这里的排序(即先在子页面中标记为COW，再在父页面中标记)实际上很重要!你知道为什么吗?试着想一个具体的例子，如果颠倒顺序可能会引起麻烦。 **我的理解是用户栈会出现问题。先标父进程的话，在你给r赋值的时候就会修改用户栈上的值（见duppage，注意系统调用不使用用户栈，反而是修改r这个局部变量时会用栈），那么此时父进程触发用户异常，另开一个物理页开始写，然后你再复制子进程的映射时就不是原来的栈了，栈换了不要紧，但是之后父进程还要继续执行fork，还要写这个栈，这个时候父进程就会修改这个栈还不用另开内存，因为此时已经触发完异常了，栈页已经是可写的了，而不是cow的了，这就污染了子进程的栈**】 duppage设置了两个pte（父子），使得该页不可写，并将PTE_COW包含在"avail"字段中，以区分写时复制的页和真正的只读页。
**不过，异常栈不会以这种方式重新映射。相反，您需要在子进程中为异常栈分配一个新页。由于页错误处理程序将执行实际的复制，而页错误处理程序运行在异常栈上，因此不能在写时复制异常栈:谁会复制它呢?**
  fork()也需要处理存在但不可写或写时复制的页面。
* 4.父进程设置user page fault entrypoint，使子进程看起来像自己的。
* 5.子进程现在可以运行了，因此父进程将其标记为runnable。
  
每当某个环境写入尚未写入的写时复制页时，就会发生缺页异常。以下是用户页面异常处理程序的控制流:
* 1.内核将缺页异常传播到_pgfault_upcall，后者调用fork()的pgfault() handler。
* 2.pgfault()检查异常是否是写异常(检查错误码中的FEC_WR)，并且该页的PTE标记是否为PTE_COW。如果不是，那就panic。
* 3.pgfault()分配一个映射在临时位置的新页，并将发生故障的页的内容复制到临时位置。然后，错误处理程序将新页映射到具有读/写权限的适当地址，而不是旧的只读映射。
  
用户级的lib/fork.c代码在执行上述几个操作时，必须查阅环境的页表(例如，某一页的PTE为PTE_COW)。内核将环境的页表映射到UVPT正是为此目的。它使用了一个[巧妙的映射技巧](https://pdos.csail.mit.edu/6.828/2018/labs/lab4/uvpt.html) （这个trick我回去重复看才看懂，trick中为页目录项赋值的语句位于 pmap.c中的mem_init()中`kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;`），使用户代码查找PTE变得容易。lib/entry.s设置了uvpt和uvpd，使您可以轻松查找lib/fork.c中的页表信息。

### Exercise 12
>练习12
在lib/fork.c中实现fork、duppage和pgfault。
用forktree程序测试代码。它应该产生以下消息，其中穿插着 'new env'， 'free env' 和 'exit graceful' 消息。消息可能不是按此顺序出现的，而且环境id可能不同。

```c
//fork()
envid_t
fork(void)
{
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
		    // dup page to child
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
		}
	}
	//分配异常栈
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
	if(r<0) return r;

	//4.
	// Assembly language pgfault entrypoint defined in lib/pfentry.S.
	extern void _pgfault_upcall(void);
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if(r<0) return r;

	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;

	return envid;
}

//duppage()
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
	envid_t this_envid = sys_getenvid();//父进程号
	void * va = (void *)(pn * PGSIZE);

	int perm = uvpt[pn] & 0xFFF;
	if ( (perm & PTE_W) || (perm & PTE_COW) ){
		perm |= PTE_COW;
		perm &= ~PTE_W;
	}
	perm&=PTE_SYSCALL; // 写sys_page_map函数时 perm必须要达成的要求

	r=sys_page_map(this_envid, va, envid, va, perm);
	if(r<0) return r;

	r=sys_page_map(this_envid, va, this_envid, va, perm);//一定要用系统调用， 因为权限！！
	if(r<0) return r;

	return 0;
}

//pgfault()
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
        if(r<0) panic("pgfault: page allocation failed %e", r);

        addr = ROUNDDOWN(addr, PGSIZE);
        memmove(PFTEMP, addr, PGSIZE);
	if ((r = sys_page_unmap(envid, addr)) < 0)
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
		panic("pgfault: page unmap failed (%e)", r);
}

```

Part B到此结束。运行`make grade`，请确保通过了所有Part B测试。

通过测试！！！

## Part C: Preemptive Multitasking and Inter-Process communication (IPC) 
在实验4的最后一部分，您将修改内核以抢占不合作的环境，并允许环境之间显式传递消息。

### 时钟中断和抢占
运行user/spin测试程序。这个测试程序分支出一个子环境，一旦它接收到CPU的控制，它就永远在一个紧密的循环中旋转。父环境和内核都不会重新获得该CPU。就保护系统不受用户态环境中的bug或恶意代码的影响而言，这显然不是理想的情况，因为任何用户态环境都可能导致整个系统停止，只要进入无限循环，而CPU就永远不会被占用。为了允许内核抢占运行环境，强制重新获得对CPU的控制，我们必须扩展JOS内核以支持来自时钟硬件的外部硬件中断。

### 中断规则
**外部中断(即设备中断)称为IRQ。有16个可能的IRQ，编号从0到15。IRQ编号到IDT项的映射不是固定的。picirq.c中的pic_init将IRQ 0 ~ 15映射到IDT项IRQ_OFFSET到IRQ_OFFSET+15。**

在inc/trap.h中，IRQ_OFFSET定义为十进制32。因而IDT项32-47对应于IRQs 0-15。例如，时钟中断是IRQ 0。因而，IDT[IRQ_OFFSET+0]（即IDT[32]）包含了内核中时钟中断处理程序例程的地址。选择该IRQ_OFFSET是为了使设备中断不与处理器异常重叠，这显然可能导致混淆。(事实上，在运行MS-DOS的pc的早期，IRQ_OFFSET实际上是0，这确实在处理硬件中断和处理处理器异常之间造成了巨大的混乱!)

**在JOS中，与xv6 Unix相比，我们做了一个关键简化。外部设备中断在内核中总是禁用的(与xv6类似，在用户空间启用)**。外部中断由%eflags寄存器的FL_IF标志位控制(参见inc/mmu.h)。在设置该比特位时，将启用外部中断。虽然位可以通过几种方式进行修改，但由于我们的简化，我们将只通过在进入和离开用户模式时保存和恢复%eflags寄存器的过程来处理它。

你必须确保运行时在用户环境中设置FL_IF标志位，以便在中断到达时，它被传递到处理器并由中断代码处理。否则，中断将被屏蔽或忽略，直至重新启用中断。我们用引导加载程序的第一个指令屏蔽了中断(也就是lab1中我们看到的`cli`)，到目前为止，我们还没有重新启用它们。

### Exercise 13
>练习13
修改kern/trapentry.S和kern/trap.c来初始化IDT中适当的项，并为IRQ 0到15提供处理程序。然后修改kern/env.c中env_alloc()中的代码，以确保用户环境总是在启用中断的情况下运行。
还要取消sched_halt()中sti指令的注释，以便空闲cpu解除中断掩码。
在调用硬件中断处理程序时，处理器从不推送错误代码。此时，读者可能需要重读[80386参考手册](https://pdos.csail.mit.edu/6.828/2018/readings/i386/toc.htm)的9.2节。
完成这个练习后，如果你用任何运行一定时间长度(例如spin)的测试程序运行内核，你应该会看到内核打印硬件中断的陷阱帧(trap frames)。虽然中断现在在处理器中启用了，但JOS还没有处理它们，因此您应该看到它将每个中断错误地归为当前运行的用户环境并销毁它。最终，它应该耗尽可以销毁的环境并进入monitor。

```c
//kern/trapentry.S
//lab4 exercise 13
//IRQS 
TRAPHANDLER_NOEC(timer_handler, IRQ_OFFSET + IRQ_TIMER);
TRAPHANDLER_NOEC(kbd_handler, IRQ_OFFSET + IRQ_KBD);
TRAPHANDLER_NOEC(serial_handler, IRQ_OFFSET + IRQ_SERIAL);
TRAPHANDLER_NOEC(spurious_handler, IRQ_OFFSET + IRQ_SPURIOUS);
TRAPHANDLER_NOEC(ide_handler, IRQ_OFFSET + IRQ_IDE);
TRAPHANDLER_NOEC(error_handler, IRQ_OFFSET + IRQ_ERROR);

//kern/trap.c
void timer_handler();
void kbd_handler();
void serial_handler();
void spurious_handler();
void ide_handler();
void error_handler();

SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],    0, GD_KT, timer_handler,   0);//中断是让内核抢占控制权，所以dpl应该设置为0。
SETGATE(idt[IRQ_OFFSET + IRQ_KBD],      0, GD_KT, kbd_handler,     0);
SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],   0, GD_KT, serial_handler,  0);
SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, spurious_handler,0);
SETGATE(idt[IRQ_OFFSET + IRQ_IDE],      0, GD_KT, ide_handler,     0);
SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],    0, GD_KT, error_handler,   0);

//kern/env.c env_alloc()
// Enable interrupts while in user mode.
// LAB 4: Your code here.
e->env_tf.tf_eflags |= FL_IF;

//sched.c sched_halt()
// Uncomment the following line after completing exercise 13
"sti\n"
```

### 处理时钟中断
在user/spin程序中，在子环境第一次运行之后，它只是在循环中旋转，内核再也没有获得控制权。我们需要对硬件进行编程，以周期性地产生时钟中断，这将迫使控制权回到内核，在内核中，我们可以将控制权切换到不同的用户环境。

对lapic_init和pic_init的调用(来自init.c中的i386_init)设置了时钟和用于产生中断的中断控制器。现在需要编写代码来处理这些中断。

### Exercise 14
>练习14
修改内核的trap_dispatch()函数，使其在时钟中断发生时调用sched_yield()来查找并运行一个不同的环境。
现在应该能够让user/spin测试工作了:父环境应该fork子环境，sys_yield()多次，但每次都在一个时间片之后重新获得对CPU的控制，最后终止子环境并terminate gracefully。

```
//trap_dispatch() 
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	case (IRQ_OFFSET + IRQ_TIMER):
		lapic_eoi();
		sched_yield();
		break;
```

> 注意！！！！！！
另外在此实验中，我看到[其他人的博客](https://www.jianshu.com/p/8d8425e45c49)中发现了对SETGATE()宏中istrap参数的争议。 
查阅过后发现：应该是将系统调用设置为1,因为它应该允许其他中断干扰它。而其他均设置为0，因为这些异常以及中断不应该再被干扰。
但是！！！！！！！上文加粗部分提到：JOS对此做了简化，所以。。。。都应该设置为0。

这是做回归测试的好时机。确保你没有通过启用中断来破坏实验之前正常工作的任何部分(例如forktree)。此外，请尝试使用`make CPUS =2 target`运行多个cpu。你现在也应该能够通过`stresssched`了。运行`make grade`。你现在应该得到这个实验的65/80分。

测试成功！！

### 进程间通信(IPC)
(从技术上讲，在JOS中这是“环境间通信(inter-environment communication)”或“IEC”，但其他人都称它为IPC，所以我们将使用标准术语。)

我们一直在关注操作系统的隔离方面，它提供了每个程序都有一台属于自己的机器的错觉。操作系统的另一项重要服务是允许程序在需要时相互通信。它可以非常强大地让程序与其他程序交互。Unix管道模型就是典型的例子。

进程间通信有许多模型。即使在今天，关于哪种模型是最好的仍然存在争论。我们就不讨论这个了。相反，我们将实现一个简单的IPC机制，然后尝试它。

### JOS中的IPC
我们将实现几个额外的JOS内核系统调用，它们共同提供了一个简单的进程间通信机制。需要实现两个系统调用，sys_ipc_recv和sys_ipc_try_send。然后你将实现两个库包装器ipc_recv和ipc_send。

用户环境可以使用JOS的IPC机制相互发送的“消息”由两个部分组成:单个32位值和可选的单个页映射。允许环境以消息的形式传递页映射，这提供了一种高效的方式来传输比单个32位整数所能容纳的更多的数据，还允许环境轻松地建立共享内存。

### 发送和接收消息
为接收消息，环境调用sys_ipc_recv。该系统调用取消当前环境的调度，直到收到消息后才再次运行。当一个环境等待接收消息时，任何其他环境都可以向它发送消息——不仅仅是特定的环境，也不仅仅是与接收环境有父/子关系的环境。换句话说，你在A部分实现的权限检查不适用于IPC，因为IPC系统调用经过了精心设计，是“安全的”:一个环境不会仅仅通过向它发送消息就导致另一个环境故障(除非目标环境也有bug)。

为了尝试发送一个值，环境调用sys_ipc_try_send，传入接收方的环境id和要发送的值。如果指定的环境实际上正在接收(它已经调用了sys_ipc_recv，但还没有得到值)，则发送端发送消息并返回0。否则，发送端返回-E_IPC_NOT_RECV，表示目标环境当前不期望接收值。

用户空间中的库函数ipc_recv负责调用sys_ipc_recv，然后在当前环境的struct Env中查找接收到的值的信息。

类似地，库函数ipc_send将负责重复调用sys_ipc_try_send，直到发送成功。

### 转移页面
在环境用有效的dstva参数(在UTOP下面)调用sys_ipc_recv时，环境表示它愿意接收页映射。如果发送方发送了一页，那么该页应该映射到接收方地址空间的dstva。如果接收方已经在dstva映射了一页，则unmap前一页。

当一个环境用一个有效的srcva(在UTOP下面)调用sys_ipc_try_send时，这意味着发送方想要将当前映射在srcva的页发送给接收方，并具有perm权限。在一个成功的IPC之后，发送方在其地址空间中保留其对srcva页的原始映射，但接收方也在接收方的地址空间中获得了接收方最初指定的dstva中相同物理页的映射。因此，该页面在发送方和接收方之间共享。

如果发送方或接收方没有指示要传输页，则不传输页。在任何IPC之后，内核将接收方的Env结构体中的新字段env_ipc_perm设置为接收到的页的权限，如果没有接收到页，则设置为0。

### 实现IPC

### Exercise 15
>练习15
在kern/syscall.c中实现sys_ipc_recv和sys_ipc_try_send。在实现它们之前，请阅读关于它们的注释，因为它们必须一起工作。当您在这些例程中调用envid2env时，您应该将checkperm标志设置为0，这意味着允许任何环境向任何其他环境发送IPC消息，内核除了验证目标envid是否有效之外，不会进行特殊的权限检查。
然后实现lib/ipc.c中的ipc_recv和ipc_send函数。
使用user/pingpong和user/primes函数测试你的IPC机制。user/primes将为每个质数生成一个新环境，直到JOS用完所有环境。你可能会对user/primes.c的内容感兴趣，因为它可以看到所有在幕后发生的forking和IPC。

```c
//sys_ipc_recv
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_recv not implemented");
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;
	
	curenv->env_ipc_recving = true;
	curenv->env_ipc_dstva = dstva;
	curenv->env_status = ENV_NOT_RUNNABLE;
	//别忘了这步
	curenv->env_ipc_from = 0;
	sched_yield();
	
	return 0;
}

//sys_ipc_try_send
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");

	int r;
	struct Env *dstenv;
	if ( (r = envid2env( envid, &dstenv, 0)) < 0)  return r;

	// 不处于等待接收状态， 或有进程已经请求发送数据
	if ( (dstenv->env_ipc_recving != true)  || dstenv->env_ipc_from != 0)  return -E_IPC_NOT_RECV;

	dstenv->env_ipc_perm=0;//如果没转移页，设置为0
	//也发送一个页。
	if((uintptr_t) srcva <  UTOP){
		if ( PGOFF(srcva) )  return -E_INVAL;
		if (  !(perm & PTE_P ) || !(perm & PTE_U) )  return -E_INVAL;
		if (perm &  (~ PTE_SYSCALL))   return -E_INVAL; 

		//
		pte_t *pte;
		struct PageInfo *pp;
		if ((pp = page_lookup(curenv->env_pgdir, srcva, &pte)) == NULL )  return -E_INVAL;

		if ((perm & PTE_W) && !(*pte & PTE_W) )   return -E_INVAL;

		// 接收进程愿意接收一个页
		if (dstenv->env_ipc_dstva) {
			// 开始映射
			if( (r = page_insert(dstenv->env_pgdir, pp, dstenv->env_ipc_dstva,  perm) ) < 0)  return r;
			dstenv->env_ipc_perm = perm;
		}
	}

	dstenv->env_ipc_recving = false;
	dstenv->env_ipc_from = curenv->env_id;
	dstenv->env_ipc_value = value;
	dstenv->env_status = ENV_RUNNABLE;
	// 返回值
	dstenv->env_tf.tf_regs.reg_eax = 0;
	return 0;

}

//syscall 
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
//ipc_recv
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
	int r=sys_ipc_recv(pg);

	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);

	if(r<0) return r;

	return thisenv->env_ipc_value;
}

//ipc_send
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;

	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
	}while (r<0);

}

```
通过测试！！！

Part C结束。确保你通过了所有的`make grade`测试。
在提交之前，使用`git status`和`git diff`检查您的更改。使用` git commit -am 'my solutions to lab 4' `提交你的更改。

