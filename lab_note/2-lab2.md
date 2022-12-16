# lab2
这个实验是为操作系统编写内存管理代码。内存管理分为两部分： 内核的物理内存分配器，虚拟内·存。<br>
1 page : 4k bytes<br>
为获取lab2所需文件，执行如下命令：
```language
git pull
git checkout -b lab2 origin/lab2
git merge lab1
//如果下列文件出现，则成功：
//inc/memlayout.h; kern/pmap.c; kern/pmap.h; kern/kclock.h; kern/kclock.c
```
其中Memlayout.h描述了必须通过修改pmap.c实现的虚拟地址空间布局，如果有不懂的地址名词就去这个文件里找！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

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

boot_alloc()函数中ROUNDUP(a,n)函数在inc/types.h中定义：目的是用来进行地址向下对齐，即增大数a至n的倍数减一处。
而boot_alloc()函数注释也解释：这个函数只分配内存，并不初始化内存，函数中。所以我们仿照该函数中nextfree分配地址的方式分配内存即可。
```language
//boot_alloc()函数修改处
//
// LAB 2: Your code here.
result=nextfree;
nextfree=ROUNDUP(nextfree+n, PGSIZE);
if( (uint32_t)nextfree<KERNBASE ){
	panic("boot_alloc: out of memory\n");
}
//其中KERBASE就在memlayout.h文件中定义。这块检测内存不足的判定我也不确定，但根据lab1中我们的结论：将kernel加载到了虚拟地址0xf0000000处，所以判定应该是这样的。
//这也与博客的写法 if( (uint32_t)nextfree - KERNBASE > (npages*PGSIZE))所不同。
return result;
```

mem_init()函数修改处：
```language
//////////////////////////////////////////////////////////////////////
// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
// The kernel uses this array to keep track of physical pages: for
// each physical page, there is a corresponding struct PageInfo in this
// array.  'npages' is the number of physical pages in memory.  Use memset
// to initialize all fields of each struct PageInfo to 0.
// Your code goes here:
//根据注释提示以及之前几句的仿写修改即可，比较简单。
pages = boot_alloc(npages * sizeof(struct PageInfo) )
memset(pages, 0, npages * sizeof(struct PageInfo);
```

page_init()函数修改处（写这部分的时候要注意，lab1中对于kern读取进内存的部分的结论不能直接用了，因为你现在实际就是在进行这个过程，所有已知结论均通过pmap.c的前文得出）：
```language
//根据注释修改即可
// Change the code to reflect this.
// NB: DO NOT actually touch the physical memory corresponding to
// free pages!
size_t i;
page_free_list = NULL;//其实是多余的，因为它本就是空指针，这只是为了方便阅读一点。
uint32_t EXTPHYSMEM_alloc = (uint32_t)boot_alloc(0) - KERNBASE;//EXTPHYSMEM_alloc：在EXTPHYSMEM区域已经被占用的bytes数
//从memlayout.h中可以看到 pp_ref是使用page_alloc分配的页 指向此页的指针（通常在页表条目中）数, 不太明白。。。。。 但我看博客上将使用的page 置1.
for (i = 0; i < npages; i++) {
	if( i==0 ||(i>=IOPHYSMEM/PGSIZE && i<(EXTPHYSMEM+EXTPHYSMEM_alloc)/PGSIZE)){//不标记为free的页
		pages[i].pp_ref = 1;
	}else{//标记为free的页
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];	
	}
}
```

page_alloc()函数修改处:
```language
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	//不要增加页面的引用计数(pp_ref) - 调用方必须在必要时执行这些操作（显式或通过 page_insert ）。
	struct PageInfo * res=NULL;
	if(!page_free_list) return res;

	res=page_free_list;
	page_free_list=page_free_list -> pp_link;
	res ->pp_link=NULL;
	
	if (alloc_flags & ALLOC_ZERO){//尚未发现ALLOC_ZERO宏在哪个文件中定义，直接根据注释来
		memset(page2kva(res) , '\0' ,  PGSIZE );
	}

	//返回这个页表索引的地址即可(并非 page2kva(res) )
	return res;
}
```

page_free()函数修改处:
```language
void
page_free(struct PageInfo *pp)
{
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//assert()函数在 inc/assert.h文件中定义，其就是按格式调用panic。
      	assert(pp->pp_ref == 0);
      	assert(pp->pp_link == NULL);
	
	pp->pp_link=page_free_list;
	page_free_list=pp;
}
```

上述代码完成后，测试结果如下，说明代码正确(测试时不要忘记改动mem_init()中的该行语句的位置 )：
```language
panic("mem_init: This function is not finished\n")
```

![lab2_exercise1_测试成功.png](0)

## Part 2: Virtual Memory
先熟悉x86的保护模式内存管理体系结构:即段和页面转换。练习2就在做这个事情。

