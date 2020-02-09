%% Script to verify if the distribution of number of events from a Poisson process on time interval [0,T] is equal to the sum of number of events on smaller sub-intervals in [0,T]

clc
clear all

lambda = 0.1;
T = 10;
nBins = 1;
nSamples = 10000;
delta = T/nBins;

%%

disp('Simulating...');
nEventsWhole = poissrnd(lambda*T, 1, nSamples);
nEventsBins = poissrnd(lambda*delta, nBins, nSamples);
nEventsBinsSummed = sum(nEventsBins, 1);
disp('Done.');

%% 
close all
subplot(1,2,1)
histogram(nEventsWhole)
subplot(1,2,2)
histogram(nEventsBinsSummed)

disp('By observing the histograms, we condlude that we the distributions are the same')