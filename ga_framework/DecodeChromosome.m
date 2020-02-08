function pricingSequence = DecodeChromosome(chromosome, ticketPriceInterval, ticketPriceResolution)
%DecodeChromosome Return the neural network encoded by chromosome

  minTicketPrice = ticketPriceInterval(1);
  maxTicketPrice = ticketPriceInterval(2);
  
  pricingSequence = minTicketPrice + (maxTicketPrice - minTicketPrice)*chromosome;
  pricingSequence = ticketPriceResolution * floor(pricingSequence / ticketPriceResolution); % Round to nearest multiple of ticketPriceResolution
  
end

