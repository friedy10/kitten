/*
 * CCI Driver to communicate with s5k4ec cameras
 * 2022, Friedrich Doku <frd20@pitt.edu>
 */
#include "cci.h"

unsigned int fifo_last_pt;

extern struct csi csi;

#define csi_cci_udelay(x) friedy_udelay(x)

void
friedy_udelay(uint64_t s){
    uint64_t i = 0;
    while(i < (s * 1000)){
            i++;
    }
}
inline
uint32_t vfe_reg_readl(volatile void* addr)
{
    return __csi_read32(addr);
}

inline
void vfe_reg_writel(volatile void*addr, uint32_t reg_value)
{
    __csi_write32(addr, reg_value);
}

inline
void vfe_reg_clr(volatile void* reg, uint32_t clr_bits)
{
	uint32_t v = vfe_reg_readl(reg);
	vfe_reg_writel(reg, v & ~clr_bits);
}

inline
void vfe_reg_set(volatile void* reg, uint32_t set_bits)
{
	uint32_t v = vfe_reg_readl(reg);
	vfe_reg_writel(reg, v | set_bits);
}

//clr_bits for mask
inline
void vfe_reg_clr_set(volatile void __iomem * reg, uint32_t clr_bits, uint32_t set_bits)
{
	uint32_t v = vfe_reg_readl(reg);
	vfe_reg_writel(reg, (v & ~clr_bits) | (set_bits & clr_bits));
}

void csi_cci_enable()
{
	vfe_reg_set(CCI_CTRL_OFF, 1 << CCI_CTRL_CCI_EN);
}

void csi_cci_disable()
{
	vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_CCI_EN);
}

void csi_cci_reset()
{
	vfe_reg_set(CCI_CTRL_OFF, 1 << CCI_CTRL_SOFT_RESET);
	vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_SOFT_RESET);
}

void csi_cci_set_clk_div(unsigned char *div_coef)
{
	vfe_reg_clr_set(CCI_BUS_CTRL_OFF , CCI_BUS_CTRL_CLK_M_MASK, 
						div_coef[0] << CCI_BUS_CTRL_CLK_M);
	vfe_reg_clr_set(CCI_BUS_CTRL_OFF , CCI_BUS_CTRL_CLK_N_MASK, 
						div_coef[1] << CCI_BUS_CTRL_CLK_N);
}

//interval unit in 40 scl cycles
void csi_cci_set_pkt_interval( unsigned char interval)
{
	vfe_reg_clr_set(CCI_CFG_OFF , CCI_CFG_INTERVAL_MASK, 
					interval << CCI_CFG_INTERVAL);
}

//timeout unit in scl cycle
void csi_cci_set_ack_timeout( unsigned char to_val)
{
	vfe_reg_clr_set(CCI_CFG_OFF , CCI_CFG_TIMEOUT_N_MASK, 
				to_val << CCI_CFG_TIMEOUT_N);
}

//trig delay unit in scl cycle
void csi_cci_set_trig_dly( unsigned int dly)
{
	if(dly == 0) {	
		vfe_reg_clr(CCI_BUS_CTRL_OFF, 1 << CCI_BUS_CTRL_DLY_TRIG);
	} else {
		vfe_reg_set(CCI_BUS_CTRL_OFF, 1 << CCI_BUS_CTRL_DLY_TRIG);
		vfe_reg_clr_set(CCI_BUS_CTRL_OFF , CCI_BUS_CTRL_DLY_CYC_MASK, 
				dly << CCI_BUS_CTRL_DLY_CYC);
	}
}

void csi_cci_trans_start( enum cci_trans_mode trans_mode)
{
	fifo_last_pt = 0;
	switch(trans_mode)
	{
		case SINGLE:
			vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_REPEAT_TRAN);
			vfe_reg_set(CCI_CTRL_OFF, 1 << CCI_CTRL_SINGLE_TRAN);
			break;
		case REPEAT:
			vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_SINGLE_TRAN);
			vfe_reg_set(CCI_CTRL_OFF, 1 << CCI_CTRL_REPEAT_TRAN);
			break;
		default:
			vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_SINGLE_TRAN);
			vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_REPEAT_TRAN);
			break;
	}
}

