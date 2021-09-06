region = 'AI';
unit = 'MU';
type = '8ch500';
folderdir = fullfile('Data',region,unit,type);
f = dir(folderdir);
f = f(3:end);

for neuron = 1:length(f)
    trialInstance = load(fullfile(folderdir,f(neuron).name));
    trialInstance = trialInstance.spkdata.sets;
    
    % This sets the no. of rows needed for making the binned array
    % as every phoneme repetition time trial has diff no. of cells.
    checkInstance = trialInstance(1).sweeps;
    sweep_height = length(checkInstance);
    height = sweep_height*length(trialInstance);
    %% setting the parameters for the bins
    set_bin = 0.001;
    bins = 700;
    bin_array = zeros(height,bins);
    repIndex = sweep_height;

    % This will be the no. of rows for the trial matrix
    for trial = 1:length(trialInstance)
        % accessing the ith sweep containing the repetitions of spkTimes
        sweepInstance = trialInstance(trial).sweeps;

        %% accessing each repetition for the phoneme
        for rep = 1:repIndex 
            % accessing the nth spike time array
            repetitionList = sweepInstance(rep);
            % since its a cell, we change it to an array for indexing
            repetitionList = cell2mat(repetitionList);
            % checking if the repetition list for this GX_ file COMPLETELY empty
            % if it IS, then make it a 1x1 zeros array
            if isempty(repetitionList) == 1
                repetitionList = zeros(1,1);
            end

            % This is looping through 1 spike train and binning.
            for spkTimeIndex = 1:length(repetitionList)
                spkTime = repetitionList(spkTimeIndex);
                if spkTime == 0 && trial == 1
%                     bin_array(sweeps:sweep_height,:) = zeros(sweep_height,bins);
                    continue
                end
                if spkTime == 0 && trial ~= 1
                    % This triggers for ONLY the 1x1 zeros array made in
                    % line 33 to make a 10x10 zeros binned matrix.
%                     bin_array((sweeps*sweep_height)-sweep_height+1:sweeps*sweep_height,:) = zeros(sweep_height,bins);
                    continue
                end
                if spkTime <= set_bin && spkTime > 0
                    where = rep-1;
                    if where == 0 && trial == 1
      
                        bin_array((trial*sweep_height)-sweep_height + 1,1) = bin_array((trial*sweep_height)-sweep_height + 1,1) + 1;
                        continue
                    end
                    bin_array((trial*sweep_height)-sweep_height + where,1) = bin_array((trial*sweep_height)-sweep_height + where,1) + 1;      
                end
                for i = 1:bins
                    if spkTime > set_bin * i && spkTime <= set_bin * i + set_bin && i ~= bins && trial ~= 1
                       if trial ==1
                           bin_array((trial*sweep_height)-sweep_height + 1,i+1) = bin_array((trial*sweep_height)-sweep_height + 1,i+1) + 1;
                       else
%                            disp(sweeps)
                           bin_array((trial*sweep_height)-sweep_height + (rep-1),i+1) = bin_array((trial*sweep_height)-sweep_height + (rep-1),i+1) + 1;
                       end
                    end
                    
                end
            end

           % so far I have created a binned spike time matrix for 1 trial.
                    
        end
    end
neuronID = int2str(neuron);
where_to_save = strcat('binnedMatrices\',region,'\',unit,'\',type,'\','otherbins\','\1ms\');
saveResultsAs = strcat(where_to_save,'neuron',neuronID,'_1ms');
save(saveResultsAs,'bin_array');

end

% imagesc(bin_array)
% title("IC || Single Unit || Single Trial || Spike Time Bin Response");
% xlabel("Time-bins in Milliseconds (ms)");
% xticklabels(["70", "140", "210", "280", "350", "420", "490", "560", "630", "700"])
% ylabel("Sweeps");
% hcb=colorbar;
% hcb.Title.String = "Number of spikes firing";
% colormap('jet')
% save('neuron99','bin_array');





            
