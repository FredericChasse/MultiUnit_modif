classdef Array_t < SimPkg.ArrayPkg.AbstractArrayInterface_t
  
  properties
    obj
    units
  end
  
  %Class interface
  properties
    id_if
    nUnits_if
    units_if
    EvaluateFunc_if
    SplitArrayFunc_if
  end
  
  methods
    
    % Constructor
    function array = Array_t(obj)
      import SimPkg.UnitPkg.*
      
      array.obj = obj;
      
      % From class interface
      array.id_if             = obj.id_if;
      array.nUnits_if         = obj.nUnits_if;
      array.units_if          = obj.units_if;
      array.EvaluateFunc_if   = obj.EvaluateFunc_if;
      array.SplitArrayFunc_if = obj.SplitArrayFunc_if;
      
      % Create array of units based on object received
      array.units = Unit_t.empty;
      for i = 1 : obj.(array.nUnits_if)
        array.units(i) = Unit_t(array.obj.(array.units_if)(i));
      end
    end
    
    function [a1, a2] = SplitArray(array, idxToSplit, newId)
      import SimPkg.*
      import SimPkg.ArrayPkg.*
      import SimPkg.UnitPkg.*
      
      [a1, a2] = array.obj.(array.SplitArrayFunc_if)(idxToSplit, newId);
      a1 = Array_t(a1);
      a2 = Array_t(a2);
    end
    
    % Destructor
    function Del(array)
      delete(array);
    end
    
    function EvalUnit(array, id)
      array.obj.(array.EvaluateFunc_if)(id);
    end
    
    function id = id(array)
      id = array.obj.(array.id_if);
    end
    
    function nUnits = nUnits(array)
      nUnits = array.obj.(array.nUnits_if);
    end
    
  end
  
end

