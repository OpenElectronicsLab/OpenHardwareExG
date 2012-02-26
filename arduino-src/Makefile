
# the name of the main file and sources to be used
APPNAME=serial_echo
SOURCES=$(APPNAME).o

ARDUINO_SOURCES_DIR=/usr/share/arduino/hardware/arduino/cores/arduino

# port the arduino is connected to
# and CPU type as defined by gcc and AVR-DUDE
ifeq ($(wildcard /dev/ttyACM0),)
PORT=/dev/ttyUSB0
GCC_MMCU=atmega1280
AVRDUDE_MCU=m1280
AVRDUDE_STK=stk500v1
AVRDUDE_BAUD=57600
else
PORT=/dev/ttyACM0
GCC_MMCU=atmega2560
AVRDUDE_STK=stk500v2
AVRDUDE_MCU=atmega2560
AVRDUDE_BAUD=115200
endif

#GCC_MMCU=atmega328p
#AVRDUDE_MCU=atmega328p
#AVRDUDE_STK=stk500v1
#AVRDUDE_BAUD=57600

# CPU Clock speed (cycles per second)
CLOCKSPEED=16000000
#CLOCKSPEED=8000000

CC=avr-gcc
CXX=avr-g++

SHAREDFLAGS= -gstabs -Os \
		-funsigned-char -funsigned-bitfields -fpack-struct \
		-fshort-enums \
		-I$(ARDUINO_SOURCES_DIR) -mmcu=$(GCC_MMCU) -DF_CPU=$(CLOCKSPEED)

CFLAGS=-std=gnu99 -Wstrict-prototypes $(SHAREDFLAGS)
CXXFLAGS=$(SHAREDFLAGS)
NOISYFLAGS=-Wall -Wextra -pedantic -Werror
#NOISYFLAGS=
CXX_WORKAROUND_FLAGS=-Wno-variadic-macros -Wno-ignored-qualifiers

ARDUINOSOURCES= HardwareSerial.o \
			pins_arduino.o \
			Print.o \
			Tone.o \
			WInterrupts.o \
			wiring_analog.o \
			wiring.o \
			wiring_digital.o \
			wiring_pulse.o \
			wiring_shift.o \
			WMath.o \
			WString.o


%.o : %.c
	$(CC) $(CFLAGS) $(NOISYFLAGS) -c $< -o $@

%.o : %.cpp
	$(CXX) $(NOISYFLAGS) $(CXXFLAGS) $(CXX_WORKAROUND_FLAGS) -c $< -o $@

%.o : $(ARDUINO_SOURCES_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o : $(ARDUINO_SOURCES_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

all: $(APPNAME).hex
	echo YAY

clean:
	rm -f *.o *.a *.hex

upload: $(APPNAME).hex
	stty -F $(PORT) hupcl # e.g. reset the arduino
	avrdude -v -c $(AVRDUDE_STK) -p $(AVRDUDE_MCU) \
		-b $(AVRDUDE_BAUD) -P $(PORT) -U flash:w:$(APPNAME).hex

%.hex : %
	avr-objcopy -O ihex -R .eeprom $< $@

libarduinocore.a: $(ARDUINOSOURCES)
	ar rc $@ $^

$(APPNAME) : $(SOURCES) libarduinocore.a
	$(CXX) $(CXXFLAGS) $(NOISYFLAGS) $^ -o $@ -L. -larduinocore

