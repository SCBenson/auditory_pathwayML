% binsize and duration in seconds
function neurograms=buildneurograms(input,binsize,duration)

  if ischar(input)
    load(input,'spkdata');
  elseif isstruct(input)
    spkdata=input;
    clearvars('input');
  else
    error('Invalid input. Must be either filename or spk data struct.');
  end
  
  stimgrid=cat(1,spkdata.sets.parameter_values);
  
  speaker={'speakerID'};
  speakeridx=find(ismember(spkdata.parameter_names,speaker));
  
  token={'tokenID','consonantID'};
  tokenidx=find(ismember(spkdata.parameter_names,token));
  
  speakers=unique(stimgrid(:,speakeridx));
  tokens=unique(stimgrid(:,tokenidx));
  
  % Initialise neurograms
  nspeakers=numel(speakers);
  ntokens=numel(tokens);
  nreps=min(arrayfun(@(x) numel(x.sweeps),spkdata.sets)); 
  neurograms=cell(nspeakers,ntokens,nreps);
  
  edges=0:binsize:duration;
  
  for i=1:nspeakers
    for j=1:ntokens
      setidx=ismember(stimgrid(:,[speakeridx,tokenidx]),[speakers(i),tokens(j)],'rows');
      sweeps=spkdata.sets(setidx).sweeps;
      
      for k=1:nreps
        neurograms{i,j,k}=histcounts(sweeps{k},edges);
      end
    end
  end
end