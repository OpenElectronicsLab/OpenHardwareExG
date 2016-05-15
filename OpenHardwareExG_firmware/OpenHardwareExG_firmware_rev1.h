/* OpenHardwareExG_firmware_rev1.h */
#ifndef OPENHARDWAREEXG_FIRMWARE_REV1_H
#define OPENHARDWAREEXG_FIRMWARE_REV1_H

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

// LED_ENABLE is PD6, PIN 29
#define IPIN_LED_ENABLE 29

// LED_LATCH is PD3, PIN 28
#define PIN_LED_LATCH 28

// LED_CLEAR is PD2, PIN 27
#define IPIN_LED_CLEAR 27

// LED_CLK (LED clock) is PD1, PIN 26
#define PIN_LED_CLK 26

// LED_SERIAL is PD0, PIN 25
#define PIN_LED_SERIAL 25

#endif /* OPENHARDWAREEXG_FIRMWARE_REV1_H */
