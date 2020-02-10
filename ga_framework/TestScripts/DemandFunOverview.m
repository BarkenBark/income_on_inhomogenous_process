%% Script to overview a Demand estimation function
clc
clear all
close all

% Add Demand Function directory to path
assert(strcmp(pwd, '/home/bark/repos/matlab/income_on_inhomogeneous_process/ga_framework/TestScripts'), 'Go to TestScripts directory')
addpath('../DemandFunctions');

%% Choose demand function

iDemand = 2;

eventTime = 100;
if iDemand == 1 % Tanh demand
  parameters = [7.5, 0.015, 4.5, 100, eventTime];
  demandFun = @(t,p) TanhDemand(t, p, parameters);
elseif iDemand == 2 % Tanh2 demand
  parameters = [10, 0.8, 0.02, 10, 10, eventTime];
  demandFun = @(t,p) TanhDemand2(t, p, parameters);
end



%% Settings
xRes = 1000;
zRes = 10;
tEnd = 100;
pLims = [0,1000];

%% Plot demand estimation function over the defined time interval and price interval



f1 = figure(1);
ax1 = subplot(1,2,1);
set(ax1, 'NextPlot', 'add')
ax2 = subplot(1,2,2);
set(ax2, 'NextPlot', 'add')

legendStrings = {};
pricePlotRange = linspace(pLims(1), pLims(2), zRes);
timePlotRange = linspace(0, tEnd, xRes);
for price = pricePlotRange
  legendStrings{end+1} = strcat(num2str(price), ' kr');
  lambdas = demandFun(timePlotRange, price);
  plot(ax1, eventTime-timePlotRange, lambdas);
  set(ax1, 'xdir', 'reverse')
end
l = legend(ax1, legendStrings);
title(l, 'Price');
xlabel(ax1, 'Time until event (days)')
ylabel(ax1, 'Demand (sales/day)')

legendStrings = {};
timePlotRange = linspace(0, tEnd, zRes);
pricePlotRange = linspace(pLims(1), pLims(2), xRes);
for time = timePlotRange
  legendStrings{end+1} = strcat(num2str(eventTime-time), ' days');
  lambdas = demandFun(time, pricePlotRange);
  plot(ax2, pricePlotRange, lambdas);
  hold on
end
l = legend(ax2, legendStrings);
title(l, 'Time until event');
xlabel(ax2, 'Price (kr)')
ylabel(ax2, 'Demand (sales/day)')














