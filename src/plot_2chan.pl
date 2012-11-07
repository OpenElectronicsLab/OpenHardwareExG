#!/usr/bin/perl
use strict;
use warnings;

# Inspired by Thanassis Tsiodras's script here:
# http://users.softlab.ece.ntua.gr/~ttsiod/gnuplotStreaming.html
# and Andreas Bernauer's extension here:
# http://www.lysium.de/blog/index.php?/archives/234-Plotting-data-with-gnuplot-in-real-time.html

use IO::Handle;

my $samplerate       = 250;    # SPS
my $duration_visible = 4;      # seconds
my $refresh_rate     = 10;     # Hz
my $numchannels      = 2;      #8;

# start gnuplot
my $pipe;
open( $pipe, "|-", "gnuplot -geometry 800x600" )
  or die "failed to start gnuplot: $!";
print $pipe "set xtics\n";
print $pipe "set ytics\n";
print $pipe "set style data lines\n";
print $pipe "set grid\n";
print $pipe "set term x11\n";

#print $pipe "set yrange [-0.005:0.005]\n";
#print $pipe "set yrange [-0.5:0.5]\n";
#print $pipe "set yrange [-5.0:5.0]\n";
print $pipe "set xrange [0:" . ( $samplerate * $duration_visible ) . "]\n";

# set up a list of lists for buffering the incoming data
my @data;
for ( my $i = 0 ; $i < $numchannels ; $i++ ) {
    push @data, [];
}

# generate a plot command for the appropriate number of channels (but don't sent it yet)
my $plotcommand = "plot \"-\" title 'channel 1'";
for ( my $i = 2 ; $i <= $numchannels ; $i++ ) {
    $plotcommand = $plotcommand . ", \"-\" title 'channel $i'";
}
$plotcommand = $plotcommand . "\n";

our $valid_row_regex = qr/
   (?<chan1>-?[0-9]+(?:\.[0-9]*)),\s*
   (?<chan2>-?[0-9]+(?:\.[0-9]*))[.]*
/x;
my $samples_since_last_update = 0;
while (<STDIN>) {
    next if $_ eq "\n";

    # parse the data
    if ( $_ =~ m/$valid_row_regex/ ) {
        my $chan_1 = $+{chan1};
        my $chan_2 = $+{chan2};

        push( @{ $data[0] }, $chan_1 );
        push( @{ $data[1] }, $chan_2 );
    }
    else {
        warn "unrecognized data string: '" . $_ . "'\n";
    }

    # Drop any data that's older than the interval of time we're showing
    for ( my $i = 0 ; $i < $numchannels ; $i++ ) {
        if ( scalar( @{ $data[$i] } ) > $samplerate * $duration_visible ) {
            shift @{ $data[$i] };
        }
    }

    $samples_since_last_update++;
    if ( $samples_since_last_update > $samplerate * 1. / $refresh_rate ) {
        $samples_since_last_update = 0;

        # generate the plot
        my @sorted = sort { $b <=> $a } @{ $data[0] };
        my $padding = 0.05 * ( $sorted[0] - $sorted[-1] );
        my $onemin  = $sorted[-1] - $padding;
        my $onemax  = $sorted[0] + $padding;
        print $pipe "set yrange [$onemin:$onemax]\n";
        print $pipe $plotcommand;
        for ( my $i = 0 ; $i < $numchannels ; $i++ ) {
            print $pipe join( "\n", @{ $data[$i] } ) . "\ne\n";
        }
        $pipe->flush;
    }
}

print $pipe, "exit;";
