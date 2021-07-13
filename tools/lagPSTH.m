function y=lagPSTH(x,maxshift)
  ndim=numel(x)-2*maxshift;
  y=zeros(2*maxshift+1,numel(x));
  idx=1;
  
  for i=-2*maxshift:0
    y(idx,:)=circshift(x,i);
    % y(idx,:)=circshift(x,[i,0]); % As promted by MATLAB WARNING this is
    % due to me having an older version, the function changed after version 2016a
    idx=idx+1;
  end
  
  y=y(:,1:ndim);
end