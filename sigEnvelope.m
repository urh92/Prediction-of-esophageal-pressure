function [upperenv, lowerenv] = sigEnvelope(signal, method)
%sigEnvelope - Computes upper and lower envelope of input signal
%
% Syntax:  [upperenv, lowerenv] = sigEnvelope(signal, method)
% 
% Inputs: 
%    signal - The input signal
%    method - Interpolation method
%
% Outputs: 
%    upperenv - Upper envelope of input signal
%    lowerenv - Lower envelope of input signal
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% April 2017; Last revision: 16-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Linear interpolation is the default method 
if nargin == 1 
    method = 'linear';
end

% Find local maxima and minima in input signal
maxima = find(diff(sign(diff(signal))) < 0) + 1;
minima = find(diff(sign(diff(signal))) > 0) + 1;

start_point = 1;
end_point = length(signal);

% Using diff twice shortens the signal by two samples
% to preserve the length a start point and end point is added
maxima = [start_point; maxima; end_point];
minima = [start_point; minima; end_point];

num_of_samples = start_point:end_point;

% Generate upper envelope by interpolating the local maxima using 'method'
upperenv = interp1(maxima, signal(maxima), num_of_samples, method);

% Generate lower envelope by interpolating the local minima using 'method'
lowerenv = interp1(minima, signal(minima), num_of_samples, method);

%------------------------------ END OF CODE -------------------------------