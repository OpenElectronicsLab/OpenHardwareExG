#!/usr/bin/perl

use strict;
use warnings;

sub v {
    my $intval = hex(shift(@_));
    my $ref = 4.;
    my $potential = $intval * $ref / (2**23 - 1);
    if ($intval > 0x7FFFFF) {
        return $potential - 2 * $ref;
    } else {
        return $potential;
    }
}

my $regex =
qr/\[go\]([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})\[on\]/;
while (<>) {
    if ( $_ =~ m/$regex/ ) {
        print $1 . "," . v($2) . "," . v($3) . "," . v($4) . "," . v($5) . "," . v($6) . "," . v($7) . "," . v($8) . "," . v($9) . "\n";
    }
}
