# lab1

## 一些暂时未尝试的东西
git diff将显示自上次提交以来对代码的更改，
git diff origin/lab1将显示相对于为这个实验室提供的初始代码的更改。
提交系统能打分，不知道能不能用。
PC Assembly Language Book书中使用的是NASM汇编器，而项目使用GNU汇编器，二者依据所提供的 Brennan's Guide to Inline Assembly文件转化

## Exercise 1.2(The ROM BIOS)
[f000:fff0]    0xffff0:	ljmp   $0xf000,$0xe05b //一条跳转指令，跳转到0xfe05b地址处

