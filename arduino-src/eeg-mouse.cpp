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
	int i = 0;

	// error - loop forever (nice if you can attach a debugger)
	while (1) {
		if ((i++ % 1000) == 0) {
			fill_error_frame("__cxa_pure_virtual");
			Serial.print(byte_buf);
		}
		continue;
	}
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

void fill_error_frame(const char *msg)
{
	int i = 0;

	pos = 0;

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = 'h';
	byte_buf[pos++] = ']';

	while ((msg[i] != 0) && (pos < (IN_BUF_SIZE - 7))) {
		byte_buf[pos++] = msg[i++];
	}

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'n';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = ']';
	byte_buf[pos++] = '\n';
}

void wait_for_drdy(const char *msg, int interval)
{
	int i = 0;
	while (digitalRead(IPIN_DRDY) == HIGH) {
		if ((i++ % interval) != 0) {
			continue;
		}
		if (i < interval) {
			continue;
		}
		fill_error_frame(msg);
		Serial.print(byte_buf);
	}
}

int main(void)
{
	char in_byte;
	int i;

	init();

	// initialize the USB Serial connection
	Serial.begin(230400);

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
    SPI.setClockDivider(SPI_CLOCK_DIV4);
    SPI.setDataMode(1);

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

	// All GPIO set to output 0x0101
    delay(1);
	digitalWrite(IPIN_CS, HIGH);
    delay(1);
	digitalWrite(IPIN_CS, LOW);
	SPI.transfer(WREG | 0x14);
	SPI.transfer(0);	// number of registers to be read/written – 1
	SPI.transfer(0x50);
    delay(1);
	digitalWrite(IPIN_CS, HIGH);
    delay(1);
	digitalWrite(IPIN_CS, LOW);

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
	wait_for_drdy("waiting for DRDY in setup", 1000);

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
		wait_for_drdy("no data", 5000);
		fill_sample_frame();
		Serial.print(byte_buf);
	}
}
