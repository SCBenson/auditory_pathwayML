%Random Forest Classification

%% Selecting REGION / UNIT / MODE && Getting Directories
tic
region = 'IC';
unit = 'SU';
mode = '2ch16';
ms_bin = '5ms';

datadir = fullfile('binnedMatrices',region,unit,mode);
%datadir = fullfile('binnedMatrices',region,unit,mode,'otherbins',ms_bin);
sweepdir = fullfile('Data',region,unit,mode);

neuronList = dir(datadir); % lists all of the .mat files
neuronList = neuronList(3:end); %3:size(fileList)??
len = length(neuronList) - 1;
neuronList = neuronList(1:len);
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
model = struct();
%% TreeBagging
for i = 1:length(neuronList)
    disp(i)
    % get a bin_array and it's neuronID name [the file is scrambled]
    neuronID = neuronList(i).name;
    neuronID = extractBefore(neuronID,'.mat');
    bin_array_instance = load(fullfile(datadir,neuronList(i).name));
    % we have to check how many sweeps there are:
    sweepDimension = load(fullfile(sweepdir,sweepList(i).name));
    sweepDimension = sweepDimension.spkdata;
    sweepSets = sweepDimension.sets;
    repDimension = length(sweepSets(1).sweeps);
    sweepDimension = length(sweepSets);
    
    %One row per observation
    %One column per predictor
    X = bin_array_instance.bin_array;
    size_of_bin_array = repDimension*sweepDimension;
    if size_of_bin_array ~= size(X,1)
        size_of_bin_array = size(X,1);
        repDimension = (size(X,1))/48;
    end
    training_size = round(0.8 * size_of_bin_array);
    testing_size = floor(0.2 * size_of_bin_array);
    

    % The list of VCVs to create the Y input matrix
    p = ["ABA", "ADA", "AFA", "AGA", "AKA", "ALA", "AMA", ...
        "ANA", "APA", "ASA", "ASHA", "ATA", "ATHA", "AVA", "AYA", "AZA"];


    % make sure we enter the height of the sweeps into the function
    output_length = 3*repDimension;
    if output_length ~= floor(output_length)
        output_length = round(output_length);
    end
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
    n = size(X,1);
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
    mdl = TreeBagger(100,training_input,training_output,'OOBPrediction','off','OOBPredictorImportance','on'); 
    Y_hat = predict(mdl, testing_input);
    [Yfit,scores] = predict(mdl,testing_input);
    acc = Y_hat == testing_output; % phonemes if this doesnt work
    total_acc = sum(acc(:,1));
    accuracy = total_acc/length(testing_input);
    %% Save the accuracy points for graphing later
    yGraph = cat(1,yGraph,accuracy);
    %% Save the default tbgmdl's parameters for future bootstrapping
    model(i).default_tbgmdl = mdl;
    model(i).training_input = training_input;
    model(i).training_output = training_output;
    model(i).testing_input = testing_input;
    model(i).testing_output = testing_output;

end
%% Get the default tbgmdl's number of neurons above the threshold for accuracy rating
accuracy_threshold = 0.18;
threshold_of_success = (yGraph > accuracy_threshold);
num_highest_accuracy = sum(threshold_of_success(:)==1);
%% BOOTSTRAPPING
% this is our desired threshold for the bins 'importance'
% feature_threshold = 0.75;
yGraph_bootstrapped = [];
model_bootstrapped = struct();
% now lets get our bootrapped model running on each neuron...
for i = length(neuronList)
    mean_featureImportance = sum(model(i).default_tbgmdl.OOBPermutedPredictorDeltaError)/length(model(i).default_tbgmdl.OOBPermutedPredictorDeltaError);
    feature_importance = find(model(i).default_tbgmdl.OOBPermutedPredictorDeltaError>mean_featureImportance);
    tr_i = model(i).training_input;
    tr_o = model(i).training_output;
    te_i = model(i).testing_input;
    te_o = model(i).testing_output;
    % get the bootstrapped model
    mdl_bootstrapped = TreeBagger(400,tr_i(:,feature_importance),tr_o, ...
        'OOBPrediction','on','OOBPredictorImportance','off');
    % get the y_hat from bootstrapped model
    Y_hat_bootstrapped = predict(mdl_bootstrapped, te_i(:,feature_importance)); 
    % get the indexes where there was an accurate prediction
    accDist_bootstrapped = Y_hat_bootstrapped == te_o;
    % Get the sum of correct answers found
    total_correct_bootstrapped = sum(accDist_bootstrapped(:,1));
    % get the ratio of correct/total
    accuracy_bootstrapped = total_correct_bootstrapped/length(te_i);
    % accuracy above threshold
    yGraph_bootstrapped = cat(1,yGraph_bootstrapped,accuracy_bootstrapped);
    % get the error distribution
    error_bootstrapped = oobError(mdl_bootstrapped);
    % get the margin distribution
    margin_bootstrapped = oobMeanMargin(mdl_bootstrapped);
    
    % save bootstrapped answers...
    model_bootstrapped(i).tbgmdl = mdl_bootstrapped;
    model_bootstrapped(i).Y_hat = Y_hat_bootstrapped;
    model_bootstrapped(i).totalCorrect = total_correct_bootstrapped;
    model_bootstrapped(i).accuracyRatio = accuracy_bootstrapped;
    model_bootstrapped(i).error = error_bootstrapped;
    model_bootstrapped(i).margin = margin_bootstrapped;
   
