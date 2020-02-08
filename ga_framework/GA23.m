%% Main code
clc; clear all
clf; close all

%System
% The parameters here do not change across GA optimizations
eventTime = 100; % In time units from start time which is 0
timeBinWidth = 1;
nbrOfTimeBins = ceil(eventTime / timeBinWidth);
ticketSalesCapacity = 1000;
demandEstimationFun = @(t,p) 10*((1-t/eventTime) - (1-t/eventTime) .* tanh(0.01*(1-t/eventTime)*p - 3*(1-t/eventTime)));
ticketPriceInterval = [100, 1000];
ticketPriceResolution = 10;
systemParameters = struct('eventTime', eventTime, 'timeBinWidth', timeBinWidth, ...
  'maxTicketsSold', ticketSalesCapacity, 'demandEstimationFun', demandEstimationFun);

% System state
% The parameters here are updated for every time we'll do a GA optimization
currentTimeIndex = 90;
currentTicketsSold = 621;
currentSystemState = struct('currentTimeIndex', currentTimeIndex, 'currentTicketsSold', currentTicketsSold);


%% Plot demand estimation function over the defined time interval

tRes = 1000;
pRes = 10;
pricePlotRange = linspace(ticketPriceInterval(1), ticketPriceInterval(2), pRes);
timePlotRange = linspace(0, eventTime, tRes);

f1 = figure(1);
legendStrings = {};
for price = pricePlotRange
  legendStrings{end+1} = num2str(price);
  lambdas = demandEstimationFun(timePlotRange, price);
  plot(timePlotRange, lambdas);
  hold on
end
legend(legendStrings)


%% Genetic Algorithm - Parameters
NUMBER_OF_GENERATIONS = 1000;
COPIES_OF_BEST_INDIVIDUAL = 2;
HOLDOUT_THRESHOLD = 100; %No. generations to wait for improvement before termination

populationSize = 100;
nbrOfGenes = nbrOfTimeBins - currentTimeIndex + 1;

mutationProbability = 4/nbrOfGenes;
creepRate = 0.1;
creepProbability = 0.95;
tournamentSelectionParameter = 0.70;
tournamentSize = 2;
crossoverProbability = 0.3;

%% Genetic Algorithm - Script

population = InitializePopulation2(populationSize, nbrOfGenes);

maximumTrainingFitness = zeros(NUMBER_OF_GENERATIONS, 1);
maximumValidationFitness = zeros(NUMBER_OF_GENERATIONS, 1);
prevMaximumValidationFitness = 0;
maximumValidationFitnessSoFar = 0;
bestValidationIndividual = zeros(1, nbrOfGenes);

f2 = figure(2);

t = tic;
holdoutStrikes = 0;
for iGeneration = 1:NUMBER_OF_GENERATIONS

  %Evaluate population
  trainingFitness = zeros(populationSize, 1);
  validationFitness = zeros(populationSize, 1);
  iBestIndividual = 0;
  for iIndividual = 1:populationSize
    chromosome = population(iIndividual,:);
    pricingSequence = DecodeChromosome(chromosome, ticketPriceInterval, ticketPriceResolution);
    trainingFitness(iIndividual) = EvaluateIndividual(pricingSequence, currentSystemState, systemParameters);
    if trainingFitness(iIndividual) > maximumTrainingFitness(iGeneration)
      maximumTrainingFitness(iGeneration) = trainingFitness(iIndividual);
      iBestIndividual = iIndividual;
      bestPricingSequence = pricingSequence;
    end
  end
  bestIndividual = population(iBestIndividual, :);
  
