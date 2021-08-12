%% Generating the Path
% Add the neccessary scripts to the path
savepath=path;
addpath(genpath(pwd));
%% Neurogram Parameters
%Now we must declare parameters for future neurogram.
binsize=1e-3;
duration=0.7;
load('Default.mat','parameters');

%% Region & Node Specific Parameters
region = 'AN'; % AN: Auditory Nerve (simulated) || IC: Inferior Colliculus (Real-data) || AI: Primary Auditory Cortex (Real-data)
mode = '1ch16'; % [natural(AN),RF(IC,AI)] OR xchyyy , where x=[0(IC,AI),1,2,4,8] yyy=[16,50(IC&AI),160(IC&AI),500]
unitType = 'SU'; % SU-Single Unit || MU-Multi Unit
%% Extracting Region/Node Specific Data
if region == 'AN'
    % Path to IC/AI data
    datadir=fullfile('Data',region,mode);
end
if region ~= 'AN'
    % Path to AN data
    datadir=fullfile('Data',region,unitType,mode);
end

fileList = dir(datadir); % lists all of the .mat files

% formatting to get rid of unnecessary cells:
fileList = fileList(3:102); %3:size(fileList)??
%% For Plotting Later...
freqList = zeros(100,1);
getFigDirec=dir('figures');
figDirec = getFigDirec(1).folder;


% Now to split the names of each of the cells in fileList to obtain the
% frequency:
if region == 'AN'
    for ij=1:100
        inter_mediary = split(fileList(ij).name,'H');
        inter_mediary = cell2mat(inter_mediary(1));
        freqList(ij) = str2num(inter_mediary);
    end
end
%% Batch Processing

% We must access each .spk file via a for loop.
%spkList = fileList(3).name; For example

for i=1:100
    switch region
        case 'AN'
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
        case 'IC'
            
            dataInstance = load(fullfile(datadir,fileList(i).name));
            
            dataInstance = dataInstance.spkdata;
            
            rep_size = size(dataInstance.sets(1).sweeps);
            reps = rep_size(1);
            window_length=round(logspace(0,log10(400),reps)); % rep size is the no. of repetitions
            N=numel(window_length);  
            
            % load the spk instance into the buildneurogram function
            neurograms=buildneurograms(dataInstance(1),binsize,duration);
    
            % Now we run the classifier for it:
            fprintf('Batch number: %i\n', i);
        case 'AI'
          
            
            dataInstance = load(fullfile(datadir,fileList(i).name));
            
            dataInstance = dataInstance.spkdata;
            
            rep_size = size(dataInstance.sets(1).sweeps);
            reps = rep_size(1);
            window_length=round(logspace(0,log10(400),reps)); % rep size is the no. of repetitions
            N=numel(window_length);              
            
            % load the spk instance into the buildneurogram function
            neurograms=buildneurograms(dataInstance(1),binsize,duration);
    
            % Now we run the classifier for it:
            fprintf('Batch number: %i\n', i);
    end


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
        figName = int2str(freqList(i));
        figFullName = strcat(mode,figName,s2,'.fig');
        savingPosition = strcat(figDirec,'\',figFullName);
        savefig(savingPosition);

        
    end    
    
    
    
end
% 
% if region == 'IC'
%     stoppage = length(dataInstance.sets);
%     spkSetInfo = dataInstance.sets.sweeps;
%             
%     %Compute the SpikeRate and intermittent Spike Times:
%            
%     sR = spikeRate(spkSetInfo, stoppage);



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
header = ' '+'Maximum Prediction Frequencies';
p_T = strcat(region,mode,header);
title(p_T);
figSaveAs = strcat(region, mode,'.fig');
savePosition = strcat(figDirec,'\',figSaveAs);
xlabel('Frequency (Hz)');
ylabel('Maximum Successful Prediction (%)');
savefig(savePosition);
path=savepath;

for i = 1:100

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



end
