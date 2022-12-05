# lab2
这个实验是为操作系统编写内存管理代码。内存管理分为两部分： 内核的物理内存分配器，虚拟内存。<br>
1 page : 4k bytes<br>
为获取lab2所需文件，执行如下命令：
```language
git pull
git checkout -b lab2 origin/lab2
git merge lab1
//如果下列文件出现，则成功：
//inc/memlayout.h; kern/pmap.c; kern/pmap.h; kern/kclock.h; kern/kclock.c
```
其中Memlayout.h描述了必须通过修改pmap.c实现的虚拟地址空间布局。
memlayout.h和mmap.h定义了PageInfo结构，您将使用该结构跟踪哪些物理内存页面是空闲的。kclock.c和kclock.h操作PC的电池支持时钟和CMOS RAM硬件，BIOS在其中记录PC所包含的物理内存量，以及其他内容。
pmap.c中的代码需要读取这个设备硬件，以便计算出有多少物理内存，但这部分代码已经完成了:我们并不需要知道CMOS硬件如何工作的细节。
inc/mmu.h也很重要，因为它包含许多对本实验有用的定义。

在本实验室和后续的实验室中，完成实验室中描述的所有常规练习和至少一个挑战性问题。

## Part 1: Physical Page Management





