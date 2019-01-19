function [rawSignals, fs, stages, eventStruct] = loadChannels(edfName, evtName, channels, fs, fsMax)
%loadChannels - Loads the relevant signals and the corresponding hypnogram
%               and event files
%
% Syntax:  [rawSignals, fs, stages, eventStruct] = loadChannels(edfName, evtName, channels, fs, fsMax)
% 
% Inputs: 
%    edfName  - The name of the EDF file to be loaded
%    evtName  - The name of the evts file to be loaded
%    channels - A vector containing the channel numbers in the order:
%               [nasal, oral, thoracic, abdominal, PES, snoring]
%    fs       - A vector containing the sampling frequencies corresponding
%               to the channels 
%    fsMax    - The maximum sampling frequency in the PSG recording
%
% Outputs: 
%    rawSignals  - A cell containing the raw downsampled signals in the same
%                  order as the channels vector
%    fs          - A vector containing the downsampled sampling frequencies
%    stages      - A vector containing the sleep stages for each sample
%    eventStruct - A struct containing all events and their indexes
%
% Other m-files required: CLASS_codec.m, loadEDF.m, downSample.m
% Subfunctions: lightsOffOn, prepHypnogram, prepEvents
% MAT-files required: none
%
% Author: Umaer Hanif
% February 2017; Last revision: 10-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Load the event file and hypnogram from the evts file
[eventStruct, stages] = CLASS_codec.parseSSCevtsFile(evtName);

% Load the raw signals using the specified channel numbers
[~, signals] = loadEDF(edfName, channels);
rawSignals = cell(length(channels), 1);

% Downsample all signals except snoring to 16 Hz
for i = 1:length(signals)-2
    [signals{i}, dsFs] = downSample(signals{i}, fs(i));
    fs(i) = dsFs;
end

% Extract all signals from lights off to lights on
for i = 1:length(rawSignals)
    rawSignals{i} = lightsOffOn(signals{i}, eventStruct, fs(i), fsMax, dsFs);
end

% Extract the hypnogram from lights off to lights on and transform it from
% epochs of 30 seconds to having the same length as the PES signal
stages = prepHypnogram(stages, eventStruct, fs(5), fsMax);

% Truncate the hypnogram if it is longer than the signal
if length(rawSignals{5}) < length(stages)
    stages = stages(1:length(rawSignals{5}));
end

% Remove events before lights off and after lights on so that the event
% struct matches the signal
[events, samples] = prepEvents(eventStruct, fs(5), fsMax);
eventStruct.events = events;
eventStruct.samples = samples;

%------------------------------ END OF CODE -------------------------------

%----------------------------- SUBFUNCTIONS -------------------------------

    function extractSig = lightsOffOn(sig, events, fsChl, fsMax, newFs)
        
        lightsoff = find(ismember(events.description,'Lights Off'));
        lightson = find(ismember(events.description,'Lights On'));
        start = floor(events.startStopSamples(lightsoff,1) * newFs/fsMax);
        stop = floor(events.startStopSamples(lightson,end) * newFs/fsMax);
        startChl = start * fsChl/newFs;
        stopChl = stop * fsChl/newFs;
        extractSig = sig(startChl+1:stopChl);
        
    end

    function truncHypnogram = prepHypnogram(hypnogram, events, fsPes, fsMax)
        
        lightsoff = find(ismember(events.description,'Lights Off'));
        start = floor(events.startStopSamples(lightsoff,1) * fsPes/fsMax); 
        truncHypnogram = repmat(hypnogram', 30*fsPes, 1);
        truncHypnogram = reshape(truncHypnogram, size(truncHypnogram,1)*size(truncHypnogram,2), 1);
        truncHypnogram = truncHypnogram(start+1:end)';
        
    end

    function [evts, sam] = prepEvents(events, fsPes, fsMax)
        
        evts = events.description;
        sam = events.startStopSamples;
        lightsoff = find(ismember(events.description,'Lights Off'),1);
        start = floor(events.startStopSamples(lightsoff,1));
        sam = floor((sam - start) * fsPes/fsMax);
        before = find(sam(:,1) < 0);
        sam(before,:) = [];
        evts(before) = [];
        after = find(ismember(evts, 'Lights On'));
        
        if length(evts) > after
            evts(after:end) = [];
            sam(after:end,:) = [];
        else
            evts(after) = [];
            sam(after,:) = [];
        end
        
    end

end