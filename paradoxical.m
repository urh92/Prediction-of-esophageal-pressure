function PLV = paradoxical(chest, abdomen, fs)
%paradoxical - Computes the phase-locking value (PLV) feature which
%indicates paradoxical breathing
%
% Syntax:  PLV = paradoxical(chest, abdomen, fs)
% 
% Inputs: 
%    chest   - The thoracic effort signal
%    abdomen - The abdominal effort signal
%    fs      - The sampling frequency
%
% Outputs: 
%    PLV  - A vector containing the PLV feature for each window
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% April 2017; Last revision: 15-June-2017

%------------------------------ BEGIN CODE --------------------------------

wDuration = 10;                       % Window duration of 10 seconds
wOverlap = 0.5;                       % Window overlap of 50%
wSize = wDuration*fs;                 % Window size in samples
wDistance = floor(wSize*(1-wOverlap));% Distance between windows in samples
numOfWindows = floor((length(chest)-wSize)/wDistance)+1;% Number of windows
PLV = nan(numOfWindows, 1); %Preallocate vector for PLV values

% Compute the PLV feature in sliding windows
for i = 1:numOfWindows
    wStart = (i-1)*wDistance+1;        % Start index of window
    window = wStart:wStart+wSize-1;    % Indexes of window
    thc = atan(imag(hilbert(chest(window)))./chest(window)); % From paper
    tha = atan(imag(hilbert(abdomen(window)))./abdomen(window));%From paper
    PLV(i) = abs((1/length(window))*sum(exp(1i*(thc-tha)))); % From paper
end

end

%------------------------------ END OF CODE -------------------------------