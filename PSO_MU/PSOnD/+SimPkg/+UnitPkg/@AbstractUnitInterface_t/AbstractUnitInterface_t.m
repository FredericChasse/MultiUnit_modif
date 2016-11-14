classdef (Abstract) AbstractUnitInterface_t < handle & matlab.mixin.Heterogeneous
  
  % Class interface
  properties (Abstract)
    id_if         % ID of the unit
    unitInput_if  % Controls the perturbations
    pos_if        % Algorithm's control variable
    fitness_if    % Objective function
    beta_if       % Difference of optimal position to a reference
    gamma_if      % Difference of optimal fitness to a reference
  end
  
end