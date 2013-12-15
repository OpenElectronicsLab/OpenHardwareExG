/* eeg_mouse_firmware.h */
#ifndef _EEG_MOUSE_FIRMWARE_H_
#define _EEG_MOUSE_FIRMWARE_H_

#ifndef EEG_MOUSE_HARDWARE_VERSION
#define EEG_MOUSE_HARDWARE_VERSION 1
#endif

#if EEG_MOUSE_HARDWARE_VERSION == 0
#include "eeg_mouse_firmware_rev0.h"
#else
#include "eeg_mouse_firmware_rev1.h"
#endif

#endif /* _EEG_MOUSE_FIRMWARE_H_ */
