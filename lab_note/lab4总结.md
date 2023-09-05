# lab4总结
fork()这块属实挺复杂的，我现在看都得看一天才能把这个总结写出来。

## 过程总结
* 首先要扩展JOS以在多处理器系统上运行，所以我们写了前几个exercise，即mmio，应用程序处理器的启动引导（像APIC,和每个CPU都需要我们前几个lab所写的独立的变量，寄存器值 ，这部分需要我们写的也不是很多，读读源代码就好）
* 然后我们运行起多CPU的系统后，我们就需要锁了。项目中部署的大内核锁应该是一种最简单的处理方式（还可以对各种对象加锁，也就是我们在应用层写代码调的mutex一样），即一个时刻只有一个CPU在运行内核程序，这样自然就不会有竞争现象。JOS中自旋锁的实现我也在下面放了出来。部署锁的位置也很好理解，一是初始化时在启动aps时获取锁，二是在内核与用户态转换时获取释放锁。
**此处一个我感觉一个容易混淆的点：即内核程序从始至终只作为启动程序和运行起用户进程后的处理程序。内核程序根本不算一个进程，因为每次我们陷入内核后，把要做得的事情做完，即执行完处理程序后，我们直接就开始运行用户进程，根本没有保存上下文，也没有PCB结构。起初我以为是JOS为了简单没有写这种类似内核进程的概念。但现在我查了一下，其实Linux也是像JOS如此，根本不需要保存内核程序的上下文。**
* 然后就是调度：exercise要求我们写的调度还是比较容易的，我后面自己又写了一个MFQ，大伙也可以去看看。
* 实现fork()前要先写几个进程相关的系统调用：创建进程，为进程分配页表，内存映射等等。用户级错误处理程序会调用这几个系统调用。
  fork()父进程返回子进程id，子进程返回0的实现来自sys_exofork()。原理为：父进程正常系统调用返回之前，将创建的子进程PCB的eax置为0(我们在syscall中知道eax保存着系统调用函数的返回值)。这样在父进程将子进程状态设置为RUNNABLE后，子进程通过上下文返回后，就会返回0了。

#### fork() 
这块挺绕的，我就单独开个标题写了。

写时复制fork()：在fork()上，内核将地址空间映射从父进程复制到子进程，而不是映射页的内容，同时将现在共享的页标记为只读。

此处的用户级page fault处理很重要，他应该也是我们平时写在用户层写应用程序时大量发生的事情，下面写一下几个点：
* 用户级处理程序的入口在PCB中，即e-> env_pgfault_upcall。
* 在用户态发生页错误时，内核将在用户异常栈上运行指定的用户级页错误处理程序，重启用户环境，注意，过程是：用户出错->通过trap()进内核，page_fault_handler()发现是用户出错，就在用户异常栈上压utf，然后置esp eip，启用异常栈，在用户空间（同一个进程）把env_pgfault_upcall() （此时它被置为了_pgfault_upcall）运行起来。
* _pgfault_upcall干了如下事情：调用用户处理程序_pgfault_handler()（它才是用户页错误处理程序，即根据cow错误发生的地址，重新申请物理页，把对应的虚拟地址页拷贝映射过去。），然后再用汇编操作utf ，把用户栈切换回来（这块汇编写的也挺绕），把上下文重新复原成用户进程发生错误前的模样。
* 异常栈的申请是在fork()的开头通过set_pgfault_handler()就完成了。

以下是用户页面异常处理程序的控制流:
* 1.内核将缺页异常传播到_pgfault_upcall，后者调用fork()的pgfault() handler。
* 2.pgfault()检查异常是否是写异常(检查错误码中的FEC_WR)，并且该页的PTE标记是否为PTE_COW。如果不是，那就panic。
* 3.pgfault()分配一个映射在临时位置的新页，并将发生故障的页的内容复制到临时位置。然后，错误处理程序将新页映射到具有读/写权限的适当地址，而不是旧的只读映射。

