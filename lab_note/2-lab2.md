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
Chapter 5 Memory Management:<br>
Intel 80386将逻辑地址(即程序员看到的地址)转换为物理地址(即物理内存中的实际地址)分为两个步骤:  1.  段转换，其中逻辑地址(由段选择子和段偏移量组成) 被转换为线性地址。2.  页转换，将线性地址转换为物理地址。这个步骤是可选的，由系统软件设计人员自行决定。

5.2 Page Translation：<br>
页面转换步骤是可选的。只有设置了CR0的PG位，页面转换才有效，该位通常由操作系统在软件初始化期间设置。
![lab2_exercise2_1通过页表的地址转换.png](1)
当前页目录的物理地址存储在CPU寄存器CR3中，也称为页目录基寄存器(PDBR)。

在对页进行读或写操作之前，处理器将两层页表中相应的访问位设置为1。（这可能与cpu多核处理相关）








