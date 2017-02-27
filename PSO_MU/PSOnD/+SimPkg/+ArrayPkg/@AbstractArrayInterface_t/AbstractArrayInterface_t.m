classdef (Abstract) AbstractArrayInterface_t < handle & matlab.mixin.Heterogeneous
  
  properties (Abstract)
    id_if
    nUnits_if
    units_if
    realTime_if
    integrationTime_if
    EvaluateFunc_if
    SplitArrayFunc_if
    AddUnitToArray_if
  end
  
%   methods
%   end
  
end

