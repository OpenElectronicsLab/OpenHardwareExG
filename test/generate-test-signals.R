duration = 20.0; # seconds
signalAmplitude = 1e-3; # volts, peak to peak
samplingRate = 250; # samples per second

noiseAmplitude = 0.1e-3; # volts

signalDuration = 1.0; # seconds
signalStartTime = duration/2; # seconds
signalFrequency = 11; # Hz

time = (0:floor(duration * samplingRate)) / samplingRate;

# generate the noise
noise = rnorm(length(time), sd=noiseAmplitude);

# generate the pure signal (as a sine wave for the given duration)
signalStartingSample = floor(signalStartTime * samplingRate);
signalEndingSample = floor((signalStartTime + signalDuration) * samplingRate);
signal = (1:length(time)); # generate an array of numbers
signal = signal * 0; # reset the array to all zeros
signal[signalStartingSample:signalEndingSample] =
	(signalAmplitude / 2) *
	sin(
		2 * pi * signalFrequency *
		time[signalStartingSample:signalEndingSample]
	);

signalPlusNoise = signal + noise;

# write out the resulting file
write.table(signalPlusNoise, "signal-with-noise.csv", row.names=F, col.names=F);
