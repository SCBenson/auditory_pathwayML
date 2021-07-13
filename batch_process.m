% Add the neccessary scripts to the path
savepath=path;
addpath(genpath(pwd));

% Path to AN data
datadir=fullfile('Data','AN','natural');
% datadir=fullfile('..', 'data', 'AI','SU', '0ch');
fileList = dir(datadir); % lists all of the .spk files
%Now we must declare parameters for future neurogram.
binsize=1e-3;
duration=0.7;
load('Default.mat','parameters');
window_length=round(logspace(0,log10(400),10));
N=numel(window_length);

% We must access each .spk file via a for loop.
%spkList = fileList(3).name; For example

for i=3:102
    spkInstance = fileList(i).name;
    spkInstance = spk_read(spkInstance);
    % load the spk instance into the buildneurogram function
    neurograms=buildneurograms(spkInstance,binsize,duration);
    % Now we run the classifier for it:
    for io=1:N
        fprintf(['Smoothing=',num2str(window_length(io)),'ms (',...
            num2str(io),' of ',num2str(N),')\n']);
end
    