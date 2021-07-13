stimPath='../../stimuli';
wavPath=[stimPath 'unprocessed\'];
unprocessed = dir([wavPath '*.wav']);
unprocessed = cellfun(@(x) [wavPath x], {unprocessed.name}, ...
  'uniformOutput', false);
[signals, fs] = cellfun(@wavread, unprocessed, ...
  'uniformOutput', false);
[~, names] = cellfun(@fileparts, unprocessed, ...
  'uniformOutput', false);

nChannels = [1 2 4 8];
envBWs = [16 500];
rampDuration = 0.01;

for ii = 1: numel(nChannels)
  
  % cutoffs taken from Shannon 1995
  switch nChannels(ii)
    case 1
      cutoffs = [100 4000];
    case 2
      cutoffs = [100 1500 4000];
    case 4
      cutoffs = [100 800 1500 2500 4000];
    case 8
      cutoffs = [100 283 800 1095 1500 1937 2500 3162 4000];
    otherwise
      cutoffs = logspace(log10(100), log10(4000), numChannels + 1);
  end
    
  for jj = 1: numel(envBWs)
    folder = [num2str(nChannels(ii)) 'channel_' ...
      num2str(envBWs(jj)) 'Hz'];
      
    if ~exist(folder, 'dir')
      mkdir(folder);
    end
    
    for kk = 1: numel(unprocessed)
      
      vocoded=vocode(signals{kk}, ...
        fs{kk}, cutoffs, ...
        envBWs(jj), 'noise', false);
      
      %normalise
      
      dt = 1 / fs{kk};
      rampT = dt:dt:rampDuration;
      ramp = ...
        [0.5 * (1 + cos(pi * (1 + rampT / rampDuration)))...
        ones(1, length(vocoded) - length(rampT))];
      ramp = ramp .* fliplr(ramp);
      
      vocoded = ramp' .* (0.99 * vocoded / max(abs(vocoded))); 
      soundsc(vocoded, fs{kk});
      
      %save
      filename = [stimPath folder filesep names{kk}];
      audiowrite(vocoded, 44100, filename);
    end
  end
end