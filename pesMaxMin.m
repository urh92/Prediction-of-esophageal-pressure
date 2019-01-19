function targets = pesMaxMin(signal, fs, hypnogram)
%pesMaxMin - Extracts the target vector from the input signal (PES)
%
% Syntax:  targets = pesMaxMin(signal, fs, hypnogram)
% 
% Inputs: 
%    signal    - The input signal
%    fs        - The sampling frequency
%    hypnogram - A vector containing the sleep stages for each sample
%
% Outputs: 
%    targets - The target vector 
%
% Other m-files required: sigEnvelope.m
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% April 2017; Last revision: 16-June-2017

%------------------------------ BEGIN CODE --------------------------------

wDuration = 10;                             % Window duration of 10 seconds
wOverlap = 0.5;                             % Window overlap of 50%
wSize = wDuration*fs;                       % Window size in samples
wDistance = floor(wSize*(1-wOverlap));% Distance between windows in samples
windows = getWindows(pes, fs);

% Detect minima and compute envelope using cubic spline interpolation
[upperenv, lowerenv] = sigEnvelope(signal, 'pchip');
lowerenv(lowerenv > -0.5) = 0;
upperenv(upperenv < 0.5) = 0;

% Detect minima based on cubic spline and perform linear interpolation
[upperenv, ~] = sigEnvelope(upperenv');

% Find wake segments and store separately in a cell array
wake = find(hypnogram == 0);
idx = find([diff(wake)>1, 1]);
did = [idx(1), diff(idx)];
wakeSegments = mat2cell(wake,1,did);

% Define parameters for minimum duration of each wake segment
epochSize = 30;
minWakeEpochs = 6;
removeEpochs = 2;
k = 0;
refPesMin = [];

% Store wake segments that are minimum 6 epochs long in a new cell array
for i = 1:length(wakeSegments)
    if length(wakeSegments{i}) > minWakeEpochs*epochSize*fs
        k = k + 1;
        refSegments{k} = wakeSegments{i}(removeEpochs*epochSize*fs:end-removeEpochs*epochSize*fs);
    end
end

% For each segment, run sliding window and compute the median of the lower
% envelope for each window and store values in vector 
for i = 1:length(refSegments)
    numOfWindows = floor((length(refSegments{i})-wSize)/wDistance)+1;
    wakePesMin = nan(numOfWindows, 1);
    wakeLowerEnv = lowerenv(refSegments{i});
    for j = 1:numOfWindows
        wStart = (j-1)*wDistance+1;
        window = wStart:wStart+wSize-1;
        wakePesMin(j) = median(wakeLowerEnv(window));
    end
    wakePesMin(wakePesMin < prctile(wakePesMin, 5)) = [];
    refPesMin = [refPesMin; wakePesMin];
end

% Preallocate vector for computing negative PES values in sliding window
pesMin = nan(numOfWindows, 1);
numOfWindows = floor((length(signal)-wSize)/wDistance)+1;

for i = 1:numOfWindows
    wStart = (i-1)*wDistance+1;             % Start index of window
    window = wStart:wStart+wSize-1;         % Indexes of window
    pesMin(i) = median(lowerenv(window));   % Median of lower envelope PES
end

% Set values above 99th percentile equal to 99th percentile and values
% below 1st percentile equal to 1st percentile
p1 = pesMin > prctile(pesMin, 99);
p2 = pesMin < prctile(pesMin, 1);
pesMin(p1) = prctile(pesMin, 99);
pesMin(p2) = prctile(pesMin, 1);

% Subtract the reference value from wake from each negative esophageal
% pressure value obtained in sliding window
targets = pesMin - median(refPesMin);

end

%------------------------------ END OF CODE -------------------------------