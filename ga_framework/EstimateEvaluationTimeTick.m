function evaluationTime = EstimateEvaluationTimeTick(nbrOfGenes, systemParameters)

nbrOfTrials = 10000;

% Choose pricing sequence such that we will not terminate early
pricingSequence = 99999999999999999*ones(1, nbrOfGenes);
eventTimeIndex = ceil(systemParameters.eventTime / systemParameters.timeBinWidth);
dummySystemState = struct('currentTimeIndex', eventTimeIndex-nbrOfGenes+1, 'currentTicketsSold', 0);

% Measure evluation time
t = tic;
for iTrial = 1:nbrOfTrials
  EvaluateIndividual(pricingSequence, dummySystemState, systemParameters);
end
t = toc(t);
evaluationTime = t / nbrOfTrials;


end