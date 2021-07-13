function spk_display_rasters_basic(spkdata,sweepdur,ncols,replim)

if ischar(spkdata),load(spkdata);end

nsets=numel(spkdata.sets);

if nargin<4
  replim=0;
  if nargin<3
    nrows=ceil(sqrt(nsets));
    ncols=ceil(nsets/nrows);
  else
    nrows=ceil(nsets/ncols);
  end
end

h=zeros(nsets,1);
for i=1:nsets
  h(i)=subplot(nrows,ncols,i);
  nsweeps=numel(spkdata.sets(i).sweeps);
  
  if replim
    lim=min(nsweeps,replim);
    spkdata.sets(i).sweeps=spkdata.sets(i).sweeps(1:lim);
    nsweeps=lim;
  end
  
  spikecounts=cellfun(@numel, spkdata.sets(i).sweeps);
  yvals=repelem(1:nsweeps,spikecounts);
  times=cell2mat(spkdata.sets(i).sweeps);
  
  scatter(times,yvals,'rd','filled');
  
  ylim([0.5,nsweeps+0.5]);
  xlim([0,sweepdur]);
end
linkaxes(h);

end