%   maximumValidationFitness(iGeneration) = EvaluateIndividual(bestPricingSequence, currentSystemState, systemParameters);
%   if maximumValidationFitness(iGeneration) > maximumValidationFitnessSoFar
%     maximumValidationFitnessSoFar = maximumValidationFitness(iGeneration);
%     bestValidationIndividual = bestIndividual;
%     holdoutStrikes = 0;
%   else
%     holdoutStrikes = holdoutStrikes + 1;
%     if holdoutStrikes == HOLDOUT_THRESHOLD
%       fprintf(strcat('Optimization terminated due to no increase of',  ...
%         ' maximum validation fitness in %d generations.\n'), HOLDOUT_THRESHOLD)
%       maximumTrainingFitness(iGeneration+1:end) = [];
%       maximumValidationFitness(iGeneration+1:end) = [];
%       break
%     end
%   end
     
  % Update traiing curves
  subplot(1,2,1)
  cla
  hold on
  plot(maximumTrainingFitness(1:iGeneration))
  %plot(maximumValidationFitness(1:iGeneration))
  set(gca, 'FontSize', 14)
  xlabel('Generation')
  ylabel('Fitness')
  %legend({'Training', 'Validation'}, 'Location', 'southeast')
  drawnow
  
  % Update best sequence plot
  subplot(1,2,2)
  cla
  sequencePlotTime = (currentTimeIndex-1:nbrOfTimeBins-1)*timeBinWidth;
  plot(sequencePlotTime, DecodeChromosome(bestIndividual, ticketPriceInterval, ticketPriceResolution))
  ylim(ticketPriceInterval)
  xlabel('Time (days)')
  ylabel('Price (kr)')
  title(sprintf('Starting from day %d/%d', (currentTimeIndex-1)*timeBinWidth, eventTime))
  drawnow
  
  if iGeneration == NUMBER_OF_GENERATIONS
    fprintf('All %d generations completed.\n', NUMBER_OF_GENERATIONS);
    break
  end
  
  tempPopulation = population;

  %Selection and crossover
  for i = 1:2:populationSize
    i1 = TournamentSelect(trainingFitness, tournamentSelectionParameter, tournamentSize);
    i2 = TournamentSelect(trainingFitness, tournamentSelectionParameter, tournamentSize);
    chromosome1 = population(i1,:);
    chromosome2 = population(i2,:);
    
    r = rand;
    if (r < crossoverProbability)
      newChromosomePair = Cross(chromosome1, chromosome2);
      tempPopulation(i,:) = newChromosomePair(1,:);
      tempPopulation(i+1,:) = newChromosomePair(2,:);
    else
      tempPopulation(i,:) = chromosome1;
      tempPopulation(i+1,:) = chromosome2;
    end
  end

  %Mutation
  for i = 1:populationSize
    originalChromosome = tempPopulation(i,:);
    mutatedChromosome = Mutate(originalChromosome, mutationProbability, ...
      creepRate, creepProbability);
    tempPopulation(i,:) = mutatedChromosome;
  end

  tempPopulation = InsertBestIndividual(tempPopulation, bestIndividual, ...
    COPIES_OF_BEST_INDIVIDUAL);
  population = tempPopulation;
 
  if mod(iGeneration, NUMBER_OF_GENERATIONS/50)==0
    t = toc(t);
    fprintf('Generation %d/%d complete after %.2f seconds.\n', ...
      iGeneration, NUMBER_OF_GENERATIONS, t)
    t = tic;
  end
 
end


%% Plot the best pricing sequence

f3 = figure(3);
t = (currentTimeIndex-1:nbrOfTimeBins-1)*timeBinWidth;
plot(t, DecodeChromosome(bestIndividual, ticketPriceInterval, ticketPriceResolution))
ylim(ticketPriceInterval)
xlabel('Time (days)')
ylabel('Price (kr)')
title(sprintf('Starting from day %d/%d', (currentTimeIndex-1)*timeBinWidth, eventTime))

%% Print relevent stats

disp(' ')
currentPrice = bestPricingSequence(1);
meanFirstPrices = mean(bestPricingSequence(1:5));
[~, expectedTicketsSoldHistory] = EvaluateIndividual(bestPricingSequence, currentSystemState, systemParameters);
fprintf('Starting day: %d\n', (currentTimeIndex-1)*timeBinWidth)
fprintf('Current price: %d\nCurrent price (mean): %d\n', currentPrice, meanFirstPrices)
fprintf('Expected tickets sold in the next 10 days: %d\n', expectedTicketsSoldHistory(10))



