/* eeg_mouse_firmware_rev1.h */
#ifndef _EEG_MOUSE_FIRMWARE_REV1_H_
#define _EEG_MOUSE_FIRMWARE_REV1_H_

// IPIN_ is for pins that are inverted

// CS (chip select) is PB14, CANTX1/IO, PIN53
#define IPIN_CS 53

//  SCLK (serial clock) is PA27, SPCK, SPI PIN 3
// #define PIN_SCLK

// DIN (data in) is  PA26, MOSI, SPI PIN 4
// #define PIN_DIN

// DOUT (data out) is PA25, MISO, SPI PIN 1
// #define PIN_DOUT

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
