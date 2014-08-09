#include "util.h"

void to_hex(char byte, char *buf)
{
	int i;
	char nibbles[2];

	nibbles[0] = (byte & 0xF0) >> 4;
	nibbles[1] = (byte & 0x0F);

	for (i = 0; i < 2; i++) {
		if (nibbles[i] < 10) {
			buf[i] = '0' + nibbles[i];
		} else {
			buf[i] = 'A' + nibbles[i] - 10;
		}
	}
	buf[2] = '\0';
}
