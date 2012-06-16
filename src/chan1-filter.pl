#!/usr/bin/perl
use strict;
use warnings;

# turn off output buffering
$| = 1;

# C, 00, 00, 0, 0, 0, 0, -0.1136117, -0.1485806, -0.1476560, -0.1508017, -0.2974134, -0.2481733, -0.2990923, -0.9263688

my $valid_row_regex = qr/
   (?<magic>C),\s*.*
   (?<loff_statp>[0-9A-F]{2}),\s*
   (?<loff_statn>[0-9A-F]{2}),\s*
   (?<gpio_1>[01]),\s*
   (?<gpio_2>[01]),\s*
   (?<gpio_3>[01]),\s*
   (?<gpio_4>[01]),\s*
   (?<chan1>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan2>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan3>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan4>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan5>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan6>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan7>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan8>-?[0-9]+(?:\.[0-9]*))\s*
/x;

while (<STDIN>) {

    # parse the data
    if ( $_ =~ m/$valid_row_regex/ ) {
        print $+{chan1}, "\n";
    }
    else {
        warn "unrecognized data string:\n", $_, "\n";
    }
}
