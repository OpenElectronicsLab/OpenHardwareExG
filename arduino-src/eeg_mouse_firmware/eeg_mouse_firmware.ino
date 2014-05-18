// modified from: http://www.windmeadow.com/node/38

#include <Arduino.h>
#include <SPI.h>

#include "eeg_mouse_firmware.h"
#include "eeg_lead_leds.h"
#include "ads1298.h"
#include "util.h"

// actual size today is 64, but a few extra will not hurt
#define DATA_BUF_SIZE 80

#ifndef LIVE_CHANNELS_NUM
#define LIVE_CHANNELS_NUM 8
#endif

#ifdef  _VARIANT_ARDUINO_DUE_X_
#define SPI_CLOCK_DIVIDER_VAL 21
#else
// #define SPI_CLOCK_DIVIDER_VAL SPI_CLOCK_DIV4
#define SPI_CLOCK_DIVIDER_VAL SPI_CLOCK_DIV8
#endif

#ifdef _VARIANT_ARDUINO_DUE_X_
#if ARDUINO_DUE_USB_PROGRAMMING == 1
#define SERIAL_OBJ Serial
#else // default to the NATIVE port
#define SERIAL_OBJ SerialUSB
#endif
#endif

#ifndef SERIAL_OBJ
#define SERIAL_OBJ Serial
#endif

// global variables
char setup_2_run;
char in_byte;
int led_status;
unsigned long last_blink;
unsigned long blink_interval_millis;
#if EEG_MOUSE_HARDWARE_VERSION != 0
Eeg_lead_leds lead_leds;
#endif

#define LED_PIN 13
#define BLINK_INTERVAL_SETUP 100;
#define BLINK_INTERVAL_WAITING 500;
#define BLINK_INTERVAL_SENDING 2000;

// if this becomes more flexible, we may need to pass in
// the byte_buf size, but for now we are safe to skip it
void fill_sample_frame(char *byte_buf)
{
	int i, j;
	uint8_t in_byte;

	unsigned int pos = 0;

	digitalWrite(IPIN_CS, LOW);
	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'g';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = ']';

	// read 24bits of status then 24bits for each channel
	for (i = 0; i <= 8; ++i) {
		for (j = 0; j < 3; ++j) {
			in_byte = SPI.transfer(0);
			to_hex(in_byte, byte_buf + pos);
			pos += 2;

			if (i == 0) {
				if (j == 0) {
					// IN8P-IN5P leadoff
					for (int k = 4; k < 8; ++k) {
						bool leadoff =
						    ((in_byte >> (k - 4)) & 1);
						lead_leds.set_green_led(k,
									!leadoff);
						lead_leds.set_yellow_led(k,
									 leadoff);
					}
				} else if (j == 1) {
					// IN5P-IN8P leadoff
					for (int k = 0; k < 4; ++k) {
						bool leadoff =
						    ((in_byte >> (k + 4)) & 1);
						lead_leds.set_green_led(k,
									!leadoff);
						lead_leds.set_yellow_led(k,
									 leadoff);
					}
					// IN8N-IN5N leadoff
					for (int k = 4; k < 8; ++k) {
						bool leadoff =
						    ((in_byte >> (k - 4)) & 1);
						lead_leds.set_green_led(k + 8,
									!leadoff);
						lead_leds.set_yellow_led(k + 8,
									 leadoff);
					}
				}
				// IN1N leadoff
				else if (j == 2) {
					// IN5N-IN8N leadoff
					for (int k = 0; k < 4; ++k) {
						bool leadoff =
						    ((in_byte >> (k + 4)) & 1);
						lead_leds.set_green_led(k + 8,
									!leadoff);
						lead_leds.set_yellow_led(k + 8,
									 leadoff);
					}
				}
			}
		}
	}

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = 'n';
	byte_buf[pos++] = ']';
	byte_buf[pos++] = '\n';
	byte_buf[pos++] = 0;
	delayMicroseconds(1);
	digitalWrite(IPIN_CS, HIGH);
}

void serial_print_error(const char *msg)
{
	SERIAL_OBJ.print("[oh]");
	SERIAL_OBJ.print(msg);
	SERIAL_OBJ.print("[no]\n");
}

void wait_for_drdy(const char *msg, int interval)
{
	int i = 0;
	while (digitalRead(IPIN_DRDY) == HIGH) {
		if (i < interval) {
			continue;
		}
		i = 0;
		serial_print_error(msg);
	}
}

void adc_send_command(int cmd)
{
	digitalWrite(IPIN_CS, LOW);
	SPI.transfer(cmd);
	delayMicroseconds(1);
	digitalWrite(IPIN_CS, HIGH);
}

byte adc_rreg(int reg)
{
	byte val;

	digitalWrite(IPIN_CS, LOW);

	SPI.transfer(ADS1298::RREG | reg);
	SPI.transfer(0);	// number of registers to be read/written – 1
	val = SPI.transfer(0);

	delayMicroseconds(1);
	digitalWrite(IPIN_CS, HIGH);

	return val;
}

void adc_wreg(int reg, int val)
{
	digitalWrite(IPIN_CS, LOW);

	SPI.transfer(ADS1298::WREG | reg);
	SPI.transfer(0);	// number of registers to be read/written – 1
	SPI.transfer(val);

	delayMicroseconds(1);
	digitalWrite(IPIN_CS, HIGH);
}

void blink_led(void)
{
	unsigned long now = millis();

	if ((now - last_blink) > blink_interval_millis) {
		led_status = (led_status == HIGH) ? LOW : HIGH;
		digitalWrite(LED_PIN, led_status);
		last_blink = now;
	}
}

