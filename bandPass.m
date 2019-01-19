function filtSig = bandPass(signal, N, fc1, fc2, fs)
%bandPass - Bandpass filters input signal in a specified frequency range
%
% Syntax:  filtSig = bandPass(signal, N, fc1, fc2, fs)
% 
% Inputs: 
%    signal - The input signal
%    N       - The filter order
%    fc1     - The first cut-off frequency
%    fc2     - The second cut-off frequency
%    fs      - The sampling frequency of the input signal
%
% Outputs: 
%    filtSig  - The bandpass filtered signal
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% February 2017; Last revision: 14-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Create an object containing the filter specifications
h  = fdesign.bandpass('N,F3dB1,F3dB2', N, fc1, fc2, fs);

% Use object to design a Butterworth bandpass filter
Hd = design(h, 'butter');

% Get coefficients for the filter transfer function
[b,a] = sos2tf(Hd.sosMatrix,Hd.Scalevalues);

% Filter signal in both directions to perform zero-phase filtering 
filtSig = filtfilt(b,a,signal);

end

%------------------------------ END OF CODE -------------------------------