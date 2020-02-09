function [expectedTicketsSold, expectedTicketDepletionTime] = EstimateTicketDepletion(pricingSequence, currentSystemState, systemParameters)
  
  ticketSalesCapacity = systemParameters.maxTicketsSold;
  currentTicketsSold = currentSystemState.currentTicketsSold;
  sequenceTimes = currentSystemState.sequenceTimes;
  demandEstimationFun = systemParameters.demandEstimationFun;

  expectedTicketsSold = currentTicketsSold;
  for iTime = 1:(length(sequenceTimes)-1)
    time = sequenceTimes(iTime);
    if expectedTicketsSold >= ticketSalesCapacity
      expectedTicketDepletionTime = time;
      return
    end
    ticketPrice = pricingSequence(iTime);
    lambda = demandEstimationFun(time, ticketPrice); % NOTE: Should redfine the demandEstimationFunction such that it expects timeUntilEvent rather than current time
    timeBinWidth = sequenceTimes(iTime+1)-sequenceTimes(iTime);
    expectedBinTicketsSold = min(lambda*timeBinWidth, ticketSalesCapacity-expectedTicketsSold);
    expectedTicketsSold = expectedTicketsSold + expectedBinTicketsSold;
  end

  % If we don't expected to sell out
  expectedTicketDepletionTime = sequenceTimes(end);
  
end