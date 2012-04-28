#include "serial.h"

#include <Arduino.h>

extern "C" void __cxa_pure_virtual(void)
{
	int i = 0;

	// error - loop forever (nice if you can attach a debugger)
	while (1) {
		if ((i++ % 1000) == 0) {
			Serial.print("[oh]__cxa_pure_virtual[no]\n");
		}
		continue;
	}
}
