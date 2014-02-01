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
    my ( $ref, $value, $footprint, $partnum ) = split ',', $line;
    next if ( !$partnum );
    $parts->{$partnum}->{value} = $value;
    $parts->{$partnum}->{refs} ||= [];
    push @{ $parts->{$partnum}->{refs} }, $ref;
    @{ $parts->{$partnum}->{refs} } =
      sort by_number @{ $parts->{$partnum}->{refs} };
    $parts->{$partnum}->{count}++;
}

for my $partnum (
    sort {
        substr( $parts->{$a}->{refs}->[0], 0, 1 ) cmp
          substr( $parts->{$b}->{refs}->[0], 0, 1 )
          or int( substr( $parts->{$a}->{refs}->[0], 1 ) ) <=>
          int( substr( $parts->{$b}->{refs}->[0], 1 ) )
    } keys %$parts
  )
{
    my $part = $parts->{$partnum};
    my $cust_num = join( "_", @{ $part->{refs} } );
    print $partnum, "  |  ", $part->{count}, "  |  ", $part->{value}, "  |  ",
      $cust_num, "\n";
}
