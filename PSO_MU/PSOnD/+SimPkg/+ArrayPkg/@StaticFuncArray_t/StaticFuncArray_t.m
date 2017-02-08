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
    SplitArrayFunc_if
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
      array.id_if             = 'id';
      array.nUnits_if         = 'nUnits';
      array.units_if          = 'units';
      array.EvaluateFunc_if   = 'EvalUnit';
      array.SplitArrayFunc_if = 'SplitArray';
    end
    
    function [aSplit, aKeep, idxToKeep] = SplitArray(array, idxToSplit, newId)
      import SimPkg.*
      import SimPkg.ArrayPkg.*
      import SimPkg.UnitPkg.*
      
      idxToKeep = [];
      for iUnit = 1 : array.nUnits
        if isempty(find(idxToSplit == iUnit, 1))
          idxToKeep = [idxToKeep iUnit]; %#ok<AGROW>
        end
      end
      
      nUnitsToSplit = length(idxToSplit);
      nUnitsToKeep  = length(idxToKeep );
      
      aSplit = StaticFuncArray_t(newId    , nUnitsToSplit);
      aKeep  = StaticFuncArray_t(newId + 1, nUnitsToKeep);
      
      for iUnit = 1 : nUnitsToSplit
        aSplit.units(iUnit).Del;
        aSplit.units(iUnit) = array.units(idxToSplit(iUnit));
      end
      
      for iUnit = 1 : nUnitsToKeep
        aKeep.units(iUnit).Del;
        aKeep.units(iUnit) = array.units(idxToKeep(iUnit));
      end
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

