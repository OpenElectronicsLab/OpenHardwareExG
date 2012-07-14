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
#include "ads1298.h"
#include "eeg-mouse.h"
#include "eeg-mouse-usb-descriptors.h"
#include "util.h"
#include "opencm3util.h"

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
			 * This Linux cdc_acm driver requires this to be
			 * implemented even though it's optional in the CDC
			 * spec, and we don't advertise it in the ACM
			 * functional descriptor.
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

u8 send_command(u16 command, u8 data)
{
	u16 return_value;
	u16 ignore;

	gpio_clear(ADS_GPIO, GPIO3);
	spi_send(SPI1, command);
	ignore = spi_read(SPI1);
	spi_send(SPI1, data);
	return_value = spi_read(SPI1);
	gpio_set(ADS_GPIO, GPIO3);
	return (u8) return_value;
}

u8 read_motion_axis(u8 axis)
{
	u16 command;
	u8 data;

	data = 0;

	command =
	    /* READ bit */
	    (0x1 << 7) |
	    /* MS bit:  When 0 do not increment address */
	    (0x0 << 6) |
	    /* bits 2-7 are address */
	    (axis << 0);

	return send_command(command, data);
}

u32 read_motion()
{
	u8 x, y, z;
	u32 combined;

	x = read_motion_axis(0x29);
	y = read_motion_axis(0x2B);
	z = read_motion_axis(0x2D);

	combined = (((u32) x) << 16) | (((u32) y) << 8) | z;
	return combined;
}

void setup_accelerometer()
{
	u16 command;
	u8 data;

	command =
	    /* READ bit not set */
	    (0x0 << 7) |
	    /* MS bit:  When 0 do not increment address */
	    (0x0 << 6) |
	    /* bits 2-7 are address */
	    (0x20 << 0);

	data =
	    /* data rate selection, 1 = 400Hz */
	    (0x1 << 7) |
	    /* power down control, 1 = active */
	    (0x1 << 6) |
	    /* full scale selection (1 = 8G, 0 = 2G) */
	    (0x0 << 5) |
	    /* Z axis enable */
	    (0x1 << 2) |
	    /* Y axis enable */
	    (0x1 << 1) |
	    /* X axis enable */
	    (0x1 << 0);

	send_command(command, data);
}

// rotates all of the letters in the buffer forward one letter.
static void echo_with_read_motion(char *buf, int *len)
{
	int i;
	u32 motion;
	u8 x, y, z;

	motion = read_motion();
	x = (u8) (motion >> 16);
	y = (u8) (motion >> 8);
	z = (u8) (motion >> 0);

	i = 0;

	buf[i++] = 'X';
	buf[i++] = ':';
	buf[i++] = ' ';
	buf[i++] = '0';
	buf[i++] = 'x';
	buf[i++] = to_hex(x, 1);
	buf[i++] = to_hex(x, 0);

	buf[i++] = ',';
	buf[i++] = ' ';

	buf[i++] = 'Y';
	buf[i++] = ':';
	buf[i++] = ' ';
	buf[i++] = '0';
	buf[i++] = 'x';
	buf[i++] = to_hex(y, 1);
	buf[i++] = to_hex(y, 0);

	buf[i++] = ',';
	buf[i++] = ' ';

	buf[i++] = 'Z';
	buf[i++] = ':';
	buf[i++] = ' ';
	buf[i++] = '0';
	buf[i++] = 'x';
	buf[i++] = to_hex(z, 1);
	buf[i++] = to_hex(z, 0);

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
		echo_with_read_motion(buf, &len);
		while (usbd_ep_write_packet(EEG_MOUSE_USB_DATA_ENDPOINT, buf,
			len) == 0) {
		}
	}
	/* flash the LEDs so we know we're doing something */
	gpio_toggle(GPIOD, GPIO12 | GPIO13 | GPIO14 | GPIO15);
}

static void cdcacm_set_config(u16 wValue)
{
	(void)wValue;

	usbd_ep_setup(0x01, USB_ENDPOINT_ATTR_BULK, 64, cdcacm_data_rx_cb);
	usbd_ep_setup(EEG_MOUSE_USB_DATA_ENDPOINT, USB_ENDPOINT_ATTR_BULK, 64, NULL);
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
				    /* USB OTG */
				    RCC_AHB2ENR_OTGFSEN);

	rcc_peripheral_enable_clock(&RCC_APB2ENR,
				    /* SPI 1 */
				    RCC_APB2ENR_SPI1EN);
}

void setup_usb_fullspeed()
{
	gpio_mode_setup(SPI_GPIO, GPIO_MODE_AF, GPIO_PUPD_NONE,
			GPIO9 | GPIO11 | GPIO12);
	gpio_set_af(SPI_GPIO, GPIO_AF10, GPIO9 | GPIO11 | GPIO12);

	usbd_init(&otgfs_usb_driver, &dev, &config, usb_strings);
	usbd_register_set_config_callback(cdcacm_set_config);
}

