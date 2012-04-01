/*
 * This file is part of the libopencm3 project.
 *
 * Copyright (C) 2010 Gareth McMullin <gareth@blacksphere.co.nz>
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdlib.h>
#include <libopencm3/stm32/f4/rcc.h>
#include <libopencm3/stm32/f4/gpio.h>
#include <libopencm3/usb/usbd.h>
#include <libopencm3/usb/cdc.h>
#include "eeg-mouse-usb-descriptors.h"

static int cdcacm_control_request(struct usb_setup_data *req, u8 **buf,
		u16 *len, void (**complete)(struct usb_setup_data *req))
{
	(void)complete;
	(void)buf;

	switch (req->bRequest) {
	case USB_CDC_REQ_SET_CONTROL_LINE_STATE: {
		/*
		 * This Linux cdc_acm driver requires this to be implemented
		 * even though it's optional in the CDC spec, and we don't
		 * advertise it in the ACM functional descriptor.
		 */
		return 1;
		}
	case USB_CDC_REQ_SET_LINE_CODING:
		if (*len < sizeof(struct usb_cdc_line_coding))
			return 0;

		return 1;
	}
	return 0;
}

// rotates all of the letters in the buffer forward one letter.
static void rotate_letters(char* buf, int len) {
    int i;

    for (i = 0; i < len; ++i) {
        if (buf[i] >= 'a' && buf[i] < 'z') {
            buf[i] = buf[i] + 1;
        } else if (buf[i] == 'z') {
            buf[i] = 'a';
        }
        else if (buf[i] >= 'A' && buf[i] < 'Z') {
            buf[i] = buf[i] + 1;
        } else if (buf[i] == 'Z') {
            buf[i] = 'A';
        }
    }
}

static void cdcacm_data_rx_cb(u8 ep)
{
	(void)ep;

	char buf[64];
	int len = usbd_ep_read_packet(0x01, buf, 64);

	if (len) {
        rotate_letters(buf, len);
        while (usbd_ep_write_packet(0x82, buf, len) == 0)
			;
	}

    // flash the LEDs so we know we're doing something
	gpio_toggle(GPIOC, GPIO5);
    gpio_toggle(GPIOD, GPIO12 | GPIO13 | GPIO14 | GPIO15);
}

static void cdcacm_set_config(u16 wValue)
{
	(void)wValue;

	usbd_ep_setup(0x01, USB_ENDPOINT_ATTR_BULK, 64, cdcacm_data_rx_cb);
	usbd_ep_setup(0x82, USB_ENDPOINT_ATTR_BULK, 64, NULL);
	usbd_ep_setup(0x83, USB_ENDPOINT_ATTR_INTERRUPT, 16, NULL);

	usbd_register_control_callback(
				USB_REQ_TYPE_CLASS | USB_REQ_TYPE_INTERFACE,
				USB_REQ_TYPE_TYPE | USB_REQ_TYPE_RECIPIENT,
				cdcacm_control_request);
}

int main(void)
{
	//rcc_clock_setup_hse_3v3(&hse_8mhz_3v3[CLOCK_3V3_120MHZ]);
	rcc_clock_setup_hse_3v3(&hse_8mhz_3v3[CLOCK_3V3_168MHZ]);

	rcc_peripheral_enable_clock(&RCC_AHB1ENR, RCC_AHB1ENR_IOPAEN);
	rcc_peripheral_enable_clock(&RCC_AHB2ENR, RCC_AHB2ENR_OTGFSEN);
	rcc_peripheral_enable_clock(&RCC_AHB1ENR, RCC_AHB1ENR_IOPDEN);

	gpio_mode_setup(GPIOA, GPIO_MODE_AF, GPIO_PUPD_NONE, 
			GPIO9 | GPIO11 | GPIO12);
	gpio_set_af(GPIOA, GPIO_AF10, GPIO9 | GPIO11 | GPIO12);

	usbd_init(&otgfs_usb_driver, &dev, &config, usb_strings);
	usbd_register_set_config_callback(cdcacm_set_config);

	/* Set two LEDs for wigwag effect when toggling. */
	gpio_mode_setup(GPIOD, GPIO_MODE_OUTPUT,
			GPIO_PUPD_NONE, GPIO12 | GPIO13 | GPIO14 | GPIO15);
	gpio_set(GPIOD, GPIO12 | GPIO14);

	while (1)
		usbd_poll();
}

