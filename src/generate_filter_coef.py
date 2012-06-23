#!/usr/bin/python
import numpy as np
from scipy import signal
from matplotlib import pyplot as plt

nyquest_freq = 250./2;

# 10-12 Hz 10th order elliptic bandpass filter, from
x_filter = signal.iirdesign(
    wp = [10./nyquest_freq, 12./nyquest_freq],
    ws = [7./nyquest_freq, 17./nyquest_freq],
    gstop=110, gpass=1, ftype='ellip'
)

# 21.5-24.5 Hz 12th order elliptic bandpass filter, from
y_filter = signal.iirdesign(
    wp = [21.5/nyquest_freq, 24.5/nyquest_freq],
    ws = [18./nyquest_freq, 29./nyquest_freq],
    gstop=105, gpass=1, ftype='ellip'
)

# 5 Hz 10th order elliptic lowpass filter, from
smooth_filter = signal.iirdesign(
    wp = 5./nyquest_freq,
    ws= 7./nyquest_freq, gstop=100,
    gpass=1, ftype='ellip'
)


fig = plt.figure()
for filter in [x_filter, y_filter, smooth_filter]:
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
    f.write('smooth_filter:\n');
    f.write('    in_coef: ' + str(smooth_filter[0].tolist()) + '\n');
    f.write('    out_coef: ' + str(smooth_filter[1][1:].tolist()) + '\n');

