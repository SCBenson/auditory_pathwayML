function cf=parseANfilename(filename)
  expr='(\d+)Hz';
  tok=regexp(filename,expr,'tokens');
  cf=str2double(tok{:});
end