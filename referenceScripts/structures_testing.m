tic
model = struct();

for i = 1:13
    B= B_important;
    Y = [1,2 ...
        3];
    model(i).tbgmodel = B;
    model(i).yHat = Y;
end

great.models = model;
toc
%% plot3 test

x = [50, 35, 117, 85, 67, 32, 56, 158, 45, 66, 87];
y = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
yticklabels(["0ch","1ch16","1ch50","1ch160","1ch500","2ch16","2ch500","4ch16","4ch500","8ch16","8ch500"])
z = [0.2, 0.5, 0.8, 0.45, 0.2, 0.6, 0.35, 0.77, .25, 0.15, 0.95];
scatter3(x,y,z)
%% Plotting test
t = figure;
plot(x,y,'visible','off');
%saveas(fig,filename,formattype) [template]
filename = strcat(pwd,'\figures\testing_inputExample');
saveas(t,filename,'epsc');