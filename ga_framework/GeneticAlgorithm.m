function [bestIndividual, bestFitness] = GeneticAlgorithm(parameters, progressFigureHandle)
%GeneticAlgorithm Perform GA optimization and obtain best solution
%   Detailed explanation goes here

% Unpack parameters
% % GA Functions
fitnessFunction = parameters.fitnessFunction;
popInitFunction = parameters.popInitFunction;
decodingFunction = parameters.decodingFunction;

% % GA Optimization Parameters
nbrOfGenerations = parameters.nbrOfGenerations;
populationSize = parameters.populationSize;
nbrOfGenes = parameters.nbrOfGenes;
mutationProbability = parameters.mutationProbability;
creepRate = parameters.creepRate;
creepProbability = parameters.creepProbability;
tournamentSelectionParameter = parameters.tournamentSelectionParameter;
tournamentSize = parameters.tournamentSize;
crossoverProbability = parameters.crossoverProbability;
copiesOfBestIndividual = parameters.copiesOfBestIndividual;

% % Visualization parameters
plotting = parameters.plotting;
plotInterval = parameters.plotInterval;
solutionPlotFunction = parameters.solutionPlotFunction;

% Initialize population
population = popInitFunction(populationSize, nbrOfGenes);
maximumTrainingFitness = zeros(1, nbrOfGenerations);

% Initialize plots
fitnessAxisHandle = subplot(1,2,1, 'Parent', progressFigureHandle);
fitnessAxisHandle = PlotMaximumFitness([], fitnessAxisHandle);
solutionAxisHandle = subplot(1,2,2, 'Parent', progressFigureHandle);
solutionAxisHandle = solutionPlotFunction(population(1,:), solutionAxisHandle);

% Run GA
t = tic;
for iGeneration = 1:nbrOfGenerations

  %Evaluate population
  trainingFitness = zeros(1, populationSize);
  iBestIndividual = 0;
  for iIndividual = 1:populationSize
    chromosome = population(iIndividual,:);
    individual = decodingFunction(chromosome);
    trainingFitness(iIndividual) = fitnessFunction(individual);
    if trainingFitness(iIndividual) >= maximumTrainingFitness(iGeneration)
      maximumTrainingFitness(iGeneration) = trainingFitness(iIndividual);
      iBestIndividual = iIndividual;
      bestIndividual = individual;
    end
  end
  bestChromosome = population(iBestIndividual, :);

  % Initiate population update
  tempPopulation = population;

  % % Selection and crossover
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

  % % Mutation
  for i = 1:populationSize
    originalChromosome = tempPopulation(i,:);
    mutatedChromosome = Mutate(originalChromosome, mutationProbability, ...
      creepRate, creepProbability);
    tempPopulation(i,:) = mutatedChromosome;
  end
  
  % % Insertion
  tempPopulation = InsertBestIndividual(tempPopulation, bestChromosome, ...
    copiesOfBestIndividual);
  
  % % Population update end
  population = tempPopulation;
         
  % Update plots
  if plotting && mod(iGeneration, plotInterval)==0
    PlotMaximumFitness(maximumTrainingFitness(1:iGeneration), fitnessAxisHandle);
    solutionPlotFunction(bestIndividual, solutionAxisHandle);
    drawnow
  end
    
  % Print status
  if iGeneration == nbrOfGenerations
    fprintf('All %d generations completed.\n', nbrOfGenerations);
    break
  end
  
%   if mod(iGeneration, nbrOfGenerations/50)==0
%     t = toc(t);
%     fprintf('Generation %d/%d complete after %.2f seconds.\n', ...
%       iGeneration, nbrOfGenerations, t)
%     t = tic;
%   end
  
end

bestFitness = fitnessFunction(bestIndividual);

end

