function features = featureExtraction(signal, fs)
%featureExtraction - Extracts features from the input signal
%
% Syntax:  features = featureExtraction(signal, fs)
% 
% Inputs: 
%    signal - The input signal
%    fs     - The sampling frequency
%
% Outputs: 
%    features  - The feature matrix
%
% Other m-files required: arclength.m, wavelet.m, featureNormalization.m
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

% Preallocate vectors containing window indexes and different features
windows = nan(wSize, numOfWindows);
alength = nan(numOfWindows, 1);
waveCoef = nan(numOfWindows, 1);
waveCoef2 = nan(numOfWindows, 1);
N = 6;               % Levels of wavelet decomposition                         
wname = 'bior1.5';   % Biorthogonal mother wavelet

% Extract features in sliding windows
for i = 1:numOfWindows
    wStart = (i-1)*wDistance+1;                     % Start index of window
    window = wStart:wStart+wSize-1;                 % Indexes of window
    windows(:,i) = window;                          % Store current window
    alength(i) = arclength(1:wSize, signal(window));% Arc length feature
    [C, D] = wavelet(signal(window), N, wname);     % Wavelet coefficients
    waveCoef(i) = sum(D{end}.^2)+sum(D{end-1}.^2);  % Wavelet feature 1 
    waveCoef2(i) = waveCoef(i)/(sum(C.^2));         % Wavelet feature 2 
end

area = sum(abs(signal(windows)))';                  % Area feature
variance = var(signal(windows))';                   % Variance feature
derivative = sum(abs(diff(diff(signal(windows)))))';% 2nd derivative featur
fse = sqrt(signal(windows) + hilbert(signal(windows)));% From paper
hht = mean(abs(fse))';                              % CVE feature 1                      
hht2 = var(abs(fse))';                              % CVE feature 2 

% Collect all feature vectors into a feature matrix
features = [area variance alength derivative hht hht2 waveCoef waveCoef2];

% Normalize all features using 5th and 95th percentiles
features = featureNormalization(features);

end

%------------------------------ END OF CODE -------------------------------