### Exercise 2
> 练习2
Look at chapters 5 and 6 of the Intel 80386 Reference Manual, if you haven't done so already. Read the sections about page translation and page-based protection closely (5.2 and 6.4). We recommend that you also skim the sections about segmentation; while JOS uses the paging hardware for virtual memory and protection, segment translation and segment-based protection cannot be disabled on the x86, so you will need a basic understanding of it.

### Exercise 2 阅读笔记
#### Chapter 5 Memory Management:<br>
Intel 80386将逻辑地址(即程序员看到的地址)转换为物理地址(即物理内存中的实际地址)分为两个步骤:  1.  段转换，其中逻辑地址(由段选择子和段偏移量组成) 被转换为线性地址。2.  页转换，将线性地址转换为物理地址。这个步骤是可选的，由系统软件设计人员自行决定。

#### 5.2 Page Translation：<br>
页面转换步骤是可选的。只有设置了CR0的PG位，页面转换才有效，该位通常由操作系统在软件初始化期间设置。
![lab2_exercise2_1通过页表的地址转换.png](1)
当前页目录的物理地址存储在CPU寄存器CR3中，也称为页目录基寄存器(PDBR)。

在对页进行读或写操作之前，处理器将两层页表中相应的访问位设置为1。（这可能与cpu多核处理相关）

当80386被用来执行为没有分段的体系结构设计的软件时，有效地“关闭”80386的分段功能可能是权宜宜之。80386没有禁用分段的模式，但是可以通过在段寄存器中初始加载包含整个32位线性地址空间的描述符的选择器来实现相同的效果。一旦加载，段寄存器不需要改变。80386指令使用的32位偏移量足以寻址整个线性地址空间。（这也是linux的寻址方式）

#### Chapter 6 Protection
为了帮助更快地调试应用程序并使其在工作中更加稳定，80386包含了验证内存访问和指令执行是否符合保护标准的机制。根据系统设计目标，可以使用或忽略这些机制。

段是保护的单位。

#### 6.4 Page-Level Protection
与页面相关的保护有两种:可寻址域限制 与 类型检查。

### Exercise 3 
在x86术语中，虚拟地址由段选择子和段内的偏移量组成。线性地址是在段转换之后，页面转换之前得到的地址。物理地址是经过段和页转换后最终得到的地址，或者说最终通过硬件总线传输到RAM的地址。

在boot/boot.S文件中，我们安装了一个全局描述符表(GDT)，其通过将所有段基址设置为0，将段限制为0xffffffff 来有效地禁用段转换。因此，“选择子”没有作用，线性地址总是等于虚拟地址的偏移量。在实验室3中，我们将不得不与段进行更多的交互，以设置特权级别，但对于内存转换，我们可以在整个JOS实验室中忽略段，而只关注页转换。

回想一下，在实验1的第3部分中，我们安装了一个简单的页表，这样内核就可以在它的链接地址0xf0100000上运行，即使它实际上是在ROM BIOS上方的0x00100000上加载到物理内存中。这个页表只映射了4MB内存。在本实验中将为JOS设置的虚拟地址空间布局中，我们将扩展该布局，来映射从虚拟地址0xf0000000开始的第一个256MB物理内存，并映射虚拟地址空间的许多其他区域。

> 练习3
While GDB can only access QEMU's memory by virtual address, it's often useful to be able to inspect physical memory while setting up virtual memory. Review the QEMU monitor commands from the lab tools guide, especially the xp command, which lets you inspect physical memory. To access the QEMU monitor, press Ctrl-a c in the terminal (the same binding returns to the serial console).
Use the xp command in the QEMU monitor and the x command in GDB to inspect memory at corresponding physical and virtual addresses and make sure you see the same data.
Our patched version of QEMU provides an info pg command that may also prove useful: it shows a compact but detailed representation of the current page tables, including all mapped memory ranges, permissions, and flags. Stock QEMU also provides an info mem command that shows an overview of which ranges of virtual addresses are mapped and with what permissions.

```language
xp/Nx paddr //查看paddr物理地址处开始的，N个字的16进制的表示结果。
info registers //展示所有内部寄存器的状态。
info mem -//展示所有已经被页表映射的虚拟地址空间，以及它们的访问优先级。
info pg //展示当前页表的结构。
//具体去手册上看
```



为了帮助编写代码，JOS源代码区分了两种情况:uintptr_t类型表示不透明的虚拟地址，physaddr_t类型表示物理地址。JOS内核可以通过先将uintptr_t转换为指针类型来完成对uintptr_t的解引用。
注意：MMU会转换所有的内存引用！！！！！！！！！！！！！！！！内核不能绕过虚拟地址转换，因此不能直接加载和存储到物理地址。

> qustion
Assuming that the following JOS kernel code is correct, what type should variable x have, uintptr_t or physaddr_t?

x应该是uintptr_t。

为了将物理地址转换为内核可以实际读写的虚拟地址，内核必须向物理地址添加0xf0000000，以便在重新映射的区域中找到其对应的虚拟地址。您应该使用KADDR(pa)来完成该添加。

