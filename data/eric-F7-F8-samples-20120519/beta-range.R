#!/usr/bin/RScript

# lead eegf7f8
eegf7f8 <- read.csv("eog0.csv")[,8]

# sample rate (samples per second)
rate <- 250

# num samples
N <- length(eegf7f8);

# times
t <- (0:(N - 1)) / rate;

# possible/valid fft frequencies
f <- (0:(N - 1)) / N * rate;

# fft samples
eegf7f8_fft <- fft(eegf7f8)

# band pass filter the result
highPass <- 15; # Hz
highPassWidth <- 0.5; # Hz
lowPass <- 30; # Hz
lowPassWidth <- 1; # Hz
# windowing function (just the product of two sigmoid functions)
win <- function(freq) { 1 / ((1 + exp(-(freq - highPass) / highPassWidth)) * (1 + exp((freq - lowPass) / lowPassWidth))) };
eegf7f8_fft_f <- eegf7f8_fft * (win(f) + win(f[length(f)] - f));
eegf7f8_f <- Re(fft(eegf7f8_fft_f, inverse=TRUE) / N);
eegf7f8_f_abs <- abs(eegf7f8_f)
smpl_avg <- floor(rate/10)
eegf7f8_smoothed <- filter(eegf7f8_f_abs, rep(1/smpl_avg, smpl_avg))

par(mfrow=c(3,1))
plot(t, eegf7f8,   xlim=c(10,20), type="l", lwd=1, col="grey")
plot(t, eegf7f8_f, xlim=c(10,20), type="l", lwd=2, col="red")
plot(t, eegf7f8_smoothed, xlim=c(10,20), type="l", lwd=2, col="blue")

