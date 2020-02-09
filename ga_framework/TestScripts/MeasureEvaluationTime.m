%% Script to measure maximum evaluation times

nSamples = 100;
maxNGenes = 100;
geneRes = 2;
genesToTest = 1:geneRes:maxNGenes;


demandFun = Tan

evalTimeVsNGenes = zeros(1, length(genesToTest));
for iGene = 1:length(genesToTest)

  nbrOfGenes = genesToTest(iGene);
  
  % Choose pricing sequence such that we will not terminate early
  pricingSequence = zeros(1, nbrOfGenes);
  
  % Measure evluation time
  t = tic;
  EvaluateIndividual(pricingSequence, currentSystemState, systemParameters);
  t = toc(t);
  evalTimeVsNGenes(iGene) = t;

end