function features = featureExtraction2(signal, fs)
%featureExtraction2 - Extracts features from the input signal (snoring)
%
% Syntax:  features = featureExtraction2(signal, fs)
% 
% Inputs: 
%    signal - The input signal
%    fs     - The sampling frequency
%
% Outputs: 
%    features  - The feature matrix
%
% Other m-files required: featureNormalization.m
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% March 2017; Last revision: 15-June-2017

%------------------------------ BEGIN CODE --------------------------------

wDuration = 10;                             % Window duration of 10 seconds
wOverlap = 0.5;                             % Window overlap of 50%
wSize = wDuration*fs;                       % Window size in samples
wDistance = floor(wSize*(1-wOverlap));% Distance between windows in samples
numOfWindows = floor((length(signal)-wSize)/wDistance)+1;%Number of windows

% Preallocate vectors containing window indexes
windows = nan(wSize, numOfWindows);

for i = 1:numOfWindows
    wStart = (i-1)*wDistance+1;             % Start index of window
    window = wStart:wStart+wSize-1;         % Indexes of window
    windows(:,i) = window;                  % Store current window
end

area = sum(abs(signal(windows)))';          % Area feature
variance = var(signal(windows))';           % Variance feature

% Collect both feature vectors into a feature matrix
features = [area variance];      

% Normalize all features using 5th and 95th percentiles
features = featureNormalization(features); 

end

%------------------------------ END OF CODE -------------------------------