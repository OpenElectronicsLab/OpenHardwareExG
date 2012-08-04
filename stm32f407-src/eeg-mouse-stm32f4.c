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
// actual size today is 64, but a few extra will not hurt
#define DATA_BUF_SIZE 800
// GLOBALS
int send_data;
// END GLOBALS

static int cdcacm_control_request(struct usb_setup_data *req, u8 ** buf,
				  u16 * len,
				  void (**complete) (struct usb_setup_data *
						     req))
{
	// by casting to void, we avoid an unused argument warning
	(void)complete;
	(void)buf;

	switch (req->bRequest) {
	case USB_CDC_REQ_SET_CONTROL_LINE_STATE:{
			// This Linux cdc_acm driver requires this to be
			// implemented even though it's optional in the CDC
			// spec, and we don't advertise it in the ACM
			// functional descriptor.
			return 1;
		}
	case USB_CDC_REQ_SET_LINE_CODING:
		if (*len < sizeof(struct usb_cdc_line_coding))
			return 0;

		return 1;
	}
	return 0;
}

static void cdcacm_data_rx_cb(u8 ep)
{

	char buf[64];
	int len = usbd_ep_read_packet(0x01, buf, 64);

	// by casting to void, we avoid an unused argument warning
	(void)ep;

	// if (ep != EEG_MOUSE_USB_DATA_ENDPOINT) {
	//      return;
	// }

	if (len) {
		send_data = (buf[0] != 'x');
	}
	// flash the LEDs so we know we're doing something
	gpio_toggle(GPIOD, GPIO12 | GPIO13 | GPIO14 | GPIO15);
}

