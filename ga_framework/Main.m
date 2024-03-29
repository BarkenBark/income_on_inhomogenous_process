%% Main script for simulating dynamic pricing controller

% The sale of tickets is modeled as a inhomogenous poisson process with
% piecewise constant rate (rate = demand)

% We have a demand model specifying the rate/demand of ticket sales as a
% function of price and time

% Assuming we posted the event ticket sales at time 0, and the event takes
% place at time T, we partition this time span into n bins of width delta

% The goal is to at each dicretizised time step decide what price to set
% for tickets the next time step

% This is done by finding a sequence of prices for the remaining time step
% as to optimize the expected remaining income. The first entry in the
% sequence of prices is then taken to be the ticket price for the next time
% step. Then, at the next time step, the process is repeated. 

%% Clean slate
clc
close all
clear all

addpath('DemandFunctions');

%% Settings

% System
% The parameters here do not change across GA optimizations
% sequenceTimes contains the edges of the discretizied time bins
% sequenceTimes = flip([0,1,2,3,5,7,14,21,28,42,63]); % In time units until event.
sequenceTimes = flip([100-0, 100-1, 100-2, 100-3, 100-5, 100-7, 100-14, 100-21, 100-42, 100-63]);
systemParameters = struct( ...
  'sequenceTimes', sequenceTimes,  ... % In time units since posting., ...
  'maxTicketsSold', 1000, ...
  'ticketPriceInterval', [200, 500], ...
  'ticketPriceResolution', 10, ...
  'demandEstimationFunction', [] ... % Is set below
);

% Demand estimation function
iDemand = 1;
if iDemand == 1 % Tanh demand
  eventTime = sequenceTimes(end);
  parameters = [7.5, 0.015, 4.5, 100, eventTime];
  demandEstimationFun = @(t,p) TanhDemand(t, p, parameters);
elseif iDemand == 2 % Tanh2 demand
  eventTime = sequenceTimes(end);
  parameters = [10, 0.8, 0.02, 10, 10, eventTime];
  demandEstimationFun = @(t,p) TanhDemand2(t, p, parameters);
end
systemParameters.demandEstimationFunction = demandEstimationFun;

% Initial state settings
initialNbrOfTicketsSold = 0;

% Genetic Algorithm parameters
fitnessFunction = @(chromosome) EvaluateIndividual();
geneticAlgorithmParameters = struct( ...
  'fitnessFunction', [], ... % Needs to be updated for each optimization
  'decodingFunction', @(chromosome) DecodeChromosome(chromosome, systemParameters), ... % Needs to be updated for each optimization
  'popInitFunction', @InitializePopulation2, ... 
  'nbrOfGenerations', 1000, ...
  'populationSize', 100, ...
  'nbrOfGenes', [], ... % Needs to be updated for each optimization
  'mutationProbability', [], ... %4/geneticAlgorithmParameters.nbrOfGenes, Needs to be updated for each optimization
  'creepRate', 0.1, ...
  'creepProbability', 0.95, ...
  'tournamentSelectionParameter', 0.70, ...
  'tournamentSize', 2, ...
  'crossoverProbability', 0.3, ...
  'copiesOfBestIndividual', 2, ...
  'plotting', false, ...
  'plotInterval', 10, ...
  'fitnessPlotFunction', @(fitnessHistory, ax) PlotMaximumFitness(fitnessHistory, ax, 'kkr', 1/1000),...
  'solutionPlotFunction', [] ... % Needs to be updated for each optimization
);


%% Script
pricingSequenceHistory = cell(1, length(sequenceTimes)-1);
finalPricingSequence = zeros(1, length(sequenceTimes)-1);
expectedRemainingIncomeHistory = zeros(1, length(sequenceTimes)-1);
currentTicketsSoldHistory = zeros(1, length(sequenceTimes)-1);
salesRateHistory = zeros(1, length(sequenceTimes)-1);
cumulativeIncome = zeros(1, length(sequenceTimes)-1);

progressFigureHandle = figure(1);

currentSystemState = struct('currentTimeIndex', 1, ...
  'remainingSequenceTimes', sequenceTimes, 'currentTicketsSold', initialNbrOfTicketsSold); % NOTE: Field remainingSequenceTimes is redundant, but is kept for compability with a function
