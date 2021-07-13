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
trial = 1:100;
maxPredictions = zeros(100,1);
maxTick = 1;

% We must access each .spk file via a for loop.
%spkList = fileList(3).name; For example

for i=3:50
    if i<=13
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
    spkInstance(1).original_filename = spkFreq;
    % load the spk instance into the buildneurogram function
    neurograms=buildneurograms(spkInstance(1),binsize,duration);
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
    % computes the maximum prediction rate for a given .spk
    maxPrediction = max(meanvals);
    maxPredictions(maxTick) = maxPrediction;
    maxTick = maxTick + 1;
  
    %Locates at which window_length the max rate occurred:
%     for j=1:N
%         instanceval = meanvals(j);
%         if instanceval == maxPrediction
%             maxPredictions(maxTick) = instanceval;
%             if maxTick == 100
%                 break
%             end
%             maxTick = maxTick + 1;
%         end
%     end
            
    semilogx(window_length,meanvals,'kx-')
    
    
end
figure()
title('Max Prediction for each frequency')
plot(trial,maxPredictions);
path=savepath;