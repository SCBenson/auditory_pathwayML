% data = spkRead(filename) load the data from a .spk file and puts it in a
% structure in the current workspace.
%
% The output structure 'data' has the following fields:
%
%   originalFilename - The name of the original brainware file that the
%                      data was taken from. May be .dam or .spk.
%   threshold        - The threshold used to detect spikes in the original
%                      Brainware file
%   sweepDuration    - The length of a sweep in ms
%   parameterNames   - The names of the parameters whose values were saved
%                      when the .spk file was created. This is an M x 1
%                      cell array where M is the number of parameters, and
%                      is in the same order as the parameter values.
%   sets             - A set for each set of parameters. Each set is itself
%                      a structure containing a field for parameter values
%                      and a field for spike times. Spike times are loaded
%                      as a N x 1 cell array, where N is the number of
%                      repeats.
%
% By Mark Steadman

function data = spk_read(filename)
  MAX_FILENAME_CHARS = 60;
  MAX_PARAM_NAME_CHARS = 40;

  if nargin < 1
    filename = uigetfile({'*.spk'});
  end

  [path, name] = fileparts(filename);
  if ~isempty(path)
    filename = [path filesep name '.spk'];
  else
    filename = [name '.spk'];
  end

  [fid, msg ]= fopen(filename, 'r');
  
  nChars = fread(fid, 1, 'uint8');
  data.original_filename = fread(fid, nChars, 'int8=>char')';
  fseek(fid, MAX_FILENAME_CHARS + 1, 'bof');
  data.threshold = fread(fid, 1, 'float');
  data.sweep_duration = fread(fid, 1, 'float');

  nSets = fread(fid, 1, 'uint16');
  nParams = fread(fid, 1, 'uint8');
  
  parameter_names = cell(nParams, 1);
  
  % Read in the parameter names
  for ii = 1: nParams
    nChars = fread(fid, 1, 'uint8');
    parameter_names{ii} = fread(fid, MAX_PARAM_NAME_CHARS, 'uint8=>char')';
    parameter_names{ii} = parameter_names{ii}(1: nChars);
  end
  data.parameter_names = parameter_names;
  
  % Read in the parameter values and spike times for each set
  for ii = 1: nSets
    data.sets(ii).parameter_values = fread(fid, nParams, 'float')';
    nReps = fread(fid, 1, 'uint8');
    spikeTimes = cell(nReps, 1);
    
    for jj = 1: nReps
      nSpikes = fread(fid, 1, 'uint16');
      if nSpikes
        spikeTimes{jj} = fread(fid, nSpikes, 'float')'./1000;
      end
    end
    data.sets(ii).sweeps = spikeTimes;
    %disp(data.sets(ii).spikeTimes)
  end

 fclose(fid);
end