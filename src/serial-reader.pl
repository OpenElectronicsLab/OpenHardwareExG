#!/usr/bin/perl
# modified from: http://www.windmeadow.com/node/38

use strict;
use warnings;
use Time::HiRes;

# Sample Perl script to transmit number
# to Arduino then listen for the Arduino
# to echo it back

use Device::SerialPort;

# turn off output buffering
$| = 1;

# Set up the serial port
# 230400, 8N1 on the USB ftdi driver
my $port;
if ( -e "/dev/ttyACM0" ) {
    $port = Device::SerialPort->new("/dev/ttyACM0");
}
else {
    $port = Device::SerialPort->new("/dev/ttyUSB0");
}
$port->databits(8);
$port->baudrate(230400);
#$port->baudrate(115200);
$port->parity("none");
$port->stopbits(1);

my $missing   = 0;
my $have_sent = 0;
while (1) {

    # Poll to see if any data is coming in
    my $received = $port->lookfor();

    # If we get data, then print it
    if ($received) {
        print "'$received'\n";
        $missing = 0;
    }
    else {
        Time::HiRes::usleep(2000);
        if ( ( $missing++ % 1000 ) == 0 ) {
            if ( ( not $have_sent ) or ( $missing > 1000 ) ) {

                # Send a number to the arduino
                my $write_out = $port->write("1");
                $have_sent = 1;
            }
            if ( $missing > 1000 ) {
                print "$missing\n";
            }
        }
    }
}
