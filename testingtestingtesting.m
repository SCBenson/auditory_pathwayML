tic
model = struct('tbgmodel', struct,'yHat', [1,100]);

for i = 1:13
    B= B_important;
    Y = [1,2 ...
        3];
    model(i).tbgmodel = B;
    model(i).yHat = Y;
end

great.models = model;
toc