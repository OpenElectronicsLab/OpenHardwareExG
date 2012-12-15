#!/usr/bin/python
import numpy as np
from scipy import signal
from matplotlib import pyplot as plt

nyquest_freq = 250./2;

# 7-14 Hz elliptic bandpass filter
x_filter = signal.iirdesign(
    wp = [7./nyquest_freq, 14./nyquest_freq],
    ws = [4./nyquest_freq, 20./nyquest_freq],
    gstop=40, gpass=3, ftype='ellip'
)

# 20-26 Hz elliptic bandpass filter
y_filter = signal.iirdesign(
    wp = [20.0/nyquest_freq, 26.0/nyquest_freq],
    ws = [16./nyquest_freq, 32./nyquest_freq],
    gstop=40, gpass=3, ftype='ellip'
)

# 16.5-17.5 Hz elliptic bandpass filter
baseline_filter = signal.iirdesign(
    wp = [16.5/nyquest_freq, 17.5/nyquest_freq],
    ws = [15.5/nyquest_freq, 18.5/nyquest_freq],
    gstop=40, gpass=3, ftype='ellip'
)

# 5 Hz elliptic lowpass filter
smooth_filter = signal.iirdesign(
    wp = 5./ nyquest_freq,
    ws = 10./ nyquest_freq, gstop=40,
    gpass=3, ftype='ellip'
)

# 15-35 Hz band-pass filter
broad_bandpass_filter = signal.iirdesign(
    wp = [15/nyquest_freq, 35/nyquest_freq],
    ws = [5/nyquest_freq, 45/nyquest_freq],
    gstop=40, gpass=3, ftype='butterworth'
)


fig = plt.figure()
for filter in [x_filter, y_filter, baseline_filter, smooth_filter, broad_bandpass_filter]:
    w,h = signal.freqz(*filter)
    plt.plot(w*(nyquest_freq/max(w)), np.abs(h))
    plt.xlim(0,40)
    plt.xlabel('frequency (Hz)');
    plt.ylabel('response');
fig.savefig("test.png")

with open('filter_coefs.yaml','wt') as f:
    f.write('x_filter:\n');
    f.write('    in_coef: ' + str(x_filter[0].tolist()) + '\n');
    f.write('    out_coef: ' + str(x_filter[1][1:].tolist()) + '\n');
    f.write('y_filter:\n');
    f.write('    in_coef: ' + str(y_filter[0].tolist()) + '\n');
    f.write('    out_coef: ' + str(y_filter[1][1:].tolist()) + '\n');
    f.write('baseline_filter:\n');
    f.write('    in_coef: ' + str(baseline_filter[0].tolist()) + '\n');
    f.write('    out_coef: ' + str(baseline_filter[1][1:].tolist()) + '\n');
    f.write('smooth_filter:\n');
    f.write('    in_coef: ' + str(smooth_filter[0].tolist()) + '\n');
    f.write('    out_coef: ' + str(smooth_filter[1][1:].tolist()) + '\n');
    f.write('broad_bandpass_filter:\n');
    f.write('    in_coef: ' + str(broad_bandpass_filter[0].tolist()) + '\n');
    f.write('    out_coef: ' + str(broad_bandpass_filter[1][1:].tolist()) + '\n');

