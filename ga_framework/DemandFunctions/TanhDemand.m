function lambda = TanhDemand(time, price, parameters)
  
  A = parameters(1);
  a = parameters(2);
  b = parameters(3);
  T = parameters(4);
  eventTime = parameters(5);
  
  timeUntilEvent = eventTime - time;
  if timeUntilEvent < 0
    error("Can't estimate demand after the event has passed")
  end
  lambda = A*(1-tanh((a*price-b).*timeUntilEvent/T)).*timeUntilEvent/T;
  
end