function binMatrix = imageThis(completeList)

for image = 1:18
    figure();
    imagesc(completeList(:,:,image))
    colormap('jet')
    colorbar
%     folderTitle = sprintf('Channel and Filter: %i',folderName(image).name);
    header = sprintf("Vowel-Consonant-Vowel Spike Occurences for: %s", folderNames(image).name);
    title(header);
    xlabel("Time-bins in Milliseconds (ms)");
    ylabel("Vowel-Consonant-Vowel (VCV)");
    xticklabels(["70", "140", "210", "280", "350", "420", "490", "560", "630", "700"])
    yticklabels(["ABA", "ADA", "AFA", "AGA", "AKA", "ALA", "AMA", "ANA", "APA", "ASA", "ASHA", "ATA", "ATHA", "AVA", "AYA", "AZA"])
    xticks(1:10)
    yticks(1:16)

end
end