#!/bin/bash

SAMPLE=`date +"%Y%m%d.%H%M%S"`

# tee >(./plot_frames.pl) |

./devreader.sh |
./frame-parser.pl |
tee -a sample-${USER}-${SAMPLE}.csv |
./chan2-filter.pl |
./window.pl |
./plot_2chan.pl
