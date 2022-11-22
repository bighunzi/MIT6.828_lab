# lab1

## 一些暂时未尝试的东西
git diff将显示自上次提交以来对代码的更改，
git diff origin/lab1将显示相对于为这个实验室提供的初始代码的更改。
提交系统能打分，不知道能不能用。
PC Assembly Language Book书中使用的是NASM汇编器，而项目使用GNU汇编器，二者依据所提供的 Brennan's Guide to Inline Assembly文件转化
本项目中使用的GNU汇编器使用AT&T/Unix语法:
source在左，destination在右

## PC Bootstrap
### Exercise 2(The ROM BIOS)
```language
//当PC机启动时，CPU运行在实模式(real mode)下，而当进入操作系统内核后，将会运行在保护模式下(protected mode)。
//实模式下指令中出现的地址都是采用 (段基址：段内偏移)。
//但是由于8088CPU中寄存器都是16位，而CPU地址总线是20位的，所以把段寄存器中的值左移4位，形成20位段基址，然后和16位段内偏移相加，就得到了真实地址

[f000:fff0]    0xffff0:	ljmp   $0xf000,$0xe05b 
//一条跳转指令，跳转到0xfe05b地址处
//16*0xf000 + 0xfff0=0xffff0 

[f000:e05b]    0xfe05b:	cmpl   $0x0,%cs:0x6ac8
//把0x0这个立即数和$cs:0x6ac8所代表的内存地址处的值比较

[f000:e062]    0xfe062:	jne    0xfd2e1
//jne指令：如果ZF标志位为0的时候跳转，即上一条指令cmpl的结果不是0时跳转，也就是$cs:0x6ac8地址处的值不是0x0时跳转。

[f000:e066]    0xfe066:	xor    %dx,%dx
//xor 异或
//0xfe066表明上面的跳转指令并没有跳转。这条指令的功能是把dx寄存器清零。

[f000:e068]    0xfe068:	mov    %dx,%ss
[f000:e06a]    0xfe06a:	mov    $0x7000,%esp
[f000:e070]    0xfe070:	mov    $0xf34c2,%edx
//设置寄存器的值

[f000:e076]    0xfe076:	jmp    0xfd15c
//跳转

[f000:d15c]    0xfd15c:	mov    %eax,%ecx
//寄存器

[f000:d15f]    0xfd15f:	cli
//关闭中断指令。这个比较好理解，启动时的操作是比较关键的，所以肯定是不能被中断的。这个关中断指令用于关闭那些可以屏蔽的中断。比如大部分硬件中断。

[f000:d160]    0xfd160:	cld    
//设置方向标识位为0，表示后续的串操作比如MOVS操作，内存地址的变化方向，如果为0代表从低地址值变为高地址

[f000:d161]    0xfd161:	mov    $0x8f,%eax

//out，in 是用来操作IO端口的（设备控制器当中的寄存器）
[f000:d167]    0xfd167:	out    %al,$0x70
//向 0x70 端口写入al寄存器的值
[f000:d169]    0xfd169:	in     $0x71,%al
//利用al寄存器 读取 0x71端口的值
//0070-0071	NMI（不可屏蔽中断） Enable / Real Time Clock
//见于 http://web.archive.org/web/20040501054447/http://members.iweb.net.au/~pstorr/pcbook/book2/ioassign.htm


[f000:d16b]    0xfd16b:	in     $0x92,%al
//0090-009F	System devices
[f000:d16d]    0xfd16d:	or     $0x2,%al
//按位或
[f000:d16f]    0xfd16f:	out    %al,$0x92


[f000:d171]    0xfd171:	lidtw  %cs:0x6ab8
//lidt指令：加载中断向量表寄存器(IDTR)。
[f000:d177]    0xfd177:	lgdtw  %cs:0x6a74
//把从0xf6a74为起始地址处的6个字节的值加载到全局描述符表格寄存器中GDTR中。这个表实现保护模式非常重要的一部分，我们在介绍boot loader时会具体介绍它。
[f000:d17d]    0xfd17d:	mov    %cr0,%eax
[f000:d180]    0xfd180:	or     $0x1,%eax
[f000:d184]    0xfd184:	mov    %eax,%cr0
//计算机中包含CR0~CR3四个控制寄存器，用来控制和确定处理器的操作模式。其中这三个语句的操作明显是要把CR0寄存器的最低位(0bit)置1。CR0寄存器的0bit是PE位，启动保护位，当该位被置1，代表开启了保护模式。但是这里出现了问题，我们刚刚说过BIOS是工作在实模式之下，后面的boot loader开始的时候也是工作在实模式下，而后切换到保护模式，所以这里把它切换为保护模式，显然是自相矛盾。所以只能推测它在检测是否机器能工作在保护模式下。(我也不懂)

//后面的应该就不是了
[f000:d187]    0xfd187:	ljmpl  $0x8,$0xfd18f
The target architecture is set to "i386".
=> 0xfd18f:	mov    $0x10,%eax
=> 0xfd194:	mov    %eax,%ds
=> 0xfd196:	mov    %eax,%es
=> 0xfd198:	mov    %eax,%ss
=> 0xfd19a:	mov    %eax,%fs
=> 0xfd19c:	mov    %eax,%gs
=> 0xfd19e:	mov    %ecx,%eax

```


