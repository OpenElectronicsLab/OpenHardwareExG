/* OpenHardwareExG_firmware_sheild.h */
#ifndef OPENHARDWAREEXG_FIRMWARE_SHIELD_H
#define OPENHARDWAREEXG_FIRMWARE_SHIELD_H

// IPIN_ is for pins that are inverted

#define HAVE_SLAVE_AND_MASTER_CS 1

// MASTER CS (chip select) PWM7 "MASTER_~CS~"
#define IPIN_MASTER_CS 7

// SLAVE CS (chip select) PWM6 "SLAVE_~CS~"
#define IPIN_SLAVE_CS 6

// DRDY (data ready) PWM5 "MASTER_~DRDY~"
#define IPIN_MASTER_DRDY 5

#endif /* OPENHARDWAREEXG_FIRMWARE_SHIELD_H */
