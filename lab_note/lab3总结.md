这个lab拷打的地方可太多了，除了总结，我还会放一下我被拷打过的问题和答案。

### 过程总结
* 同内存系统一样，先开PCB数组的内存，并对其初始化，讲未分配进程以链表形式串联。
* 然后是功能组件函数：
  为进程页目录分配空间，为进程分配物理内存，往一个进程的内存中加载ELF二进制文件，创建用户环境，运行用户环境。
  其中load_icode()和env_run()代码我感觉还是有东西的。
  * load_icode()注意两点，一是根据elf头文件进行拷贝（我在lab1总结里面有讲，在这就不说了。）；二是要注意页目录基寄存器的切换，之前讲过我们写代码无法绕过mmu，所以我们往内存中复制时也要切换页目录以确保拷贝的位置位于那个用户进程的空间中。
  * env_run()主要是切换上下文那一下比较秀。即env_pop_tf()，它不是硬给寄存器赋值，而是把tf这个结构体的指针赋给esp，即栈寄存器，然后以一种弹栈的方式+iret中断返回指令就把寄存器值赋好了。
    ```c
    void
    env_pop_tf(struct Trapframe *tf)
    {
        // Record the CPU we are running on for user-space debugging
        curenv->env_cpunum = cpunum();

        asm volatile(
            "\tmovl %0,%%esp\n"
            "\tpopal\n"
            "\tpopl %%es\n"
            "\tpopl %%ds\n"
            "\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
            "\tiret\n" /*中断返回指令*/
            : : "g" (tf) : "memory");
        panic("iret failed");  /* mostly to placate the compiler */
    }
    ```
* 然后就是中断和异常，此处很重要！！！此处是否理解也直接影响后面系统调用，库封装等等工作。这块也不太好总结，感觉笔记上每一个字都很重要，直接去看我原笔记吧。
* 系统调用：注意此处传参是在寄存器中传递系统调用编号和系统调用参数。这样，内核就不需要遍历用户环境的栈或指令流。系统调用编号将进入%eax，参数(最多5个)将分别进入%edx、%ecx、%ebx、%edi和%esi。另外系统调用过程中地址合法性检查是很重要的一个行为，

  



### 一些拷打过的问题

**PCB都保存哪些信息？**
寄存器 id 父进程id，种类（普通用户，特殊（宏内核架构）） 状态 运动时间 cpu 页目录地址  ipc相关信息
一些lab中的特殊设置： mfq 用户异常处理函数入口点    


**怎么调用用户进程，过程**
先创建这个进程： 申请内存构造 PCB, 页目录。 

然后开始初始化PCB：置寄存器（修改PCB中eip，段寄存器权限，栈寄存器，EFLAGS权限寄存器，允许中断，IO等）

然后就开始加载程序，分配栈内存：根据编译好的二进制可执行文件的elf文件头把这个文件拷入到内存中。给栈分配寄存器。

最后运行：切换页目录寄存器，将PCB中保存的寄存器释放出来.
此处切换寄存器很巧妙,将esp指向tf地址，然后以返回的方式就自动切换回来了。
```c
void env_pop_tf(struct Trapframe *tf)
{
	asm volatile(
		"\tmovl %0,%%esp\n"  /*将%esp指向tf地址处*/
		"\tpopal\n"			//弹出Trapframe结构中的tf_regs值到通用寄存器
		"\tpopl %%es\n"		//弹出Trapframe结构中的tf_es值到%es寄存器
		"\tpopl %%ds\n"		 //弹出Trapframe结构中的tf_ds值到%ds寄存器
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"  /*  //中断返回指令，具体动作如下：从Trapframe结构中依次弹出tf_eip,tf_cs,tf_eflags,tf_esp,tf_ss到相应寄存器*/
		: : "g" (tf) : "memory"); //g是一个通用约束，可以表示使用通用寄存器、内存、立即数等任何一种处理方式
	panic("iret failed");  /* mostly to placate the compiler */
}
//IRET(interrupt return)中断返回，中断服务程序的最后一条指令。IRET指令将推入堆栈的段地址和偏移地址弹出，使程序返回到原来发生中断的地方。其作用是从中断中恢复中断前的状态，具体作用有如下三点：
```


**什么情况下会在用户态和内核态之间切换**
系统调用, 中断（例如时钟中断,抢占式调度），异常（这条当时没答出来，比如访问权限不对，缺页）
内核态回用户态：内部调度。