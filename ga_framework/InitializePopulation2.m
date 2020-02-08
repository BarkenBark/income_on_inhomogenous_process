function population = InitializePopulation2(populationSize, nbrOfGenes)

  population = zeros(populationSize, nbrOfGenes);

  for i = 1:populationSize
    chromosome = i/populationSize * ones(1, nbrOfGenes);
    population(i,:) = chromosome;
  end

end

