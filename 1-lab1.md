# lab1

## 一些暂时未尝试的东西
git diff将显示自上次提交以来对代码的更改，
git diff origin/lab1将显示相对于为这个实验室提供的初始代码的更改。
提交系统能打分，不知道能不能用。
PC Assembly Language Book书中使用的是NASM汇编器，而项目使用GNU汇编器，二者依据所提供的 Brennan's Guide to Inline Assembly文件转化

## Exercise 1.2(The ROM BIOS)
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
//




