#!/usr/bin/perl

# turn off output buffering
$| = 1;

my $samplerate  = 250;            # SPS
my $numchannels = 8;
my $pi          = 3.1415926535;

my $dt            = 1.0 / $samplerate;
my $lowpass_freq  = 30;
my $lowpass_alpha = $dt / ( ( 1 / ( 2 * $pi * $lowpass_freq ) ) + $dt );

my $hipass_freq = 15;
my $hipass_alpha = 1 / ( 1 + ( 2 * $pi * $hipass_freq ) * $dt );

my $smoothed_freq = 5;
my $smoothed_alpha = $dt / ( ( 1 / ( 2 * $pi * $smoothed_freq ) ) + $dt );

my @previous_values   = ( 0, 0, 0, 0, 0, 0, 0, 0 );
my @previous_hipass   = ( 0, 0, 0, 0, 0, 0, 0, 0 );
my @previous_lowpass  = ( 0, 0, 0, 0, 0, 0, 0, 0 );
my @previous_smoothed = ( 0, 0, 0, 0, 0, 0, 0, 0 );

sub lowpass_filter {
    my ( $channel, $in_val ) = @_;

    my $out_val =
      ( $previous_lowpass[$channel] * ( 1 - $lowpass_alpha ) ) +
      ( $in_val * $lowpass_alpha );

    $previous_lowpass[$channel] = $out_val;

    return $out_val;
}

sub hipass_filter {
    my ( $channel, $in_val ) = @_;

    my $out_val =
      ( $hipass_alpha * $previous_highpass[$channel] ) +
      $hipass_alpha * ( $in_val - $previous_values[$channel] );

    $previous_values[$channel] = $in_val;
    $previous_hipass[$channel] = $out_val;

    return $out_val;
}

sub final_smooth {
    my ( $channel, $in_val ) = @_;

    my $abs_val = abs $in_val;

    my $out_val =
      ( $previous_smoothed[$channel] * ( 1 - $smoothed_alpha ) ) +
      ( $abs_val * $smoothed_alpha );

    $previous_smoothed[$channel] = $out_val;

    return $out_val;
}

sub smooth {
    my ( $channel, $in_val ) = @_;
    my $mid_val = hipass_filter( $channel, $in_val );
    my $rough_val = lowpass_filter( $channel, $mid_val );
    my $out_val = final_smooth( $channel, $rough_val );
    return sprintf( "%.7f", $out_val );
}

# C, 00, 00, 0, 0, 0, 0, -0.1136117, -0.1485806, -0.1476560, -0.1508017, -0.2974134, -0.2481733, -0.2990923, -0.9263688

my $valid_row_regex = qr/
   (?<magic>C),\s*.*
   (?<loff_statp>[0-9A-F]{2}),\s*
   (?<loff_statn>[0-9A-F]{2}),\s*
   (?<gpio_1>[01]),\s*
   (?<gpio_2>[01]),\s*
   (?<gpio_3>[01]),\s*
   (?<gpio_4>[01]),\s*
   (?<chan1>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan2>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan3>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan4>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan5>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan6>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan7>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan8>-?[0-9]+(?:\.[0-9]*))\s*
/x;

my @row;
while (<STDIN>) {

    # parse the data
    if ( $_ =~ m/$valid_row_regex/ ) {
        print join( ", ",
            $+{magic},
            $+{loff_statp},
            $+{loff_statn},
            $+{gpio_1},
            $+{gpio_2},
            $+{gpio_3},
            $+{gpio_4},
            smooth( 1, $+{chan1} ),
            smooth( 2, $+{chan2} ),
            smooth( 3, $+{chan3} ),
            smooth( 4, $+{chan4} ),
            smooth( 5, $+{chan5} ),
            smooth( 6, $+{chan6} ),
            smooth( 7, $+{chan7} ),
            smooth( 8, $+{chan8} ),
          ),
          "\n";
    }
    else {
        die "unrecognized data string:\n", $_, "\n";
    }
}
