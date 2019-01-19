function [channels, fs, fsMax] = getChannels(edfName)
%getChannels - Extracts the relevant channel numbers and the
%              corresponding sampling frequencies from the patient file
%
% Syntax:  [channels, fs, fsMax] = getChannels(edfName)
% 
% Inputs: 
%    edfName - The name of the EDF file to be loaded
%
% Outputs: 
%    channels - A vector containing the channel numbers in the order:
%               [nasal, oral, thoracic, abdominal, PES, snoring] 
%    fs       - A vector containing the sampling frequencies corresponding
%               to the channels 
%    fsMax    - The maximum sampling frequency in the PSG recording   
%   
% Other m-files required: loadEDF.m
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% February 2017; Last revision: 9-June-2017

%------------------------------ BEGIN CODE --------------------------------

% The possible labels for the different channels
nasalLabel = {'Nasal Pressure', 'Cannula', 'Nasal'};
oralLabel = {'Airflow', 'Oral', 'Oral Therm', 'Trach Therm'};
chestLabel = 'Chest';
abdomenLabel = {'Abdomen', 'Abdmn', 'Abd'};
pesLabel = {'Pes', 'PES'};
snoreLabel = {'MIC', 'MIC1', 'Mic', 'Snore'};
oxygenLabel = 'SpO2';

% Load struct that contains channel numbers and sampling frequencies and
% store the relevant channel numbers
hdr = loadEDF(edfName);
warning('off', 'MATLAB:catenate:DimensionMismatch')
nasalChl = [find(ismember(hdr.label,nasalLabel{1}),1) ...
    find(ismember(hdr.label,nasalLabel{2}),1) ...
    find(ismember(hdr.label,nasalLabel{3}),1)];
oralChl = [find(ismember(hdr.label,oralLabel{1}),1) ...
    find(ismember(hdr.label,oralLabel{2}),1) ...
    find(ismember(hdr.label,oralLabel{3}),1) ...
    find(ismember(hdr.label,oralLabel{4}),1)];
chestChl = find(ismember(hdr.label, chestLabel),1);
abdomenChl = [find(ismember(hdr.label, abdomenLabel{1}),1) ...
    find(ismember(hdr.label, abdomenLabel{2}),1) ...
    find(ismember(hdr.label, abdomenLabel{3}),1)];
warning('off', 'MATLAB:catenate:DimensionMismatch')
pesChl = [find(ismember(hdr.label,pesLabel{1}),1) ...
    find(ismember(hdr.label,pesLabel{2}),1)];
snoreChl = [find(ismember(hdr.label,snoreLabel{1}),1) ...
    find(ismember(hdr.label,snoreLabel{2}),1) ...
    find(ismember(hdr.label,snoreLabel{3}),1) ...
    find(ismember(hdr.label,snoreLabel{4}),1)];
oxygenChl = find(ismember(hdr.label, oxygenLabel),1);
channels = [nasalChl oralChl chestChl abdomenChl pesChl snoreChl oxygenChl];

% Store the sampling frequencies corresponding to the channel numbers
fsMax = max(hdr.fs);
fsFlow = hdr.fs(nasalChl);
fsOral = hdr.fs(oralChl);
fsChest = hdr.fs(chestChl);
fsAbdomen = hdr.fs(abdomenChl);
fsPes = hdr.fs(pesChl);
fsSnore = hdr.fs(snoreChl);
fsOxygen = hdr.fs(oxygenChl);
fs = [fsFlow fsOral fsChest fsAbdomen fsPes fsSnore fsOxygen];

end

%------------------------------ END OF CODE -------------------------------