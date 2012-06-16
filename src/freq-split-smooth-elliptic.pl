#!/usr/bin/perl
use strict;
use warnings;

# turn off channel buffering
$| = 1;

my $samplerate = 250;            # SPS
my $pi         = 3.1415926535;

my $dt = 1.0 / $samplerate;

# IIR filtering coefficients designed using scipy.signal with the specified
# function call.  The first set of each pair is used to take a weighted sum of
# the previous input values to the filter, and the second set of each pair is
# used for taking the weighted sum of the previous channels of the filter.
# N.B.: These need to be kept at high precision; pasting these with nine
# significant figures produced an unstable filter (!)
my @filter_coef = (
    {
        # 10-12 Hz 10th order elliptic bandpass filter, from
        # signal.iirdesign(wp = [10./125, 12./125], ws= [7./125, 17./125],
        #     gstop= 110, gpass=1, ftype='ellip');
        in_coef => [
            1.949501594783228700e-06,
            -1.458929916957959253e-05,
            4.674352747443366829e-05,
            -8.006558354202509870e-05,
            6.851033269566627021e-05,
            -1.924374783353002136e-19,
            -6.851033269566645994e-05,
            8.006558354202509870e-05,
            -4.674352747443366151e-05,
            1.458929916957959253e-05,
            -1.949501594783228700e-06,
        ],
        out_coef => [
            #1.000000000000000000e+00,
            -9.574998279821066660e+00,
            4.162514078352752733e+01,
            -1.081670509475952429e+02,
            1.860386794218514694e+02,
            -2.212667900149721447e+02,
            1.842959688338052331e+02,
            -1.061500581245527144e+02,
            4.046632555290385369e+01,
            -9.221250318094858400e+00,
            9.540354614515088594e-01,
        ]
    },
    {
        # 21.5-24.5 Hz 12th order elliptic bandpass filter, from
        # signal.iirdesign(wp=[21.5/125, 24.5/125], ws=[18./125, 29./125],
        #     gstop=105, gpass=1, ftype='ellip');
        in_coef => [
            6.420951837254146843e-06,
            -6.110810776438764893e-05,
            2.791417080911814497e-04,
            -8.069075813764282727e-04,
            1.641297392536303920e-03,
            -2.472581628326266188e-03,
            2.827480763593624366e-03,
            -2.472581628326268790e-03,
            1.641297392536303920e-03,
            -8.069075813764282727e-04,
            2.791417080911818291e-04,
            -6.110810776438764893e-05,
            6.420951837254146843e-06,
        ],
        out_coef => [
            #1.000000000000000000e+00,
            -9.991699885075963294e+00,
            4.752533843412010128e+01,
            -1.417241547104771087e+02,
            2.944190709641572994e+02,
            -4.482315298230243457e+02,
            5.123947397238457597e+02,
            -4.430409714057009865e+02,
            2.876397870019338825e+02,
            -1.368574810393778023e+02,
            4.536195576023762754e+01,
            -9.426452692823545476e+00,
            9.325072693442091332e-01,
        ]
    }
);

# old input and output values for each filter
my @old_filter_in_vals = (
    [ map { 0.0 } @{ $filter_coef[0]{in_coef} } ],
    [ map { 0.0 } @{ $filter_coef[1]{in_coef} } ],
);
my @old_filter_out_vals = (
    [ map { 0.0 } @{ $filter_coef[0]{out_coef} } ],
    [ map { 0.0 } @{ $filter_coef[1]{out_coef} } ],
);


my $smoothed_freq = 5;
my $smoothed_alpha = $dt / ( ( 1 / ( 2 * $pi * $smoothed_freq ) ) + $dt );

my @previous_smoothed  = map { 0.0 } @filter_coef;

sub bandpass_filter {
    my ( $channel, $in_val ) = @_;
    my $order = @{ $filter_coef[$channel]{out_coef} };

    # update the input value list with the new input value
    pop @{ $old_filter_in_vals[$channel] };
    unshift @{ $old_filter_in_vals[$channel] }, $in_val;

    # calculate a weighted sum of the old inputs minus the old outputs
    my $total = 0;
    my $i;
    for ($i = 0; $i < $order + 1; $i++) {
        $total += $filter_coef[$channel]{in_coef}[$i]
            * $old_filter_in_vals[$channel][$i];
    }
    for ($i = 0; $i < $order; $i++) {
        $total -= $filter_coef[$channel]{out_coef}[$i]
            * $old_filter_out_vals[$channel][$i];
    }

    # update the output value list with the new output value
    pop @{ $old_filter_out_vals[$channel] };
    unshift @{ $old_filter_out_vals[$channel] }, $total;

    # print "@{ $old_filter_out_vals[$channel] }\n";

    return $total;
}

sub final_smooth {
    my ( $channel, $in_val ) = @_;

    #return $in_val;
    my $abs_val = abs $in_val;

    my $out_val =
      ( $previous_smoothed[$channel] * ( 1 - $smoothed_alpha ) ) +
      ( $abs_val * $smoothed_alpha );

    $previous_smoothed[$channel] = $out_val;

    return $out_val;
}

sub smooth {
    my ( $channel, $in_val ) = @_;
    my $rough_val = bandpass_filter( $channel, $in_val );
    my $out_val = final_smooth( $channel, $rough_val );
    return sprintf( "%10f", $out_val );
}

my $valid_row_regex = qr/
   (?<val>-?[0-9]+(?:\.[0-9]*)?(?:e[+-]?[0-9]+)?)\s*
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
