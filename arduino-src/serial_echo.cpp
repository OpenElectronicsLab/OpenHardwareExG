// modified from: http://www.windmeadow.com/node/38
#include <stdio.h>
#include <string.h>
#include <WProgram.h>

char incomingByte;		// for incoming serial data
char str1[50];
int count = 0;

extern "C" void __cxa_pure_virtual(void)
{
	// error - loop forever (nice if you can attach a debugger)
	while (true) ;
}

int main(void)
{

// setup ()
	init();
	Serial.begin(19200);
	digitalWrite(13, HIGH);	//turn on debugging LED

//  MAIN CODE
	while (1) {
		// send data only when you receive data:
		if (Serial.available() > 0) {
			// read the incoming byte:
			incomingByte = Serial.read();

			// Store it in a character array
			str1[count] = incomingByte;
			count++;

			// check if we have over 49 characaters or we recieve a return or line feed
			if (count > 49 || incomingByte == 10
			    || incomingByte == 13) {
				// Send the string back
				Serial.print(str1);
				count = 0;
			}
		}
	}

}
