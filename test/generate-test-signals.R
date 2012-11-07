#!/usr/bin/Rscript
totalDuration = 20.0; # seconds
signalAmplitude = 1e-3; # volts, peak to peak
samplingRate = 250; # samples per second

noiseAmplitude = 0.1e-3; # volts

lowSignalParams = list(
	duration = c(1.0, 1.0), # seconds
	startTime = c(5, 10), # seconds
	frequency = 11 # Hz
);
highSignalParams = list(
	duration = c(1.0, 1.0), # seconds
	startTime = c(10, 15), # seconds
	frequency = 23 # Hz
);

time = (0:floor(totalDuration * samplingRate)) / samplingRate;

# generate the noise
set.seed(1234);
noise = rnorm(length(time), sd=noiseAmplitude);

# generate the pure signal (as a sine wave for the given totalDuration)
generateSignal = function(params) {
	signal = (1:length(time)); # generate an array of numbers
	signal = signal * 0; # reset the array to all zeros
	for (i in 1:length(params$duration)) {
		signalStartingSample = floor(
			params$startTime[i] * samplingRate);
		signalEndingSample = floor(
			(params$startTime[i] + params$duration[i]) *
			samplingRate);
		signal[signalStartingSample:signalEndingSample] =
			(signalAmplitude / 2) *
			sin(
				2 * pi * params$frequency *
				time[signalStartingSample:signalEndingSample]
			);
	}
	return(signal);
}

lowSignal = generateSignal(lowSignalParams);
highSignal = generateSignal(highSignalParams);

signalsPlusNoise = lowSignal + highSignal + noise;

# write out the resulting file
write.table(data.frame(low=lowSignal, high=highSignal), "signal.csv",
	row.names=F, col.names=F, sep=",");
write.table(signalsPlusNoise, "signal-with-noise.csv", row.names=F, col.names=F);
