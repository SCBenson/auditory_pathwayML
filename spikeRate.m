% Takes in a 10x1 cell array of spike times for each repitition
function sR = spikeRate(cellOfSpikes, stoppage)
    % create a new variable to store the spike times
    spikeCells = cellOfSpikes;
    limit = stoppage;
    %will contain the no. of spikes recorded for each repetition
    averagedSpikes = zeros(limit,10);
    %spkRates = zeros(stoppage,1);
    for i = 1:length(dataInstance.sets)
        spikeSweep = spikeCells{i};
        for j = 1:10
            emptyArray = zeros(1,10);
            emptyArray(j) = length(spikeSweep(j)/700);
        end
        averagedSpikes(i,:) = emptyArray(:);
    end
    sR = averagedSpikes;  
    
end