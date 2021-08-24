savepath=path;
addpath(genpath(pwd));

%Support Vector Machine Classification

% Creates a hyper plane of n-dimensions to
% classify the .spk files; there are 16 classes.

% One row per observation
% One column per predictor
Y = linspace(1,16,16);
Y_predictions = repmat(Y,30);
Y_predictions = Y_predictions(1,:);

