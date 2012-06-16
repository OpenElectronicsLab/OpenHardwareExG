#!/bin/sh

SAMPLE=`date +"%Y%m%d.%H%M%S"`

./serial-reader.pl |
./frame-parser.pl |
tee -a sample-${USER}-${SAMPLE}.csv |
./parsed-frame-filter.pl |
./window.pl |
./plot.pl
