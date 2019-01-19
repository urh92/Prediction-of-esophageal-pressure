function filtSig = highPass(signal, N, fc, fs)
%highPass - Highpass filters input signal at a specified frequency
%
% Syntax:  filtSig = highPass(signal, N, fc, fs)
% 
% Inputs: 
%    signal - The input signal
%    N      - The filter order
%    fc     - The cut-off frequency
%    fs     - The sampling frequency of the input signal
%
% Outputs: 
%    filtSig - The highpass filtered signal
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% February 2017; Last revision: 14-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Design Butterworth highpass filter using the specified cut-off frequency
% and get coefficients for the filter transfer function
[b, a] = butter(N, fc/(fs/2), 'high');

% Filter signal in both directions to perform zero-phase filtering 
filtSig = filtfilt(b, a, signal);

end

%------------------------------ END OF CODE -------------------------------