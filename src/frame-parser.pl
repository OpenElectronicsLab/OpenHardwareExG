#!/usr/bin/perl

use strict;
use warnings;

# turn off output buffering
$| = 1;

sub v {
    my ($hex_str) = @_;

    my $intval = hex($hex_str);

    my $maxsigned24bit = 0x7FFFFF;
    if ( $intval > $maxsigned24bit ) {

        # two's complement
        $intval = $intval - 2**24;
    }

    my $gain = 24.0;         # PGA gain setting
    my $refvoltage = 4.0;    # volts

    my $potential = ( $refvoltage / $gain ) * ( $intval / ( 2.0**23 - 1 ) );
    return $potential;
}

# The format of the 24 status bits is:
#  (1100 + LOFF_STATP + LOFF_STATN + bits[4:7] of the GPIO register)
my $status_regex        = qr/([0-9A-F])([0-9A-F]{2})([0-9A-F]{2})([0-9A-F])/;
my @ordered_status_keys = qw/
  magic
  loff_statp
  loff_statn
  gpio_1
  gpio_2
  gpio_3
  gpio_4
  /;

sub status {
    my ($value) = @_;

    my $href = {};
    if ( $value !~ m/$status_regex/ ) {
        print STDERR "unexpected value '$value'\n";
    }
    my $gpio = hex($4);

    my $status = {};
    $status->{magic}      = $1;
    $status->{loff_statp} = $2;
    $status->{loff_statn} = $3;
    $status->{gpio_1}     = ( $gpio >> 0 ) & 0b1;
    $status->{gpio_2}     = ( $gpio >> 1 ) & 0b1;
    $status->{gpio_3}     = ( $gpio >> 2 ) & 0b1;
    $status->{gpio_4}     = ( $gpio >> 3 ) & 0b1;

    return $status;
}

my $valid_frame_regex =
qr/\[go\]([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})([0-9A-F]{6})\[on\]/;
while (<STDIN>) {
    if ( $_ =~ m/$valid_frame_regex/ ) {
        my $status = status($1);
        my $statstr = join ', ', map { $status->{$_} } @ordered_status_keys;
        printf "%s,%13.9f,%13.9f,%13.9f,%13.9f,%13.9f,%13.9f,%13.9f,%13.9f\n",
          $statstr, v($2), v($3), v($4), v($5), v($6), v($7), v($8), v($9);
    }
}
