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

在本实验和后续的实验中，完成实验室中描述的所有常规练习和至少一个挑战性问题。

## Part 1: Physical Page Management
JOS以页面粒度管理PC的物理内存，这样它就可以使用MMU来映射和保护每一块已分配内存。

### Exercise 1
这个练习将编写物理页面分配器。它使用结构体 PageInfo对象 的链表跟踪哪些页面是空闲的(与xv6不同的是，这些对象没有嵌入到空闲页面本身中)，每个页面对应一个物理页面。

> 练习1
In the file kern/pmap.c, you must implement code for the following functions (probably in the order given).
boot_alloc(); mem_init() (only up to the call to check_page_free_list(1)); page_init(); page_alloc(); page_free().
check_page_free_list() and check_page_alloc() test your physical page allocator. You should boot JOS and see whether check_page_alloc() reports success. Fix your code so that it passes. You may find it helpful to add your own assert()s to verify that your assumptions are correct.

boot_alloc()函数中ROUNDUP(a,n)函数在inc/types.h中定义：目的是用来进行地址向下对齐，即增大数a至n的倍数处。
而boot_alloc()函数注释也解释：这个函数只分配内存，并不初始化内存，函数中
```language
//boot_alloc()函数修改处

```







