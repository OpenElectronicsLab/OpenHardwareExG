#include <Arduino.h>
#include "eeg_mouse_firmware.h"
#include "eeg_lead_leds.h"

enum states {
	first_data_state = 0,
	last_data_state = 2 * 16 * 2,
	latch_start,
	latch_end,
	last_state = latch_end
};

Eeg_lead_leds::Eeg_lead_leds()
{
	leds_state = 0;
	step = 0;
}

void Eeg_lead_leds::begin()
{
	// set up the pins for the LEDs
	pinMode(IPIN_LED_ENABLE, OUTPUT);
	pinMode(PIN_LED_LATCH, OUTPUT);
	pinMode(IPIN_LED_CLEAR, OUTPUT);
	pinMode(PIN_LED_CLK, OUTPUT);
	pinMode(PIN_LED_SERIAL, OUTPUT);

	digitalWrite(PIN_LED_LATCH, LOW);
	digitalWrite(PIN_LED_CLK, LOW);
	digitalWrite(IPIN_LED_ENABLE, LOW);

	// clear the LEDs to start
	digitalWrite(IPIN_LED_CLEAR, LOW);
	delayMicroseconds(10);
	digitalWrite(IPIN_LED_CLEAR, HIGH);

	update_all();
}

void Eeg_lead_leds::set_green_led(int led_num, bool on)
{
	uint32_t mask = (1 << (2 * led_num + 1));

	leds_state = (leds_state & ~mask);
	if (on) {
		leds_state |= mask;
	}
}

void Eeg_lead_leds::set_yellow_led(int led_num, bool on)
{
	uint32_t mask = (1 << (2 * led_num));

	leds_state = (leds_state & ~mask);
	if (on) {
		leds_state |= mask;
	}
}

void Eeg_lead_leds::update_tick()
{
	switch (step) {
	case latch_start:
		// latch the data from the shift register to the LEDs
		digitalWrite(PIN_LED_LATCH, HIGH);
		++step;
		break;

	case latch_end:
		// reset the latch
		digitalWrite(PIN_LED_LATCH, LOW);
		step = 0;
		break;

	default:
		if (step % 2 == 0) {
			// ready the clock and set the data
			digitalWrite(PIN_LED_CLK, LOW);
			digitalWrite(PIN_LED_SERIAL,
				     ((leds_state >> (step / 2)) & 1) ? HIGH :
				     LOW);
		} else {
			// clock out the data we set
			digitalWrite(PIN_LED_CLK, HIGH);
		}
		++step;
		break;
	}
}

void Eeg_lead_leds::update_all()
{
	step = 0;
	do {
		update_tick();
		delayMicroseconds(10);
	} while (step != 0);
}
