/* OpenHardwareExG_firmware_rev0.h */
#ifndef OPENHARDWAREEXG_FIRMWARE_REV0_H
#define OPENHARDWAREEXG_FIRMWARE_REV0_H

// IPIN_ is for pins that are inverted

// CS (chip select) is SS PB0 PIN 53 (through level shifter)
#define IPIN_CS 53

// SCLK (serial clock) is SCK PB1 PIN 52 (through level shifter)
#define PIN_SCLK 52

// DIN (data in) is MOSI PB2 PIN 51 (through level shifter)
#define PIN_DIN 51

// DOUT (data out) is MISO PB3 PIN 50 (direct)
#define PIN_DOUT 50

// CLKSEL (clock select) is PL0 PIN 49 (through level shifter)
#define PIN_CLKSEL 49

// PWDN (power down) is PL1 PIN 48 (through level shifter)
#define IPIN_PWDN 48

// RESET is PL2 PIN 47 (through level shifter)
#define IPIN_RESET 47

// START is PL3 PIN 46 (through level shifter)
#define PIN_START 46

// DRDY (data ready) is PL4 PIN 45 (direct)
#define IPIN_DRDY 45

#endif /* OPENHARDWAREEXG_FIRMWARE_REV0_H */
