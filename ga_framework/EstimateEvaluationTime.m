function [nbrOfGenes, evaluationTime] = EstimateEvaluationTime(systemParameters)

nbrOfTrials = 100;

maxNGenes = 100;
geneRes = 2;
nbrOfGenes = 1:geneRes:maxNGenes;

evaluationTime = zeros(1, length(nbrOfGenes));
for iGene = 1:length(nbrOfGenes)

  thisNbrOfGenes = nbrOfGenes(iGene);
  
  % Choose pricing sequence such that we will not terminate early
  pricingSequence = 9999999*ones(1, thisNbrOfGenes);
  eventTimeIndex = ceil(systemParameters.eventTime / systemParameters.timeBinWidth);
  dummySystemState = struct('currentTimeIndex', eventTimeIndex-thisNbrOfGenes+1, 'currentTicketsSold', 0);
  
  % Measure evluation time
  t = tic;
  for iTrial = 1:nbrOfTrials
    EvaluateIndividual(pricingSequence, dummySystemState, systemParameters);
  end
  t = toc(t);
  evaluationTime(iGene) = t / nbrOfTrials;

end

end