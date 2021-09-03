%load('neuron1','bin_array')
%Random Forest Classification


region = 'IC';
unit = 'SU';
mode = '8ch160';

datadir = fullfile('binnedMatrices',region,unit,mode);
sweepdir = fullfile('Data',region,unit,mode);

neuronList = dir(datadir); % lists all of the .mat files
neuronList = neuronList(3:end); %3:size(fileList)??
sweepList = dir(sweepdir);
sweepList = sweepList(3:end);
%% File creating
path = strcat('binnedMatrices\',region,'\',unit,'\','answers');
parent_folder = what(path);
parent_folder = parent_folder.path;
folder_name = strcat(mode,'_tbgmdl_results');
mkdir(parent_folder,folder_name);
%% Setting graphing parameters..
xGraph = linspace(1,length(neuronList)-1,length(neuronList)-1);
yGraph = [];
for i = 1:length(neuronList)
    disp(i)
    % get a bin_array and it's neuronID name [the file is scrambled]
    neuronID = neuronList(i).name;
    neuronID = extractBefore(neuronID,'.mat');

    bin_array_instance = load(fullfile(datadir,neuronList(i).name));
    % we have to check how many sweeps there are:
    sweepDimension = load(fullfile(sweepdir,sweepList(i).name));
    sweepDimension = sweepDimension.spkdata;
    sweepDimension = sweepDimension.sets;
    repDimension = length(sweepDimension(1).sweeps);
    sweepDimension = length(sweepDimension);
    
    %One row per observation
    %One column per predictor
    X = bin_array_instance.bin_array;
    size_of_bin_array = repDimension*sweepDimension;
    if size_of_bin_array ~= length(X)
        size_of_bin_array = length(X);
        repDimension = (length(X))/48;
    end
    training_size = 0.8 * size_of_bin_array;
    testing_size = 0.2 * size_of_bin_array;

    % The list of VCVs to create the Y input matrix
    p = ["ABA", "ADA", "AFA", "AGA", "AKA", "ALA", "AMA", ...
        "ANA", "APA", "ASA", "ASHA", "ATA", "ATHA", "AVA", "AYA", "AZA"];


    % make sure we enter the height of the sweeps into the function
    output_length = 3*repDimension;
    phon = [];
    phonemes = [];
    for j = 1:length(p)
        phon = p(j);
        phone = repmat(phon,output_length);
        phone = phone(1,:)';
        phonemes = cat(1,phonemes,phone);
    end

    Y = repmat(phonemes,output_length);
    Y = Y(1,:);

    % n random numbers to split the data.
    n = repDimension * sweepDimension;
    splitting_indx = randi([1 n],1,n);

    organisedPhonemes = [];
    for k = 1:length(p)
        idx = (phonemes==p(k));
        samePhoneme = X(idx,:);
        organisedPhonemes = cat(1,organisedPhonemes,samePhoneme);
    end
    
    %% Create the Testing and Training Inputs
    training_input = [];
    testing_input = [];
    training_output = [];
    testing_output = [];

    for u = 1:training_size
        training_input = cat(1,training_input,organisedPhonemes(splitting_indx(u),:));
        training_output = cat(1,training_output,phonemes(splitting_indx(u)));
    end
    for t = 1:testing_size
        testing_input = cat(1,testing_input,organisedPhonemes(splitting_indx(t),:));
        testing_output = cat(1,testing_output,phonemes(splitting_indx(t)));
    end
    

    %% Inserting the Training and Testing Data and Predicting Phonemes
    % Randomise the data for test and train
    %ClassTreeEns = fitensemble(organisedPhonemes,phonemes,'AdaBoostM2',3000,'Tree');
    B = TreeBagger(100,training_input,training_output,'OOBPrediction','off','OOBPredictorImportance','on'); 
    Y_hat = predict(B, testing_input);
    acc = Y_hat == testing_output; % phonemes if this doesnt work
    total_acc = sum(acc(:,1));
    accuracy = total_acc/n;
    %error = oobError(B);
    %% Save the accuracy point for graphing
%     where_to_save = strcat('binnedMatrices\',region,'\',unit,'\',mode,'\','randtrees_results','\');
%     saveResultsAs = strcat(where_to_save,neuronID,'_randForestAccuracy');
%     save(saveResultsAs,'accuracy');
    
    % save the accuracies in an array called yGraph
    yGraph = cat(1,yGraph,accuracy);
    %% Save the default tbgmdl's parameters for future bootstrapping
    model(i).default_tbgmdl = B;
    model(i).training_input = training_input;
    model(i).training_output = training_output;
    model(i).testing_input = testing_input;
    model(i).testing_output = testing_output;

end
%% Get the default tbgmdl's number of neurons above the threshold for accuracy rating
accuracy_threshold = 0.18;
threshold_of_success = (yGraph > accuracy_threshold);
num_highest_accuracy = sum(threshold_of_success(:)==1);
%% Error
% figure
% bar(B.OOBPermutedPredictorDeltaError);
%% Margin

thresholded_importance = find(B.OOBPermutedPredictorDeltaError>0.75);
% xlabel('Feature Index')
% ylabel('Out-of-Bag Feature Importance')
%% now test again, but bootstrapped...
% this is our desired threshold for the bins 'importance'
feature_threshold = 0.75;
model_bootstrapped = struct('bootstrapped_tbgmdl', cell(1, length(neuronList)-1));
for i = length(neuronList)
    feature_importance = find(model(i).default_tbgmdl.OOBPermutedPredictorDeltaError>feature_threshold);
    tr_i = model(i).training_input;
    tr_o = model(i).training_output;
    te_i = model(i).testing_input;
    te_o = model(i).testing_output;
    % get the bootstrapped model
    B_bootstrapped = TreeBagger(400,tr_i(:,feature_importance),tr_o, ...
        'OOBPrediction','on','OOBPredictorImportance','off');
    % get the y_hat from bootstrapped model
    Y_hat_bootstrapped = predict(B_bootstrapped, te_i(:,feature_importance)); 
    % get the indexes where there was an accurate prediction
    accDist_bootstrapped = Y_hat_bootstrapped == te_o;
    % Get the sum of correct answers found
    total_correct_bootstrapped = sum(accDist_bootstrapped(:,1));
    % get the ratio of correct/total
    accuracy_bootstrapped = total_correct_bootstrapped/n;
    % 
    
    % save bootstrapped answers...
    model_bootstrapped(i).bootstrapped_tbgmdl = B_bootstrapped;
    
end
%%
B_important = TreeBagger(400,training_input(:,thresholded_importance), ... 
    training_output,'OOBPrediction','on','OOBPredictorImportance','off'); 

Y_hat_bootstrap = predict(B_important, testing_input(:,thresholded_importance));
accuracyDistribution_bootstrap = Y_hat == testing_output;
total_correct_bootstrap = sum(accuracyDistribution_bootstrap(:,1));
accuracy_bootstrap = total_correct_bootstrap/480;
threshold_of_success = (accuracyDistribution_bootstrap > .18);
num_highest_accuracy_bootstrap = sum(threshold_of_success(:)==1);

% plot(oobMeanMargin(B_important));
% xlabel('Number of Grown Trees')
% ylabel('Out-of-Bag Mean Classification Margin')
% figure
tbgmdl_error = oobError(B);
bootstrap_tbgmdl_error = oobError(B_important);
% plot(oobError(B_important),'r-')
% hold on
% plot(oobError(B),'b-')
% xlabel('Number of Grown Trees')
% ylabel('Out-of-Bag Classification Error')

% plot(xGraph,yGraph*100)
% xticklabels(xGraph)

%% Saving the answers in a structure called answer
% The region, unit and mode of this file
answer.region = region;
answer.unit = unit;
answer.mode = mode;
% Models for default tbg & bootstrapped
answer.default_tbgmodels = model;
answer.tbgmdl_bootstrap_tbmdl = B_important; % to be added
% Accuracy of default tbg & bootstrapped
answer.tbgmdl_accuracy = yGraph;
answer.tbgmdl_accuracy_bootstrap = accuracy_bootstrap;
% Number of neurons showing accuracies above the threshold for default tbg & bootstrapped (=0.18)
answer.tbgmdl_numhighestacc = accs;
answer.tbgmdl_numhighestacc_bootstrap = num_highest_accuracy_bootstrap;
% Error distribution for default tbg & bootstrapped
answer.tbgmdl_error = tbgmdl_error;
answer.tbgmdl_error_bootstrap = bootstrap_tbgmdl_error;


%% Saving the answer structure
folder = strcat(parent_folder,'\',folder_name,'\','answer');
save(folder,'-struct','answer');
%% Save all the results