内核全局变量和由boot_alloc()分配的内存位于加载内核的区域，从0xf0000000开始，正是我们映射所有物理内存的区域。因此，要将该区域中的虚拟地址转换为物理地址，内核可以简单地减去0xf0000000。您应该使用PADDR(va)来做这个减法。

在未来的实验中，经常会将相同的物理页面同时映射到多个虚拟地址(或多个环境的地址空间)。将在对应于物理页面的struct PageInfo的pp_ref字段中保存对每个物理页面的引用数量的计数。当物理页的此计数为零时，可以释放该页，因为不再使用它。一般来说，这个计数应该等于物理页在所有页表中出现在UTOP下面的次数(UTOP上面的映射大部分是由内核在引导时设置的，永远不应该被释放，所以没有必要引用计数它们)。我们还将使用它来跟踪指向页目录页的指针数量，以及页目录对页表页的引用数量。

使用page_alloc时要小心。它返回的页面总是有一个0的引用计数，所以只要对返回的页面做了一些事情(比如将它插入到页表中)，pp_ref就应该增加。有时这由其他函数(例如page_insert)处理，有时调用page_alloc的函数必须直接处理。


### Exercise 4

现在将编写一组例程来管理页表:插入和删除线性地址到物理地址映射，并在需要时创建页表页。

> 练习4
In the file kern/pmap.c, you must implement code for the following functions : pgdir_walk(), boot_map_region(), page_lookup(), page_remove(), page_insert().
check_page(), called from mem_init(), tests your page table management routines. You should make sure it reports success before proceeding.

从头捋一下。

pgdir_walk()代码：
```language

```

boot_map_region()代码：
```language

```

page_lookup()代码：
```language

```

page_remove()代码：
```language

```


page_insert()代码：
```language

```
报告成功！

## Part 3: Kernel Address Space
JOS将处理器的32位线性地址空间分为两部分。我们将在实验3中开始加载和运行的用户环境(进程)将控制下部(lower part)的布局和内容，而内核始终保持对上部(upper part)的完全控制。分隔线是由inc/memlayout.h中的符号ULIM任意定义的，其为内核保留了大约256MB(0xffffffff-0xef800000)的虚拟地址空间。这就解释了为什么我们需要在实验1中给内核提供如此高的链接地址:否则内核的虚拟地址空间中就没有足够的空间同时映射到下面的用户环境中

对于本部分和后面的实验，参考inc/memlayout.h中的JOS内存布局图是很有帮助的！

由于内核和用户内存都存在于每个环境的地址空间中，我们必须在x86页表中使用权限位，以使用户代码只访问地址空间的用户部分。

用户环境将没有权限访问ULIM以上的任何内存，而内核将能够读写这些内存。对于地址范围[UTOP,ULIM)，内核和用户环境都有相同的权限:它们可以读但不能写这个地址范围。这个地址范围用于向用户环境公开只读的某些内核数据结构。最后，UTOP下面的地址空间是供用户环境使用的;用户环境将设置访问此内存的权限。

### Exercise 5

该练习将在UTOP上面设置地址空间:地址空间的内核部分。inc /memlayout.h显示了你应该使用的布局。将使用刚才编写的函数来设置适当的线性到物理映射。

> 练习5
在调用check_page()之后，填充mem_init()中缺失的代码。完成代码后应该可以通过check_kern_pgdir()和check_page_installed_pgdir()检查。

添加的代码：
```language

```

测试成功！


> 问题2
此时页目录中的哪些条目(行)已被填充?它们映射哪些地址，指向哪里?换句话说，尽可能多地填写这个表格。

> 问题3
我们将内核和用户环境放在同一个地址空间中。为什么用户程序不能读写内核内存?保护内核内存的具体机制是什么?

用户程序不能去随意修改内核中的代码，数据，否则可能会破坏内核，造成程序崩溃。
因为在页目录项，页表项中有Supervisor/User标志位，通过标志位标识该段内存的受代码访问权限。

> 问题4
这个操作系统能支持的最大物理内存是多少?为什么?



> 问题5
如果我们实际拥有最大数量的物理内存，那么管理内存的空间开销是多少?这些开销是如何分解的?

最大物理内存即4G， 那么我们需要 1个page directory table (4K Bytes),1K个page entry table (4K Bytes) ,  1M个 struct PageInfo (如果存在内存对齐机制的话, 8 Bytes)，共计 12M+ 4K Bytes. 

> 问题6
重新查看kern/entry.s和kern/entrypgdir.c中的页表设置。在我们立即打开分页之后，EIP仍然是一个较低的数字(略多于1MB)。我们在什么时候过渡到运行在KERNBASE之上的EIP ?在启用分页和开始在KERNBASE之上的EIP上运行之间，是什么使我们能够继续在低EIP上执行?为什么这种转变是必要的?