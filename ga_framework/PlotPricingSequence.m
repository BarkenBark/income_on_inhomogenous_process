function axisHandle = PlotPricingSequence(pricingSequence, axisHandle, currentSystemState, systemParameters)
  % arguments after axisHandle are only required once, when initializing the axis
  % pricingSequence is a 1*length(times) vector
  
  if strcmp(axisHandle.UserData, 'pricingSequencePlot')
    
    pricingSequencePlotHandle = findobj(axisHandle, 'Tag', 'pricingSequence');
    set(pricingSequencePlotHandle, 'YData', [pricingSequence, pricingSequence(end)]);
    
    ticketDepletionTimeLineHandle = findobj(axisHandle, 'Tag', 'ticketDepletionTime');
    [~, expectedTicketDepletionTime] = EstimateTicketDepletion(pricingSequence, currentSystemState, systemParameters);
    set(ticketDepletionTimeLineHandle, 'XData', [expectedTicketDepletionTime, expectedTicketDepletionTime]);
    
  else
    
    %disp('Initializing PricingSequencePlot')
    cla(axisHandle)
    sequenceTimes = currentSystemState.remainingSequenceTimes;
    %fprintf('[PlotPricingSequence]: length(sequenceTimes) = %d\n', length(sequenceTimes))
    %fprintf('[PlotPricingSequence]: length(pricingSequence) = %d\n', length(pricingSequence))
    priceInterval = systemParameters.ticketPriceInterval;
    ylim = priceInterval + 0.05*[-diff(priceInterval), diff(priceInterval)];
    
    stairs(sequenceTimes, [pricingSequence, pricingSequence(end)], 'Parent', axisHandle, 'Tag', 'pricingSequence');
    set(axisHandle, 'NextPlot', 'add');
    [~, expectedTicketDepletionTime] = EstimateTicketDepletion(pricingSequence, currentSystemState, systemParameters);
    line(axisHandle, [expectedTicketDepletionTime, expectedTicketDepletionTime], ylim, 'Tag', 'ticketDepletionTime');
    
    xlabel(axisHandle, 'Time (days)');
    ylabel(axisHandle, 'Ticket Price (kr)');
    title(axisHandle, 'Pricing Sequence');
    set(axisHandle, 'YLim', ylim);
    set(axisHandle, 'UserData', 'pricingSequencePlot');
  
  end
    
end