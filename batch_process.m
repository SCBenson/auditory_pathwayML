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
    if i<=10
        figure();
        xlabel('Smoothing window, ms');
        ylabel('Percent correct');
        xlim([min(window_length),max(window_length)]);
        title(fileList(i).name);
    end
    % Ascertains the frequency.
    spkFreq = fileList(i).name;
    spkInstance = spk_read(spkFreq);
    % Labels each .spk instance with its respective freq.
    spkInstance(i).original_filename = spkFreq;
    % load the spk instance into the buildneurogram function
    neurograms=buildneurograms(spkInstance,binsize,duration);
    % Now we run the classifier for it:
    fprintf('Batch number: %i\n', i-2);
    for io=1:N
        
        fprintf(['Smoothing=',num2str(window_length(io)),'ms (',...
            num2str(io),' of ',num2str(N),')\n']);
        parameters.window_length=window_length(io);
        results(:,io)=classify(neurograms,parameters);
        fprintf('\n');
    end
    meanvals = mean(arrayfun(@(x) x.correct,results),1);
    semilogx(window_length,meanvals,'kx-')
    
    
end
path=savepath;