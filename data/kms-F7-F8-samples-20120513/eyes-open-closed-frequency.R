
o1 <- read.csv("open1.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
o2 <- read.csv("open2.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
o3 <- read.csv("open3.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
o4 <- read.csv("open4.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
o5 <- read.csv("open5.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
o6 <- read.csv("open6.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
c1 <- read.csv("closed1.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
c2 <- read.csv("closed2.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
c3 <- read.csv("closed3.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
c4 <- read.csv("closed4.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
c5 <- read.csv("closed5.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))
c6 <- read.csv("closed6.csv", col.names = c('magic', 'loffp', 'loffn', 'g1', 'g2', 'g3', 'g4', 'i1', 'i2', 'i3', 'i4', 'i5', 'i6', 'i7', 'i8'))

opens <- list(o1$i1, o2$i1, o3$i1, o4$i1, o5$i1, o6$i1);
closd <- list(c1$i1, c2$i1, c3$i1, c4$i1, c5$i1, c6$i1);

# open and closed eyes FFTed
opensfft <- sapply(opens, function (data) { fft(data) })
closdfft <- sapply(closd, function (data) { fft(data) })

# open and closed eyes as seconds not samples
offtseconds <- sapply(opensfft, function (data) {
    ((0:(length(data)-1)/length(data))*250)
});
cfftseconds <- sapply(closdfft, function (data) {
    ((0:(length(data)-1)/length(data))*250)
});

par(mfrow=c(6,2), mar=c(0,0,0,0))
freq_min = 0.1;
freq_max = 4;
for(i in 1:6) {
  plot(offtseconds[[i]], log(abs(opensfft[[i]])),
        type='l', col='red', xlim=c(freq_min,freq_max), ylim=c(-10,-2));
  plot(cfftseconds[[i]], log(abs(closdfft[[i]])),
        type='l', col='blue', xlim=c(freq_min,freq_max), ylim=c(-10,-2));
}

opens_beta <- sapply(1:6, function (i) {
	mean(abs(opensfft[[i]][
		  (offtseconds[[i]] >= freq_min)
                & (offtseconds[[i]] < freq_max)])) })

closd_beta <- sapply(1:6, function (i) {
	mean(abs(closdfft[[i]][
		  (cfftseconds[[i]] >= freq_min)
                & (cfftseconds[[i]] < freq_max)])) })

ttest <- t.test(opens_beta, closd_beta);
ttest
