%% Generating the Path
% Add the neccessary scripts to the path
savepath=path;
addpath(genpath(pwd));
%% Neurogram Parameters
%Now we must declare parameters for future neurogram.
binsize=1e-3;
duration=0.7;
load('Default.mat','parameters');
%% Batch Processing
% We must access each .spk file via a for loop.
%spkList = fileList(3).name; For example
modesList = ["1ch16","1ch500","2ch16","2ch500","4ch16","4ch500","8ch16","8ch500","natural"];
for m = 1:9
    mo = modesList(m);
    maxPred = zeros(1,length(modesList));
    maxPredictions = zeros(100,1);
    maxTick = 1;
    datadir=fullfile('Data','AN',mo);
    fileList = dir(datadir); % lists all of the .mat files
    freqList = zeros(100,1);

    % formatting to get rid of unnecessary cells:
    fileList = fileList(3:102); %3:size(fileList)??
    
    for i=1:10

        window_length=round(logspace(0,log10(400),10));
        N=numel(window_length);
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
    end    
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
    maxPred(1,m) = max(y); %max prediction value
    pointer = max(y);
    corresFreq = zeros(1,9);
    for p = 1:100
        if pointer == x(p)
           corresFreq(1,m) = p;
        end
    end  
end

freqList = zeros(100,1);
getFigDirec=dir('figures');
figDirec = getFigDirec(1).folder;

maxPredictions = zeros(100,1);

maxTick = 1;
% Now to split the names of each of the cells in fileList to obtain the
% frequency:

for ij=1:100
    inter_mediary = split(fileList(ij).name,'H');
    inter_mediary = cell2mat(inter_mediary(1));
    freqList(ij) = str2num(inter_mediary);
end


figure();
plot(corresFreq,maxPred);


