% [vocoded envs cutoffs] = vocode(signal, fs, varargin)
% vocodes a signal
%
% Inputs:
%
% Required:
%   signal - Mono or stereo signal to be vocoded
%   fs     - Sample rate of the signal
%
% Optional:
%   nChans    - Number of channels. If this is not set, then fList must be
%               provided.
%   envBW     - Envelope bandwidth. Set the cutoff for a lowpass filter
%               used to limit envelope modulation. Envelope is not filtered
%               if this is not set.
%   minFreq   - Lowest cutoff of filter for channel 1. Defaults to 50 Hz.
%   maxFreq   - High cutoff for filter in channel N. Defaults to 8 kHz.
%   fList     - A list of cutoffs to use. If this is specified, it
%               overrides cutoff frequencies that would otherwise have been
%               calculated using nChans, minFreq and maxFreq.
%   type      - Either 'sine' or 'noise'. Defaults to 'noise' unless
%               carrier filenames are provided (see below). In that case,
%               this input is ignored.
%   envelopeFiltOrder - The order of the envelope smoothing filter used.
%                       Defaults to 3.
%   analysisFiltOrder - The order of the analysis band filters used.
%                       Defaults to 3.
%   carrierFilename  - A .wav file that contain the carrier to
%                       use. This can either be a
%                       single file if a single carrier sound is to be used
%                       (for example, for producing 'auditory chimeras') or
%                       nChans files. Anything else is ambiguous and so
%                       will cause an error.
%   seed              - random noise generator seed
%
% Example 1:
% [x, envs, cuts] = vocode(signal, fs, ...
%   'fList', [100 200 400 800 1600], ...
%   'type', 'noise, ...
%   'envBW', 100);
%
% Example 2: 
% [x, envs, cuts] = vocode(signal, fs, ...
%   'nChans', 4, ...
%   'minFreq', 100, ...
%   'maxFreq', 8000, ...
%   'carrierFilename', {'freezer.wav'}, ...
%   'envBW', 20);
%
% By Mark Steadman

function [vocoded, envs, freqs] = ...
  vocode(signal, fs, varargin)

  %% Input validation  
  p = inputParser;
  p.addRequired('signal', ...
    @(x) ndims(x)==2 & min(size(x)) <= 2);
  p.addRequired('fs', ...
    @isnumeric);
  p.addParamValue('nChans', [], ...
    @(x) isnumeric(x) && ~rem(x, 1) && x > 0);
  p.addParamValue('envBW', 0, ...
    @isnumeric);
  p.addParamValue('minFreq', 20, ...
    @(x) isnumeric(x) && x > 0);
  p.addParamValue('maxFreq', 8000, ...
    @(x) isnumeric(x) && x > 0);
  p.addParamValue('fList', [], ...
    @(x) isnumeric(x) && all(x > 0));
  p.addParamValue('type', 'noise', ...
    @(x) any(strcmp(x, {'noise', 'tone'})));
  p.addParamValue('analysisFiltOrder', 3, ...
    @(x) isnumeric(x) && x > 0);
  p.addParamValue('envelopeFiltOrder', 3, ...
    @(x) isnumeric(x) && x > 0);
  p.addParamValue('carrierFilename', [], ...
    @iscell);
  p.addParamValue('frozen', false, ...
    @islogical);
  p.addParamValue('seed', 0, ...
    @(x) isnumeric(x) && x >= 0);
  p.parse(signal, fs, varargin{:});
  inputs = p.Results;
  
  if isempty(inputs.nChans)
    % Check for fList. If fList was not provided, or does not monotonically
    % increase with the maximum being less that the nyquist limit, then we
    % cannot continue.   
    if isempty(inputs.fList)
      error('tools:vocode', 'Must provide either nChans or fList');
    elseif ~all(diff(inputs.fList) > 0)
      error('tools:vocode', 'fList was not monotonically increasing');
    end
    inputs.nChans = numel(inputs.fList) - 1;
  else
    inputs.fList = ...
      logspace(log10(inputs.minFreq), ...
      log10(inputs.maxFreq), ...
      inputs.nChans + 1);
  end
  
  if ~isempty(inputs.carrierFilename)   
    % Check that the files are .wav files
    [~, ~, ext] = cellfun(@fileparts, inputs.carrierFilename, ...
      'uniformOutput', false);
    
    if ~all(strcmp('.wav', ext))
      error('tools:vocode', ...
        'Not all carrier wav files had a .wav extension');
    end
  end
  
  %% Main
  % Make sure that the signal is arranged as one or two column vectors
  [rows, cols] = size(inputs.signal);
  if rows < cols, inputs.signal = inputs.signal'; end
  nyquist = inputs.fs * 0.5;
  
  % Design the envelope bandlimiting filter
  if inputs.envBW
    [z, p, k] = butter(inputs.envelopeFiltOrder, ...
      inputs.envBW / nyquist, 'low');
    [sos_lp, g_lp] = zp2sos(z,p,k);
  end
  
  vocoded = zeros(size(inputs.signal));
  envs = cell(inputs.nChans, 1);
  freqs = inputs.fList;
  
  for ii = 1: inputs.nChans
    
    % Design the analysis filter
    [z,p,k] = butter(inputs.envelopeFiltOrder, ...
      [inputs.fList(ii),inputs.fList(ii+1)]/nyquist);
    [sos,g]=zp2sos(z,p,k);
    bp_filt=dfilt.df2sos(sos,g);
    
    % Calulate the envelope(s) for this channel
    if inputs.envBW
      envs{ii} = filtfilt(sos_lp,g_lp,abs(filter(bp_filt,inputs.signal)));
    else
      envs{ii} = abs(filter(bp_filt,inputs.signal,1));
    end
    
    % Get the carrier signal for this channel
    if ~isempty(inputs.carrierFilename)
      % Load carrier wav files
      if numel(inputs.carrierFilename) > 1
        [carrier, fs_c] = audioread(inputs.carrierFilename{ii});
      else
        [carrier, fs_c] = audioread(inputs.carrierFilename{1});
      end
      
      if ~(fs_c == inputs.fs)
        error('tools:vocode', ...
          'Carrier and input signal had different sample rates');
      end
      carrier=filter(bpb, bpa, carrier);
      
    elseif strcmp(inputs.type, 'noise')
      % Noise carrier
      if inputs.frozen
        rng(inputs.seed);
      end
      carrier=filter(bp_filt,2*rand(size(inputs.signal))-1);
    else
      % Tone carrier
      t=(0:rows-1)'/fs;
      f=exp(mean([log(inputs.fList(ii)) log(inputs.fList(ii + 1))]));
      carrier=repmat(sin(2*pi*f*t),1,cols);
    end
    
    % Make sure carrier is the same size as the signal. If it is too small,
    % there will be an error
    carrier = carrier(1:rows, 1:cols);
    band = filter(bp_filt, carrier .* envs{ii});
    vocoded = vocoded + band;
  end
end