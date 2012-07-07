#include "opencm3util.h"

u32 spi_read_mode_fault(u32 spi)
{
	return SPI_SR(spi) & SPI_SR_MODF;
}

void spi_clear_mode_fault(u32 spi)
{
	if (spi_read_mode_fault(spi)) {
		SPI_CR1(spi) = SPI_CR1(spi);
	}
}
