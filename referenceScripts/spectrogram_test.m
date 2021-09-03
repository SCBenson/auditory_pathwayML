savepath=path;
addpath(genpath(pwd));
[y,fs] = audioread('M2ABA7M.wav');
figure()

plot_audspecgram(y, fs);