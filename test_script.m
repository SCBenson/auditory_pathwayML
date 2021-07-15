% Add the neccessary scripts to the path
savepath=path;
addpath(genpath(pwd));

% Path to AN data
datadir=fullfile('Data','IC','SU','1ch16');
% datadir=fullfile('..', 'data', 'AI','SU', '0ch');
fileList = dir(datadir);
fileList = fileList(3:113);

lenFile = length(fileList);
% 
% for i = 3:lenFile
%     instanceFile = fullfile(fileList(i).name);
%     filename=spk_read(filename);
% end
 

% filename(s)
%filename=fullfile(datadir,'111Hz.spk');
filename=fullfile(datadir,'G1_1_1411_p1_6300_vcv_1ch_unit1_SPK_envBW_16.mat');
filename=spk_read(filename);

% (Optional) Display the spike rasters
%load(filename,'spkdata');
%figure();
% spk_display_rasters_basic(spkdata,0.7,16);
%spk_display_rasters_basic(filename,0.7,16);
%%
% Build the neurograms
binsize=1e-3; % 1ms bin size
duration=0.7; % 700ms stim duration
neurograms=buildneurograms(filename,binsize,duration);

% Define classifier parameters
load('Default.mat','parameters');
window_length=round(logspace(0,log10(400),10));
N=numel(window_length);

% Run classifier
for i=1:N
  fprintf(['Smoothing=',num2str(window_length(i)),'ms (',...
    num2str(i),' of ',num2str(N),')\n']);
  parameters.window_length=window_length(i);
  results(:,i)=classify(neurograms,parameters); %#ok
  fprintf('\n');
end

% Plot the classifier results
meanvals=mean(arrayfun(@(x) x.correct,results),1);
figure();
semilogx(window_length,meanvals,'kx-')
xlabel('Smoothing window, ms');
ylabel('Percent correct');
xlim([min(window_length),max(window_length)]);
[~,name]=fileparts(filename);
title(strrep(name,'_','\_'));

% Restore the path
path=savepath;