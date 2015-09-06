/* OpenHardwareExG_firmware.h */
#ifndef OPENHARDWAREEXG_FIRMWARE_H
#define OPENHARDWAREEXG_FIRMWARE_H

#ifndef OPENHARDWAREEXG_HARDWARE_VERSION
#define OPENHARDWAREEXG_HARDWARE_VERSION 1
#endif

#if OPENHARDWAREEXG_HARDWARE_VERSION == 0
#include "OpenHardwareExG_firmware_rev0.h"
#else
#include "OpenHardwareExG_firmware_rev1.h"
#endif

#endif /* OPENHARDWAREEXG_FIRMWARE_H */
