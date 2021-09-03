pathway = fullfile('stimuli', '1channel_16Hz');
pathway2 = fullfile('stimuli', '1channel_16Hz');
contents = dir(pathway);
contents = contents(3:50);
contents2 = dir(pathway2);
contents2 = contents2(3:length(contents2));
test = contents(1).name;
test2 = contents2(48).name;
result = audioread(test);
result2 = audioread(test2);
spectro = spectrogram(result);
spectro2 = spectrogram(result2);

figure();
spectrogram(result,'yaxis');

figure();
spectrogram(result2,'yaxis');

if result == result2
    disp('identical');
else
    disp('They are not identical');
end
    

