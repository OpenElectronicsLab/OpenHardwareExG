#ifndef _OPENCM3UTIL_H_
#define _OPENCM3UTIL_H_

#include <libopencm3/stm32/f4/spi.h>

u32 spi_read_mode_fault(u32 spi);
void spi_clear_mode_fault(u32 spi);

#endif /* _OPENCM3UTIL_H_ */
