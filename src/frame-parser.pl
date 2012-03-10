#!/usr/bin/perl

use strict;
use warnings;

my $regex =
qr/\[go\]([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})\[on\]/;
while (<>) {
    if ( $_ =~ m/$regex/ ) {
        print "$1 $2 $3 $4 $5 $6 $7 $8 $9\n";
    }
}
