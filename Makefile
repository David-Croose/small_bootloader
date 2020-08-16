TARGET = s3c2440_preboot
CROSS_COMPILER ?= arm-linux-
CFLAGS = -Wall -O0
CONFILE = config.h

SRC += nand_boot.c uart0.c s3c2440_startup.S

AS      = $(CROSS_COMPILER)gcc
CC      = $(CROSS_COMPILER)gcc
LD      = $(CROSS_COMPILER)ld
NM      = $(CROSS_COMPILER)nm
SIZE    = $(CROSS_COMPILER)size
OBJCOPY = $(CROSS_COMPILER)objcopy
OBJDUMP = $(CROSS_COMPILER)objdump

TARGET_ELF = $(TARGET).elf
TARGET_DIS = $(TARGET).dis
TARGET_BIN = $(TARGET).bin

OBJ = $(patsubst %.c, %.o, $(patsubst %.S, %.o, $(SRC)))

all: $(CONFILE) $(OBJ) Makefile link.lds
	@$(LD) -Tlink.lds $(OBJ) -o $(TARGET_ELF)
	@$(OBJCOPY) -O binary -S $(TARGET_ELF) $(TARGET_BIN)
	@$(OBJDUMP) -D -m arm $(TARGET_ELF) > $(TARGET_DIS)
	@echo "$(TARGET_BIN) is ready"

%.o: %.c
	@$(CC) $(CFLAGS) -o $@ -c $<
	@echo "  CC	"$<

%.o: %.S
	@$(AS) $(CFLAGS) -o $@ -c $<
	@echo "  AS	"$<

$(CONFILE):
	@echo "  GEN	"$@
	$(shell echo '#define CONFIG_APP_ADDR 0x30000000' > $@)
	$(shell echo '#define CONFIG_COPY_BYTES (256 * 1024)' >> $@)

clean:
	@rm -f $(TARGET_ELF) $(TARGET_DIS) $(TARGET_BIN) $(OBJ)

mrproper: clean
	@rm -f $(CONFILE)

help:
	@echo "How to build:"
	@echo "	make [CROSS_COMPILER=<your cross compiler prefix>]"
	@echo "	e.g: make CROSS_COMPILER=arm-linux-"
	@ECHO "How to burn:"
	@echo "	1. push the board's boot switch button to nor boot then power up."
	@echo "	2. enter backspace in your serial terminal to let u-boot stay in command line."
	@echo "	3. enter 'n' to u-boot menu in your serial terminal."
	@echo "	4. start dnw, USB Port--->Transmit, don't need to care about the Configuration."
	@echo "	5. push the board's boot switch button to nand boot then repower up. you may need to wait for a while for the board's booting."
	@echo "	6. done."

.PHONY: clean help mrproper