void setup_spi()
{
	gpio_mode_setup(SPI_GPIO, GPIO_MODE_AF, GPIO_PUPD_NONE,
			/* serial clock */
			PIN_SCLK |
			/* master in/slave out */
			PIN_DIN |
			/* master out/slave in */
			PIN_DOUT);
	gpio_set_af(SPI_GPIO, GPIO_AF5, PIN_SCLK | PIN_DIN | PIN_DOUT);

	spi_disable_crc(SPI1);
	spi_init_master(SPI1, SPI_CR1_BAUDRATE_FPCLK_DIV_32,
			/* high or low for the peripheral device */
			SPI_CR1_CPOL_CLK_TO_0_WHEN_IDLE,
			/* CPHA: Clock phase: read on falling edge of clock */
			SPI_CR1_CPHA_CLK_TRANSITION_2,
			/* DFF: Date frame format (8 or 16 bit) */
			SPI_CR1_DFF_8BIT,
			/* Most or Least Sig Bit First */
			SPI_CR1_MSBFIRST);

	spi_enable_software_slave_management(SPI1);
	spi_set_nss_high(SPI1);

	spi_clear_mode_fault(SPI1);

	spi_enable(SPI1);
}

void print_error(const char *buf, u16 len)
{
	while (usbd_ep_write_packet(EEG_MOUSE_USB_DATA_ENDPOINT, buf,
		len) == 0) {
	}
}

void wait_for_drdy(const char *msg, u16 msg_len, unsigned interval)
{
	unsigned i = 0;
	while (gpio_get(ADS_GPIO, IPIN_DRDY) != 0) {
		usbd_poll();
		if (i < interval) {
			continue;
		}
		i = 0;
		print_error(msg, msg_len);
	}
}

void adc_send_command(int cmd)
{
	gpio_clear(ADS_GPIO, IPIN_CS);
	spi_xfer(SPI1, cmd);
	pause_microseconds(1);
	gpio_set(ADS_GPIO, IPIN_CS);
}

void adc_wreg(int reg, int val)
{
	gpio_clear(ADS_GPIO, IPIN_CS);

	spi_xfer(SPI1, WREG | reg);
	spi_xfer(SPI1, 0);	// number of registers to be read/written – 1
	spi_xfer(SPI1, val);

	pause_microseconds(1);
	gpio_set(ADS_GPIO, IPIN_CS);
}

void setup_ads1298()
{
	unsigned i;

	/* chip select */
	gpio_mode_setup(ADS_GPIO, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE,
			IPIN_CS |
			PIN_CLKSEL |
			IPIN_PWDN |
			IPIN_RESET |
			PIN_START);

	gpio_mode_setup(ADS_GPIO, GPIO_MODE_INPUT, GPIO_PUPD_NONE, IPIN_DRDY);

	setup_spi();

	//gpio_clear(ADS_GPIO, IPIN_CS);
	gpio_set(ADS_GPIO, PIN_CLKSEL);

	// Wait for 20 microseconds Oscillator to Wake Up
	pause_microseconds(50);	// we'll actually wait 50

	gpio_set(ADS_GPIO, IPIN_PWDN);
	gpio_set(ADS_GPIO, IPIN_RESET);

	// Wait for 33 milliseconds (we will use 100 millis)
	//  for Power-On Reset and Oscillator Start-Up
	pause_microseconds(100 * 1000);

	// Issue Reset Pulse,
	gpio_clear(ADS_GPIO, IPIN_RESET);
	// actually only needs 1 microsecond, we'll go with 100
	pause_microseconds(100);
	gpio_set(ADS_GPIO, IPIN_RESET);
	// Wait for 18 tCLKs AKA 9 microseconds, we use 100
	pause_microseconds(100);

	// Send SDATAC Command (Stop Read Data Continuously mode)
	adc_send_command(SDATAC);

	// All GPIO set to output 0x0000
	// (floating CMOS inputs can flicker on and off, creating noise)
	adc_wreg(GPIO, 0);

	// Power up the internal reference and wait for it to settle
	adc_wreg(CONFIG3, RLDREF_INT | PD_RLD | PD_REFBUF | VREF_4V | CONFIG3_const);
	pause_microseconds(150 * 1000);

	adc_wreg(RLD_SENSP, 0x01);	// only use channel IN1P and IN1N
	adc_wreg(RLD_SENSN, 0x01);	// for the RLD Measurement

	// Write Certain Registers, Including Input Short
	// Set Device in HR Mode and DR = fMOD/1024
	adc_wreg(CONFIG1, LOW_POWR_250_SPS);
	adc_wreg(CONFIG2, INT_TEST);	// generate internal test signals
	// Set the first two channels to input signal
	for (i = 1; i <= 2; ++i) {
		adc_wreg(CHnSET + i, ELECTRODE_INPUT | GAIN_12X);
	}
	// Set all remaining channels to shorted inputs
	for (; i <= 8; ++i) {
		adc_wreg(CHnSET + i, SHORTED | GAIN_12X);
	}

	gpio_set(ADS_GPIO, PIN_START);
	wait_for_drdy("waiting for DRDY in setup\r\n", 26, 1000);
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
	setup_ads1298();
	setup_usb_fullspeed();
	setup_leds();
	setup_accelerometer();

	while (1) {
		usbd_poll();
	}
}
