#include "util.h"

char to_hex(char byte, char high)
{
	char nibble;

	if (high) {
		nibble = (byte & 0xF0) >> 4;
	} else {
		nibble = (byte & 0x0F);
	}

	if (nibble < 10) {
		return '0' + nibble;
	}
	return 'A' + nibble - 10;
}

void pause_microseconds(unsigned microseconds)
{
	unsigned i, j, cycles_per_us;
	/* clock speed is set to 168MHz
		the for loop we estimate to be:
		nop
		increment
		compare
		jump not zero

		thus 4 cycles per loop in non-debug-build

		168 cycles per microsecond / 4 cycles per loop = 42
	*/
	cycles_per_us = 42;

	for (i = 0; i < microseconds; ++i) {
		for (j = 0; j < cycles_per_us; ++j) {
			__asm__("nop");
		}
	}
}
