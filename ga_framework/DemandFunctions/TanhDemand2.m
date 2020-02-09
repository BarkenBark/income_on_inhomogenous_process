function lambda = TanhDemand2(time, price, parameters)
  
  A = parameters(1);
  B = parameters(2);
  a = parameters(3);
  b = parameters(4);
  T = parameters(5);
  eventTime = parameters(6);
  
  timeUntilEvent = eventTime - time;
  if timeUntilEvent < 0
    error("Can't estimate demand after the event has passed")
  end
  timeFactor = 1 - B*(0.1/B).^(timeUntilEvent/T);
  lambda = A*(1-tanh((a*price-b).*timeFactor)).*sqrt(timeFactor);
  
end