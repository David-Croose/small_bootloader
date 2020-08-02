/**
 * File:s3c2440_start.S
 * Author:Sam Hotiky
 * Description:boot routine for JZ2440 board(CPU:S3C2440A,400MHz,ARM920T;SDRAM:64MB;NANDFLASH:256MB;NORFLASH:2MB;etc
 */

/**
 * watch dog timer register
 */
#define  WTCON          0x53000000

/**
 * bank6 registers for SDRAM
 */
#define  SDRAMCON       0x48000000
#define  BANKCON6       0x4800001C
#define  RFSHCON        0x48000024
#define  BKSZCON        0x48000028
#define  MRSR6CON       0x4800002C

/**
 * clock registers
 */
#define  CLKDIV         0x4C000014
#define  MPLLCON        0x4C000004

#define CONFIG_APP_ADDR	0x31400000

.text
.section .boot
.global _start
_start:
	b   Reset
	b   HandleUndef
	b   HandleSWI
	b   HandlePrefetchAbort
	b   HandleDataAbort
	b   HandleNotUsed
	b   HandleIRQ
	b   HandleFIQ

Reset:
	/**
	 * disable the watch dog timer
	 */
	ldr		r0, =0x53000000
	mov		r1, #0
	str		r1, [r0]

	/**
	 * make the clock run in 400MHz
	 */
	ldr		r0, =CLKDIV	
	mov		r1, #5
	str		r1, [r0]
	/***************************/
	mrc		p15, 0, r1, c1, c0, 0
	orr		r1, r1, #0xC0000000
	mcr		p15, 0, r1, c1, c0, 0
	/***************************/
	ldr		r0, =MPLLCON	
	ldr		r1, =0x5c011
	str		r1, [r0]

	/**
	 * enable the I,D cache
	 */
	mrc		p15, 0, r0, c1, c0, 0
	orr		r0, r0, #0x0004
	orr		r0, r0, #0x1000
	mcr		p15, 0, r0, c1, c0, 0

	/**
	 * setup the SDRAM
	 */
	ldr		r0, =SDRAMCON
	ldr		r1, =0x22011110
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000700
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000700
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000700
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000700
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000700
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000700
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00018005
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00018005
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x008C07A3
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x000000B1
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000030
	str		r1, [r0]
	add		r0, r0, #4
	ldr		r1, =0x00000030
	str		r1, [r0]
	add		r0, r0, #4

	/**
	 * set stack
	 */
	ldr		sp, =0x34000000

	bl		uart0_init
	ldr		r0, =print1
	bl		uart0_puts

	/**
	 * copy nandflash's app code to sdram
	 */
	ldr		sp, =0x34000000
	bl		nand_boot_init
	ldr		r0, =4096
	ldr		r1, =CONFIG_APP_ADDR
	ldr		r2, =512			/* pages = image_bytes / bytes_per_page = 1MB / 2048 */
	bl		nand_boot_copy2sdram

	/**
	 * jump to app()
	 */
	ldr		r0, =print2
	bl		uart0_puts
	ldr		lr, =halt_loop
	ldr		pc, =CONFIG_APP_ADDR
halt_loop:
	b		halt_loop

HandleUndef:
    b		.

HandleSWI:
    b		.

HandlePrefetchAbort:
    b		.

HandleDataAbort:
    b		.

HandleNotUsed:
    b		.

HandleIRQ:
	b		.

HandleFIQ:
    b		.

print1:
	.string "\r\ncopying image from NandFlash to SDRAM...\r\n"

print2:
	.string "now jumping to app\r\n"