end
threshold_of_success_bootstrapped = (yGraph_bootstrapped > accuracy_threshold);
num_highest_accuracy_bootstrapped = sum(threshold_of_success_bootstrapped(:)==1);
model_bootstrapped(len+1).num_highest_accuracy_bootstrapped = num_highest_accuracy_bootstrapped;  
%% Saving the answers in a structure called answer
% The region, unit and mode of this file
answer.region = region;
answer.unit = unit;
answer.mode = mode;
% Model structures with answers
answer.model = model;
answer.model_bootstrapped = model_bootstrapped;
% Accuracy of default tbg & bootstrapped
answer.tbgmdl_accuracy = yGraph;
answer.tbgmdl_accuracy_bootstrap = yGraph_bootstrapped;
% Number of neurons showing accuracies above the threshold for default tbg & bootstrapped (=0.18)
answer.tbgmdl_numhighestacc = num_highest_accuracy;
answer.tbgmdl_numhighestacc_bootstrap = num_highest_accuracy_bootstrapped;
% Error distribution for default tbg & bootstrapped
% answer.tbgmdl_error = tbgmdl_error;
% answer.tbgmdl_error_bootstrap = bootstrap_tbgmdl_error;
%% Saving the answer structure
folder = strcat(parent_folder,'\',folder_name,'\','answer');
save(folder,'-struct','answer');
toc
% %% plotting and saving all the results
% title("Training Input ")
% xlabel("")
% figurePath = 'C:\Users\SeanG\github\auditory_pathwayML\figures';
% savePosition = strcat(figurePath,'\','trainingInputOverleaf.fig');
% xlabel('Frequency (Hz)');
% ylabel('Maximum Successful Prediction (%)');
% savefig(savePosition);
% path=savepath;
% % plot(oobMeanMargin(B_important));
% % xlabel('Number of Grown Trees')
% % ylabel('Out-of-Bag Mean Classification Margin')
% % figure
% % plot(oobError(B_important),'r-')
% % hold on
% % plot(oobError(B),'b-')
% % xlabel('Number of Grown Trees')
% % ylabel('Out-of-Bag Classification Error')
% 
% % plot(xGraph,yGraph*100)
% % xticklabels(xGraph)
% %% Get three images for the different bin sizes (10ms, 5ms and 1ms)
% ticks_x = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65,];
% %ticks_y = linspace(1,480,480);
% image_path = strcat(pwd,'\binnedMatrices\AI\SU\0ch\otherbins\5ms\neuron1_5ms.mat');
% figures_path = strcat(pwd,'\figures\examples\');
% neuron = load(image_path);
% ms_bin_array = neuron.bin_array;
% h = imagesc(ms_bin_array);
% set(gca, 'XTick', ticks_x)
% hcb = colorbar;
% hcb.Title.String = "Number of Strings Firing";
% title("Binned Spike-Time Matrix || 5ms bins",'FontSize',14)
% xlabel("Time in milliseconds (ms)",'FontSize',12)
% ylabel("Vowel-Consonant-Vowels (VCVs)",'FontSize',12)
% print -depsc 5ms_bin_arrayExample
% % xl = xticklabels;
% % yl = yticklabels;
% %xticklabels(ticks_x)
% %yticklabels()
% %yticklabels(ticks_y)
% %%
% ticks_x = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140];
% %ticks_y = linspace(1,480,480);
% image_path = strcat(pwd,'\binnedMatrices\AI\SU\0ch\otherbins\5ms\neuron1_5ms.mat');
% % figures_path = strcat(pwd,'\figures\examples\');
% neuron = load(image_path);
% ms_bin_array = neuron.bin_array;
% h = imagesc(ms_bin_array(1:16,:));
% set(gca, 'XTick', ticks_x)
% hcb = colorbar;
% hcb.Title.String = "Number of Strings Firing";
% title("Binned Spike-Time Matrix || 5ms bins",'FontSize',14)
% xlabel("Time in milliseconds (ms)",'FontSize',12)
% ylabel("Vowel-Consonant-Vowels (VCVs)",'FontSize',12)
% xticklabels(ticks_x)
% yticklabels()
% print -depsc 5ms_bin_arrayExample

%% Accuracy
% plot(length(neuronList),, 'r')
% hold on
% plot(length(neuronList),

%%
    %load answer for 0ch and 1ch16
%     figure;
%     imagesc(X)
%     print '-r300' X '-djpeg'
%     oobErrorBaggedEnsemble = oobError(mdl_bootstrapped);
%     plot(oobErrorBaggedEnsemble,'LineWidth',3)
%     hold on
%     title('Out-of-bag Error for a singular neuron || Region: Inferior Colliculus','Fontsize',14);
%     xlabel 'Number of grown trees';
%     ylabel 'Out-of-bag classification error';

