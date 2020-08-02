#include "def.h"

#define CLKCON   0x4C00000C
#define GPHCON   0x56000070
#define GPHUP    0x56000078
#define INTMSK   0X4A000008

#define ULCON0   0x50000000
#define UCON0    0x50000004
#define UFCON0   0x50000008
#define UMCON0   0x5000000C
#define UTRSTAT0 0x50000010
#define UERSTAT0 0x50000014
#define UFSTAT0  0x50000018
#define UMSTAT0  0x5000001C
#define UTXH0    0x50000020
#define URXH0    0x50000024
#define UBRDIV0  0x50000028
#define ULCON1   0x50004000
#define UCON1    0x50004004
#define UFCON1   0x50004008
#define UMCON1   0x5000400C
#define UTRSTAT1 0x50004010
#define UERSTAT1 0x50004014
#define UFSTAT1  0x50004018
#define UMSTAT1  0x5000401C
#define UTXH1    0x50004020
#define URXH1    0x50004024
#define UBRDIV1  0x50004028
#define ULCON2   0x50008000
#define UCON2    0x50008004
#define UFCON2   0x50008008
#define UTRSTAT2 0x50008010
#define UERSTAT2 0x50008014
#define UFSTAT2  0x50008018
#define UTXH2    0x50008020
#define URXH2    0x50008024
#define UBRDIV2  0x50008028

#define PCLK	 50000000
#define BAUDRATE 115200

void uart0_putc(u8 sendbyte);
void uart0_puts(const char *p);

void uart0_init(void)
{
	u32 tmp;

	// enable uart clock
	tmp = *(vu32 *)CLKCON;
	tmp |= 1 << 10;
	*(vu32 *)CLKCON = tmp;

	// set GPH2 multiplexed as TX0
	tmp = *(vu32 *)GPHCON;
	tmp &= ~((0x3 & 0x3) << (2 * 2));
	tmp |= (0x2 & 0x3) << (2 * 2);
	*(vu32 *)GPHCON = tmp;

	// set GPH3 multiplexed as RX0
	tmp = *(vu32 *)GPHCON;
	tmp &= ~((0x3 & 0x3) << (3 * 2));
	tmp |= (0x2 & 0x3) << (3 * 2);
	*(vu32 *)GPHCON = tmp;

	// set GPH2 pull up
	tmp = *(vu32 *)GPHUP;
	tmp &= ~(1 << 2);
	*(vu32 *)GPHUP = tmp;

	// set GPH3 pull up
	tmp = *(vu32 *)GPHUP;
	tmp &= ~(1 << 3);
	*(vu32 *)GPHUP = tmp;

	tmp = 0;
	tmp |= (3 & 0x3) << 0;    // Normal mode operation
	tmp |= (0 & 0x1) << 2;    // No parity
	tmp |= (0 & 0x7) << 3;    // One stop bit per frame
	tmp |= (0 & 0x1) << 6;    // 8-bits data
	*(vu32 *)ULCON0 = tmp;

	tmp = 0;
	tmp |= (1 & 0x3) << 0;    // Rx Interrupt request or polling mode
	tmp |= (1 & 0x3) << 2;    // Tx Interrupt request or polling mode
	tmp |= (0 & 0x1) << 4;    // Don't send break signal while transmitting
	tmp |= (0 & 0x1) << 5;    // Don't use loopback mode
	tmp |= (1 & 0x1) << 6;    // Generate receive error status interrupt
	tmp |= (1 & 0x1) << 7;    // Disable Rx time out interrupt when UART FIFO is enabled. The interrupt is a receive interrupt
	tmp |= (0 & 0x1) << 8;    // Interrupt is requested the instant Rx buffer receivesthe data in Non-FIFO mode or reaches Rx FIFO Trigger Level inFIFO mode
	tmp |= (0 & 0x1) << 9;    // Interrupt is requested as soon as the Tx bufferbecomes empty in Non-FIFO mode or reaches Tx FIFO TriggerLevel in FIFO mode
	tmp |= (0 & 0x3) << 10;   // Select PCLK as the source clock of UART0
	*(vu32 *)UCON0 = tmp;

	// UBRDIVn = (int)( UART clock / ( buad rate x 16) ) –1
	*(vu32 *)UBRDIV0 = (PCLK * 10 / BAUDRATE / 16 % 10) >= 5
	                   ? (PCLK / BAUDRATE / 16 + 1 - 1)
					   : (PCLK / BAUDRATE / 16 - 1);

	*(vu32 *)INTMSK |= 1 << 28;   // make INT_UART0 Irq disable
}

void uart0_putc(u8 sendbyte)
{
	while(!((*(vu32 *)UTRSTAT0) & (1 << 2)));
	*(vu8 *)UTXH0 = sendbyte;
}

void uart0_puts(const char *p)
{
	while(*p) {
		uart0_putc(*p);
		p++;
	}
}