综上，我们可以看到BIOS的操作就是在控制，初始化，检测各种底层的设备，比如时钟，GDTR寄存器。以及设置中断向量表。这都和Lab 1 Part 1.2最后两段说的一样。但是作为PC启动后运行的第一段程序，它最重要的功能是把操作系统从磁盘中导入内存，然后再把控制权转交给操作系统。所以BIOS在运行的最后会去检测可以从当前系统的哪个设备中找到操作系统，通常来说是我们的磁盘。也有可能是U盘等等。当BIOS确定了，操作系统位于磁盘中，那么它就会把这个磁盘的第一个扇区，通常把它叫做启动区（boot sector）先加载到内存中，这个启动区中包括一个非常重要的程序--boot loader，它会负责完成整个操作系统从磁盘导入内存的工作，以及一些其他的非常重要的配置工作。最后操作系统才会开始运行。

可见PC启动后的运行顺序为 BIOS --> boot loader --> 操作系统内核

## The Boot Loader
看boot/boot.S源码：
参考 https://www.cnblogs.com/cyx-b/p/11809742.html与其他收藏教程
几个知识点：
test命令将两个操作数进行逻辑与运算，并根据运算结果设置相关的标志位。

看boot/main.c源码：
看收藏的博客即可，另外去重看一边CS:appS书 再回来看一遍这个。

### Exercise 3
其中这个练习中的 boot.asm 并未细看，以后重看一下

> 问题1
1.At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
boot.s文件中  ljmp    $PROT_MODE_CSEG, $protcseg

这条语句之前的几句开启了保护模式，这条语句跳转到了32位对应代码处
是修改了CR0 bit0位导致了32位模式的开启

> 问题2
2.What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?
call   *0x10018

movw   $0x1234,0x472

> 问题3
3.Where is the first instruction of the kernel?

0x10000c

![lab1_exercise3_1.png](0)

> 问题4
4.How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?

main.c程序中通过ELFHDR指向的struct中的对象，也就是elf.h头文件中Program Header Table

### Exercise 4
看pointer.c的几行输出
1,2,4,6行很简单，c语言基础
3: 3[c]的写法很奇怪，没见过
5:注意window是小端系统(数据的低位字节序的内容放在低地址处，即人读的顺序应该是从右到左)，所以拼接的时候注意顺序。
修改前a[1]=400=0x00000190。 按byte存放：90 01 00 00
      a[2]=302=0x0000012e  按byte存放：2e 01 00 00
修改后将 指针后移了1个byte 赋值500，即0x000001f4。 按byte存放：f4 01 00 00
于是a[1]变为 90 f4 01 00(128144)   a[2]变为 00 01 00 00(256)

### Exercise 5
Link Address是指编译器指定代码和数据所需要放置的内存地址，由链接器配置
Load Address是指程序被实际加载到内存的位置

