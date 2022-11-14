# lab1

## 一些暂时未尝试的东西
git diff将显示自上次提交以来对代码的更改，
git diff origin/lab1将显示相对于为这个实验室提供的初始代码的更改。
提交系统能打分，不知道能不能用。
PC Assembly Language Book书中使用的是NASM汇编器，而项目使用GNU汇编器，二者依据所提供的 Brennan's Guide to Inline Assembly文件转化

## Exercise 1.2(The ROM BIOS)
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
//利用al寄存器读取出 $0x70的值
[f000:d169]    0xfd169:	in     $0x71,%al
//向$0x71 写入al寄存器的值
//0070-0071	NMI（不可屏蔽中断） Enable / Real Time Clock
//见于
//http://web.archive.org/web/20040501054447/http://members.iweb.net.au/~pstorr/pcbook/book2/ioassign.htm


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
//计算机中包含CR0~CR3四个控制寄存器，用来控制和确定处理器的操作模式。其中这三个语句的操作明显是要把CR0寄存器的最低位(0bit)置1。CR0寄存器的0bit是PE位，启动保护位，当该位被置1，代表开启了保护模式。

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




