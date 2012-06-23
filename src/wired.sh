#!/bin/bash

SAMPLE=`date +"%Y%m%d.%H%M%S"`

# tee >(./plot_frames.pl) |

./serial-reader.pl |
./frame-parser.pl |
tee -a sample-${USER}-${SAMPLE}.csv |
./chan1-filter.pl |
./freq-split-smooth.pl |
./window.pl |
./plot_2chan.pl
