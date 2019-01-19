function flatlineStruct = flatlineDetection(signal, jitter)
%flatlineDetection - Detects flatline segments in input signal
%
% Syntax:  flatlineStruct = flatlineDetection(signal, jitter)
% 
% Inputs: 
%    signal - The input signal
%    jitter - The amount of jitter that is allowed in the flatline
%
% Outputs: 
%    flatlineStruct  - A struct containing all detected flatlines
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% March 2017; Last revision: 15-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Preallocate struct containing all detected flatline segments
flatlineStruct = {};

% Find all indexes where the change in signal is smaller than threshold
zero_intervals = abs(diff(signal))<(jitter*eps);
zero_intervals = find(zero_intervals)';

% Find end index in each detected flatline segment
idx = find([diff(zero_intervals)>1, 1]);

% Find the length of each detected flatline segment
did = [idx(1), diff(idx)];

% Divide each segment into a cell array
allFlat = mat2cell(zero_intervals,1,did);
k = 0;

% Loop through all detected flatlines and store the ones that exceed 2 min
for i = 1:length(allFlat)
    if length(allFlat{i}) > 2*60*16
        k = k + 1;
        flatlineStruct{k} = allFlat{i};
    end
end
end

%------------------------------ END OF CODE -------------------------------