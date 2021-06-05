RPI_VERSION ?= 0

BOOTMNT ?= boot

#ARMGNU ?= aarch64-linux-gnu
ARMGNU ?= arm-none-eabi

ifeq ($(RPI_VERSION), 4)
ARCH = -march=armv8-a
KERNEL_FILE=kernel8
endif
ifeq ($(RPI_VERSION), 3)
ARCH = -march=armv8
KERNEL_FILE=kernel8
else
MCPU = -mcpu=arm1176jzf-s
KERNEL_FILE=kernel
# -mcpu=arm1176jzf-s
endif

COPS = -DRPI_VERSION=$(RPI_VERSION) $(MCPU) -fpic $(ARCH) -Wall  -nostdlib -nostartfiles -ffreestanding \
	    -Iinclude -mgeneral-regs-only

ASMOPS = -Iinclude

BUILD_DIR = build
SRC_DIR = src

all: kernel.img

# Run in VM, also testing with bootcode (on real hardware, you ought to use latest bootcode 
#   and on VM, this method of starting isn't fully supported as VM fakes the bootcode)
#	With --monitor statement, in another terminal window, you can connect to emulator with 'telnet localhost 1235' 
vmpi0:
	qemu-system-arm -m 512 --monitor telnet:127.0.0.1:1235,server,nowait -M raspi0,firmware=kernel.img  -serial stdio

# A well supported way to test your kernel in VM
# 	run 'gdb build/kernel.elf' in another terminal window and issue command 'target remote :1234'
vmpi0d:
	qemu-system-arm -m 512 --monitor telnet:127.0.0.1:1235,server,nowait -M raspi0 -kernel build/kernel.elf -serial stdio -S -s

# Run in VM, also testing with bootcode (on real hardware, you ought to use latest bootcode 
#   and on VM, this method of starting isn't fully supported as VM fakes the bootcode)
#	With --monitor statement, in another terminal window, you can connect to emulator with 'telnet localhost 1235' 
vmpi0:
	qemu-system-arm -m 512 --monitor telnet:127.0.0.1:1235,server,nowait -M raspi0,firmware=kernel.img  -serial stdio

# A well supported way to test your kernel in VM
# 	run 'gdb build/kernel.elf' in another terminal window and issue command 'target remote :1234'
vmpi0d:
	qemu-system-arm -m 512 --monitor telnet:127.0.0.1:1235,server,nowait -M raspi0 -kernel build/kernel.elf -serial stdio -S -s

# A variant to use if using mini-uart -- this is defined a second serial port in qemu
#
vmpi0mini:
	qemu-system-arm -m 512 --monitor telnet:127.0.0.1:1235,server,nowait -M raspi0 -kernel build/kernel.elf -serial null -serial stdio 

clean:
	rm -rf $(BUILD_DIR) *.img 


$(BUILD_DIR)/linker_precomp.ld: $(SRC_DIR)/linker.ld
	mkdir -p $(@D)
	$(ARMGNU)-gcc -E -x c $< | grep -v '^#' > $@

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc  -std=gnu99 $(COPS) -MMD -c $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

kernel.img: $(BUILD_DIR)/linker_precomp.ld $(OBJ_FILES)
	@echo "Building for RPI $(value RPI_VERSION)"
	@echo "Deploy to $(value BOOTMNT)"
	@echo ""
	$(ARMGNU)-ld -T $(BUILD_DIR)/linker_precomp.ld -o $(BUILD_DIR)/kernel.elf $(OBJ_FILES)
	$(ARMGNU)-objcopy $(BUILD_DIR)/kernel.elf -O binary kernel.img
ifeq ($(RPI_VERSION), 4)
	cp kernel.img $(BOOTMNT)/kernel-rpi4.img
else
	cp kernel.img $(BOOTMNT)/
endif
	cp config.txt $(BOOTMNT)/
	sync
