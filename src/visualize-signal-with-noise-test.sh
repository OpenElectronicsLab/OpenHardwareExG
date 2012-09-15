#!/bin/bash

cat ../test/signal-with-noise.csv |
   ./freq-split-smooth.pl > ../test/freq-split-smooth.out

cat ../test/signal-with-noise.csv |
 ./freq-split-smooth.pl --skipsmooth > ../test/freq-split-no-smooth.out

R --vanilla <<'EOF'
signal = read.table("../test/signal.csv");
r1 = read.table("../test/freq-split-smooth.out");
r2 = read.table("../test/freq-split-no-smooth.out");
png("plotted.png");
plot(1:length(r2$V1), r2$V1, type="l", col="gray")
lines(1:length(r1$V1), r1$V1, col="black")
lines(1:length(signal$V1), signal$V1*250e3, col="blue")
dev.off();
EOF

firefox ./plotted.png
