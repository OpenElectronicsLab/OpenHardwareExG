# Makefile for building and flashing an Arduino Due

# Copyright (C) 2013, 2014 Kendrick Shaw <kms15@case.edu>
# Copyright (C) 2013, 2014 Eric Herman <eric@freesa.org>
# Copyright (C) 2013, 2014 Ace Medlock <ace.medlock@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# the name of the main file and sources to be used
APPNAME=OpenHardwareExG_firmware

SRC_DIR=.

# manual dependencies
APP_OBJS=$(APPNAME).o util.o exg_lead_leds.o

# set ARDUINO_DUE_USB_PROGRAMMING=1 if you plan to communicate to the
# firmware running on the ardiuno DUE using the "programming" port
# (not the "native" port)
#
# set OPENHARDWAREEXG_HARDWARE_VERSION=0 for the rev0 board
# see: https://github.com/OpenElectronicsLab/ads1298-breakout
# set -DOPENHARDWAREEXG_HARDWARE_VERSION=1 for the rev1 board
# set OPENHARDWAREEXG_HARDWARE_VERSION=2 for the OpenHardwareExG_Shield
#APP_FLAGS=-DARDUINO_DUE_USB_PROGRAMMING=0 -DOPENHARDWAREEXG_HARDWARE_VERSION=1
APP_FLAGS=-DARDUINO_DUE_USB_PROGRAMMING=0

# port the arduino is connected to while flashing new firmware
PORT=ttyACM0
# This is linux specific
RESET_PORT=stty -F /dev/$(PORT) 1200; sleep 1

# set the "BOSSAC_USB_NATIVE" to "false" if you plan to flash the firmware
# using the "programming" (not the "native") port
BOSSAC_USB_NATIVE=true
#BOSSAC_USB_NATIVE=false

ARDUINO_ROOT=$(HOME)/arduino-1.5.5
ARDUINO_SAM_DIR=$(ARDUINO_ROOT)/hardware/arduino/sam
ARDUINO_SPI_DIR=$(ARDUINO_SAM_DIR)/libraries/SPI
ARDUINO_SOURCES_DIR=$(ARDUINO_SAM_DIR)/cores/arduino
ARDUINO_VARIANT_DIR=$(ARDUINO_SAM_DIR)/variants/arduino_due_x
ARDIUNO_TOOLS_DIR=$(ARDUINO_ROOT)/hardware/tools



# see:  https://github.com/esden/summon-arm-toolchain
#TOOLCHAIN_BIN_DIR=$(HOME)/sat/bin

TOOLCHAIN_BIN_DIR=$(ARDIUNO_TOOLS_DIR)/g++_arm_none_eabi/bin

CC=$(TOOLCHAIN_BIN_DIR)/arm-none-eabi-gcc
CXX=$(TOOLCHAIN_BIN_DIR)/arm-none-eabi-g++
OBJCOPY=$(TOOLCHAIN_BIN_DIR)/arm-none-eabi-objcopy
AR=$(TOOLCHAIN_BIN_DIR)/arm-none-eabi-ar

# see: http://sourceforge.net/projects/b-o-s-s-a/
BOSSAC=$(ARDIUNO_TOOLS_DIR)/bossac

COMMIT_HASH=`git show HEAD | head -n1 | cut -f2 -d' '`
MODIFIED_CNT=`git status -uno --short | wc -l`

SHAREDFLAGS= -g -Os \
		-DEEG_MOUSE_COMMIT_HASH=\"$(COMMIT_HASH)\" \
		-DEEG_MOUSE_FILES_MODIFIED=\"$(MODIFIED_CNT)\" \
		-ffunction-sections \
		-fdata-sections \
		-nostdlib \
		--param max-inline-insns-single=500 \
		-Dprintf=iprintf \
		-mcpu=cortex-m3 \
		-DF_CPU=84000000L \
		-DARDUINO=155 \
		-DARDUINO_SAM_DUE \
		-DARDUINO_ARCH_SAM \
		-D__SAM3X8E__ \
		-mthumb \
		-DUSB_VID=0x2341 \
		-DUSB_PID=0x003e \
		-DUSBCON \
		-DUSB_MANUFACTURER='"Unknown"' \
		-DUSB_PRODUCT='"Arduino Due"' \
		-I$(SRC_DIR) \
		-I$(ARDUINO_SOURCES_DIR) \
		-I$(ARDUINO_VARIANT_DIR) \
		-I$(ARDUINO_SPI_DIR) \
		-I$(ARDUINO_SPI_DIR)/utility \
		-I$(ARDUINO_SAM_DIR)/system/libsam \
		-I$(ARDUINO_SAM_DIR)/system/CMSIS/CMSIS/Include \
		-I$(ARDUINO_SAM_DIR)/system/CMSIS/Device/ATMEL \
		-I$(ARDUINO_SOURCES_DIR)/avr

