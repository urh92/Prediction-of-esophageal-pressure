function filtSig = notch(signal, N, fc1, fc2, fs)
%notch - Notch filters input signal in a specified frequency range
%
% Syntax:  filtSig = notch(signal, N, fc1, fc2, fs)
% 
% Inputs: 
%    signal - The input signal
%    N      - The filter order
%    fc1    - The first cut-off frequency
%    fc2    - The second cut-off frequency
%    fs     - The sampling frequency of the input signal
%
% Outputs: 
%    filtSig - The notch filtered signal
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% February 2017; Last revision: 14-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Design Butterworth notch filter using the specified cut-off frequencies
% and get coefficients for the filter transfer function
[b, a] = butter(N, [fc1/(fs/2), fc2/(fs/2)], 'stop');

% Filter signal in both directions to perform zero-phase filtering 
filtSig = filtfilt(b, a, signal);

end

%------------------------------ END OF CODE -------------------------------