fork()的基本控制流程如下:
* 1.父进程使用set_pgfault_handler()函数，将pgfault()设置为用户级别的页面错误处理程序。
* 2.父进程调用sys_exofork()创建子环境。
* 3.对于位于UTOP下的地址空间中的每个可写页或写时复制页，父进程都会调用duppage，该函数会将页的写时复制映射到子进程的地址空间中，然后在自己的地址空间中重新映射页的写时复制。【注意:这里的排序(即先在子页面中标记为COW，再在父页面中标记)实际上很重要! **我的理解是用户栈会出现问题。先标父进程的话，在你给r赋值的时候就会修改用户栈上的值（见duppage，注意系统调用不使用用户栈，反而是修改r这个局部变量时会用栈），那么此时父进程触发用户异常，另开一个物理页开始写，然后你再复制子进程的映射时就不是原来的栈了，栈换了不要紧，但是之后父进程还要继续执行fork，还要写这个栈，这个时候父进程就会修改这个栈还不用另开内存，因为此时已经触发完异常了，栈页已经是可写的了，而不是cow的了，这就污染了子进程的栈**】 duppage设置了两个pte（父子），使得该页不可写，并将PTE_COW包含在"avail"字段中，以区分写时复制的页和真正的只读页。
**不过，异常栈不会以这种方式重新映射**
* 4.父进程设置子进程用户页错误处理程序入口点。
* 5.子进程现在可以运行了，因此父进程将其标记为runnable。
  
**不开异常栈，直接用用户栈会怎么样呢？**
我的感觉不一定完全正确 ：额，首先很乱。然后fork（）的时候父进程本身就会触发页错误，这个时候感觉父子进程就全乱套了。。。。。。



#### IPC
也单独开个标题写吧。 
外部中断(即设备中断)称为IRQ。有16个可能的IRQ。这个别和lab3写的处理器内部中断异常搞混了。

* 这部分前两个exercise先实现了下外部中断（要用时钟中断做抢占调度，内核检测到时钟中断向量后，用lapic_eoi()把接收外部中断，然后调度进程）。
* 另外，中断异常入口设置有个点我lab3忘说了。在这里说一下： **应该是将系统调用设置为1,因为它应该允许其他中断干扰它。而其他均设置为0，因为这些异常以及中断不应该再被干扰。但是！！！！！！！上文加粗部分提到：JOS对此做了简化，所以。。。。都应该设置为0。**
* 然后就该IPC了。IPC机制相互发送的“消息”由两个部分组成:单个32位值和可选的单个页映射。这块其实也比较好写，就是把两个进程通信的顺序捋清楚，然后封装时再加上异常值检测。
* IPC顺序：
  * 接收环境调用ipc_recv()，再调用sys_ipc_recv()，此时接收环境的PCBipc相关变量被设置，并且环境阻塞,状态变为ENV_NOT_RUNNABLE。直到sys_ipc_try_send()成功发送，改变ipc相关变量，然后再层层返回，最终用户调用的ipc_recv()才会返回。

  * 发送环境调用ipc_send()，传入接收方的环境id和要发送的值。它反复调用sys_ipc_try_send()，直到找到那个接收环境并成功发送。 而sys_ipc_try_send()中如果指定的环境实际上正在接收(它已经调用了sys_ipc_recv，但还没有得到值)，则发送端发送消息并返回0。否则，发送端返回-E_IPC_NOT_RECV，表示目标环境当前不期望接收值。


### 被拷打过的一个问题： 锁，实现的锁么？还是调用的？
调用的自旋锁
```c
struct spinlock {
	unsigned locked;       // Is the lock held?

#ifdef DEBUG_SPINLOCK
	// For debugging:
	char *name;            // Name of lock.
	struct CpuInfo *cpu;   // The CPU holding the lock.
	uintptr_t pcs[10];     // The call stack (an array of program counters)
	                       // that locked the lock.
#endif
};

void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}

static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand. 也就是原子操作
	asm volatile("lock; xchgl %0, %1" 
		     : "+m" (*addr), "=a" (result)
		     : "1" (newval)
		     : "cc");
	return result;
}
```
总结：自旋锁核心：调用xchg()函数，该函数其中为内联汇编，不优化顺序的原子操作：交换*addr 和newval 并返回 老*addr值。
