classdef (Abstract) AbstractLinkInterface_t < handle & matlab.mixin.Heterogeneous
  
  properties (Abstract)
    simUnitId_if
    algoId_if
    algoUnitId_if
    algoDimId_if
  end
  
end