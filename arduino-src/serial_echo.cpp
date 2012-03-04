// modified from: http://www.windmeadow.com/node/38
#include <SPI/SPI.h>
#include <WProgram.h>

#define IN_BUF_SIZE 50

// CS (chip select) is SS PB0 PIN 53 (through level shifter)
#define PIN_CS 53

// SCLK (serial clock) is SCK PB1 PIN 52 (through level shifter)
#define PIN_SCLK 52

// DIN (data in) is MOSI PB2 PIN 51 (through level shifter)
#define PIN_DIN 51

// DOUT (data out) is MISO PB3 PIN 50 (direct)
#define PIN_DOUT 50

// CLKSEL (clock select) is PL0 PIN 49 (through level shifter)
#define PIN_CLKSEL 49

// START is PL3 PIN 46 (through level shifter)
#define PIN_START 46

// RESET is PL2 PIN 47 (through level shifter)
#define PIN_RESET 47

// PWDN (power down) is PL1 PIN 48 (through level shifter)
#define PIN_PWDN 48

// DRDY (data ready) is PL4 PIN 45 (direct)
#define PIN_DRDY 45

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

	pinMode(PIN_CS, OUTPUT);
	pinMode(PIN_SCLK, OUTPUT);
	pinMode(PIN_DIN, OUTPUT);
	pinMode(PIN_DOUT, INPUT);

	pinMode(PIN_CLKSEL, OUTPUT);
	pinMode(PIN_START, OUTPUT);
	pinMode(PIN_RESET, OUTPUT);
	pinMode(PIN_PWDN, OUTPUT);
	pinMode(PIN_DRDY, INPUT);

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
