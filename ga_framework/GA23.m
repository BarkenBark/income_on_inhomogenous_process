%% Main code
clc; clear all
clf; close all

%System
% The parameters here do not change across GA optimizations
eventTime = 100; % In time units from start time which is 0
timeBinWidth = 7;
nbrOfTimeBins = ceil(eventTime / timeBinWidth);
ticketSalesCapacity = 100;
demandEstimationFun = @(t,p) 10*((1-t/eventTime) - (1-t/eventTime) .* tanh(0.01*(1-t/eventTime)*p - 3*(1-t/eventTime)));
ticketPriceInterval = [200, 1000];
ticketPriceResolution = 10;
systemParameters = struct('eventTime', eventTime, 'timeBinWidth', timeBinWidth, ...
  'maxTicketsSold', ticketSalesCapacity, 'demandEstimationFun', demandEstimationFun, ...
  'ticketPriceInterval', ticketPriceInterval, 'ticketPriceResolution', ticketPriceResolution);

% System state
% The parameters here are updated for every time we'll do a GA optimization
currentTimeIndex = 1;
currentTicketsSold = 0;
sequenceTimes = ((currentTimeIndex-1):(nbrOfTimeBins))*timeBinWidth;
currentSystemState = struct('currentTimeIndex', currentTimeIndex, 'currentTicketsSold', currentTicketsSold, 'sequenceTimes', sequenceTimes);


%% Plot demand estimation function over the defined time interval

tRes = 1000;
pRes = 10;
pricePlotRange = linspace(ticketPriceInterval(1), ticketPriceInterval(2), pRes);
timePlotRange = linspace(0, eventTime, tRes);

f1 = figure(1);
legendStrings = {};
for price = pricePlotRange
  legendStrings{end+1} = strcat(num2str(price), ' kr');
  lambdas = demandEstimationFun(timePlotRange, price);
  plot(timePlotRange, lambdas);
  hold on
end
legend(legendStrings)
xlabel('Time (days)')
ylabel('Demand (sales/day)')


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

%% Print some statistics

nbrOfFeasibleSolutions = ((ticketPriceInterval(2)-ticketPriceInterval(1)) / ticketPriceResolution)^nbrOfTimeBins; % NOTE: This is not correct.
fprintf('Total number of feasible solutions: %d\n', nbrOfFeasibleSolutions)
nbrOfGaEvaluations = populationSize*NUMBER_OF_GENERATIONS;
fprintf('Expected number of GA evaluations: %d\n\n', nbrOfGaEvaluations)


%% Genetic Algorithm - Script

population = InitializePopulation2(populationSize, nbrOfGenes);

maximumTrainingFitness = zeros(NUMBER_OF_GENERATIONS, 1);
maximumValidationFitness = zeros(NUMBER_OF_GENERATIONS, 1);
prevMaximumValidationFitness = 0;
maximumValidationFitnessSoFar = 0;
bestValidationIndividual = zeros(1, nbrOfGenes);

% Initialize plots
gaProgressFigureHandle = figure(2);
fitnessAxisHandle = subplot(1,2,1, 'Parent', gaProgressFigureHandle);
fitnessAxisHandle = PlotMaximumFitness([], fitnessAxisHandle, 'kr');
solutionAxisHandle = subplot(1,2,2, 'Parent', gaProgressFigureHandle);
solutionAxisHandle = PlotPricingSequence(population(1,:), solutionAxisHandle, currentSystemState, systemParameters); % The solution plotting method could be passed as parameter to GA function

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
     
%   % Update training curves
  PlotMaximumFitness(maximumTrainingFitness(1:iGeneration), fitnessAxisHandle);

%   subplot(1,2,1)
%   cla
%   hold on
%   plot(maximumTrainingFitness(1:iGeneration))
%   %plot(maximumValidationFitness(1:iGeneration))
%   set(gca, 'FontSize', 14)
%   xlabel('Generation')
%   ylabel('Fitness')
%   %legend({'Training', 'Validation'}, 'Location', 'southeast')
%   drawnow
  
  % Update best sequence plot
  PlotPricingSequence(bestPricingSequence, solutionAxisHandle, currentSystemState, systemParameters);
  
%   subplot(1,2,2)
%   cla
%   sequencePlotTime = (currentTimeIndex-1:nbrOfTimeBins-1)*timeBinWidth;
%   stairs(sequencePlotTime, DecodeChromosome(bestIndividual, ticketPriceInterval, ticketPriceResolution))
%   ylim(ticketPriceInterval)
%   xlabel('Time (days)')
%   ylabel('Price (kr)')
%   title(sprintf('Starting from day %d/%d', (currentTimeIndex-1)*timeBinWidth, eventTime))
%   drawnow

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
ax = axes(f3);
bestPricingSequence = DecodeChromosome(bestIndividual, systemParameters.ticketPriceInterval, systemParameters.ticketPriceResolution);
PlotPricingSequence(bestPricingSequence, ax, currentSystemState, systemParameters);

%% Print relevent stats

disp(' ')
currentPrice = bestPricingSequence(1);
meanFirstPrices = mean(bestPricingSequence(1:5));
[expectedTicketsSoldFinal, expectedTicketDepletionTimeFinal] = EstimateTicketDepletion(bestPricingSequence, currentSystemState, systemParameters);
fprintf('Starting day: %d\n', (currentTimeIndex-1)*timeBinWidth)
fprintf('Current price: %d\nCurrent price (mean): %d\n', currentPrice, meanFirstPrices) ,