修改  $(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 -o $@.out $^  该行地址
我将其改为0x7D00

问题：BIOS将 boot loader加载到 0x7c00，所以咱们修改链接地址的结果是导致了boot.s以及后续的main.c的变化。
https://blog.csdn.net/sgy1993/article/details/89281964表示链接地址和加载地址的区别，咱们只是修改了链接地址！！！！！

下文均为参考博客进行的实验

修改后重新编译，发生变化处：0x7c1e:	lgdtw  0x7d64

![lab1_exercise5_1.png](1)

上面这条指令是把指令后面的值所指定内存地址处后6个字节的值输入全局描述符表寄存器GDTR，但是当前这条指令读取的内存地址是0x7d64，我们在图中也展示了一下这个地址处后面6个单元存放的值，发现是全部是0。这肯定是不对的，正确的应该是在0x7c64处存放的值，即图中最下面一样的值。可见，问题出在这里，GDTR表的值读取不正确，这是实现从实模式到保护模式转换的非常重要的一步。
进一步执行，到后面这条语句发现：程序由于跳转地址的错误，已经无法执行了。(本人猜测，可能因为并没有0x7d32地址对应的指令，所以无法跳转。从boot.asm文件中可以看出，7d30和7d33有指令，7d32并没有）

![lab1_exercise5_2.png](2)

### Exercise 6
at the point the BIOS enters the boot loader：
0x100000:	0x00000000	0x00000000	0x00000000	0x00000000
0x100010:	0x00000000	0x00000000	0x00000000	0x00000000

at the point the boot loader enters the kernel：
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x1000b812	0x220f0011	0xc0200fd8

> 问题
他们为什么不同？

bootmain中最后一句加载内核的程序是((void (*)(void)) (ELFHDR->e_entry))()， 其中e_entry字段的含义是这个可执行文件的第一条指令的虚拟地址。所以这句话的含义就是把控制权转移给操作系统内核。
在这之前bootmain已经把kernel程序装载到0x10000处了 从main.c就可以看出来，这几处有了改变。

> 问题
在第二个情况下那里的东西是什么？

是kernel程序， 但是是程序的哪一部分我不清楚。

## The Kernel
### Exercise 7
注：从Exercise 3看出来 kernel 的入口地址是0x10000c（博客说的）。


stop at the movl %eax, %cr0.
执行完该句的前一句指令，si提示下一句为movl %eax, %cr0时：
at 0x00100000:
(gdb) x/10x 0x00100000 
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x1000b812	0x220f0011	0xc0200fd8
0x100020:	0x0100010d	0xc0220f80

at 0xf0100000:
(gdb) x/10x 0xf0100000
0xf0100000 <_start-268435468>:	0x00000000	0x00000000	0x00000000	0x00000000
0xf0100010 <entry+4>:	0x00000000	0x00000000	0x00000000	0x00000000
0xf0100020 <entry+20>:	0x00000000	0x00000000

使用stepi (si命令显示的下一行将要执行的指令！) GDB命令执行完该指令.
at 0x00100000:
(gdb) x/10x 0x00100000 
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x1000b812	0x220f0011	0xc0200fd8
0x100020:	0x0100010d	0xc0220f80

at 0xf0100000:
(gdb) x/10x 0xf0100000
0xf0100000 <_start-268435468>:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0xf0100010 <entry+4>:	0x34000004	0x1000b812	0x220f0011	0xc0200fd8
0xf0100020 <entry+20>:	0x0100010d	0xc0220f80

可见原本存放在0xf0100000处的内容，已经被映射到0x00100000处了。

> 问题
What is the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place? 

将entry.S文件中的%movl %eax, %cr0这句话注释掉，进行尝试：
![lab1_exercise7_1.png](0)

其中在0x10002a处的jmp指令，要跳转的位置是0xf010002C，由于没有进行分页管理，此时不会进行虚拟地址到物理地址的转化。所以报出错误。

### Exercise 8
> Exercise 8
We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.

分析一下三个文件：
printf.c文件中有三个函数: 
putch()调用consol.c中的cputchar(), 
vcprintf()调用 printfmt.c中的 vprintfmt(), 
cprintf()调用vcprintf().

剩下两个文件代码太多了，先跟着博客一点点分析。
先分析console.c：
这个文件中定义了如何把一个字符显示到console上，即我们的显示屏之上，里面包括很多对IO端口的操作。
最重要的cputchar函数：其调用cons_putc,而根据注释,后者的功能是输出一个字符到控制台(计算机的屏幕)。（注意：putch主体是调用cputchar）

再看printfmt.c:
文件注释：精简的原语printf风格的格式化例程，通常由printf、sprintf、fprintf等使用。内核程序和用户程序也使用此代码。
其中根据注释，printfmt()函数是格式化和打印字符串的主要函数，而其调用vprintfmt函数
vprintfmt函数：

答案：省略的部分在 printfmt.c文件208行处，修改为：
```language
case 'o':
	// Replace this with your code.
	//imitate (unsigned) hexadecimal and unsigned decimal part
	num = getuint(&ap, lflag);
	base=8;
	go to number;
	//no break,because "break" is in number:
```

并回答下列问题：
> 问题1
1.Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?

printf.c中putch()调用consol.c中的cputchar()
用来向显示屏上显示字符。

> 问题2
2.Explain the following from console.c:

crt_buf:这是一个字符数组缓冲区，里面存放着要显示到屏幕上的字符
crt_pos:这个表示当前最后一个字符显示在屏幕上的位置。

当crt_pos >= CRT_SIZE，其中CRT_SIZE = 80*25，由于我们知道crt_pos取值范围是0~(80*25-1)，那么这个条件如果成立则说明现在在屏幕上输出的内容已经超过了一页。所以此时要把页面向上滚动一行，即把原来的1~79号行放到现在的0~78行上，然后把79号行换成一行空格（当然并非完全都是空格，0号字符上要显示你输入的字符int c）。所以memcpy操作就是把crt_buf字符数组中1~79号行的内容复制到0~78号行的位置上。而紧接着的for循环则是把最后一行，79号行都变成空格。最后还要修改一下crt_pos的值。


> 问题3
3.In the call to cprintf(), to what does fmt point? To what does ap point?

> 问题3
List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.

> 问题4
4.

> 问题5
5.In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?

> 问题6
6.Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?