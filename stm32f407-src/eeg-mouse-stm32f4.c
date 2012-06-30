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
#include <libopencm3/stm32/f4/spi.h>
#include <libopencm3/stm32/f4/rcc.h>
#include <libopencm3/stm32/f4/gpio.h>
#include <libopencm3/usb/usbd.h>
#include <libopencm3/usb/cdc.h>
#include "eeg-mouse-usb-descriptors.h"
#include "util.h"

static int cdcacm_control_request(struct usb_setup_data *req, u8 ** buf,
				  u16 * len,
				  void (**complete) (struct usb_setup_data *
						     req))
{
	/* by casting to void, we avoid an unused argument warning */
	(void)complete;
	(void)buf;

	switch (req->bRequest) {
	case USB_CDC_REQ_SET_CONTROL_LINE_STATE:{
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

u8 read_who_am_i() {
	u16 data;
	u16 command;

	if (0) {
	data = 0x17;
	} else {
	command = 0;
	command = command |
	/* READ bit */
        (0x1 << 15) |
	/* MS bit:  When 0 do not increment address */
	(0x0 << 14) |
	/* bits 2-7 are address */
	(0x0F << 8);

	gpio_clear(GPIOE, GPIO2);
	spi_send(SPI1, command);
	data = spi_read(SPI1);
	gpio_set(GPIOE, GPIO2);
	}
	return (u8) data;
}

// rotates all of the letters in the buffer forward one letter.
static void echo_with_who_am_i(char *buf, int *len)
{
	int i;
	u8 b;

	b = read_who_am_i();
	i = 0;
	buf[i++] = 'h';
	buf[i++] = 'i';
	buf[i++] = ':';
	buf[i++] = ' ';
	buf[i++] = to_hex(b, 1);
	buf[i++] = to_hex(b, 0);
	buf[i++] = '\r';
	buf[i++] = '\n';

	*len = i;
}

static void cdcacm_data_rx_cb(u8 ep)
{
	(void)ep;

	char buf[64];
	int len = usbd_ep_read_packet(0x01, buf, 64);

	if (len) {
		echo_with_who_am_i(buf, &len);
		while (usbd_ep_write_packet(0x82, buf, len) == 0) ;
	}
	/* flash the LEDs so we know we're doing something */
	gpio_toggle(GPIOD, GPIO12 | GPIO13 | GPIO14 | GPIO15);
}

static void cdcacm_set_config(u16 wValue)
{
	(void)wValue;

	usbd_ep_setup(0x01, USB_ENDPOINT_ATTR_BULK, 64, cdcacm_data_rx_cb);
	usbd_ep_setup(0x82, USB_ENDPOINT_ATTR_BULK, 64, NULL);
	usbd_ep_setup(0x83, USB_ENDPOINT_ATTR_INTERRUPT, 16, NULL);

	usbd_register_control_callback(USB_REQ_TYPE_CLASS |
				       USB_REQ_TYPE_INTERFACE,
				       USB_REQ_TYPE_TYPE |
				       USB_REQ_TYPE_RECIPIENT,
				       cdcacm_control_request);
}

void setup_main_clock()
{
	rcc_clock_setup_hse_3v3(&hse_8mhz_3v3[CLOCK_3V3_168MHZ]);
}

void setup_peripheral_clocks()
{
	rcc_peripheral_enable_clock(&RCC_AHB1ENR,
		/* GPIO A */
		RCC_AHB1ENR_IOPAEN |
		/* GPIO D */
		RCC_AHB1ENR_IOPDEN |
		/* GPIO E */
		RCC_AHB1ENR_IOPEEN);

	rcc_peripheral_enable_clock(&RCC_AHB2ENR,
		/* SPI 1 */
		RCC_APB2ENR_SPI1EN |
		/* USB OTG */
		RCC_AHB2ENR_OTGFSEN);
}

void setup_usb_fullspeed()
{
	gpio_mode_setup(GPIOA, GPIO_MODE_AF, GPIO_PUPD_NONE,
			GPIO9 | GPIO11 | GPIO12);
	gpio_set_af(GPIOA, GPIO_AF10, GPIO9 | GPIO11 | GPIO12);

	usbd_init(&otgfs_usb_driver, &dev, &config, usb_strings);
	usbd_register_set_config_callback(cdcacm_set_config);
}

void setup_spi()
{
	/* chip select */
	gpio_mode_setup(GPIOE, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO2);
	/* set to high which is not-selected */
	gpio_set(GPIOE, GPIO2);

	gpio_mode_setup(GPIOA, GPIO_MODE_AF, GPIO_PUPD_NONE,
		/* serial clock */
		GPIO5 |
		/* master in/slave out */
		GPIO6 |
		/* master out/slave in */
		GPIO7);
	gpio_set_af(GPIOA, GPIO_AF5, GPIO5 | GPIO6 | GPIO7);

	spi_init_master(SPI1, SPI_CR1_BAUDRATE_FPCLK_DIV_32,
		/* high or low for the peripheral device */
		SPI_CR1_CPOL_CLK_TO_1_WHEN_IDLE,
		/* CPHA: Clock phase: read on rising edge of clock */
		SPI_CR1_CPHA_CLK_TRANSITION_2,
		/* DFF: Date frame format (8 or 16 bit) */
		SPI_CR1_DFF_8BIT,
		/* Most or Least Sig Bit First */
		SPI_CR1_MSBFIRST);
	/* spi_enable_ss_output(SPI1);*/ /* ?? */

	spi_enable(SPI1);
}

void setup_leds()
{
	/* enable the four LEDs */
	gpio_mode_setup(GPIOD, GPIO_MODE_OUTPUT,
			GPIO_PUPD_NONE, GPIO12 | GPIO13 | GPIO14 | GPIO15);
	/* Set two LEDs for wigwag effect when toggling. */
	gpio_set(GPIOD, GPIO12 | GPIO14);
}

int main(void)
{
	setup_main_clock();
	setup_peripheral_clocks();
	setup_usb_fullspeed();
	setup_spi();
	setup_leds();

	while (1)
		usbd_poll();
}
