#!/usr/bin/perl
use strict;
use warnings;

use Time::HiRes qw(gettimeofday);

# turn off output buffering
$| = 1;

while (<STDIN>) {
    my ($seconds, $microseconds) = gettimeofday();
    chomp $_;
    printf("%d.%06d, %s\n", $seconds, $microseconds, $_);
}
