function fitness = EvaluateIndividual(pricingSequence, currentSystemState, systemParameters)
  
  % pricingSequence should be a vector whose length is equal to the number
  % of remaining time steps until the event
  
  demandEstimationFun = systemParameters.demandEstimationFun;
  eventTime = systemParameters.eventTime;
  timeBinWidth = systemParameters.timeBinWidth; % TODO: Discard this as a constant. Calculate timeBinWidth dynamically from time sequence
  ticketSalesCapacity = systemParameters.maxTicketsSold;
  eventTimeIndex = ceil(eventTime / timeBinWidth);

  currentTimeIndex = currentSystemState.currentTimeIndex;
  currentTicketsSold = currentSystemState.currentTicketsSold;
  
  % NOTE: Within loop, we are iterating over time. "current" above refers
  % to where we actually are now in real time, "time" within the for loop
  % above represents where we will be in future time
  expectedRemainingIncome = 0;
  expectedTicketsSold = currentTicketsSold;
  for iTime = currentTimeIndex:eventTimeIndex
    if expectedTicketsSold >= ticketSalesCapacity % We do not expect our remaining income to be affected by sales after the point at which we expect to have sold out the tickets
      break
    end
    time = timeBinWidth*(iTime-1); % NOTE: Maybe replace with middle time of bin, rather than starting time of bin as it is now?
    ticketPrice = pricingSequence(iTime-currentTimeIndex+1);
    lambda = demandEstimationFun(time, ticketPrice);
    expectedBinTicketsSold = min(lambda*timeBinWidth, ticketSalesCapacity-expectedTicketsSold);
    expectedTicketsSold = expectedTicketsSold + expectedBinTicketsSold;
    expectedTimeBinIncome = expectedBinTicketsSold*ticketPrice;
    expectedRemainingIncome = expectedRemainingIncome + expectedTimeBinIncome;
    %fprintf('%d, %.2f, %.2f, %.2f, %d\n', expectedTicketsSold, lambda, expectedTimeBinIncome, ticketPrice, time);
  end
  
  fitness = expectedRemainingIncome;
  
end
