#include <Arduino.h>
#include "OpenHardwareExG_firmware_rev1.h"
#include "exg_lead_leds.h"

const int num_inputs_per_channel = 2;	// IN1N, IN1P
const int num_leds =
    Eeg_lead_leds::num_channels * num_inputs_per_channel *
    Eeg_lead_leds::num_colors;
const int states_per_led = 2;	// clock low and high

enum states {
	first_data_state = 0,
	last_data_state = (states_per_led * num_leds) - 1,
	latch_start,		// no value is the same as previous element + 1
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

	// set LEDs to leds_state (probably 0, all off)
	update_all();
}

void Eeg_lead_leds::set_led(led_color color, int channel, polarity pol, bool on)
{
	int led_num = (num_colors * (channel + pol)) + color;
	uint32_t mask = (1 << led_num);

	leds_state = (leds_state & ~mask);
	if (on) {
		leds_state |= mask;
	}
}

void Eeg_lead_leds::set_green_positive(int channel, bool on)
{
	set_led(green, channel, positive, on);
}

void Eeg_lead_leds::set_yellow_positive(int channel, bool on)
{
	set_led(yellow, channel, positive, on);
}

void Eeg_lead_leds::set_green_negative(int channel, bool on)
{
	set_led(green, channel, negative, on);
}

void Eeg_lead_leds::set_yellow_negative(int channel, bool on)
{
	set_led(yellow, channel, negative, on);
}

void Eeg_lead_leds::update_tick()
{
	switch (step) {
	case latch_start:	// this happens almost last (defaults are first)
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
		if (step % states_per_led == 0) {
			// ready the clock and set the data
			digitalWrite(PIN_LED_CLK, LOW);
			int bit_number_for_led = step / states_per_led;
			int bit_val = (1 & (leds_state >> bit_number_for_led));
			digitalWrite(PIN_LED_SERIAL, bit_val ? HIGH : LOW);
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
