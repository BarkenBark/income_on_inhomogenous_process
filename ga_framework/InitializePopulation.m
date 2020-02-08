function population = InitializePopulation(populationSize, nbrOfGenes)

  population = zeros(populationSize, nbrOfGenes);

  for i = 1:populationSize
    chromosome = zeros(1, nbrOfGenes);
    for j = 1:nbrOfGenes
      chromosome(j) = rand;
    end
    population(i,:) = chromosome;
  end

end

