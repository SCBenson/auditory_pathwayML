% uniqueStruct works in the same way as the native function unique but for
% structures

function output=unique_struct(array)

if ~isstruct(array(1))
  error('Input was not a structure array.')
end

isDuplicate=zeros(1, numel(array));
for i=1:numel(array)
  isDuplicate(i)=any(arrayfun(@(x) isequal(x, array(i)),array(i+1:end)));
end
output=array(~isDuplicate);

end