CFLAGS=-std=gnu99 -Wstrict-prototypes $(SHAREDFLAGS)
CXXFLAGS=$(SHAREDFLAGS) -fno-rtti -fno-exceptions

#NOISYFLAGS=-Wall -Wextra -pedantic -Werror
NOISYFLAGS=-Wall -Wextra -Werror
#NOISYFLAGS=

ARDUINO_MISC_OBJS=syscalls_sam3.o SPI.o

ARDUINO_CORE_OBJS=itoa.o \
		wiring.o \
		cortex_handlers.o \
		WInterrupts.o \
		hooks.o \
		wiring_shift.o \
		wiring_analog.o \
		iar_calls_sam3.o \
		wiring_digital.o \
		dtostrf.o \
		WMath.o \
		main.o \
		IPAddress.o \
		USARTClass.o \
		cxxabi-compat.o \
		USBCore.o \
		HID.o \
		CDC.o \
		Reset.o \
		RingBuffer.o \
		UARTClass.o \
		Stream.o \
		WString.o \
		Print.o \
		wiring_pulse.o \
		variant.o

# extracted from https://github.com/torvalds/linux/blob/master/scripts/Lindent
LINDENT=indent -npro -kr -i8 -ts8 -sob -l80 -ss -ncs -cp1 -il0

%.o : $(SRC_DIR)/%.ino
	$(CXX) $(NOISYFLAGS) $(CXXFLAGS) $(APP_FLAGS) \
		-E -C -x c++ $< -o $<.macros_expanded
	$(CXX) $(NOISYFLAGS) $(CXXFLAGS) $(APP_FLAGS) \
		-c -x c++ $< -o $@

%.o : $(SRC_DIR)/%.c
	$(CC) $(NOISYFLAGS) $(CFLAGS) $(APP_FLAGS) -c $< -o $@

%.o : $(SRC_DIR)/%.cpp
	$(CXX) $(NOISYFLAGS) $(CXXFLAGS) $(APP_FLAGS) -c $< -o $@

%.o : $(ARDUINO_SOURCES_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o : $(ARDUINO_SOURCES_DIR)/avr/%.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o : $(ARDUINO_SOURCES_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o : $(ARDUINO_SOURCES_DIR)/USB/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o : $(ARDUINO_SPI_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o : $(ARDUINO_VARIANT_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

all: $(APPNAME).bin
	echo YAY

clean:
	rm -f *.o *.a *.elf *.bin *.map $(APPNAME).cpp *.macros_expanded

tidy:
	$(LINDENT) \
		-T Data_frame \
		-T FILE \
		-T size_t \
		-T uint8_t \
		*.ino *.c* *.h

upload: $(APPNAME).bin
	$(RESET_PORT)
	$(BOSSAC) -i --port=$(PORT) -U $(BOSSAC_USB_NATIVE) -e -w -v -b $(APPNAME).bin -R

%.bin : %.elf
	$(OBJCOPY) -O binary $< $@

libarduinocore.a: $(ARDUINO_CORE_OBJS)
	$(AR) rcs $@ $^

$(APPNAME).elf : $(APP_OBJS) $(ARDUINO_MISC_OBJS) libarduinocore.a
	$(CXX) $(NOISYFLAGS) \
		-Os -Wl,--gc-sections -mcpu=cortex-m3 \
		-T$(ARDUINO_VARIANT_DIR)/linker_scripts/gcc/flash.ld \
		-Wl,-Map,$(APPNAME).map -o $@ \
		-L. -lm -lgcc -mthumb -Wl,--cref -Wl,--check-sections \
		-Wl,--gc-sections -Wl,--entry=Reset_Handler \
		-Wl,--unresolved-symbols=report-all -Wl,--warn-common \
		-Wl,--warn-section-align -Wl,--warn-unresolved-symbols \
		-Wl,--start-group \
		$^ \
		$(ARDUINO_VARIANT_DIR)/libsam_sam3x8e_gcc_rel.a \
		-Wl,--end-group

OpenHardwareExG_firmware.o : $(SRC_DIR)/OpenHardwareExG_firmware.h $(SRC_DIR)/exg_lead_leds.h \
	$(SRC_DIR)/ads1298.h $(SRC_DIR)/util.h
exg_leads_leds.o : $(SRC_DIR)/OpenHardwareExG_firmware.h $(SRC_DIR)/exg_lead_leds.h
util.o : $(SRC_DIR)/util.h
