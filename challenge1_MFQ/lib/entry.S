#include <inc/mmu.h>
#include <inc/memlayout.h>

//用户程序开始在此文件顶部运行。
.data
// Define the global symbols 'envs', 'pages', 'uvpt', and 'uvpd'
// so that they can be used in C as if they were ordinary global arrays.
	.globl envs
	.set envs, UENVS
	.globl pages
	.set pages, UPAGES
	.globl uvpt
	.set uvpt, UVPT /*0xef400000*/
	.globl uvpd
	.set uvpd, (UVPT+(UVPT>>12)*4)  /* 偏移量是总页数*4(bytes)，所以相加即是页目录所在地址，可以用其访问页目录*/


// Entrypoint - this is where the kernel (or our parent environment)
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
	jne args_exist

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
	pushl $0

args_exist:
	call libmain//调用lib/libmain.c中的libmain()
1:	jmp 1b

