/* eeg-mouse.h */
#ifndef _EEG_MOUSE_H_
#define _EEG_MOUSE_H_

// IPIN_ is for pins that are inverted

// ---------------
// SPI GPIOs for ADS1298
#define SPI_GPIO GPIOA

// SCLK (serial clock) is GPIO A 5
#define PIN_SCLK GPIO5

// DOUT (data out) is GPIO A 6
#define PIN_DOUT GPIO6

// DIN (data in) is GPIO A 7
#define PIN_DIN GPIO7


// ---------------
// Other GPIOs needed for ADS1298
#define ADS_GPIO GPIOE

// CS (chip select) is GPIO E 7
#define IPIN_CS GPIO7

// CLKSEL (clock select) is GPIO E 8
#define PIN_CLKSEL GPIO8

// PWDN (power down) is GPIO E 9
#define IPIN_PWDN GPIO9

// RESET is GPIO E 10
#define IPIN_RESET GPIO10

// START is GPIO E 11
#define PIN_START GPIO11

// DRDY (data ready) is GPIO E 12
#define IPIN_DRDY GPIO12

#endif /* _EEG_MOUSE_H_ */
