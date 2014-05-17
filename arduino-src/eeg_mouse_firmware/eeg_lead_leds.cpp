#include "eeg_lead_leds.h"

class Eeg_lead_leds {
	// 32 bits of LED state;
	// uint32_t leds_state;
	// int step;

Eeg_lead_leds::Eeg_lead_leds()
{
	leds_state = 0;
	step = 0;
}


void Eeg_lead_leds::set_green_led(int led_num, bool on)
{
	uint32_t mask = (1 << (2*(led_num - 1) + 1));


	leds_state = (leds_state & ~mask);
	if (on) {
		leds_state |= mask;
	}
}

void Eeg_lead_leds::set_yellow_led(int led_num, bool on)
{
}

void Eeg_lead_leds::update_tick()
{
}

void Eeg_lead_leds::update_all()
{
}
