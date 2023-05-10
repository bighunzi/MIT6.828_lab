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
