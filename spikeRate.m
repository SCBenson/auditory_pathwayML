% Takes in a 10x1 cell array of spike times for each repitition
function sR = spikeRate(cellOfSpikes, stoppage)
    % create a new variable to store the spike times
    spikeCells = cellOfSpikes;
    limit = stoppage;
    %will contain the no. of spikes recorded for each repetition
    averagedSpikes = zeros(limit,1);
    %spkRates = zeros(stoppage,1);
    
    % This code sums the total number of spikes that occur in a repetition
    % and divides it by 700ms to get num_Of_Spikes/millisecond. This value
    % is then summed for the 10 repetitions and divided by 10 to get the
    % average num_Of_Spikes/ms for the ith token (VCV) for the Xth Speaker:
    % (0 / 1 / 2)
    for i = 1:length(dataInstance.sets) % 1:48 for e.g.
        spikeSweep = spikeCells{i};
        emptyArray = zeros(1,10);
        countSpikes = 0;
        for j = 1:10
            spikeTimeLength = length(spikeSweep(j));
            dispAndFireRate = struct(dispTimeList,firingRate);
            dispTimeList = zeros(1,spikeTimeLength-1); % An array to hold the displacements of neuron times.
            countSpikes = countSpikes + length(spikeSweep(j))/700; % No. of spikes per recording for jth repetition
            for k = 1:spikeTimeLength
                if k != spikeTimeLength
                    dispTime = abs(spikeSweep(k) - spikeSweep(k+1));
                    dispTimeList(k) = dispTime;
                end
                maxDisp
            end
        end
        countSpikes = countSpikes/10;
        averagedSpikes(i,1) = countSpikes; %Average spike/ms from 10 repetitions for ith token
    end
    sR = averagedSpikes;  
    
end