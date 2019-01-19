%performance - Calculates the performance measures for the system
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: p1prediction.mat - p168prediction.mat
%
% Author: Umaer Hanif
% May 2017; Last revision: 21-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Define empty vectors for performance measures
MAE = [];
PC = [];
P = [];
P2 = [];

% Loop through all patients in the validation set and calculate the median
% absolute error for each patient between true and predicted Pes
for i = 1:168
    fprintf('Patient %d out of %d...\n', i, 168)
    load(sprintf('p%dprediction.mat', i))
    predictions = eval(sprintf('p%d', i));
    MAE = [MAE predictions(1,:)-predictions(2,:)];
    P = [P predictions(1,:)];
    P2 = [P2 predictions(2,:)];
end

% Define window size of 500
wSize = 500;        
numOfWindows = floor((length(P)-wSize)/wSize)+1;
C_NORMAL = nan(numOfWindows, 1);
P_NORMAL = nan(numOfWindows, 1);

% Calculate the correlation coefficient between true and predicted pes for
% 500 windows at a time for each patient 
for i = 1:numOfWindows
    wStart = (i-1)*wSize+1;
    window = wStart:wStart+wSize-1;
    [c, p] = corrcoef(P(window), P2(window));
    C_NORMAL(i) = c(2);
    P_NORMAL(i) = p(2);
end

%------------------------------ END OF CODE -------------------------------