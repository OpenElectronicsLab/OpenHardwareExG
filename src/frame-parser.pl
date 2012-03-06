#!/usr/bin/perl

use strict;
use warnings;

my $regex  = qr/\[go\]([A-P]*)\[on\]/;
while (<>) {
    if( $_ =~ m/$regex/ ) {
        print $1, "\n";
    }
}
