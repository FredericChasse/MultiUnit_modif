classdef Algo_t < AlgoPkg.AbstractAlgoInterface_t
  
  properties
    obj
    unitArray
    
    % Algo interface
    id_if
    unitArray_if
    RunAlgoFunc_if
  end
  
  methods
    
    % Constructor
    function algo = Algo_t(obj)
      algo.obj            = obj;
      algo.unitArray      = obj.(obj.unitArray_if);
      
      % Algo interface
      algo.id_if          = obj.id_if;
      algo.unitArray_if   = obj.unitArray_if;
      algo.RunAlgoFunc_if = obj.RunAlgoFunc_if;
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
    
  end
  
end

