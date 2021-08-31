load('neuron1','bin_array')
trial = bin_array;
sweep_height = length(trial);
svmPredict = svmclassify(trial, sweep_height)