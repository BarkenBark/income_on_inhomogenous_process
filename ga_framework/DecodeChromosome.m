function pricingSequence = DecodeChromosome(chromosome, systemParameters)
%DecodeChromosome Return the neural network encoded by chromosome

  ticketPriceInterval = systemParameters.ticketPriceInterval;
  ticketPriceResolution = systemParameters.ticketPriceResolution;

  minTicketPrice = ticketPriceInterval(1);
  maxTicketPrice = ticketPriceInterval(2);
  
  pricingSequence = minTicketPrice + (maxTicketPrice - minTicketPrice)*chromosome;
  pricingSequence = ticketPriceResolution * floor(pricingSequence / ticketPriceResolution); % Round to nearest multiple of ticketPriceResolution
  
end

