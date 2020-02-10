function nbrOfTicketsSold = SimulateTicketSales(lambda, delta, remainingTickets)
% Samples the number of tickets sold during a time interval delta with the
% sales rate lambda
% remainingTickets = number of remaining tickets which can be sold

  nbrOfTicketsSold = min(poissrnd(lambda*delta), remainingTickets);

end