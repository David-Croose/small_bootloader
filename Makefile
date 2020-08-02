TARGET = s3c2440_preboot
CROSS_COMPILER ?= arm-linux-
CFLAGS = -Wall -O0

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

all: $(OBJ)
	@$(LD) -Tlink.lds $(OBJ) -o $(TARGET_ELF)
	@$(OBJCOPY) -O binary -S $(TARGET_ELF) $(TARGET_BIN)
	@$(OBJDUMP) -D -m arm $(TARGET_ELF) > $(TARGET_DIS)
	@echo "$(TARGET_BIN) is ready"

%.o: %.c
	@$(CC) $(CFLAGS) -o $@ -c $<
	@echo "  CC    "$<

%.o: %.S
	@$(AS) $(CFLAGS) -o $@ -c $<
	@echo "  AS    "$<

clean:
	@rm -f $(TARGET_ELF) $(TARGET_DIS) $(TARGET_BIN) $(OBJ)

.PHONY: clean
