classdef StaticFuncArray_t < SimPkg.ArrayPkg.AbstractArrayInterface_t
  
  properties
    id
    units
    nUnits
  end
  
  %Class interface
  properties
    id_if
    nUnits_if
    units_if
    EvaluateFunc_if
  end
  
  methods
    
    % Constructor
    function array = StaticFuncArray_t(id, nUnits)
      import SimPkg.UnitPkg.*
      
      array.id      = id;
      array.nUnits  = nUnits;
      
      array.units = StaticFunction_t.empty;
      for i = 1 : nUnits
        array.units(i) = StaticFunction_t(i);
      end
      
      % Class interface
      array.id_if           = 'id';
      array.nUnits_if       = 'nUnits';
      array.units_if        = 'units';
      array.EvaluateFunc_if = 'EvalUnit';
    end
    
    % Destructor
    function Del(array)
      delete(array);
    end
    
    % Eval function
    function EvalUnit(array, unitId)
      array.units(unitId).EvalObjFunc;
    end
    
  end
  
end

