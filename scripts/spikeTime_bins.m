% function binThis = spikeTime_bins()
% Add the neccessary scripts to the path
savepath=path;
addpath(genpath(pwd));

datadir=fullfile('Data','IC','SU','1ch16');
type = '0ch';
folders = fullfile('Data','IC','SU');
folderdir = fullfile('Data','IC','SU',type);
%grayscalea
fileList = dir(folderdir);
folderList = dir(folders);


spkFileNames = fileList(3:length(fileList));
folderNames = folderList(3:length(folderList));



% Create the time bins for spike times (1x10) e.g [0, 1, 1, 3, 2, 1, 0, 0, 0, 2]
% each index corresponds to 70ms of time elapsed.

sec = zeros(16,10,length(spkFileNames));
completeList = zeros(16,10,length(folderNames));
for f = 1:length(folderNames)
%   folderInstance = load(fullfile(folderdir,folderNames(f).name));
    type = folderNames(f).name;
    folderdir = fullfile('Data','IC','SU',type);
    fileList = dir(folderdir);
    spkFileNames = fileList(3:length(fileList));
    
%   We create a directory to a folder with data, but we need to append the
%   folder name to datadir to load it
    for s = 1:length(spkFileNames)
        folderdir = fullfile('Data','IC','SU',type);
        dataInstance = load(fullfile(folderdir,spkFileNames(s).name));
        dataInstance = dataInstance.spkdata.sets;
        spikeBin = zeros(48,10);
        for i = 1:48
            sweepRow = dataInstance(i).sweeps;
            chkLen = size(sweepRow());
            chk = chkLen(1);
            
            if chk ~= 10
                n=chk;
            else
                n=10;
            end
            for j = 1:chk % ith sweep row

                repRow = sweepRow(j);
                avgBin = zeros(chk,10);

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
        sec(:,:,s) = phonemeSpkBin;
    end
    

    % turn the 3D Matrix into a 2D Array by summing across the 3rd dim.
    folderBinTotal = zeros(16,10);
    for t = 1:length(sec)
        file2D = sec(:,:,t);
        folderBinTotal = folderBinTotal(:,:) + file2D;
    end
    
    completeList(:,:,f) = folderBinTotal;
end
imagesc(completeList(:,:,1))
colorbar
colormap('jet')

% return completeList;
% completeList = zeros(length(folderNames),16,10);
% for i = 1:length(fileNames)
% 
%     completeList = completeList + sec(:,:,i);
% 
% end
% for i=1:length(fileNames)
%     figure();
%     
% end

for imag = 1:18
%     h(imag) = imagesc(completeList(:,:,imag),h(imag));
%     image(imagesc(completeList(:,:,imag)),h(imag));
    
    
%     figure()
%     imagesc(completeList(:,:,imag))
%     colormap('jet')
%     colorbar
% %     folderTitle = sprintf('Channel and Filter: %i',folderName(image).name);
%     header = sprintf("Vowel-Consonant-Vowel Spike Occurences for: %s", folderNames(imag).name);
%     title(header);
%     xlabel("Time-bins in Milliseconds (ms)");
%     ylabel("Vowel-Consonant-Vowel (VCV)");
%     xticklabels(["70", "140", "210", "280", "350", "420", "490", "560", "630", "700"])
%     yticklabels(["ABA", "ADA", "AFA", "AGA", "AKA", "ALA", "AMA", "ANA", "APA", "ASA", "ASHA", "ATA", "ATHA", "AVA", "AYA", "AZA"])
%     xticks(1:10)
%     yticks(1:16)
%     getFigDirec=dir('figures\spikeTimeBins');
%     figDirec = getFigDirec(1).folder;
%     figName = strcat('IC_SU_',folderNames(imag).name)
%     figSaveAs = strcat(figName,'.fig');
%     savePosition = strcat(figDirec,'\',figSaveAs);
%     savefig(savePosition);


end
% end


        