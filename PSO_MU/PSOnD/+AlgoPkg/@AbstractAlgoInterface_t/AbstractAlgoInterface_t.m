classdef (Abstract) AbstractAlgoInterface_t < handle & matlab.mixin.Heterogeneous
  
  properties (Abstract)
    id_if
    unitArray_if
    RunAlgoFunc_if
  end
  
end

