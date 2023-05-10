# challenge1-MFQ

## lab4环境调度部分的challenge: 多级反馈队列(MFQ)调度算法

>chellenge原文：
向内核添加一个不那么简单的调度策略，例如一个固定优先级的调度器，使每个环境都有一个优先级，确保优先选择优先级高的环境，而不是优先级低的环境。如果你喜欢冒险，可以尝试实现unix风格的可调优先级调度器，甚至是lottery或stride调度器。(在谷歌中查找“彩票调度”和“步幅调度”。)编写一两个测试程序，验证调度算法是否正确工作(即，正确的环境按正确的顺序运行)。一旦你在本实验室的B部分和C部分实现了fork()和IPC，编写这些测试程序可能会更容易。

MFQ较 原先简单的时间片抢占轮询调度的区别(实现层面)：
* 数据结构的修改：需要多级队列（链表实现）来组织就绪状态的 struct env。
* 环境调度时要对队列进行操作：环境变为RUNNABLE时插入队列，环境解除就绪状态时（包括环境开始运行）移除队列
* 时间片中断到来时抢占的逻辑也需要修改

于是修改的大致范围确定：
* 需要自己写个链表的数据结构和组件，c库没有。
* env.h env.c 需要修改struct env 和 环境创建，运行，销毁等函数组件。
* sched.c 中的调度函数（ sched_yield() ）
* trap.c中接收到时钟中断的处理过程。
* 还需要测试程序

另外，项目中新建了my_config.h文件，方便了后面challenge的各种模式切换
#### 1.链表
inc文件夹下新建文件 my_listnode.h
```c
//链表实现文件
#ifndef JOS_INC_MY_LISTNODE_H
#define JOS_INC_MY_LISTNODE_H

struct Listnode{
	struct Listnode *prev, *next;
};//双向链表，头接尾，尾接头

static void
node_init(struct Listnode *ln) 
{
    ln->prev = ln->next = ln;
}

static void 
node_remove(struct Listnode *ln) 
{
    ln->prev->next = ln->next;
    ln->next->prev = ln->prev;
    node_init(ln);
}

static void 
node_insert(struct Listnode *pos, struct Listnode *ln) 
{
    ln->prev = pos;
    ln->next = pos->next;
    ln->prev->next = ln;
    ln->next->prev = ln;
}

static bool
queue_empty(struct Listnode * ln) 
{
    if(ln->prev==ln){
        return true;
    }else return false;
}

//返回队列头
static struct Listnode*
queue_head(struct Listnode* que)
{
    return que->next;
}

static void 
node_enqueue(struct Listnode *que, struct Listnode *ln) 
{
    node_insert(que->prev, ln);//插入到队列尾巴
}

#endif
```

#### 2.env组件修改
这部分比较零碎，我只列几处主要内容，其余操作队列，输出测试信息等地方就不罗列了，直接去找我的源代码吧。（包括inc/env.h  kern/env.h,env.c,pmap.c（要给队列头节点分空间））
```c
//env.h
struct Env {
	//MFQ
	#ifdef CONF_MFQ
		struct Listnode env_mfq_link;
		int env_mfq_level;//等级
		int env_mfq_time_slices;//剩余时间片
	#endif
    //下面同之前lab
    //......
};


//env.c
/////////////////////////////////////////////////////////
//----------------多级反馈队列调度-------------------------
//
#ifdef CONF_MFQ
struct Listnode* mfqs = NULL;

//加入队列
void 
env_mfq_add(struct Env *e) 
{
	node_remove(&e->env_mfq_link);
	if (e->env_mfq_time_slices > 0) { // 如果还有时间片剩余
		node_insert(&mfqs[e->env_mfq_level], &(e->env_mfq_link) );	//插入队列头
	} else { //没有时间片剩余
		uint32_t lv = MIN(e->env_mfq_level + 1, NMFQ - 1);
		e->env_mfq_level = lv;
		e->env_mfq_time_slices = (1 << lv) * MFQ_SLICE;
		node_enqueue(&mfqs[lv], &e->env_mfq_link);//插入队列尾巴
	}
}

//移除队列
void 
env_mfq_pop(struct Env* e)
{
	node_remove(& (e->env_mfq_link) );
}
#endif

//封装,用来替换除环境初始化外的所有e->env_status = ENV_RUNNABLE 语句
//env.c中的组件凡是修改环境状态的语句 全都要用env_ready(),env_disready()修改！！！！！！！！！！！！！！！！！！！！！！！！
void 
env_ready(struct Env* e)
{
	e->env_status = ENV_RUNNABLE;
#ifdef CONF_MFQ
	env_mfq_add(e);
#endif
}

//封装,改变ENV_RUNNABLE状态环境后 要将其移除就绪队列。
//注意：也有可能是将其执行，即改为running状态
void
env_disready(struct Env* e, enum EnvType new_envtype)
{
	e->env_status = new_envtype;
#ifdef CONF_MFQ
	env_mfq_pop(e);
#endif
}

```

