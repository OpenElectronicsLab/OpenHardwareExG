#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use Math::Trig;
use YAML qw( LoadFile );

my $pi = Math::Trig::pi;

# turn off channel buffering
$| = 1;


my $skipsmooth = 0;
my $samplerate = 250;            # SPS

GetOptions("skipsmooth" => \$skipsmooth);

my $dt = 1.0 / $samplerate;

# IIR filtering coefficients designed using scipy.signal with the specified
# function call.  The first set of each pair is used to take a weighted sum of
# the previous input values to the filter, and the second set of each pair is
# used for taking the weighted sum of the previous channels of the filter.
# N.B.: These need to be kept at high precision; pasting these with nine
# significant figures produced an unstable filter (!)
my $filter_coef = LoadFile('filter_coefs.yaml');

# old input and output values for each filter
my @old_filter_in_vals = (
    [ map { 0.0 } @{ $filter_coef->{broad_lowpass_filter}->{in_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{broad_lowpass_filter}->{in_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{baseline_filter}->{in_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{smooth_filter}->{in_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{smooth_filter}->{in_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{smooth_filter}->{in_coef} } ],
);
my @old_filter_out_vals = (
    [ map { 0.0 } @{ $filter_coef->{broad_lowpass_filter}->{out_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{broad_lowpass_filter}->{out_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{baseline_filter}->{out_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{smooth_filter}->{out_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{smooth_filter}->{out_coef} } ],
    [ map { 0.0 } @{ $filter_coef->{smooth_filter}->{out_coef} } ],
);


sub linear_filter {
    my ( $buffer_number, $coef_name, $in_val ) = @_;
    my $order = @{ $filter_coef->{$coef_name}->{out_coef} };

    # update the input value list with the new input value
    pop @{ $old_filter_in_vals[$buffer_number] };
    unshift @{ $old_filter_in_vals[$buffer_number] }, $in_val;

    # calculate a weighted sum of the old inputs minus the old outputs
    my $total = 0;
    my $i;
    for ($i = 0; $i < $order + 1; $i++) {
        $total += $filter_coef->{$coef_name}->{in_coef}[$i]
            * $old_filter_in_vals[$buffer_number][$i];
    }
    for ($i = 0; $i < $order; $i++) {
        $total -= $filter_coef->{$coef_name}->{out_coef}[$i]
            * $old_filter_out_vals[$buffer_number][$i];
    }

    # update the output value list with the new output value
    pop @{ $old_filter_out_vals[$buffer_number] };
    unshift @{ $old_filter_out_vals[$buffer_number] }, $total;

    # print "@{ $old_filter_out_vals[$channel] }\n";

    return $total;
}

sub smooth {
    my ( $buffer_number, $coef_name, $in_val ) = @_;
    my $rough_val = linear_filter( $buffer_number, $coef_name, $in_val );
    if ($skipsmooth) {
        return sprintf( "%10f", $rough_val );
    }
    my $rectified = abs($rough_val);
    my $bufoffset = $buffer_number + (( scalar @old_filter_in_vals ) / 2);
    my $out_val = linear_filter( $bufoffset, 'smooth_filter', $rectified );
    return sprintf( "%10f", $out_val );
}

my $valid_row_regex = qr/
   (?<val1>-?[0-9]+(?:\.[0-9]*)?(?:e[+-]?[0-9]+)?)\s*,\s*
   (?<val2>-?[0-9]+(?:\.[0-9]*)?(?:e[+-]?[0-9]+)?)\s*
/x;

my @row;
while (<STDIN>) {

    # parse the data
    if ( $_ =~ m/$valid_row_regex/ ) {
        my $val1 = $+{val1};
        my $val2 = $+{val2};
        print join( ", ",
            smooth( 0, 'broad_lowpass_filter', $val1 ),
            smooth( 1, 'broad_lowpass_filter', $val2 ),
            "0.0",
        ), "\n";
    }
    else {
        die "unrecognized data string:\n", $_, "\n";
    }
}
