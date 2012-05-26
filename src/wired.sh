#!/bin/sh

SAMPLE=`date +"%Y%m%d.%H%M%S"`

./serial-reader.pl |
./frame-parser.pl |
./parsed-frame-filter.pl |
tee -a sample-${USER}-${SAMPLE}.csv |
./window.pl |
./plot.pl
