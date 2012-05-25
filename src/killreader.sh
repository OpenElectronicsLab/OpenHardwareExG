#!/bin/sh
sleep $1
#
# killall on some systems works only with the first 15 characters
# this killall tries both the full name and the 15 character name
#
killall serial-reader.p 2>/dev/null
killall serial-reader.pl 2>/dev/null
