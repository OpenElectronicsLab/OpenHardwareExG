#!/bin/sh

SAMPLE=`date +"%Y%m%d.%H%M%S"`

./killreader.sh $1 &
./serial-reader.pl |
./frame-parser.pl |
./parsed-frame-filter.pl |
tee sample-${USER}-${SAMPLE}.csv |
./plot.pl
