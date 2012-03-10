// modified from: http://www.windmeadow.com/node/38

// the SPI/SPI.h in v22 has a broken double #define SPI_CLOCK_DIV64
// this looks to be fixed with commit 965480f
#include <SPI.h>

#include <WProgram.h>

#include "eeg-mouse.h"
#include "util.h"

#define IN_BUF_SIZE 80

char byte_buf[IN_BUF_SIZE];
int pos;

extern "C" void __cxa_pure_virtual(void)
{
	// error - loop forever (nice if you can attach a debugger)
	while (true) ;
}

void fill_sample_frame(void)
{
	int i, j;
	char in_byte;

	pos = 0;

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'g';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = ']';

	// read 24bits of status then 24bits for each channel
	for (i = 0; i <= 8; ++i) {
		for (j = 0; j < 3; ++j) {
			in_byte = SPI.transfer(0);
			byte_buf[pos++] = to_hex(in_byte, 1);
			byte_buf[pos++] = to_hex(in_byte, 0);
		}
	}

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = 'n';
	byte_buf[pos++] = ']';
	byte_buf[pos++] = '\n';
}

void fill_no_data_frame(void)
{
	pos = 0;

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = 'h';
	byte_buf[pos++] = ']';

	byte_buf[pos++] = 'n';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = ' ';
	byte_buf[pos++] = 'd';
	byte_buf[pos++] = 'a';
	byte_buf[pos++] = 't';
	byte_buf[pos++] = 'a';

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'n';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = ']';
	byte_buf[pos++] = '\n';
}

int main(void)
{
	char in_byte;
	int i;

	init();

	// set the LED on
	pinMode(13, OUTPUT);
	digitalWrite(13, HIGH);

	pinMode(IPIN_CS, OUTPUT);
	pinMode(PIN_SCLK, OUTPUT);
	pinMode(PIN_DIN, OUTPUT);
	pinMode(PIN_DOUT, INPUT);

	pinMode(PIN_CLKSEL, OUTPUT);
	pinMode(PIN_START, OUTPUT);
	pinMode(IPIN_RESET, OUTPUT);
	pinMode(IPIN_PWDN, OUTPUT);
	pinMode(IPIN_DRDY, INPUT);

	SPI.begin();

	SPI.setBitOrder(MSBFIRST);

	digitalWrite(IPIN_CS, LOW);
	digitalWrite(PIN_CLKSEL, HIGH);

	// Wait for 20 microseconds Oscillator to Wake Up
	delay(1);		// we'll actually wait 1 millisecond

	digitalWrite(IPIN_PWDN, HIGH);
	digitalWrite(IPIN_RESET, HIGH);

	// Wait for 33 milliseconds (we will use 1 second)
	//  for Power-On Reset and Oscillator Start-Up
	delay(1000);

	// Issue Reset Pulse,
	digitalWrite(IPIN_RESET, LOW);
	// actually only needs 1 microsecond, we'll go with milli
	delay(1);
	digitalWrite(IPIN_RESET, HIGH);
	// Wait for 18 tCLKs AKA 9 microseconds, we use 1 millisec
	delay(1);

	// Send SDATAC Command (Stop Read Data Continuously mode)
	SPI.transfer(SDATAC);

	// no external reference Configuration Register 3
	SPI.transfer(WREG | CONFIG3);
	SPI.transfer(0);	// number of registers to be read/written – 1
	SPI.transfer(PDREFBUF | CONFIG3DEF | VREF_4V);

	// Write Certain Registers, Including Input Short
	// Set Device in HR Mode and DR = fMOD/1024
	SPI.transfer(WREG | CONFIG1);
	SPI.transfer(0);
	SPI.transfer(0x86);	// TODO bitnames!
	SPI.transfer(WREG | CONFIG2);
	SPI.transfer(0);
	SPI.transfer(0x10);	// generate test signals
	// Set all channels to test signal
	for (i = 1; i <= 8; ++i) {
		SPI.transfer(WREG | (CHnSET + i));
		SPI.transfer(0);
		SPI.transfer(0x05);	// test signal
	}

	digitalWrite(PIN_START, HIGH);
	while (digitalRead(IPIN_DRDY) == HIGH) {
		continue;
	}

	Serial.begin(230400);

	// wait for a non-zero byte as a ping from the computer
	do {
		// loop until data available
		if (Serial.available() == 0) {
			continue;
		}
		// read an available byte:
		in_byte = Serial.read();
	} while (in_byte == 0);

	// Put the Device Back in Read DATA Continuous Mode
	SPI.transfer(RDATAC);

	while (1) {
		// wait for DRDY
		for (i = 0; (digitalRead(IPIN_DRDY) == HIGH) && i < 5000; ++i) {
			;	// no data yet
		}
		if (digitalRead(IPIN_DRDY) == LOW) {
			fill_sample_frame();
		} else {
			fill_no_data_frame();
		}

		Serial.print(byte_buf);
	}
}
