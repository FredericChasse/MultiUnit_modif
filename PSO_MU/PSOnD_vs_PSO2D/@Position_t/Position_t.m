classdef Position_t < handle
  
  properties
    prevPos
    curPos
    prevFitness
    curFitness
  end
  
  methods
    
    % Constructor
    function pos = Position_t(dim)
      for iDim = 1 : dim
        pos.prevPos(iDim) = 0;
        pos.curPos(iDim)  = 0;
      end
      pos.prevFitness = 0;
      pos.curFitness  = 0;
    end
    
    % Destructor
    function Del(pos)
      delete(pos);
    end
    
  end
  
end

