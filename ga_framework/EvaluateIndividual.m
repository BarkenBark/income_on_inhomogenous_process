function fitness = EvaluateIndividual(pricingSequence, currentSystemState, systemParameters)
  
  % pricingSequence should be a vector whose length is equal to the number
  % of remaining time steps until the event
  
  demandEstimationFun = systemParameters.demandEstimationFunction;
  ticketSalesCapacity = systemParameters.maxTicketsSold;
  sequenceTimes = systemParameters.sequenceTimes;

  currentTimeIndex = currentSystemState.currentTimeIndex;
  currentTicketsSold = currentSystemState.currentTicketsSold;
  
  % NOTE: Within loop, we are iterating over time. "current" above refers
  % to where we actually are now in real time, "time" within the for loop
  % above represents where we will be in future time
  expectedRemainingIncome = 0;
  expectedTicketsSold = currentTicketsSold;
  for iTimeBin = currentTimeIndex:(length(sequenceTimes)-1)
    if expectedTicketsSold >= ticketSalesCapacity % We do not expect our remaining income to be affected by sales after the point at which we expect to have sold out the tickets
      break
    end
    timeBinWidth = sequenceTimes(iTimeBin+1) - sequenceTimes(iTimeBin);
    time = (sequenceTimes(iTimeBin+1) + sequenceTimes(iTimeBin))/2; 
    ticketPrice = pricingSequence(iTimeBin-currentTimeIndex+1);
    lambda = demandEstimationFun(time, ticketPrice);
    expectedBinTicketsSold = min(lambda*timeBinWidth, ticketSalesCapacity-expectedTicketsSold);
    expectedTicketsSold = expectedTicketsSold + expectedBinTicketsSold;
    expectedTimeBinIncome = expectedBinTicketsSold*ticketPrice;
    expectedRemainingIncome = expectedRemainingIncome + expectedTimeBinIncome;
    %fprintf('%d, %.2f, %.2f, %.2f, %d\n', expectedTicketsSold, lambda, expectedTimeBinIncome, ticketPrice, time);
  end
  
  fitness = expectedRemainingIncome;
  
end
