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
