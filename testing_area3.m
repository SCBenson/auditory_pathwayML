A = [1,2;3,4];
B = [5,6;7,8];
C = [9,10;11,12];
Z = cat(3,A,B,C);
benson = zeros(2,2);
for i = 1:length(Z)
    twoD = Z(:,:,i);
    benson(:,:) = benson(:,:) + twoD;
end