void setup(void)
{
	setup_2_run = 0;
	in_byte = 0;
	led_status = HIGH;
	last_blink = 0;
	blink_interval_millis = BLINK_INTERVAL_SETUP;
	pinMode(LED_PIN, OUTPUT);
}

void setup_2(void)
{
	using namespace ADS1298;
	int i;

	// initialize the USB Serial connection
	SERIAL_OBJ.begin(230400);

	// set the LED on
	pinMode(13, OUTPUT);
	digitalWrite(13, HIGH);

	pinMode(IPIN_CS, OUTPUT);
#if EEG_MOUSE_HARDWARE_VERSION == 0
	pinMode(PIN_SCLK, OUTPUT);
	pinMode(PIN_DIN, OUTPUT);
	pinMode(PIN_DOUT, INPUT);
#endif

	pinMode(PIN_CLKSEL, OUTPUT);
	pinMode(PIN_START, OUTPUT);
	pinMode(IPIN_RESET, OUTPUT);
	pinMode(IPIN_PWDN, OUTPUT);
	pinMode(IPIN_DRDY, INPUT);

#if EEG_MOUSE_HARDWARE_VERSION != 0
	lead_leds.begin();
	// while waiting for the device to power up, sequentially light the green LEDs
	for (i = 0; i < 16; ++i) {
		lead_leds.set_green_led(i, true);
		lead_leds.update_all();
		delay(50);
	}
#endif

	SPI.begin();

	SPI.setBitOrder(MSBFIRST);
	SPI.setClockDivider(SPI_CLOCK_DIVIDER_VAL);
	SPI.setDataMode(SPI_MODE1);

	//digitalWrite(IPIN_CS, LOW);
	digitalWrite(PIN_CLKSEL, HIGH);

	// Wait for 20 microseconds Oscillator to Wake Up
	delay(1);		// we'll actually wait 1 millisecond

	digitalWrite(IPIN_PWDN, HIGH);
	digitalWrite(IPIN_RESET, HIGH);

	// Wait for 33 milliseconds (we will use 100 millis)
	//  for Power-On Reset and Oscillator Start-Up
	delay(100);

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
	adc_wreg(GPIO, 0x00);

	// Power up the internal reference and wait for it to settle
	adc_wreg(CONFIG3,
		 RLDREF_INT | PD_RLD | PD_REFBUF | VREF_4V | CONFIG3_const);
	delay(150);

	//adc_wreg(RLD_SENSP, 0xFF);    // use all postive channels and
	adc_wreg(RLD_SENSP, 0x01);	// only use channel IN1P and
	adc_wreg(RLD_SENSN, 0x01);	// IN1N for the RLD Measurement

	// Use lead-off sensing in all channels
	adc_wreg(CONFIG4, PD_LOFF_COMP);
	adc_wreg(LOFF_SENSP, 0xFF);
	adc_wreg(LOFF_SENSN, 0xFF);

	// Write Certain Registers, Including Input Short
	// Set Device in HR Mode and DR = fMOD/1024
	//adc_wreg(CONFIG1, HR | LOW_POWR_500_SPS);
	adc_wreg(CONFIG1, HR | LOW_POWR_250_SPS);
	adc_wreg(CONFIG2, INT_TEST);	// generate internal test signals
	// Set the first LIVE_CHANNELS_NUM channels to input signal
	for (i = 1; i <= LIVE_CHANNELS_NUM; ++i) {
		adc_wreg(CHnSET + i, ELECTRODE_INPUT | GAIN_12X);
		// adc_wreg(CHnSET + i, TEST_SIGNAL | GAIN_12X);
	}
	// Set all remaining channels to shorted inputs
	for (; i <= 8; ++i) {
		adc_wreg(CHnSET + i, SHORTED | PDn);
	}

	digitalWrite(PIN_START, HIGH);
	wait_for_drdy("waiting for DRDY in setup", 1000);

	blink_interval_millis = BLINK_INTERVAL_WAITING;
}

void check_for_ping_from_serial()
{
	using namespace ADS1298;
	byte version;
	int i = 0;
	char msg[40];

	if (SERIAL_OBJ.available() == 0) {
		return;
	}
	// read an available byte:
	in_byte = SERIAL_OBJ.read();

	if (in_byte != 0) {
		msg[i++] = '[';
		msg[i++] = 'i';
		msg[i++] = 't';
		msg[i++] = ']';

		version = adc_rreg(ADS1298::ID);
		msg[i++] = 'c';
		msg[i++] = 'h';
		msg[i++] = 'i';
		msg[i++] = 'p';
		msg[i++] = ' ';
		msg[i++] = 'i';
		msg[i++] = 'd';
		msg[i++] = ':';
		msg[i++] = ' ';
		msg[i++] = '0';
		msg[i++] = 'x';
		to_hex(version, msg + i);
		i += 2;

		msg[i++] = '[';
		msg[i++] = 'i';
		msg[i++] = 's';
		msg[i++] = ']';
		msg[i++] = '\n';
		msg[i++] = '\0';
		SERIAL_OBJ.print(msg);

		// Put the Device Back in Read DATA Continuous Mode
		adc_send_command(RDATAC);
		blink_interval_millis = BLINK_INTERVAL_SENDING;
	}
}

void loop(void)
{
	char byte_buf[DATA_BUF_SIZE];

	blink_led();
	lead_leds.update_tick();

	if (!setup_2_run) {
		setup_2();
		setup_2_run = 1;
	}
	// wait for a non-zero byte as a ping from the computer
	// loop until data available
	if (in_byte == 0) {
		check_for_ping_from_serial();
	} else {
		wait_for_drdy("no data", 5000);
		fill_sample_frame(byte_buf);
		SERIAL_OBJ.print(byte_buf);
	}
}