for iTimeBin = 1:length(sequenceTimes)-1
  
  currentTime = (sequenceTimes(iTimeBin+1)+sequenceTimes(iTimeBin))/2; % NOTE: Maybe use left edge of bin instead?
  currentTimeBinWidth = sequenceTimes(iTimeBin+1) - sequenceTimes(iTimeBin);
  
  % Run optimization
  nbrOfGenes = length(systemParameters.sequenceTimes) - currentSystemState.currentTimeIndex;
  fitnessFunction = @(decodedChromosome) EvaluateIndividual(decodedChromosome, currentSystemState, systemParameters);
  geneticAlgorithmParameters.nbrOfGenes = nbrOfGenes;
  geneticAlgorithmParameters.mutationProbability = 4/nbrOfGenes;
  geneticAlgorithmParameters.fitnessFunction = fitnessFunction;
  geneticAlgorithmParameters.solutionPlotFunction = @(sol, ax) PlotPricingSequence(sol, ax, currentSystemState, systemParameters);
  clf(progressFigureHandle)
  [pricingSequence, expectedRemainingIncome] = GeneticAlgorithm(geneticAlgorithmParameters, progressFigureHandle);
  %input('Press enter to continue (1/2).\n')
  
  % Simulate and update system state changes
  currentPrice = pricingSequence(1);
  simulatedCurrentSalesRate = systemParameters.demandEstimationFunction(currentTime, currentPrice);
  thisBinTicketsSold = SimulateTicketSales(simulatedCurrentSalesRate, currentTimeBinWidth, ...
    systemParameters.maxTicketsSold-currentSystemState.currentTicketsSold);
  fprintf('Number of tickets sold bin %d: %d\n', iTimeBin, thisBinTicketsSold);
  currentSystemState.currentTicketsSold = currentSystemState.currentTicketsSold + thisBinTicketsSold; % NOTE: In reality, this is something we measure independently of our optimization solution
  currentSystemState.currentTimeIndex = currentSystemState.currentTimeIndex + 1;
  currentSystemState.remainingSequenceTimes = currentSystemState.remainingSequenceTimes(2:end);
  
  % Store intermediate results
  pricingSequenceHistory{iTimeBin} = pricingSequence;
  finalPricingSequence(iTimeBin) = currentPrice;
  expectedRemainingIncomeHistory(iTimeBin) = expectedRemainingIncome;
  currentTicketsSoldHistory(iTimeBin) = currentSystemState.currentTicketsSold;
  salesRateHistory(iTimeBin) = simulatedCurrentSalesRate;
  cumulativeIncome(iTimeBin:end) = cumulativeIncome(iTimeBin:end) + currentPrice*thisBinTicketsSold;
  %input('Press enter to continue (2/2).\n')

  
end

%% Calculate some statistics

%% Plot results

resultsFig = figure(2);
clf(resultsFig)

% Price vs demand
subplot(2,2,1);
hold on
yyaxis left
stairs(sequenceTimes(1:end-1), finalPricingSequence);
yyaxis right
stairs(sequenceTimes(1:end-1), salesRateHistory, '--');
ylabel('Demand (sales/day)')
title('Ticket price vs. sales rate (NOTE: Time dependence)')

% Price vs expectedRemainingIncome
subplot(2,2,2);
hold on
yyaxis left
stairs(sequenceTimes(1:end-1), finalPricingSequence);
ylabel('Price (kr)')
yyaxis right
stairs(sequenceTimes(1:end-1), expectedRemainingIncomeHistory/1000, '--');
ylabel('Income (kkr)')
title('Ticket price vs. expected remaining income')


% Price vs money cash made
subplot(2,2,3);
hold on
yyaxis left
stairs(sequenceTimes(1:end-1), finalPricingSequence);
ylabel('Price (kr)')
yyaxis right
stairs(sequenceTimes(1:end-1), cumulativeIncome/1000, '--');
ylabel('Income (kkr)')
title('Ticket price vs. cumulative income')

% Price vs tickets sold
subplot(2,2,4);
hold on
yyaxis left
stairs(sequenceTimes(1:end-1), finalPricingSequence);
ylabel('Price (kr)')
yyaxis right
ylabel('Sold tickets')
stairs(sequenceTimes(1:end-1), currentTicketsSoldHistory, '--');
title('Ticket price vs. # tickets sold')







