classdef (Abstract) AbstractAlgoInterface_t < handle & matlab.mixin.Heterogeneous
  
  properties (Abstract)
    id_if
    unitArray_if
    simData_if
    nSimData_if
    RunAlgoFunc_if
  end
  
end

