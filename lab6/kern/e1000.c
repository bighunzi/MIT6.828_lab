#include <kern/e1000.h>
#include <kern/pmap.h>
#include <kern/pci.h>
#include <inc/string.h>

#define E1000_LOCATE(offset)  (offset >> 2) //很巧妙的写法


// LAB 6: Your driver code here
/*e1000 MMIO映射位置*/
volatile uint32_t *e1000; 

/*静态分配 发送描述符 和 缓冲区内存*/
struct e1000_tx_desc e1000_tx_desc_array[TX_DESC_ARRAY_SIZE];
char e1000_tx_buffer[TX_DESC_ARRAY_SIZE][TX_PACKET_SIZE];

/*接收描述符 和 缓冲区内存*/
struct e1000_rx_desc e1000_rx_desc_array[RX_DESC_ARRAY_SIZE];
char e1000_rx_buffer[RX_DESC_ARRAY_SIZE][RX_PACKET_SIZE];

//连接设备
int 
pci_e1000_attach(struct pci_func *pcif) 
{
	pci_func_enable(pcif);
	e1000=mmio_map_region(pcif->reg_base[0],pcif->reg_size[0]);
	cprintf("device status:[%x]\n", e1000[E1000_LOCATE(E1000_STATUS)] );/*打印设备状态寄存器， 用来测试程序*/
	
	e1000_transmit_init();
	
	e1000_receive_init();
	
	return 0;
}

/*传输*/
void
e1000_transmit_init()
{
	//参考文档14.5节步骤
	/*1.为传输描述符列表分配一个内存区域，确保内存在16字节边界上对齐。 此步骤在函数外的变量定义过程中已经完成
	* 2. 用区域地址对传输描述符基址(TDBAL/TDBAH)寄存器进行编程，将传输描述符长度(TDLEN)寄存器设置为描述符环的大小(以字节为单位)。 将0b写入传输描述符头部和尾部（TDH/TDT）寄存器。
	* 3. 初始化传输控制寄存器(TCTL) 包括：TCTL.EN置1； TCTL.PSP置1；TCTL.CT置为10h；TCTL.COLD置为40h。
	* 4. 参考IEEE 802.3 IPG标准 设置TIPG寄存器
	*/
	//1.操作描述符。这部分不在14.5中体现，我们需要参考3.3.3将它完成。
	// addr，length其实都应该用上这描述符后再赋值，但我们是静态内存，所以就直接对addr初始化了。
	memset(e1000_tx_desc_array, 0 , sizeof(struct e1000_tx_desc) * TX_DESC_ARRAY_SIZE);
	for (int i = 0; i < TX_DESC_ARRAY_SIZE; i++) {
		e1000_tx_desc_array[i].addr=PADDR(e1000_tx_buffer[i]);
		e1000_tx_desc_array[i].cmd = E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP;//设置RS位。由于每个包只用一个数据描述符，所以也需要设置EOP位
		e1000_tx_desc_array[i].status = E1000_TXD_STATUS_DD;//要置1, 不然第一轮直接就默认没有描述符用了
	}
	//2.
	e1000[E1000_LOCATE(E1000_TDBAL) ]= PADDR(e1000_tx_desc_array);
	e1000[E1000_LOCATE(E1000_TDBAH) ] = 0;
	e1000[E1000_LOCATE(E1000_TDLEN) ] = sizeof(struct e1000_tx_desc)*TX_DESC_ARRAY_SIZE;
	e1000[E1000_LOCATE(E1000_TDH) ] = 0;
	e1000[E1000_LOCATE(E1000_TDT) ] = 0;
	
	//3.
	e1000[E1000_LOCATE(E1000_TCTL) ] |= E1000_TCTL_EN | E1000_TCTL_PSP | (E1000_TCTL_CT & (0x10 << 4)) | (E1000_TCTL_COLD & (0x40 << 12));
	
	//4. {IPGT,IPGR1,IPGR2}分别为 {10,8,6}
	e1000[E1000_LOCATE(E1000_TIPG)] = E1000_TIPG_IPGT | (E1000_TIPG_IPGR1 << E1000_TIPG_IPGR1_SHIFT) | (E1000_TIPG_IPGR2 << E1000_TIPG_IPGR2_SHIFT);
}

int 
e1000_transmit(void *addr, size_t len)
{
	size_t tdt = e1000[E1000_LOCATE(E1000_TDT)] ;//TDT寄存器中存的是索引！！！
	struct e1000_tx_desc * tail_desc = &e1000_tx_desc_array[tdt];
	
	if( !(tail_desc->status & E1000_TXD_STATUS_DD) ) return -1;//传输队列已满
	
	memcpy(e1000_tx_buffer[tdt] , addr, len);
	
	tail_desc->length = (uint16_t )len;
	tail_desc->status=0;
	//tail_desc->status &= (~E1000_TXD_STATUS_DD);//清零DD位。
	
	e1000[E1000_LOCATE(E1000_TDT)]= (tdt+1) % TX_DESC_ARRAY_SIZE;
	
	return 0;
}

/*接收*/
void
e1000_receive_init()
{
	//接收地址寄存器
	e1000[E1000_LOCATE(E1000_RA)] = QEMU_DEFAULT_MAC_LOW;
	e1000[E1000_LOCATE(E1000_RA) + 1] = QEMU_DEFAULT_MAC_HIGH | E1000_RAH_AV;
	
	//处理描述符
	memset(e1000_rx_desc_array, 0, sizeof(e1000_rx_desc_array) );
	for (int i = 0; i < RX_DESC_ARRAY_SIZE; i++) {
		e1000_rx_desc_array[i].addr = PADDR(e1000_rx_buffer[i]);
	}
	
	e1000[E1000_LOCATE(E1000_RDBAL)] = PADDR(e1000_rx_desc_array);
	e1000[E1000_LOCATE(E1000_RDBAH)] = 0;
	e1000[E1000_LOCATE(E1000_RDLEN)] = sizeof(e1000_rx_desc_array);
	e1000[E1000_LOCATE(E1000_RDH)] = 0;
	e1000[E1000_LOCATE(E1000_RDT)] = RX_DESC_ARRAY_SIZE-1;//尾指针的下一个才是真尾巴，即真正软件要把它复制过来的数据包
	
	e1000[E1000_LOCATE(E1000_RCTL)] = E1000_RCTL_EN | E1000_RCTL_BAM  |  E1000_RCTL_SZ_2048 | E1000_RCTL_SECRC;	
}


int 
e1000_receive(void *addr, size_t *len)//要把长度取出来，后面struct jif_pkt需要记录长度的
{
	size_t tail = e1000[E1000_LOCATE(E1000_RDT)];
	size_t next = (tail+1)% RX_DESC_ARRAY_SIZE;//真尾巴
	
	if( !(e1000_rx_desc_array[next].status & E1000_RXD_STAT_DD) ){
		return -1;//队列空
	}
	
	*len=e1000_rx_desc_array[next].length;
	memcpy(addr, e1000_rx_buffer[next] , *len);
	
	e1000_rx_desc_array[next].status &= ~E1000_RXD_STAT_DD;//清零DD位
	e1000[E1000_LOCATE(E1000_RDT)] = next;
	
	return 0;
}




