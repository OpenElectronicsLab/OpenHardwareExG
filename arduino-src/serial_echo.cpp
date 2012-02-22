// modified from: http://www.windmeadow.com/node/38
#include <WProgram.h>

#define IN_BUF_SIZE 50

char incoming_byte;
char byte_buf[IN_BUF_SIZE];
int count = 0;

extern "C" void __cxa_pure_virtual(void)
{
	// error - loop forever (nice if you can attach a debugger)
	while (true) ;
}

int main(void)
{
	init();

	// set the LED on
	digitalWrite(13, HIGH);

	Serial.begin(19200);

	while (1) {
		// loop until data available
		if (Serial.available() == 0) {
			continue;
		}

		// read an available byte:
		incoming_byte = Serial.read();

		// Store it in the buffer
		byte_buf[count++] = incoming_byte;

		// if we recieve a carriage return or line feed
		// or if we are about to over-run our buffer
		if ((incoming_byte == 10 || incoming_byte == 13)
		    || (count > (IN_BUF_SIZE - 1))) {
			// then send the buffer contents back
			Serial.print(byte_buf);
			// and return the buffer index to start
			count = 0;
		}
	}
}
