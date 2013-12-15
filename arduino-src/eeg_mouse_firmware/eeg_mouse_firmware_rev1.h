/* eeg_mouse_firmware_rev1.h */
#ifndef _EEG_MOUSE_FIRMWARE_REV1_H_
#define _EEG_MOUSE_FIRMWARE_REV1_H_

// IPIN_ is for pins that are inverted

// CS (chip select) is PB14, CANTX1/IO, PIN53
#define IPIN_CS 53

// XXX SCLK (serial clock) is PA27, SPCK, actually SPI PIN 3
#define PIN_SCLK 52

// XXX DIN (data in) is actually PA26, MOSI, SPI PIN 4
#define PIN_DIN 51

// XXX DOUT (data out) is actually PA25, MISO, SPI PIN 1
#define PIN_DOUT 50

// CLKSEL (clock select) is PC14, PIN 49
#define PIN_CLKSEL 49

// RESET is PC15, PIN 48 (was PIN 47 in rev0)
#define IPIN_RESET 48

// PWDN (power down) is PC16, PIN 47 (was PIN 48 in rev0)
#define IPIN_PWDN 47

// START is PC17, PIN 46
#define PIN_START 46

// DRDY (data ready) is PC18, PIN 45
#define IPIN_DRDY 45

#endif /* _EEG_MOUSE_FIRMWARE_REV_1_H_ */