static void cdcacm_set_config(u16 wValue)
{
	(void)wValue;

	usbd_ep_setup(0x01, USB_ENDPOINT_ATTR_BULK, 64, cdcacm_data_rx_cb);
	usbd_ep_setup(EEG_MOUSE_USB_DATA_ENDPOINT, USB_ENDPOINT_ATTR_BULK, 64,
		      NULL);
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
				    // GPIO A
				    RCC_AHB1ENR_IOPAEN |
				    // GPIO D
				    RCC_AHB1ENR_IOPDEN |
				    // GPIO E
				    RCC_AHB1ENR_IOPEEN);

	rcc_peripheral_enable_clock(&RCC_AHB2ENR,
				    // USB OTG
				    RCC_AHB2ENR_OTGFSEN);

	rcc_peripheral_enable_clock(&RCC_APB2ENR,
				    // SPI 1
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

u32 setup_spi()
{
	gpio_mode_setup(SPI_GPIO, GPIO_MODE_AF, GPIO_PUPD_NONE,
			// serial clock
			PIN_SCLK |
			// master in/slave out
			PIN_DIN |
			// master out/slave in
			PIN_DOUT);
	gpio_set_af(SPI_GPIO, GPIO_AF5, PIN_SCLK | PIN_DIN | PIN_DOUT);

	spi_disable_crc(SPI1);
	spi_init_master(SPI1, SPI_CR1_BAUDRATE_FPCLK_DIV_64,
			// high or low for the peripheral device
			SPI_CR1_CPOL_CLK_TO_0_WHEN_IDLE,
			// CPHA: Clock phase: read on falling edge of clock
			SPI_CR1_CPHA_CLK_TRANSITION_2,
			// DFF: Date frame format (8 or 16 bit)
			SPI_CR1_DFF_8BIT,
			// Most or Least Sig Bit First
			SPI_CR1_MSBFIRST);

	spi_enable_software_slave_management(SPI1);
	spi_set_nss_high(SPI1);

	spi_clear_mode_fault(SPI1);

	spi_enable(SPI1);

	u32 reg = SPI_CR1(SPI1);
	return reg;
}

void print_msg(const char *msg, u16 len)
{
	if (!send_data) {
		return;
	}

	while (usbd_ep_write_packet(EEG_MOUSE_USB_DATA_ENDPOINT, msg, len) == 0) {
	}
}

void print_error(const char *msg, u16 len)
{
	char buf[len + 11];
	u16 i = 0;

	buf[i++] = '[';
	buf[i++] = 'o';
	buf[i++] = 'h';
	buf[i++] = ']';

	for (u16 j = 0; j < len && msg[j] != '\0'; ++j) {
		buf[i++] = msg[j];
	}

	buf[i++] = '[';
	buf[i++] = 'n';
	buf[i++] = 'o';
	buf[i++] = ']';
	buf[i++] = '\r';
	buf[i++] = '\n';
	buf[i++] = '\0';

	print_msg(buf, i);
}

int data_ready()
{
	return 0 == gpio_get(ADS_GPIO, IPIN_DRDY);
}

void wait_for_drdy(const char *msg, u16 msg_len, unsigned approx_seconds)
{
	// TODO setup timer and compare actual time, so we do not have to
	// count cpu cycles.
	unsigned USB_POLL_CYCLES = 150;
	unsigned interval = approx_seconds * 168000000 / USB_POLL_CYCLES;
	unsigned i = 0;
	while (!data_ready()) {
		usbd_poll();
		++i;
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
	pause_microseconds(1);

	spi_xfer(SPI1, cmd);
	pause_microseconds(16);

	gpio_set(ADS_GPIO, IPIN_CS);
	pause_microseconds(16);
}

void adc_wreg(int reg, int val)
{
	gpio_clear(ADS_GPIO, IPIN_CS);
	pause_microseconds(1);

	spi_xfer(SPI1, WREG | reg);
	pause_microseconds(16);

	spi_xfer(SPI1, 0);	// number of registers to be read/written – 1
	pause_microseconds(16);

	spi_xfer(SPI1, val);
	pause_microseconds(16);

	gpio_set(ADS_GPIO, IPIN_CS);
	pause_microseconds(16);
}

u8 adc_rreg(int reg)
{
	u16 val;

	gpio_clear(ADS_GPIO, IPIN_CS);
	pause_microseconds(1);

	spi_xfer(SPI1, RREG | reg);
	pause_microseconds(16);

	spi_xfer(SPI1, 0);	// number of registers to be read/written – 1
	pause_microseconds(16);

	val = spi_xfer(SPI1, 0);
	pause_microseconds(16);

	gpio_set(ADS_GPIO, IPIN_CS);
	pause_microseconds(16);

	return (u8) val;
}

void setup_ads1298()
{
	unsigned i;

	// chip select
	gpio_mode_setup(ADS_GPIO, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE,
			IPIN_CS |
			PIN_CLKSEL | IPIN_PWDN | IPIN_RESET | PIN_START);

	gpio_mode_setup(ADS_GPIO, GPIO_MODE_INPUT, GPIO_PUPD_NONE, IPIN_DRDY);

	//gpio_clear(ADS_GPIO, IPIN_CS);
	gpio_set(ADS_GPIO, PIN_CLKSEL);

	// Wait for 20 microseconds Oscillator to Wake Up
	pause_microseconds(1000);	// we'll actually wait 1 millisecond

	gpio_set(ADS_GPIO, IPIN_PWDN);
	gpio_set(ADS_GPIO, IPIN_RESET);

	// Wait for 33 milliseconds (we will use 100 millis)
	//  for Power-On Reset and Oscillator Start-Up
	pause_microseconds(100 * 1000);

	// Issue Reset Pulse,
	gpio_clear(ADS_GPIO, IPIN_RESET);
	// actually only needs 1 microsecond, we'll go with 1000
	pause_microseconds(1000);
	gpio_set(ADS_GPIO, IPIN_RESET);
	// Wait for 18 tCLKs AKA 9 microseconds, we use 1000
	pause_microseconds(1000);

	// Send SDATAC Command (Stop Read Data Continuously mode)
	adc_send_command(SDATAC);

	// Wait for 4 tCLKs AKA 2 microseconds, we use 1000
	pause_microseconds(1000);

	// All GPIO set to output 0x0000
	// (floating CMOS inputs can flicker on and off, creating noise)
	adc_wreg(GPIO, 0);

	// Power up the internal reference and wait for it to settle
	adc_wreg(CONFIG3,
		 RLDREF_INT | PD_RLD | PD_REFBUF | VREF_4V | CONFIG3_const);
	pause_microseconds(150 * 1000);

	adc_wreg(RLD_SENSP, 0x01);	// only use channel IN1P and IN1N

	// Wait for 4 tCLKs AKA 2 microseconds, we use 1000
	pause_microseconds(1000);

	adc_wreg(RLD_SENSN, 0x01);	// for the RLD Measurement

	// Write Certain Registers, Including Input Short
	// Set Device in HR Mode and DR = fMOD/1024
	adc_wreg(CONFIG1, LOW_POWR_250_SPS);
	// Wait for 4 tCLKs AKA 2 microseconds, we use 1000
	pause_microseconds(1000);

	adc_wreg(CONFIG2, INT_TEST);	// generate internal test signals
	// Wait for 4 tCLKs AKA 2 microseconds, we use 1000
	pause_microseconds(1000);

	// Set the first two channels to input signal
	for (i = 1; i <= 2; ++i) {
		// adc_wreg(CHnSET + i, ELECTRODE_INPUT | GAIN_12X);
		adc_wreg(CHnSET + i, TEST_SIGNAL | GAIN_12X);
		// Wait for 4 tCLKs AKA 2 microseconds, we use 1000
		pause_microseconds(1000);
	}
	// Set all remaining channels to shorted inputs
	for (; i <= 8; ++i) {
		adc_wreg(CHnSET + i, SHORTED | GAIN_12X);
		// Wait for 4 tCLKs AKA 2 microseconds, we use 1000
		pause_microseconds(1000);
	}

	gpio_set(ADS_GPIO, PIN_START);
	// wait_for_drdy("waiting for DRDY in setup", 25, 5);
	adc_send_command(RDATAC);
}

void setup_leds()
{
	// enable the four LEDs
	gpio_mode_setup(GPIOD, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE,
			GPIO12 | GPIO13 | GPIO14 | GPIO15);
	// Set two LEDs for wigwag effect when toggling.
	gpio_set(GPIOD, GPIO12 | GPIO14);
}

unsigned int fill_debug_frame_inner(char *byte_buf, const char *type, u32 val)
{
	unsigned int pos = 0;
	unsigned int i = 0;

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'u';
	byte_buf[pos++] = 'g';
	byte_buf[pos++] = ']';

	while (type[i] != '\0') {
		byte_buf[pos++] = type[i++];
	}
	byte_buf[pos++] = ':';
	byte_buf[pos++] = ' ';

	byte_buf[pos++] = to_hex((u8) (val >> 24), 1);
	byte_buf[pos++] = to_hex((u8) (val >> 24), 0);

	byte_buf[pos++] = to_hex((u8) (val >> 16), 1);
	byte_buf[pos++] = to_hex((u8) (val >> 16), 0);

	byte_buf[pos++] = to_hex((u8) (val >> 8), 1);
	byte_buf[pos++] = to_hex((u8) (val >> 8), 0);

	byte_buf[pos++] = to_hex((u8) (val >> 0), 1);
	byte_buf[pos++] = to_hex((u8) (val >> 0), 0);

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'l';
	byte_buf[pos++] = 'y';
	byte_buf[pos++] = ']';
	byte_buf[pos++] = '\r';
	byte_buf[pos++] = '\n';

	return pos;
}

unsigned int fill_debug_frame(char *byte_buf)
{
	// read the ID then the CONFIG1 registers
	u8 val1 = adc_rreg(ID);
	u8 val2 = adc_rreg(CONFIG1);
	u32 val = (val1 << 8) | val2;
	return fill_debug_frame_inner(byte_buf, "0,0,ID,CONFIG1", val);
}

// if this becomes more flexible, we may need to pass in
// the byte_buf size, but for now we are safe to skip it
unsigned int fill_sample_frame(char *byte_buf)
{
	int i, j;
	char in_byte;

	unsigned int pos = 0;

	gpio_clear(ADS_GPIO, IPIN_CS);
	pause_microseconds(1);

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'g';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = ']';

	// read 24bits of status then 24bits for each channel
	for (i = 0; i <= 8; ++i) {
		for (j = 0; j < 3; ++j) {
			in_byte = spi_xfer(SPI1, 0);
			pause_microseconds(16);
			byte_buf[pos++] = to_hex(in_byte, 1);
			byte_buf[pos++] = to_hex(in_byte, 0);
		}
	}

	byte_buf[pos++] = '[';
	byte_buf[pos++] = 'o';
	byte_buf[pos++] = 'n';
	byte_buf[pos++] = ']';
	byte_buf[pos++] = '\r';
	byte_buf[pos++] = '\n';

	gpio_set(ADS_GPIO, IPIN_CS);
	pause_microseconds(16);

	return pos;
}

int main(void)
{
	char byte_buf[DATA_BUF_SIZE];
	unsigned int len, reg_to_send;

	send_data = 0;
	reg_to_send = 1;

	setup_main_clock();
	setup_peripheral_clocks();
	u32 reg = setup_spi();
	setup_ads1298();
	setup_usb_fullspeed();
	setup_leds();

	while (1) {
		if (send_data && reg_to_send) {
			len = fill_debug_frame_inner(byte_buf, "reg", reg);
			print_msg(byte_buf, len);
			reg_to_send = 0;
		}
		// len = fill_debug_frame(byte_buf);
		// print_msg(byte_buf, len);

		// wait_for_drdy calls usbd_poll()
		wait_for_drdy("no data", 7, 2);
		len = fill_sample_frame(byte_buf);
		print_msg(byte_buf, len);
	}
}
