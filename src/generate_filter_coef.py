#!/usr/bin/python
from scipy import signal

# 10-12 Hz 10th order elliptic bandpass filter, from
x_filter = signal.iirdesign(wp = [10./125, 12./125], ws= [7./125, 17./125],
     gstop= 110, gpass=1, ftype='ellip')

# 21.5-24.5 Hz 12th order elliptic bandpass filter, from
y_filter = signal.iirdesign(wp=[21.5/125, 24.5/125], ws=[18./125, 29./125],
     gstop=105, gpass=1, ftype='ellip')

# 5 Hz 10th order elliptic lowpass filter, from
smooth_filter = signal.iirdesign(wp = 5./125, ws= 7./125, gstop=100,
     gpass=1, ftype='ellip')

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

