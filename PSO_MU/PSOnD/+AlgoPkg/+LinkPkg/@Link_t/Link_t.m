classdef Link_t < handle
  
  properties
    id
    simUnitId
    algoId
    algoUnitId
    algoDimId
  end
  
  methods
    
    % Constructor
    function l = Link_t(id, simUnitId, algoId, algoUnitId, algoDimId)
      l.id         = id;
      l.simUnitId  = simUnitId;
      l.algoId     = algoId;
      l.algoUnitId = algoUnitId;
      l.algoDimId  = algoDimId;
    end
    
    % Destructor
    function Del(link)
      delete(link);
    end
      
  end
  
end

