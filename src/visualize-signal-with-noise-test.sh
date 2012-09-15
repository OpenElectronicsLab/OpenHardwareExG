#!/bin/bash

cat ../test/signal-with-noise.csv |
   ./freq-split-smooth.pl > ../test/freq-split-smooth.out

cat ../test/signal-with-noise.csv |
 ./freq-split-smooth.pl --skipsmooth > ../test/freq-split-no-smooth.out

R --vanilla <<'EOF'
signals = read.csv("../test/signal.csv", col.names=c('low','high'));
r1 = read.csv("../test/freq-split-smooth.out", col.names=c('low','high'));
r2 = read.csv("../test/freq-split-no-smooth.out", col.names=c('low','high'));

png("plotted.png", 1024, 1024);

par(mfrow=c(2,1));

plot(1:length(signals$low), signals$low, col="blue", type="l")
lines(1:length(r2$low), r2$low, col="gray")
lines(1:length(r1$low), r1$low, col="black")


plot(1:length(signals$high), signals$high, col="blue", type="l")
lines(1:length(r2$high), r2$high, col="gray")
lines(1:length(r1$high), r1$high, col="black")

dev.off();
EOF

firefox ./plotted.png
