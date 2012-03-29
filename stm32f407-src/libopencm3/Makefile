##
## This file is part of the libopencm3 project.
##
## Copyright (C) 2009 Uwe Hermann <uwe@hermann-uwe.de>
##
## This library is free software: you can redistribute it and/or modify
## it under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This library is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this library.  If not, see <http://www.gnu.org/licenses/>.
##

PREFIX		?= arm-none-eabi
#PREFIX		?= arm-elf
DESTDIR		?= .
INCDIR		= $(DESTDIR)/$(PREFIX)/include
LIBDIR		= $(DESTDIR)/$(PREFIX)/lib
SHAREDIR	= $(DESTDIR)/$(PREFIX)/share/libopencm3/scripts
INSTALL		= install

TARGETS = stm32/f4

all: build

build: lib

lib:
	$(Q)for i in $(addprefix $@/,$(TARGETS)); do \
		if [ -d $$i ]; then \
			printf "  BUILD   $$i\n"; \
			$(MAKE) -C $$i || exit $?; \
		fi; \
	done

clean:
	$(Q)for i in $(addprefix lib/,$(TARGETS)) \
		     $(addsuffix /*/*,$(addprefix examples/,$(TARGETS))); do \
		if [ -d $$i ]; then \
			printf "  CLEAN   $$i\n"; \
			$(MAKE) -C $$i clean || exit $?; \
		fi; \
	done
	@printf "  CLEAN   doxygen\n"
	$(Q)rm -rf doxygen

.PHONY: build lib examples install doxy clean

