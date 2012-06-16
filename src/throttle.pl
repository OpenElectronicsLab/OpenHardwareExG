#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes;

$| = 1;

while (<STDIN>) {
    Time::HiRes::usleep( 4 * 1000 );
    print $_;
}
