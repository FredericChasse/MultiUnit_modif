classdef Algo_t < AlgoPkg.AbstractAlgoInterface_t
  
  properties
    obj
    unitArray
    
    % Algo interface
    id_if
    unitArray_if
    simData_if
    nSimData_if
    realTimeElapsed_if
    RunAlgoFunc_if
  end
  
  methods
    
    % Constructor
    function algo = Algo_t(obj)
      algo.obj            = obj;
      algo.unitArray      = obj.(obj.unitArray_if);
      
      % Algo interface
      algo.id_if              = obj.id_if;
      algo.unitArray_if       = obj.unitArray_if;
      algo.simData_if         = obj.simData_if;
      algo.nSimData_if        = obj.nSimData_if;
      algo.realTimeElapsed_if = obj.realTimeElapsed_if;
      algo.RunAlgoFunc_if     = obj.RunAlgoFunc_if;
    end
    
    % Destructor
    function Del(algo)
      delete(algo);
    end
    
    % id
    function id = id(algo)
      id = algo.obj.(algo.id_if);
    end
    
    % Algo run
    function RunAlgoIteration(algo, iteration)
      algo.obj.(algo.RunAlgoFunc_if)(iteration);
    end
    
    % SimData
    function simData = simData(algo)
      simData = algo.obj.(algo.simData_if);
    end
    
    % nSimData
    function nSimData = nSimData(algo)
      nSimData = algo.obj.(algo.nSimData_if);
    end
    
    function realTimeElapsed = realTimeElapsed(algo)
      realTimeElapsed = algo.obj.(algo.realTimeElapsed_if);
    end
    
  end
  
end

