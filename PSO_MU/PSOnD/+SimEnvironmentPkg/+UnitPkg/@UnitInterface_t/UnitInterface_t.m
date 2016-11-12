classdef (Abstract) UnitInterface_t < handle %& matlab.mixin.Heterogeneous
  
  properties (Abstract)
    perturbVar
    posVar
    fitnessVar
  end
  
end

