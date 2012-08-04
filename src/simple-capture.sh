#!/bin/bash

MONTH=`date +"%Y%m%d"`
DATE=`date +"%Y%m%d.%H%M%S"`
DURATION=10
mkdir -p ../data/$MONTH
CAPTURE=../data/$MONTH/capture-${DATE}.txt
echo "x" > /dev/ttyACM0
sleep 2
# ( ./devreader.sh > $CAPTURE &)
( ./devreader.sh | ./time-stamp.pl > $CAPTURE &)
sleep $DURATION
echo "x" > /dev/ttyACM0
sleep 1
killall devreader.sh
head -n10 $CAPTURE
wc -l $CAPTURE
lines=`wc -l $CAPTURE | cut -d' ' -f1`
echo "$lines / $DURATION" | bc