unsigned int csi_cci_get_trans_done()
{
	unsigned int reg_val, single_tran;
	reg_val = vfe_reg_readl(CCI_CTRL_OFF);
	single_tran = (reg_val & (1 << CCI_CTRL_SINGLE_TRAN) );
	if(single_tran == 0)
		return 0;
	else
		return 1;
}

void csi_cci_set_bus_fmt( struct cci_bus_fmt *bus_fmt)
{
	if(0 == bus_fmt->rs_mode)
		vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_RESTART_MODE);
	else
		vfe_reg_set(CCI_CTRL_OFF, 1 << CCI_CTRL_RESTART_MODE);

	if(0 == bus_fmt->rs_start)
		vfe_reg_clr(CCI_CTRL_OFF, 1 << CCI_CTRL_READ_TRAN_MODE);
	else
		vfe_reg_set(CCI_CTRL_OFF, 1 << CCI_CTRL_READ_TRAN_MODE);

	vfe_reg_clr_set(CCI_FMT_OFF , CCI_FMT_SLV_ID_MASK, 
			bus_fmt->saddr_7bit << CCI_FMT_SLV_ID);
	vfe_reg_clr_set(CCI_FMT_OFF , CCI_FMT_CMD_MASK, 
			bus_fmt->wr_flag << CCI_FMT_CMD);
	vfe_reg_clr_set(CCI_FMT_OFF , CCI_FMT_ADDR_BYTE_MASK, 
			bus_fmt->addr_len << CCI_FMT_ADDR_BYTE);
	vfe_reg_clr_set(CCI_FMT_OFF , CCI_FMT_DATA_BYTE_MASK, 
			bus_fmt->data_len << CCI_FMT_DATA_BYTE);
}

void csi_cci_set_tx_buf_mode( struct cci_tx_buf *tx_buf_mode)
{
	vfe_reg_clr_set(CCI_CFG_OFF , CCI_CFG_SRC_SEL_MASK, 
				tx_buf_mode->buf_src << CCI_CFG_SRC_SEL);
	vfe_reg_clr_set(CCI_CFG_OFF , CCI_CFG_PACKET_MODE_MASK, 
				tx_buf_mode->pkt_mode << CCI_CFG_PACKET_MODE);
	vfe_reg_clr_set(CCI_FMT_OFF , CCI_FMT_PACKET_CNT_MASK, 
				tx_buf_mode->pkt_cnt << CCI_FMT_PACKET_CNT);
}

void csi_cci_fifo_pt_reset()
{
	fifo_last_pt = 0;
}

void csi_cci_fifo_pt_add( unsigned int byte_cnt)
{
	fifo_last_pt += byte_cnt;
}

void csi_cci_fifo_pt_sub( unsigned int byte_cnt)
{
	fifo_last_pt -= byte_cnt;
}

static void cci_wr_tx_buf( unsigned int byte_index, unsigned char value)
{
	unsigned int index_remain,index_dw_align,tmp;
	index_remain = (byte_index)%4;
	index_dw_align = (byte_index)/4;

	tmp = vfe_reg_readl(CCI_FIFO_ACC_OFF + 4*index_dw_align);
	tmp &= ~(0xff << (index_remain<<3));
	tmp |= value << (index_remain<<3);
	vfe_reg_writel(CCI_FIFO_ACC_OFF + 4*index_dw_align, tmp);
}

static void cci_rd_tx_buf( unsigned int byte_index, unsigned char *value)
{
	unsigned int index_remain,index_dw_align,tmp;
	index_remain = (byte_index)%4;
	index_dw_align = (byte_index)/4;
	tmp = vfe_reg_readl(CCI_FIFO_ACC_OFF + 4*index_dw_align);
	*value = (tmp & ( 0xff << (index_remain<<3) )) >> (index_remain<<3);
}

void csi_cci_wr_tx_buf( unsigned char *buf, unsigned int byte_cnt)
{
	unsigned int i;
	cci_print_info();
	for(i = 0; i < byte_cnt; i++,fifo_last_pt++)
	{
		cci_wr_tx_buf(fifo_last_pt, buf[i]);
	}
}

