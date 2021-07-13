function results=classify(neurograms,parameters)

  % Define experiment properties
  ntalkers=size(neurograms,1);  % Number of talkers
  nclasses=size(neurograms,2);  % Number of consonants
  nreps=size(neurograms,3);     % Number of stim repetitions

  % Initialise output
  results.correct=0;
  results.confusions=zeros(nclasses);
  results.distmat=zeros(nclasses);
  results=repmat(results,nreps,1);
  
  % Initialse loop variables
  tocombine=cell(ntalkers,1);
  nsites=size(neurograms{1},1); % Number of fibers / recording sites
  ndim=nsites*(size(neurograms{1},2)-2*parameters.max_shift);
  y=zeros(nclasses,ndim);

  % Smooth the neurograms
  if parameters.window_length
    w=parameters.window_func(parameters.window_length)';
    w=w/sum(w);
    neurograms=cellfun(@(x) convn(x,w,'same'),neurograms,'uni',0);
  end

  for i=1:nreps
    tic;
    repidx=i==1:nreps;
    testset=neurograms(:,:,repidx);
    trainingset=neurograms(:,:,~repidx);

    % Build the training neurograms
    for j=1:nclasses
      for k=1:ntalkers
        tocombine{k}=mean(cat(3,trainingset{k,j,:}),3);
      end
      y(j,:)=combineNeurograms(tocombine,parameters.max_shift);
    end
    
    for j=1:nclasses
      for k=1:ntalkers
        x=lagNeurogram(testset{k,j},parameters.max_shift);
        [idx,d]=knnsearch(y,x,'k',1,'distance','euclidean');
        [~,minidx]=min(d);
        n=idx(minidx);
        
        % Compares euclidean distances between data points
        distances=sqrt(sum((y-repmat(x(minidx,:),nclasses,1)).^2,2));
        results(i).distmat(:,j)=results(i).distmat(:,j)+distances;
        results(i).confusions(n,j)=results(i).confusions(n,j)+1;
      end
    end
    results(i).distmat=results(i).distmat/ntalkers;
    
    % Calculate percent correct
    diag=results(i).confusions.*eye(nclasses);
    results(i).correct=100*sum(diag(:))/sum(results(i).confusions(:));

    % Report status
%     if parameters.verbose
%       disp(['  Rep ',num2str(i),' of ',num2str(nreps), ' took ', ...
%         num2str(round(toc)),' seconds. ',...
%         'PC=',num2str(results(i).correct)]);
%     end
  end
end