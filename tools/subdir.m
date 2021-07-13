% Returns a list of all the subdirectories
function D=subdir(directory_name,full)

if nargin<2
  full=0;
  
  if nargin<1
    directory_name=pwd;
  end
end

D=dir(directory_name);
D=D([D.isdir]);

if isempty(D)
  return;
end

% ignore hidden filders
idx=cellfun(@(x) x(1)~='.',{D.name});

if full
  D=cellfun(@(x) fullfile(directory_name,x),{D(idx).name}','uni',0);
else
  D={D(idx).name}';
end

end