#!/usr/bin/perl

use strict;
use warnings;

sub v {
    my $intval = hex(shift(@_));
    my $maxsigned24bit = 0x7FFFFF;
    if ($intval > $maxsigned24bit) {
        # two's complement
        $intval = $intval - 2**24;
    }
    my $refvoltage = 4.0; # volts
    my $potential = $refvoltage * ($intval / (2.0**23 - 1));
    return $potential;
}

my $regex =
qr/\[go\]([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})\[on\]/;
while (<>) {
    if ( $_ =~ m/$regex/ ) {
        printf "%s,%11.7f,%11.7f,%11.7f,%11.7f,%11.7f,%11.7f,%11.7f,%11.7f\n", $1, v($2), v($3), v($4), v($5), v($6), v($7), v($8), v($9);
    }
}
