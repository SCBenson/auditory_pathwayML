%load('neuron1','bin_array')


%Support Vector Machine Classification

% Creates a hyper plane of n-dimensions to
% classify the .spk files; there are 16 classes.

% One row per observation
% One column per predictor
X = bin_array;
size_of_bin_array = sweep_height;
training_size = 0.8 * size_of_bin_array;
testing_size = 0.2 * size_of_bin_array;

% The list of VCVs to create the Y input matrix
p = ["ABA", "ADA", "AFA", "AGA", "AKA", "ALA", "AMA", "ANA", "APA", "ASA", "ASHA", "ATA", "ATHA", "AVA", "AYA", "AZA"];


% make sure we enter the height of the sweeps into the function
output_length = 3*10;
phon = [];
% phonemes = string.empty(0,length(bin_array));
phonemes = [];
for i = 1:length(p)
    pho = p(i);
    phon = pho;
    phone = repmat(phon,output_length);
    phone = phone(1,:)';
    phonemes = cat(1,phonemes,phone);
end

 Y = repmat(phonemes,output_length);
 Y = Y(1,:);

% 480 random numbers to split the data.
splitting_indx = randi([1 480],1,480);

organisedPhonemes = [];
for i = 1:length(p)
    idx = (phonemes==p(i));
    samePhoneme = X(idx,:);
    organisedPhonemes = cat(1,organisedPhonemes,samePhoneme);
end
%% Create the Testing and Training Inputs
training_input = [];
testing_input = [];
training_output = [];
testing_output = [];

for i = 1:training_size
    training_input = cat(1,training_input,organisedPhonemes(splitting_indx(i),:));
    training_output = cat(1,training_output,phonemes(splitting_indx(i)));
end
for i = 1:testing_size
    testing_input = cat(1,testing_input,organisedPhonemes(splitting_indx(i),:));
    testing_output = cat(1,testing_output,phonemes(splitting_indx(i)));
end
    

%% Inserting the Training and Testing Data and Predicting Phonemes
% Randomise the data for test and train
%ClassTreeEns = fitensemble(organisedPhonemes,phonemes,'AdaBoostM2',3000,'Tree');
B = TreeBagger(150,training_input,training_output,'OOBPrediction','on'); 
Y_hat = predict(B, testing_input);
acc = Y_hat == testing_output; % phonemes if this doesnt work
total_acc = sum(acc(:,1));
randTrees = total_acc/480;


