// modified from: http://www.windmeadow.com/node/38

// the SPI/SPI.h in v22 has a broken double #define SPI_CLOCK_DIV64
// this looks to be fixed with commit 965480f
#include <SPI.h>

#include <WProgram.h>

#include "eeg-mouse.h"
#include "ads1298.h"
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

	digitalWrite(IPIN_CS, LOW);
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
    delayMicroseconds(1);
	digitalWrite(IPIN_CS, HIGH);
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

void adc_send_command(int cmd) {
	digitalWrite(IPIN_CS, LOW);
	SPI.transfer(cmd);
    delayMicroseconds(1);
    //digitalWrite(IPIN_CS, HIGH); // Causes RDATAC to fail - not sure why.
}

void adc_wreg(int reg, int val) {
	digitalWrite(IPIN_CS, LOW);

	SPI.transfer(ADS1298::WREG | reg);
	SPI.transfer(0);	// number of registers to be read/written – 1
	SPI.transfer(val);

    delayMicroseconds(1);
	digitalWrite(IPIN_CS, HIGH);
}

int main(void)
{
    using namespace ADS1298;
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
	SPI.setDataMode(SPI_MODE1);

	//digitalWrite(IPIN_CS, LOW);
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
    adc_send_command(SDATAC);

	// All GPIO set to output 0x0000
    // (floating CMOS inputs can flicker on and off, creating noise)
    adc_wreg(GPIO, 0);

	// Power up the internal reference and wait for it to settle
    adc_wreg(CONFIG3, PD_REFBUF | CONFIG3_const | VREF_4V);
	delay(150);

	// Write Certain Registers, Including Input Short
	// Set Device in HR Mode and DR = fMOD/1024
    adc_wreg(CONFIG1, LOW_POWR_250_SPS);
	adc_wreg(CONFIG2, INT_TEST);	// generate test signals
	// Set all channels to test signal
	for (i = 1; i <= 8; ++i) {
        adc_wreg(CHnSET + i, TEST_SIGNAL | GAIN_1X);
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
	adc_send_command(RDATAC);

	while (1) {
		wait_for_drdy("no data", 5000);
		fill_sample_frame();
		Serial.print(byte_buf);
	}
}
