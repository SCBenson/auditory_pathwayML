%% Plot Test
a = struct();
for i = 1:length(modes)
    mode = modes(mod);
    m = convertStringsToChars(mode);
    mode = m;
    d = fullfile('binnedMatrices','IC','SU','answers');
    answerList = dir(d); % lists all of the .mat files
    answerList = answerList(3:end); %3:size(fileList)??
    answerInstance = answerList(i).name;
    direc = fullfile('binnedMatrices','IC','SU','answers',answerInstance);
    answerSheet = dir(direc);
    answerSheet = answerSheet(3:end);
    answer_instance = load(fullfile(direc,answerSheet(1).name));
    a(i).answer = answer_instance;
end
   %% Plot it
   highacc = [];
   figure()
   title('Neuron ID versus number of successful phoneme predictions')
   xlabel('Neuron ID')
   ylabel('Percentage of successful phoneme predictions (%)')
   legend(modes)
   for i = 1:length(modes)
    highacc = cat(1,highacc,(a(i).answer.tbgmdl_numhighestacc));
   end
   plot(highacc)
%     figure()
%     y = mat2cell(1,linspace(1,62,62));
%     plot(answer.tbgmdl_accuracy);
%     hold on
%     plot(answer.tbgmdl_accuracy_bootstrap);
%     xticklabels(y)