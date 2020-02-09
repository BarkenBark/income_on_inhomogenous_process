function nbrOfTicketsSold = SimulateTicketSales(lambda, delta)
% Samples the number of tickets sold during a time interval delta with the
% sales rate lambda

  nbrOfTicketsSold = poissrnd(lambda*delta);

end