#### 3.调度
sched.c中sched_yield()
```c
#ifdef CONF_MFQ
	int findscope=0;
	if(curenv && curenv->env_status == ENV_RUNNING) findscope=curenv->env_mfq_level;
	else findscope=NMFQ-1;

	for (int i = 0; i <= findscope; i++) {//只在队列中找优先级高于或等于当前运行环境的环境
		if (!queue_empty(&mfqs[i])) {
			idle = (struct Env *) queue_head(&mfqs[i] );
			assert(idle->env_status == ENV_RUNNABLE);
			break;
		}
	}
	if (idle) {
		cprintf("New running environment is %08x\n",idle->env_id);//测试语句
		env_run(idle);
	} else if (curenv && curenv->env_status == ENV_RUNNING) {
		cprintf("still runs environment %08x\n",curenv->env_id);
		env_run(curenv);
	}
#else
```

#### 4.中断
trap.c
```c
		case (IRQ_OFFSET + IRQ_TIMER):
			cprintf("Timer Interupt comes, new time slice\n");
			lapic_eoi();
			time_tick();
#ifdef CONF_MFQ
			(curenv->env_mfq_time_slices)--;//当前环境运行了一个时间片，先减一
			//cprintf("当前时间片剩余 %x\n",curenv->env_mfq_time_slices);
			for(int i=0;i<curenv->env_mfq_level;i++){//如果优先级更高的队列有任务了，让出cpu
				if(!queue_empty(&mfqs[i])){
					cprintf("there is higher level environment：  ");
					sched_yield();
					break;//其实不需要break循环，但这样方便阅读。
				} 
			}
			if (curenv && (curenv->env_mfq_time_slices == 0) ) {//这个环境时间片走完
				cprintf("environment %08x time slice exhausts：  ",curenv->env_id);
				sched_yield();
			}
			
#else
			sched_yield();//时间片到达，切换环境
#endif //!CONF_MFQ
			break;
```

#### 5.测试程序
测试程序的大致思路是：先创建一个进程，然后隔一段时间fork()创建子进程，然后子进程再隔一段时间创建子子进程。观察子进程是否会抢占cpu，以及三个进程是否会按照优先队列级别依次调度，并执行相应的时间片数。

**注： 在user文件夹中写新的测试程序，要修改kern中的makefrag文件**

另外，init.c 也有修改，见于源程序。
user/MFQ_test.c  测试程序如下：
```c
//该文件用来测试MFQ算法是否部署完成
#include <inc/lib.h>

void static
sleep(int msec)
{
    int now = sys_time_msec();

    while (msec>0){//使进程运行指定时间。 
		int pre=now;
		now=sys_time_msec();
		msec-= now-pre;
	}   
}
void
umain(int argc, char **argv)
{
	cprintf("新环境 %08x开始...............\n",thisenv->env_id);
	int i;
	
	sleep(50);//该进程先跑50ms。
	//然后再fork两个子进程，之后通过打印信息来观察这三个进程的调度顺序
	envid_t eid=fork();

	if(eid<0){
		panic("fork fail");
	}else if(eid==0){ //子进程
		cprintf("我是子进程， 新环境%08x开始...............\n",thisenv->env_id);

		sleep(50);//该进程先跑50ms。
		eid=fork();//再创建子子进程

		if(eid<0){
			panic("fork fail");
		}else if(eid==0){ //子进程
			cprintf("我是子子进程，新环境%08x开始...............\n",thisenv->env_id);
		}else{//父进程
		}

	}else{//父进程
		cprintf("我是父进程，新环境%08x继续执行...............\n",thisenv->env_id);
	}

	//父子，子子进程全都进行1s
	sleep(1000);//进程进行1s
	cprintf("环境%08x结束...............\n",thisenv->env_id);
}
```

另外由于我的测试程序使用了fork(),我发现sys_env_set_status()与sys_exofork() 也需要修改。因为这两个系统调用也有改变子环境状态的语句。所以，也需要对这两个系统调用函数作出修改。

我在时间中断到来  以及 环境切换时 输出语句，以便观察调度情况。可以看到如下测试结果：环境依照不同等级的时间片依次运行。且当环境进入下一队列时分配的时间片变长。并且新环境到来时，会因为其先被放入优先级高的队列而被优先调度。
![MFQ_测试结果](./MIT6828_img/challenge_mfq_测试结果.png)