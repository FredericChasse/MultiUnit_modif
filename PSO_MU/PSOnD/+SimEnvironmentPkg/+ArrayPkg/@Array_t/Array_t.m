classdef Array_t < ArrayPkg.ArrayInterface_t
  
  properties
    obj
    
    % From interface
    id
    unitVar
    EvaluateFunc
  end
  
  methods
    
    % Constructor
    function array = Array_t(obj)
      array.obj = obj;
      
      % From class interface
      array.id = obj.id;
      array.unitVar = obj.unitVar;
      array.EvaluateFunc = obj.EvaluateFunc;
    end
    
    % Destructor
    function Del(array)
      delete(array);
    end
    
    function Eval(array, args)
      array.obj.(array.EvaluateFunc) (args);
    end
    
  end
  
end

