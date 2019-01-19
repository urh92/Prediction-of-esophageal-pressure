function [rawSignal, dsFs] = downSample(rawSignal, fs)
%downSample - Downsamples input signal to a specified sampling frequency
%
% Syntax:  [rawSignal, dsFs] = downSample(rawSignal, fs)
% 
% Inputs: 
%    rawSignal  - The raw input signal
%    fs         - The sampling frequency of the input signal
%
% Outputs: 
%    rawSignal  - The downsampled raw signal
%    dsFs       - The new sampling frequency
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% February 2017; Last revision: 14-June-2017

%------------------------------ BEGIN CODE --------------------------------

dsFs = 16; % The new sampling frequency

% Resample signal to get the desired sampling frequency
[N,D] = rat(dsFs/fs);
if(N~=D)
    rawSignal = resample(rawSignal,N,D);
end;

end

%------------------------------ END OF CODE -------------------------------