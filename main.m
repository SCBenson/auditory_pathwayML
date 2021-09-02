%% Call the batching.m to get the data.

%% Call the bin_test.m to bin all the data

%% Call the bagThis.m to classify the binned data

load('neuron1','bin_array')
sweep_height = length(bin_array);
randTrees = bagThis(bin_array,sweep_height);