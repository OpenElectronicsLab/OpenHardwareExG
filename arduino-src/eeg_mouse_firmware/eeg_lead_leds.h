/* eeg_lead_leds.h */
#ifndef _EEG_LEAD_LEDS_
#define _EEG_LEAD_LEDS_
class Eeg_lead_leds {
	// 32 bits of LED state;
	uint32_t leds_state;
	int step;

      public:
	enum led_color { yellow, green, num_colors };
	enum { num_channels = 8 };
	enum polarity { positive = 0, negative = num_channels};

	 Eeg_lead_leds();
	void begin();

	void set_led(led_color color, int channel, polarity pol, bool on);
	void set_green_positive(int channel, bool on);
	void set_yellow_positive(int channel, bool on);
	void set_green_negative(int channel, bool on);
	void set_yellow_negative(int channel, bool on);

	void update_tick();
	void update_all();
};

#endif /* eeg_lead_leds.h */
