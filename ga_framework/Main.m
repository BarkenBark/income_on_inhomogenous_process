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

%% Settings

% System
% The parameters here do not change across GA optimizations
eventTime = 100; % In time units from start time which is 0
timeBinWidth = 7;
nbrOfTimeBins = ceil(eventTime / timeBinWidth);
ticketSalesCapacity = 1000;
demandEstimationFun = @(t,p) 10*((1-t/eventTime) - (1-t/eventTime) .* tanh(0.01*(1-t/eventTime)*p - 3*(1-t/eventTime)));
ticketPriceInterval = [200, 500];
ticketPriceResolution = 10;
systemParameters = struct('eventTime', eventTime, 'timeBinWidth', timeBinWidth, ...
  'maxTicketsSold', ticketSalesCapacity, 'demandEstimationFun', demandEstimationFun);

% Initial state settings
initialNbrOfTicketsSold = 0;

% Genetic Algorithm parameters
nbrOfGenes = nbrOfTimeBins;
geneticAlgorithmParameters = struct( ...
  'fitnessFunction', [], ...
  'nbrOfGenerations', 1000, ...
  'copiesOfBestIndividual', 2, ...
  'holdoutThreshold', 100, ... %No. generations to wait for improvement before termination
  'populationSize', 100, ...
  'nbrOfGenes', nbrOfGenes, ...
  'mutationProbability', 4/nbrOfGenes, ...
  'creepRate', 0.1, ...
  'creepProbability', 0.95, ...
  'tournamentSelectionParameter', 0.70, ...
  'tournamentSize', 2, ...
  'crossoverProbability', 0.3 ...
);


%% Script

controlTimes = 1:timeBinWidth:eventTime; % TODO: Allow this to be arbitrary, define dynamic bins here

currentSystemState = struct('currentTimeIndex', controlTimes(1), 'currentTicketsSold', initialNbrOfTicketsSold);
for iTime = 1:length(controlTimes)
  
  currentTime = controlTimes(iTime);
  if iTime < length(controlTimes) % Else just use the previous timeBinWidth
    currentTimeBinWidth = controlTimes(iTime+1) - controlTimes(iTime);
  end
  
  fitnessFunction = @(decodedChromosome) EvaluateIndividual(decodedChromosome, currentSystemState, systemParameters);
  geneticAlgorithmParameters.fitnessFunction = fitnessFunction;
  pricingSequence = GeneticAlgorithm(geneticAlgorithmParameters);
  
  % Simulate system state changes
  simulatedCurrentSalesRate = systemParameters.demandEstimationFunction(currentTime, currentPrice);

  % Update system state changes
  currentSystemState.currentTimeIndex = iTime+1;
  currentSystemState.currentTicketsSold = SimulateTicketSales(simulatedCurrentSalesRate, currentTimeBinWidth); % NOTE: In reality, this is something we measure independently of our optimization solution

end











