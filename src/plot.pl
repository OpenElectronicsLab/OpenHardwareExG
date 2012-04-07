#!/usr/bin/perl

# Inspired by Thanassis Tsiodras's script here:
# http://users.softlab.ece.ntua.gr/~ttsiod/gnuplotStreaming.html
# and Andreas Bernauer's extension here:
# http://www.lysium.de/blog/index.php?/archives/234-Plotting-data-with-gnuplot-in-real-time.html

use IO::Handle;

my $samplerate = 250; # SPS
my $windowsize = 4; # seconds
my $refresh_rate = 30; # Hz
my $numchannels = 8;

# start gnuplot
my $pipe;
open $pipe, "|gnuplot -geometry 800x600\n";
print $pipe "set xtics\n";
print $pipe "set ytics\n";
print $pipe "set style data lines\n";
print $pipe "set grid\n";
print $pipe "set term x11\n";
print $pipe "set yrange [-0.003:0.003]\n";
print $pipe "set xrange [0:1000]\n";

# set up a list of lists for buffering the incoming data
my @data;
for (my $i = 0; $i < $numchannels; $i++) {
    push @data, [];
}

# generate a plot command for the appropriate number of channels (but don't sent it yet)
my $plotcommand = "plot \"-\" title 'channel 1'";
for (my $i = 2; $i <= $numchannels; $i++) {
    $plotcommand = $plotcommand . ", \"-\" title 'channel $i'";
}
$plotcommand = $plotcommand . "\n";

my $valid_row_regex =
qr/C,\s*(?:\d{1,2},\s*+){6}(-?\d+(?:\.\d*)?),\s*(-?\d+(?:\.\d*)?),\s*(-?\d+(?:\.\d*)?),\s*(-?\d+(?:\.\d*)?),\s*(-?\d+(?:\.\d*)?),\s*(-?\d+(?:\.\d*)?),\s*(-?\d+(?:\.\d*)?),\s*(-?\d+(?:\.\d*)?)/;
my $samples_since_last_update = 0;
while (<STDIN>) {
    # parse the data
    if ( $_ =~ m/$valid_row_regex/ ) {
        push (@{$data[0]}, $1);
        push (@{$data[1]}, $2);
        push (@{$data[2]}, $3);
        push (@{$data[3]}, $4);
        push (@{$data[4]}, $5);
        push (@{$data[5]}, $6);
        push (@{$data[6]}, $7);
        push (@{$data[7]}, $8);
    }

    # if we have more data than our window size, start dropping elements
    for (my $i = 0; $i < $numchannels; $i++) {
        if (scalar(@{$data[$i]}) > $samplerate * $windowsize) {
            shift @{$data[$i]}
        }
    }

    $samples_since_last_update++;
    if ($samples_since_last_update > $samplerate * 1. / $refresh_rate) {
        $samples_since_last_update = 0;

        # generate the plot
        print $pipe $plotcommand;
        for (my $i = 0; $i < $numchannels; $i++) {
            print $pipe join("\n", @{$data[$i]})."\ne\n";
        }
        $pipe->flush;
    }
}

print $pipe, "exit;"
