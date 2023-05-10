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
