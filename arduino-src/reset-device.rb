#!/usr/bin/env ruby

# resets the Arduino Due for programming

# Copyright (C) 2013 Eric Herman <eric@freesa.org>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

require 'serialport'
port = ARGV[0] || "ttyACM0";
device = "/dev/#{port}";
puts "Forcing reset using 1200bps open/close on port #{device}"
SerialPort.open(device, 1200) {|sp|}
