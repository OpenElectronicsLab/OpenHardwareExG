#!/bin/bash

SAMPLE=`date +"%Y%m%d.%H%M%S"`

# tee >(./plot_frames.pl) |

./serial-reader.pl |
./frame-parser.pl |
tee -a sample-${USER}-${SAMPLE}.csv |
./chan2-filter.pl |
./freq-broad-bandpass.pl |
./window.pl |
tee -a trial-${USER}-${SAMPLE}.csv |
./plot_3chan.pl
