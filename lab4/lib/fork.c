// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
        if(r<0) panic("pgfault: page allocation failed %e", r);
        
        addr = ROUNDDOWN(addr, PGSIZE);
        memmove(PFTEMP, addr, PGSIZE);
	if ((r = sys_page_unmap(envid, addr)) < 0)
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
		panic("pgfault: page unmap failed (%e)", r);
}	

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
// 将虚拟内存页pn 映射到目标环境
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
	envid_t this_envid = sys_getenvid();//父进程号
	void * va = (void *)(pn * PGSIZE);
	
	int perm = uvpt[pn] & 0xFFF;
	if ( (perm & PTE_W) || (perm & PTE_COW) ){
		perm |= PTE_COW;
		perm &= ~PTE_W;
	}
	perm&=PTE_SYSCALL; // 写sys_page_map函数时 perm必须要达成的要求
	
	r=sys_page_map(this_envid, va, envid, va, perm);
	if(r<0) return r;
	
	r=sys_page_map(this_envid, va, this_envid, va, perm);//一定要用系统调用， 因为权限！！
	if(r<0) return r;
	
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
		    // dup page to child
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
		}
	}
	//分配异常栈
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
	if(r<0) return r;
	
	//4.
	// Assembly language pgfault entrypoint defined in lib/pfentry.S.
	extern void _pgfault_upcall(void);
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if(r<0) return r;
	
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
