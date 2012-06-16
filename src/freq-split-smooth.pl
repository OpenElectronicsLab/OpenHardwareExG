#!/usr/bin/perl
use strict;
use warnings;

# turn off output buffering
$| = 1;

my $samplerate = 250;            # SPS
my $pi         = 3.1415926535;

my $dt = 1.0 / $samplerate;

my @lowpass_freq = ( 11.5, 23.5 );
my @hipass_freq  = ( 10.5, 22.5 );

my @lowpass_alpha =
  map { $dt / ( ( 1 / ( 2 * $pi * $_ ) ) + $dt ) } @lowpass_freq;
my @hipass_alpha = map { 1 / ( 1 + ( 2 * $pi * $_ ) * $dt ) } @hipass_freq;

my $smoothed_freq = 5;
my $smoothed_alpha = $dt / ( ( 1 / ( 2 * $pi * $smoothed_freq ) ) + $dt );

my @previous_hipass_in = map { 0.0 * $_ } @hipass_freq;
my @previous_hipass    = map { 0.0 * $_ } @hipass_freq;
my @previous_lowpass   = map { 0.0 * $_ } @lowpass_freq;
my @previous_smoothed  = map { 0.0 * $_ } @lowpass_freq;

sub lowpass_filter {
    my ( $output, $in_val ) = @_;

    my $out_val =
      ( $previous_lowpass[$output] * ( 1 - $lowpass_alpha[$output] ) ) +
      ( $in_val * $lowpass_alpha[$output] );

    $previous_lowpass[$output] = $out_val;

    return $out_val;
}

sub hipass_filter {
    my ( $output, $in_val ) = @_;

    my $out_val =
      ( $hipass_alpha[$output] * $previous_hipass[$output] ) +
      $hipass_alpha[$output] * ( $in_val - $previous_hipass_in[$output] );

    $previous_hipass_in[$output] = $in_val;
    $previous_hipass[$output]    = $out_val;

    return $out_val;
}

sub final_smooth {
    my ( $output, $in_val ) = @_;

    my $abs_val = abs $in_val;

    my $out_val =
      ( $previous_smoothed[$output] * ( 1 - $smoothed_alpha ) ) +
      ( $abs_val * $smoothed_alpha );

    $previous_smoothed[$output] = $out_val;

    return $out_val;
}

sub smooth {
    my ( $output, $in_val ) = @_;
    my $mid_val = hipass_filter( $output, $in_val );
    my $rough_val = lowpass_filter( $output, $mid_val );
    my $out_val = final_smooth( $output, $rough_val );
    return sprintf( "%10f", $out_val );
}

my $valid_row_regex = qr/
   (?<val>-?[0-9]+(?:\.[0-9]*))\s*
/x;

my @row;
while (<STDIN>) {

    # parse the data
    if ( $_ =~ m/$valid_row_regex/ ) {
        my $val = $+{val};
        print join( ", ", smooth( 0, $val ), smooth( 1, $val ) ), "\n";
    }
    else {
        die "unrecognized data string:\n", $_, "\n";
    }
}
