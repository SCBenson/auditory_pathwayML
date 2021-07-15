% Add the neccessary scripts to the path
savepath=path;
addpath(genpath(pwd));

% Path to AN data
datadir=fullfile('Data','AN','natural');

fileList = dir(datadir); % lists all of the .spk files

% formatting to get rid of unnecessary cells:
fileList = fileList(3:102);

freqList = zeros(100,1);

%Now we must declare parameters for future neurogram.
binsize=1e-3;
duration=0.7;
load('Default.mat','parameters');
window_length=round(logspace(0,log10(400),10));
N=numel(window_length);

% Now to split the names of each of the cells in fileList to obtain the
% frequency:

for ij=1:100
    inter_mediary = split(fileList(ij).name,'H');
    inter_mediary = cell2mat(inter_mediary(1));
    freqList(ij) = str2num(inter_mediary);
end
    
maxPredictions = zeros(100,1);
maxTick = 1;
% We must access each .spk file via a for loop.
%spkList = fileList(3).name; For example

for i=1:100

    % Ascertains the frequency.
    spkFreq = fileList(i).name;
    spkInstance = spk_read(spkFreq);
    % Labels each .spk instance with its respective freq.
    spkInstance(1).original_filename = spkFreq;
    % load the spk instance into the buildneurogram function
    neurograms=buildneurograms(spkInstance(1),binsize,duration);
    % Now we run the classifier for it:
    fprintf('Batch number: %i\n', i);
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
       
    
    if i<=10
        figure();
        semilogx(window_length,meanvals,'kx-')
        s1 = sprintf('Frequency: %i',freqList(i));
        s2 = 'Hz';
        title(strcat(s1,s2));
        xlabel('Smoothing window, ms');
        ylabel('Percent correct (%)');
        xlim([min(window_length),max(window_length)]);

        
    end    
    
    
    
end
figure()

%create new array for x and y with size of the freq range.
%loop through 100 indices
%and manually position x and y into the x-position they need to be in
x = zeros(100,1);
y = zeros(100,1);

sortedFreq = sort(freqList); % sorted frequencies (100Hz to 5kHz)

for u=1:100
    sortedF = sortedFreq(u); %say 100Hz
    for p=1:100
        if sortedF == freqList(p)
            movedY = maxPredictions(p); % we know which y corresponds to the x
            x(u)=sortedF; % so the sorted x is at the sorted index position
            y(u)=movedY; % the y corresponding to this move is moved to the relative sorted index.
         end
     end
 end
    
    
plot(x,y);
title('Max Prediction for each frequency');
xlabel('Frequency (Hz)');
ylabel('Maximum Successful Prediction (%)');

path=savepath;