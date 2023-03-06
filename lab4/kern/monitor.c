// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	
	
	// Your code here.
	uint32_t * ebp;
	struct Eipdebuginfo info;
	
	ebp=(uint32_t *)read_ebp();
	cprintf("Stack backtrace:\n");
	while((uint32_t)ebp != 0x0){//the first ebp value is 0x0
		//Exercise 11
		cprintf(" ebp %08x",(uint32_t) ebp);
		cprintf(" eip %08x",*(ebp+1));
		cprintf(" args");
		// the order of arguments is reverse in the stack. For example, func(a,b), in the stack is b,a.
		cprintf(" %08x",*(ebp+2));
		cprintf(" %08x",*(ebp+3));
		cprintf(" %08x",*(ebp+4));
		cprintf(" %08x",*(ebp+5));
		cprintf(" %08x\n",*(ebp+6));
		
		//Exercise 12
		debuginfo_eip(*(ebp+1) , &info);
		cprintf("\t%s:",info.eip_file);
		cprintf("%d: ",info.eip_line);
		cprintf("%.*s+%d\n", info.eip_fn_namelen , info.eip_fn_name , *(ebp+1) - info.eip_fn_addr );
		
		//
		ebp=(uint32_t *)(*ebp);
	}


	
	//codes in exercise 8, now in exercise 11, do not need them.
	/*
	cprintf("Lab1 Exercise8 qusetion3,4 start!\n");
	
	//question 3
	int x = 1, y = 3, z = 4;
        cprintf("x %d, y %x, z %d\n", x, y, z);
        
        //question 4
	unsigned int q4i = 0x00646c72;
    	cprintf("H%x Wo%s\n", 57616, &q4i);
    	
    	//question 5
    	cprintf("x=%d y=%d\n", 3);
    	
	cprintf("Lab1 Exercise8 qusetion3 finish!\n");
	*/
	return 0;
}



/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
