%% Generating the Path
% Add the neccessary scripts to the path
savepath=path;
addpath(genpath(pwd));
%% Neurogram Parameters
%Now we must declare parameters for future neurogram.
binsize=1e-3;
duration=0.7;
load('Default.mat','parameters');
%%
datadir=fullfile('Data','IC','SU','8ch160');

fileList = dir(datadir); % lists all of the .mat files

% formatting to get rid of unnecessary cells:
fileList = fileList(3:length(fileList));
dataInstance = load(fullfile(datadir,fileList(1).name));

%now we must get the average spike rate for each 16 phonemes.

dataSet = dataInstance.spkdata.sets;
dataParams = dataSet.parameter_values;