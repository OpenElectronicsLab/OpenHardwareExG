##
## This file was part of the libopencm3 project, and has been
## modified for inclusion in the eeg-mouse project.
##
## Copyright (C) 2009 Uwe Hermann <uwe@hermann-uwe.de>
## Copyright (C) 2010 Piotr Esden-Tempski <piotr@esden.net>
## Copyright (C) 2011 Fergus Noble <fergusnoble@gmail.com>
## Copyright (C) 2012 Kendrick Shaw <kms15@case.edu>
##
## This library is free software: you can redistribute it and/or modify
## it under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This library is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this library.  If not, see <http://www.gnu.org/licenses/>.
##

BINARY = eeg-mouse-stm32f4
LDSCRIPT = stm32f4-discovery.ld

PREFIX	?= arm-none-eabi
# PREFIX		?= arm-elf
CC		= $(PREFIX)-gcc
LD		= $(PREFIX)-gcc
OBJCOPY		= $(PREFIX)-objcopy
OBJDUMP		= $(PREFIX)-objdump
GDB		= $(PREFIX)-gdb
# Uncomment this line if you want to use the installed (not local) library.
#TOOLCHAIN_DIR := $(shell dirname `which $(CC)`)/../$(PREFIX)
#TOOLCHAIN_DIR   = ../../../../..
TOOLCHAIN_DIR   = ./libopencm3
CFLAGS		+= -Os -g -Wall -Wextra -I$(TOOLCHAIN_DIR)/include \
		   -fno-common -mcpu=cortex-m4 -mthumb -msoft-float -MD -DSTM32F4
LDSCRIPT	?= $(BINARY).ld
LDFLAGS		+= -lc -lnosys -L$(TOOLCHAIN_DIR)/lib \
			 -L$(TOOLCHAIN_DIR)/lib/stm32/f4 \
		   -T$(LDSCRIPT) -nostartfiles -Wl,--gc-sections \
		   -mthumb -mcpu=cortex-m4 -march=armv7 -mfix-cortex-m3-ldrd -msoft-float
OBJS		+= $(BINARY).o util.o

OOCD		?= openocd
OOCD_INTERFACE	?= flossjtag
OOCD_BOARD	?= olimex_stm32_h103
# Black magic probe specific variables
# Set the BMP_PORT to a serial port and then BMP is used for flashing
BMP_PORT        ?=

# Be silent per default, but 'make V=1' will show all compiler calls.
#ifneq ($(V),1)
#Q := @
#NULL := 2>/dev/null
#else
#LDFLAGS += -Wl,--print-gc-sections
#endif

.SUFFIXES: .elf .bin .hex .srec .list .images
.SECONDEXPANSION:
.SECONDARY:

all: images

images: $(BINARY).images
flash: $(BINARY).flash

eeg-mouse-stm32f.o: eeg-mouse-stm32f4.c eeg-mouse-usb-descriptors.h

%.images: %.bin %.hex %.srec %.list
	@#echo "*** $* images generated ***"

%.bin: %.elf
	@#printf "  OBJCOPY $(*).bin\n"
	$(Q)$(OBJCOPY) -Obinary $(*).elf $(*).bin

%.hex: %.elf
	@#printf "  OBJCOPY $(*).hex\n"
	$(Q)$(OBJCOPY) -Oihex $(*).elf $(*).hex

%.srec: %.elf
	@#printf "  OBJCOPY $(*).srec\n"
	$(Q)$(OBJCOPY) -Osrec $(*).elf $(*).srec

%.list: %.elf
	@#printf "  OBJDUMP $(*).list\n"
	$(Q)$(OBJDUMP) -S $(*).elf > $(*).list

%.elf: $(OBJS) $(LDSCRIPT) $(TOOLCHAIN_DIR)/lib/stm32/f4/libopencm3_stm32f4.a
	@#printf "  LD      $(subst $(shell pwd)/,,$(@))\n"
	$(Q)$(LD) -o $(*).elf $(OBJS) -lopencm3_stm32f4 $(LDFLAGS)

%.o: %.c Makefile
	@#printf "  CC      $(subst $(shell pwd)/,,$(@))\n"
	$(Q)$(CC) $(CFLAGS) -o $@ -c $<

$(TOOLCHAIN_DIR)/lib/stm32/f4/libopencm3_stm32f4.a : $(TOOLCHAIN_DIR)/Makefile
	$(MAKE) -C $(TOOLCHAIN_DIR) lib

clean:
	$(Q)rm -f *.o
	$(Q)rm -f *.d
	$(Q)rm -f *.elf
	$(Q)rm -f *.bin
	$(Q)rm -f *.hex
	$(Q)rm -f *.srec
	$(Q)rm -f *.list
	$(MAKE) -C $(TOOLCHAIN_DIR) clean

%.flash: %.bin
	st-flash write $< 0x8000000

.PHONY: images clean

-include $(OBJS:.o=.d)

