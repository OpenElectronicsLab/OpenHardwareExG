/* OpenHardwareExG_firmware.h */
#ifndef OPENHARDWAREEXG_FIRMWARE_H
#define OPENHARDWAREEXG_FIRMWARE_H

#ifndef OPENHARDWAREEXG_HARDWARE_VERSION
#define OPENHARDWAREEXG_HARDWARE_VERSION 2
#endif

#if OPENHARDWAREEXG_HARDWARE_VERSION == 0
#include "OpenHardwareExG_firmware_rev0.h"
#elif OPENHARDWAREEXG_HARDWARE_VERSION == 1
#include "OpenHardwareExG_firmware_rev1.h"
#else
#include "OpenHardwareExG_firmware_shield.h"
#endif

#if !defined(IPIN_MASTER_CS) && defined(IPIN_CS)
#define IPIN_MASTER_CS IPIN_CS
#endif

#if !defined(IPIN_MASTER_DRDY) && defined(IPIN_DRDY)
#define IPIN_MASTER_DRDY IPIN_DRDY
#endif

#endif /* OPENHARDWAREEXG_FIRMWARE_H */
