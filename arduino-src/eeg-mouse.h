/* eeg-mouse.h */
#ifndef _EEG_MOUSE_H_
#define _EEG_MOUSE_H_

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

// START is PL3 PIN 46 (through level shifter)
#define PIN_START 46

// RESET is PL2 PIN 47 (through level shifter)
#define IPIN_RESET 47

// PWDN (power down) is PL1 PIN 48 (through level shifter)
#define IPIN_PWDN 48

// DRDY (data ready) is PL4 PIN 45 (direct)
#define IPIN_DRDY 45

// SDATAC Command (Stop Read Data Continuously mode)
#define SDATAC 0x11
#define RDATAC 0x10

// these are pulled from the ADS1298 data sheet
#define WREG 0x40
#define CONFIG1 0x01
#define CONFIG2 0x02
#define CONFIG3 0x03
#define PDREFBUF 0x80
#define CONFIG3DEF 0x40
#define VREF_4V 0x20
#define CHnSET 0x04		// CH1SET is 0x05, CH2SET is 0x06, etc.
// we need to set the RLD at some point

extern "C" void __cxa_pure_virtual(void);
void wait_for_drdy(const char *msg, int interval);
void fill_sample_frame(void);
void fill_error_frame(const char *msg);

#endif /* _EEG_MOUSE_H_ */
