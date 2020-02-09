function axisHandle = PlotMaximumFitness(maximumFitness, axisHandle, fitnessUnitString)
  % arguments after axisHandle are only required once, when initializing the axis
  % maximumFitness is a 1*nGenerations vector where the ith element is the
  % fitness of the best individual from generation i
  
  if strcmp(axisHandle.UserData, 'maximumFitnessPlot')
    maximumFitnessPlotHandle = axisHandle.Children(1);
    set(maximumFitnessPlotHandle, 'XData', 1:length(maximumFitness), 'YData', maximumFitness);
  else
    disp('Initializing MaximumFitnessPlot')
    cla(axisHandle);
    plot(1,0, 'Parent', axisHandle);
    if exist('fitnessUnitString', 'var')
      fitnessLabelString = sprintf('Fitness (%s)', fitnessUnitString);
    else
      fitnessLabelString = 'Fitness';
    end
    xlabel(axisHandle, 'Generation');
    ylabel(axisHandle, fitnessLabelString);    
    title(axisHandle, 'Fitness');
    set(axisHandle, 'FontSize', 14);
    set(axisHandle, 'UserData', 'maximumFitnessPlot'); % To signal that this axis is a MaximumFitnessPlot for future updating
  end
    
end