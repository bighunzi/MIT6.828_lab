#include "ns.h"

extern union Nsipc nsipcbuf;

void
sleep(int msec)
{
    unsigned now = sys_time_msec();

    while (msec > sys_time_msec()-now){
    	sys_yield();
    }    
}

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	size_t len;
	char rev_buf[RX_PACKET_SIZE];
	while(1){
		while ( sys_e1000_recv(rev_buf, &len)  < 0) {
			sys_yield();//没东西读，就阻塞，切换别的环境。    
		}
		memcpy(nsipcbuf.pkt.jp_data, rev_buf, len);
		nsipcbuf.pkt.jp_len = len;
		
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U);
		
		sleep(30);//停留一段时间，不停留的话，测试不会通过，会丢包。
	}
}


