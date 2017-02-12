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
    realTime_if
    integrationTime_if
    EvaluateFunc_if
    SplitArrayFunc_if
  end
  
  methods
    
    % Constructor
    function array = Array_t(obj)
      import SimPkg.UnitPkg.*
      
      array.obj = obj;
      
      % From class interface
      array.id_if               = obj.id_if;
      array.nUnits_if           = obj.nUnits_if;
      array.units_if            = obj.units_if;
      array.realTime_if         = obj.realTime_if;
      array.integrationTime_if  = obj.integrationTime_if;
      array.EvaluateFunc_if     = obj.EvaluateFunc_if;
      array.SplitArrayFunc_if   = obj.SplitArrayFunc_if;
      
      % Create array of units based on object received
      array.units = Unit_t.empty;
      for i = 1 : obj.(array.nUnits_if)
        array.units(i) = Unit_t(array.obj.(array.units_if)(i));
      end
    end
    
    function [aSplit, aKeep, idxToKeep] = SplitArray(array, idxToSplit, newId)
      import SimPkg.*
      import SimPkg.ArrayPkg.*
      import SimPkg.UnitPkg.*
      
      [aSplit, aKeep, idxToKeep] = array.obj.(array.SplitArrayFunc_if)(idxToSplit, newId);
      aSplit = Array_t(aSplit);
      aKeep = Array_t(aKeep);
    end
    
    % Destructor
    function Del(array)
      delete(array);
    end
    
    function EvalUnit(array, id)
      array.obj.(array.EvaluateFunc_if)(id);
      array.units(id).AddMemSample(array.units(id).pos, array.units(id).fitness);
%       array.units(id).nUnitEval = array.units(id).nUnitEval + 1;
%       array.units(id).jmem(array.units(id).nUnitEval) = array.units(id).fitness;
%       array.units(id).dmem(array.units(id).nUnitEval) = array.units(id).pos;
    end
    
    function id = id(array)
      id = array.obj.(array.id_if);
    end
    
    function nUnits = nUnits(array)
      nUnits = array.obj.(array.nUnits_if);
    end
    
    function unitEvalTime = unitEvalTime(array)
      unitEvalTime = array.obj.(array.integrationTime_if);
    end
    
  end
  
end

