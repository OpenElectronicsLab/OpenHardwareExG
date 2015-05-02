#!/usr/bin/perl

use strict;
use warnings;

# turn off output buffering
$| = 1;

my $parts = {};

sub by_number {
    substr( $a, 0, 1 ) cmp substr( $b, 0, 1 )
      or int( substr( $a, 1 ) ) <=> int( substr( $b, 1 ) );
}

while (<>) {
    my $line = $_;
    chomp $line;
    my ( $ref, $value, $footprint, $partnum, $supplier ) = split ',', $line;
    next if ( !$partnum );
    $parts->{$supplier}->{$partnum}->{value} = $value;
    $parts->{$supplier}->{$partnum}->{refs} ||= [];
    push @{ $parts->{$supplier}->{$partnum}->{refs} }, $ref;
    @{ $parts->{$supplier}->{$partnum}->{refs} } =
      sort by_number @{ $parts->{$supplier}->{$partnum}->{refs} };
    $parts->{$supplier}->{$partnum}->{count}++;
}

for my $supplier ( keys %$parts ) {
    for my $partnum (
        sort {
            substr( $parts->{$supplier}->{$a}->{refs}->[0], 0, 1 ) cmp
              substr( $parts->{$supplier}->{$b}->{refs}->[0], 0, 1 )
              or int( substr( $parts->{$supplier}->{$a}->{refs}->[0], 1 ) ) <=>
              int( substr( $parts->{$supplier}->{$b}->{refs}->[0], 1 ) )
        } keys %{ $parts->{$supplier} }
      )
    {
        my $part = $parts->{$supplier}->{$partnum};
        my $cust_num = join( "_", @{ $part->{refs} } );
        print $supplier, "  |   ", $partnum, "  |  ", $part->{count}, "  |  ",
          $part->{value}, "  |  ", $cust_num, "\n";
    }
}
