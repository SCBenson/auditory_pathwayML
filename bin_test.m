folderdir = fullfile('Data','IC','SU','0ch');
f = dir(folderdir);
f = f(3:end);

for trial = 1:99
    trialInstance = load(fullfile(folderdir,f(trial).name));
    trialInstance = trialInstance.spkdata.sets;
    
    % This sets the no. of rows needed for making the binned array
    % as every phoneme repetition time trial has diff no. of cells.
    checkInstance = trialInstance(1).sweeps;
    sweep_height = length(checkInstance);
    height = sweep_height*48;
    %% setting the parameters for the bins
    set_bin = 0.07;
    bins = 10;
    bin_array = zeros(height,bins);
    repIndex = sweep_height;

    % This will be the no. of rows for the trial matrix
    for sweeps = 1:48
        % accessing the ith sweep containing the repetitions of spkTimes
        sweepInstance = trialInstance(sweeps).sweeps;

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
                if spkTime == 0 && sweeps == 1
%                     bin_array(sweeps:sweep_height,:) = zeros(sweep_height,bins);
                    continue
                end
                if spkTime == 0 && sweeps ~= 1
                    % This triggers for ONLY the 1x1 zeros array made in
                    % line 33 to make a 10x10 zeros binned matrix.
%                     bin_array((sweeps*sweep_height)-sweep_height+1:sweeps*sweep_height,:) = zeros(sweep_height,bins);
                    continue
                end
                if spkTime <= set_bin && spkTime > 0
                    where = rep-1;
                    if where == 0 && sweeps == 1
      
                        bin_array((sweeps*sweep_height)-sweep_height + 1,1) = bin_array((sweeps*sweep_height)-sweep_height + 1,1) + 1;
                        continue
                    end
                    bin_array((sweeps*sweep_height)-sweep_height + where,1) = bin_array((sweeps*sweep_height)-sweep_height + where,1) + 1;      
                end
                for i = 1:bins
                    if spkTime > set_bin * i && spkTime <= set_bin * i + set_bin && i ~= bins && sweeps ~= 1
                       if sweeps ==1
                           bin_array((sweeps*sweep_height)-sweep_height + 1,i+1) = bin_array((sweeps*sweep_height)-sweep_height + 1,i+1) + 1;
                       else
%                            disp(sweeps)
                           bin_array((sweeps*sweep_height)-sweep_height + (rep-1),i+1) = bin_array((sweeps*sweep_height)-sweep_height + (rep-1),i+1) + 1;
                       end
                    end
                    
                end
            end

           % so far I have created a binned spike time matrix for 1 trial.
                    
        end
    end
        
end

imagesc(bin_array)
title("IC || Single Unit || Single Trial || Spike Time Bin Response");
xlabel("Time-bins in Milliseconds (ms)");
xticklabels(["70", "140", "210", "280", "350", "420", "490", "560", "630", "700"])
ylabel("Sweeps");
hcb=colorbar;
hcb.Title.String = "Number of spikes firing";
colormap('jet')
save('trial99','bin_array');


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


            
