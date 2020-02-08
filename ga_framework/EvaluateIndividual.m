function [fitness, expectedTicketsSoldHistory] = EvaluateIndividual(pricingSequence, currentSystemState, systemParameters)
  
  % pricingSequence should be a vector whose length is equal to the number
  % of remaining time steps until the event
  % demandEstimation is a function of 
  
  demandEstimationFun = systemParameters.demandEstimationFun;
  eventTime = systemParameters.eventTime;
  timeBinWidth = systemParameters.timeBinWidth;
  ticketSalesCapacity = systemParameters.maxTicketsSold;
  eventTimeIndex = ceil(eventTime / timeBinWidth);

  currentTimeIndex = currentSystemState.currentTimeIndex;
  currentTicketsSold = currentSystemState.currentTicketsSold;
  
  % NOTE: Within loop, we are iterating over time. "current" above refers
  % to where we actually are now in real time, "time" within the for loop
  % above represents where we will be in future time
  expectedRemainingIncome = 0;
  expectedTicketsSold = currentTicketsSold;
  expectedTicketsSoldHistory = zeros(1, eventTimeIndex-currentTimeIndex+1);
  expectedTicketsSoldHistory(1) = currentTicketsSold;
  for iTime = currentTimeIndex:eventTimeIndex
    expectedTicketsSoldHistory(iTime-currentTimeIndex+1) = expectedTicketsSold;
    if expectedTicketsSold > ticketSalesCapacity
      fprintf('Expected ticket sales exceeded limit at time %d', time)
      break
    end
    time = timeBinWidth*(iTime-1);
    %timeUntilEvent = eventTime - time;
    ticketPrice = pricingSequence(iTime-currentTimeIndex+1);
    lambda = demandEstimationFun(time, ticketPrice); % NOTE: Should redfine the demandEstimationFunction such that it expects timeUntilEvent rather than current time
    expectedTicketsSold = expectedTicketsSold + lambda*timeBinWidth;
    expectedTimeBinIncome = lambda*timeBinWidth*ticketPrice;
    expectedRemainingIncome = expectedRemainingIncome + expectedTimeBinIncome;
    %fprintf('%d, %.2f, %.2f, %.2f, %d\n', expectedTicketsSold, lambda, expectedTimeBinIncome, ticketPrice, time);
  end
  
  fitness = expectedRemainingIncome;
  
end
