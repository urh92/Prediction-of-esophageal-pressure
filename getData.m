function [namfil, folder] = getData(database)
%getData - Extracts and stores patient IDs for all patients in the database
%
% Syntax:  [namfil, folder] = getData(database)
% 
% Inputs: 
%    database - A string that indicates whether data will be extracted from 
%               the server or the hard disk
%               database is either specified as "server" or "hard disk"
%
% Outputs: 
%    namfil - A list containing all patient IDs with the .EDF extension
%    folder - A struct containing all info for every file in the database
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author: Umaer Hanif
% February 2017; Last revision: 8-June-2017

%------------------------------ BEGIN CODE --------------------------------

% Get patient IDs from either the server or the hard disk
if strcmpi(database, 'server')
    addpath('/data1/home/umaer/MATLAB');
    addpath('/data2/psg/SSC/PES');
    folder = dir('/data2/psg/SSC/PES');
elseif strcmpi(database, 'hard disk')
    addpath('/Users/umaerhanif/Documents/Speciale/MATLAB');
    addpath('/Volumes/Seagate Backup Plus Drive/Lotte Trap/Data');
    folder = dir('/Volumes/Seagate Backup Plus Drive/Lotte Trap/Data');
else
    disp('Invalid database')
end

% Remove elements that are not patient IDs 
remove = [];
for ii = 1:numel(folder)
    if folder(ii).isdir == 1
        remove = [remove,ii];
    end
end

folder(remove) = [];

% Store all patient IDs with the .EDF extension from the database
namfil = char(zeros(numel(folder)/2,numel(folder(1).name)));
n = 1;

for f = 1:2:numel(folder)
    namfil(n,:) = folder(f).name;
    n = n + 1;
end

end

%------------------------------ END OF CODE -------------------------------