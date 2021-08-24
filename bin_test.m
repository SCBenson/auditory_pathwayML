folderdir = fullfile('Data','IC','SU','0ch');
f = dir(folderdir);
f = f(3:end);

for trial = 1:1
    trialInstance = load(fullfile(folderdir,f(trial).name));
    trialInstance = trialInstance.spkdata.sets;
    
    % This sets the no. of rows needed for making the binned array
    % as every phoneme repetition time trial has diff no. of cells.
    checkInstance = trialInstance(sweep_check).sweeps;
    sweep_height = length(checkInstance);
    height = sweep_height*48;

    % This will be the no. of rows for the trial matrix
    for sweep = 1:48
        % accessing the ith sweep containing the repetitions of spkTimes
        sweepInstance = trialInstance(sweep).sweeps;

        %% setting the parameters for the bins
        set_bin = 0.07;
        bins = 10;
        bin_array = zeros(height,bins);
        repIndex = sweep_height;
        %% accessing each repetition for the phoneme
        for rep = 1:repIndex 
            % accessing the nth spike time array
            repInstance = sweepInstance(repIndex);
            % since its a cell, we change it to an array for indexing
            repInstance = cell2mat(repInstance);
            if isempty(repInstance) == 1
                repInstance = zeros(1,1);
            end

            % This is looping throw 1 spike train and binning.
            for spkTimeIndex = 1:length(repInstance)
                spkTime = repInstance(spkTimeIndex);
%                 if spkTime == 0
%                     bin_array()
                if spkTime <= bins && spkTime > 0
                   bin_array(sweep_height*sweep,1) = bin_array(sweep_height,1) +1;      
                end
                for i = 1:bins
                    if spkTime > set_bin * i && spkTime <= set_bin * i + set_bin && i ~= bins
                       bin_array(sweep_height,i+1) = bin_array(sweep_height,i+1) + 1;
                    end
                end

            end

           % so far I have created a binned spike time matrix 
                    
        end
    end
        
end


%%
% x = {0.01, 0.01, 0.2, 0.26, 0.34, 0.41, 0.43, 0.53, 0.61, 0.61};
% y = {0.25, 0.56, 0.69};
% 
% bins = 10;
% set_bin = 0.07;
% bin_array = zeros(1,bins);
% 
% 
% for i = 1:length(x)
%     p = x(i);
%     if p <= set_bin
%         bin_array(1,1) = bin_array(1,1) + 1;
%     end
%     for i = 1:bins
%         if p > set_bin * i && p <= set_bin * i + set_bin && i ~= 10
%             bin_array(1,i+1) = bin_array(1,i+1) + 1;
%         end
%     end
% end
%     


            