void csi_cci_rd_tx_buf( unsigned char *buf, unsigned int byte_cnt)
{
	unsigned int i;
	cci_print_info();
	for(i = 0; i < byte_cnt; i++,fifo_last_pt++)
	{
		cci_rd_tx_buf(fifo_last_pt, &buf[i]);
	}
}

void csi_cci_set_trig_mode( struct cci_tx_trig *tx_trig_mode)
{
	vfe_reg_clr_set(CCI_CFG_OFF , CCI_CFG_TRIG_MODE_MASK, 
				tx_trig_mode->trig_src << CCI_CFG_TRIG_MODE);
	vfe_reg_clr_set(CCI_CFG_OFF , CCI_CFG_CSI_TRIG_MASK, 
				tx_trig_mode->trig_con << CCI_CFG_CSI_TRIG);
}

void csi_cci_set_trig_line_cnt( unsigned int line_cnt)
{
	vfe_reg_clr_set(CCI_LC_TRIG_OFF , CCI_LC_TRIG_LN_CNT_MASK, 
			line_cnt << CCI_LC_TRIG_LN_CNT);
}

void cci_int_enable( enum cci_int_sel interrupt)
{
	vfe_reg_set(CCI_INT_CTRL_OFF, ((interrupt<<16)&0xffff0000));
}

void cci_int_disable( enum cci_int_sel interrupt)
{
	vfe_reg_clr(CCI_INT_CTRL_OFF, ((interrupt<<16)&0xffff0000));
}

void inline cci_int_get_status( struct cci_int_status *status)
{
	unsigned int reg_val = vfe_reg_readl(CCI_INT_CTRL_OFF);
	status->complete = (reg_val >> CCI_INT_CTRL_S_TRAN_COM_PD) & 0x1;
	status->error	 =  (reg_val >> CCI_INT_CTRL_S_TRAN_ERR_PD) & 0x1;
}

void inline cci_int_clear_status( enum cci_int_sel interrupt)
{
	vfe_reg_clr(CCI_INT_CTRL_OFF, 0xffff << 0);
	vfe_reg_set(CCI_INT_CTRL_OFF , interrupt << 0);
}

enum cci_bus_status inline cci_get_bus_status()
{
	unsigned int reg_val = vfe_reg_readl(CCI_CTRL_OFF);
	return (reg_val >> CCI_CTRL_CCI_STA)&0xff;
}

void cci_get_line_status( struct cci_line_status *status)
{
	unsigned int reg_val = vfe_reg_readl(CCI_BUS_CTRL_OFF);
	status->cci_sck = (reg_val >> CCI_BUS_CTRL_SCL_STA)&0x1;
	status->cci_sda = (reg_val >> CCI_BUS_CTRL_SDA_STA)&0x1;
}

void cci_pad_en()
{
	vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SDA_PEN);
	vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_PEN);
}

void cci_stop()
{
	vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_MOE);
	vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SDA_MOE);
	vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_MOV);
	csi_cci_udelay(5);
	vfe_reg_clr(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SDA_MOV);
	csi_cci_udelay(5);
	vfe_reg_clr(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_MOE);
	vfe_reg_clr(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SDA_MOE);
}

void cci_sck_cycles( unsigned int cycle_times)
{
	vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_MOE);
	vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SDA_MOE);
	while(cycle_times)
	{
		vfe_reg_set(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_MOV);
		csi_cci_udelay(5);
		vfe_reg_clr(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_MOV);
		csi_cci_udelay(5);
		cycle_times--;
	}
	vfe_reg_clr(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SCL_MOE);
	vfe_reg_clr(CCI_BUS_CTRL_OFF , 1 << CCI_BUS_CTRL_SDA_MOE);
}

void cci_print_info()
{
	unsigned int reg_val = 0, i;
	printk("Print cci regs: \n");
	for(i=0; i<32; i+=4)
	{
		reg_val = vfe_reg_readl(i);
		printk("0x%x = 0x%x\n",i, reg_val);
	}
}

/*
void
cci_print_info()
{
	unsigned int reg_val = 0, i;
	printk("Print cci regs: \n");
	for(i=0; i<32; i+=4)
	{
		reg_val = __csi_read32(CSI_BASE_ADDRESS + i);
		printk("0x%x = 0x%x\n",i, reg_val);
	}
}*/
