// modified from: http://www.windmeadow.com/node/38
#include <stdio.h>
#include <string.h>
#include <WProgram.h>

#define IN_BUF_SIZE 50

char incomingByte;
char str1[IN_BUF_SIZE];
int count = 0;

extern "C" void __cxa_pure_virtual(void)
{
	// error - loop forever (nice if you can attach a debugger)
	while (true) ;
}

int main(void)
{

	init();
	Serial.begin(19200);
	digitalWrite(13, HIGH);	//turn on debugging LED

	while (1) {
		// send data only when you receive data:
		if (Serial.available() > 0) {
			// read the incoming byte:
			incomingByte = Serial.read();

			// Store it in a character array
			str1[count] = incomingByte;
			count++;

			// send if we recieve a carriage return or line feed
			// or if we are about to over-run our buffer
			if ((incomingByte == 10 || incomingByte == 13)
			    || (count > (IN_BUF_SIZE - 1))) {
				// Send the string back
				Serial.print(str1);
				count = 0;
			}
		}
	}

}
