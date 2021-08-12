load('Default.mat','parameters');
datadir=fullfile('Data','IC','SU','1ch16');
fileList = dir(datadir);
fileNames = fileList(3:length(fileList));

dataInstance = load(fullfile(datadir,fileNames(1).name));
dataInstance = dataInstance.spkdata.sets;

% Create the time bins for spike times (1x10) e.g [0, 1, 1, 3, 2, 1, 0, 0, 0, 2]
% each index corresponds to 70ms of time elapsed

spikeBin = zeros(48,10);

for i = 1:48
    sweepRow = dataInstance(i).sweeps;
    averagedSweep = zeros();
    for j = 1:10 % ith sweep row
        repRow = sweepRow(j);
        avgBin = zeros(10,10);
        if isempty(repRow{1,1})
            continue
        else
            repRow = cell2mat(repRow);
            for k = 1:length(repRow)
                spkTime = repRow(k);
                % Logical Operators to bin the spike times.
                if spkTime <= 0.07
                    avgBin(j,1) = avgBin(j,1) + 1;
                elseif spkTime > 0.07 && spkTime <= 0.14
                    avgBin(j,2) = avgBin(j,1) + 1;
                elseif spkTime > 0.14 && spkTime <= 0.21
                    avgBin(j,3) = avgBin(j,1) + 1;
                elseif spkTime > 0.21 && spkTime <= 0.28
                    avgBin(j,4) = avgBin(j,1) + 1;
                elseif spkTime > 0.28 && spkTime <= 0.35
                    avgBin(j,5) = avgBin(j,1) + 1;
                elseif spkTime > 0.35 && spkTime <= 0.42
                    avgBin(j,6) = avgBin(j,1) + 1;
                elseif spkTime > 0.42 && spkTime <= 0.49
                    avgBin(j,7) = avgBin(j,1) + 1;
                elseif spkTime > 0.49 && spkTime <= 0.56
                    avgBin(j,8) = avgBin(j,1) + 1;
                elseif spkTime > 0.56 && spkTime <= 0.63
                    avgBin(j,9) = avgBin(j,1) + 1;
                else
                    avgBin(j,10) = avgBin(j,1) + 1;
                end
            end
        
        end

    end
        %sum the columns to squash a 10x10 array to a 1x10 array, and
        %place into the spikeBin 48x10 array.
        squashedBin = sum(avgBin);
        spikeBin(i,:) = squashedBin;
end

% now we need to get the phoneme correlated avgBins
phonemeSpkBin = zeros(16,10);
for i = 1:16  
    phonemeSpkBin(i,:) = spikeBin(i,:)+spikeBin(i+16,:)+spikeBin(i+32);
end
        


