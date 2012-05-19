#!/usr/bin/RScript

# lead II
II <- read.csv("kms-ecg-II-samples-20120513.csv")[,1];

# sample rate (samples per second)
rate <- 250

# num samples
N <- length(II);

# times
t <- (0:(N - 1)) / rate;

# possible/valid fft frequencies
f <- (0:(N - 1)) / N * rate;

# fft samples
II_fft <- fft(II)

# band pass filter the result
highPass <- 1; # Hz
highPassWidth <- 0.1; # Hz
lowPass <- 40; # Hz
lowPassWidth <- 1; # Hz
# windowing function (just the product of two sigmoid functions)
win <- function(freq) { 1 / ((1 + exp(-(freq - highPass) / highPassWidth)) * (1 + exp((freq - lowPass) / lowPassWidth))) };
II_fft_f <- II_fft * (win(f) + win(f[length(f)] - f));
II_f <- Re(fft(II_fft_f, inverse=TRUE) / N);

plot(t, II_f, type="l", lwd=2, xlim=c(0,5))
