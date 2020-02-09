%% Script to overview a Demand estimation function
clc
clear all
close all

% Add Demand Function directory to path
addpath('../DemandFunctions');

%% Choose demand function

iDemand = 2;

if iDemand == 1 % Tanh demand
  parameters = [7.5, 0.015, 4.5, 100];
  demandFun = @(t,p) TanhDemand(t, p, parameters);
elseif iDemand == 2 % Tanh2 demand
  parameters = [10, 0.8, 0.02, 10, 10];
  demandFun = @(t,p) TanhDemand2(t, p, parameters);
end



%% Settings
xRes = 1000;
zRes = 10;
tEnd = 50;
pLims = [200,1000];

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
  plot(ax1, timePlotRange, lambdas);
  set(ax1, 'xdir', 'reverse')
end
legend(ax1, legendStrings)
xlabel(ax1, 'Time (days)')
ylabel(ax1, 'Demand (sales/day)')

legendStrings = {};
timePlotRange = linspace(0, tEnd, zRes);
pricePlotRange = linspace(pLims(1), pLims(2), xRes);
for time = timePlotRange
  legendStrings{end+1} = strcat(num2str(time), ' days');
  lambdas = demandFun(time, pricePlotRange);
  plot(ax2, pricePlotRange, lambdas);
  hold on
end
legend(ax2, legendStrings)
xlabel(ax2, 'Price (kr)')
ylabel(ax2, 'Demand (sales/day)')














