#include "def.h"

#define NFCONF   0x4E000000
#define NFCONT   0x4E000004
#define NFCMD    0x4E000008
#define NFADDR   0x4E00000C
#define NFDATA   0x4E000010
#define NFMECCD0 0x4E000014
#define NFMECCD1 0x4E000018
#define NFSECCD  0x4E00001C
#define NFSTAT   0x4E000020
#define NFESTAT0 0x4E000024
#define NFESTAT1 0x4E000028
#define NFMECC0  0x4E00002C
#define NFMECC1  0x4E000030
#define NFSECC   0x4E000034
#define NFSBLK   0x4E000038
#define NFEBLK   0x4E00003C

#define TACLS   2
#define TWRPH0  6
#define TWRPH1  2

static void nand_select(bool flag)
{
	int i;

	if(flag == TRUE)
	{
		*(vu32 *)NFCONT &= ~(1 << 1);
	}
	else if(flag == FALSE)
	{
		*(vu32 *)NFCONT |= (1 << 1);
	}
	for(i = 0; i < 10; i ++);
}

static void nand_send_cmd(u8 cmd)
{
	*(vu32 *)NFCMD = cmd;
}

static void nand_send_addr(u32 addr)
{
	u32 i, col, page;
	vu8 *p = (vu8 *)NFADDR;

	col = addr & (2048 - 1);
	page = addr / 2048;

	*p = col & 0xff; /* Column Address A0~A7 */
	for(i = 0; i < 10; i ++);
	*p = (col >> 8) & 0x0f; /* Column Address A8~A11 */
	for(i = 0; i < 10; i ++);
	*p = page & 0xff; /* Row Address A12~A19 */
	for(i = 0; i < 10; i ++);
	*p = (page >> 8) & 0xff; /* Row Address A20~A27 */
	for(i = 0; i < 10; i ++);
	*p = (page >> 16) & 0x03; /* Row Address A28~A29 */
	for(i = 0; i < 10; i ++);
}

static void nand_wati_idle(void)
{
	int i;

	while(!((*(vu32 *)NFSTAT) & 1))
	{
		for(i = 0; i < 10; i ++);
	}
}

static u8 nand_read_byte_raw(void)
{
	return *(vu8 *)NFDATA;
}

static void nand_reset(void)
{
	nand_select(TRUE);
	nand_send_cmd(0xFF);
	nand_wati_idle();
	nand_select(FALSE);
}

void nand_boot_init(void)
{
	*(vu32 *)NFCONF = (TACLS << 12) | (TWRPH0 << 8) | (TWRPH1 << 4);
	*(vu32 *)NFCONT = (1 << 4) | (1 << 1) | (1 << 0);
	nand_reset();
}

/**
 * copy nandflash's code to sdram
 * @param addr : the nandflash address
 * @param buf  : the buffer in sdram or sram to copy to
 * @param page : how many pages to copy
 */
void nand_boot_copy2sdram(u32 addr, u8 *buf, u32 pages)
{
	u32 i, j;

	nand_select(TRUE);

	for(i = 0; i < pages; i ++)
	{
		for(j = 0; j < 2048; j ++)
		{
			nand_send_cmd(0);
			nand_send_addr(addr ++);
			nand_send_cmd(0x30);
			nand_wati_idle();
			*buf = nand_read_byte_raw();
			buf ++;
		}
	}

	nand_select(FALSE);
}
