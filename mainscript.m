%mainscript - Main script for preprocessing and feature extraction
%
% Other m-files required: getData.m, getChannels.m, loadChannels.m, 
%                         bandPass.m, highPass.m, notch.m,
%                         flatlineDetection.m, featureExtraction.m,
%                         featureExtraction2.m, paradoxical, pesMaxMin.m
% Subfunctions: none
% MAT-files required: patient_problems.mat
%
% Author: Umaer Hanif
% January-June 2017; Last revision: 16-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Get patient IDs from the server or the hard disk 
database = 'hard disk';
[namfil, folder] = getData(database);

% Remove all patients with technical problems
patients = 1:1576;
load patient_problems
patients(patient_problems) = [];

% Initialize feature matrix X and target vector Y
X = [];
Y = [];

% Run loop for each patient
for pID = 1
    fprintf('Patient %d out of %d...\n', pID, length(patients))
    edfName = namfil(patients(pID),:);      % Subject ID
    evtName = folder(patients(pID)*2).name; % Name of annotation file
    
    % Get the nasal pressure, oral airflow, thoracic and abdominal effort, 
    % snoring and PES signal and their sampling frequencies
    [channels, fs, fsMax] = getChannels(edfName); 
    
    % Load the signals specificed above and the corresponding hypnogram
    [rawSignals, fs, hypnogram, ~] = loadChannels(edfName, evtName, channels, fs, fsMax);
    
    N = 4;          % Filter order
    fc1 = 0.05;     % First cut-off frequency
    fc2 = 5;        % Second cut-off frequency for nasal, oral, and belts
    fc3 = 1;        % Second cut-off frequency for PES
    fc1_notch = 59; % First cut-off frequency for notch filter
    fc2_notch = 61; % Second cut-off frequency for noth filter
    
    % Filter all signals using the above specified cut-off frequencies
    nasal = bandPass(rawSignals{1}, N, fc1, fc2, fs(1));   % Bandpass nasal
    oral = bandPass(rawSignals{2}, N, fc1, fc2, fs(2));    % Bandpass oral
    chest = bandPass(rawSignals{3}, N, fc1, fc2, fs(3));   % Bandpass chest
    abdomen = bandPass(rawSignals{4}, N, fc1, fc2, fs(4)); % Bandpass abdom
    pes = bandPass(rawSignals{5}, N, fc1, fc3, fs(5));     % Bandpass PES
    snore = highPass(rawSignals{6}, N, fc1, fs(6));        % Highpass snore
    snore = notch(snore, N, fc1_notch, fc2_notch, fs(6));  % Notch snore
    
    % Detect flatline segments from the PES signal
    jitter = 10e14;
    flatlineStruct = flatlineDetection(pes, jitter);
    
    % Set flatline index values as NaN in the nasal signal and hypnogram
    for i = 1:length(flatlineStruct)
        nasal(flatlineStruct{i}) = nan;
        hypnogram(flatlineStruct{i}) = nan;
    end
    
    % Extract features from all noninvasive signals and relative negative
    % esophageal pressure values from PES in a sliding window 
    featuresNasal = featureExtraction(nasal, fs(1));     % Nasal features
    featuresOral = featureExtraction(oral, fs(2));       % Oral features
    featuresChest = featureExtraction(chest, fs(3));     % Chest features
    featuresAbdomen = featureExtraction(abdomen, fs(4)); % Abdomen features
    PLV = paradoxical(chest, abdomen, fs(4));            % PLV feature
    featuresPes = pesMaxMin(pes, fs(5), hypnogram);      % Negative PES
    featuresSnore = featureExtraction2(snore, fs(6));    % Snore features
    
    % Concatenate all features in a feature matrix
    features = [featuresNasal featuresOral featuresChest featuresAbdomen PLV featuresSnore];

    % Remove features in which a flatline segment was present from earlier
    removeNaN = find(isnan(features(:,1)));
    features(removeNaN,:) = [];
    featuresPes(removeNaN,:) = [];
    
    % Add feature matrix from current patient to matrix of all patients
    X = [X; features];
    
    % Add target vector from current patient to vector of all patients
    Y = [Y; featuresPes];
    
end

%------------------------------ END OF CODE -------------------------------