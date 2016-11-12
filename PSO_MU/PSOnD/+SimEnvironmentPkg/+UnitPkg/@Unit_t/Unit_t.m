% classdef Unit_t < matlab.mixin.Heterogeneous & handle
classdef Unit_t < UnitPkg.UnitInterface_t
  
  properties
    % Class interface
    id
    perturbVar
    posVar
    fitnessVar
  end
  
  properties
    obj
  end
  
  methods
    
    % Constructor
    function unit = Unit_t(obj)
      unit.obj        = obj;
      
      % Class interface
      unit.id         = obj.id;
      unit.perturbVar = obj.perturbVar;
      unit.posVar     = obj.posVar;
      unit.fitnessVar = obj.fitnessVar;
    end
    
    % Destructor
    function Del(unit)
      delete(unit);
    end
    
    function ApplyPerturb(unit, perturbAmp)
      unit.obj.(unit.perturbVar) = unit.obj.(unit.perturbVar) + perturbAmp;
    end
    
    function SetPos(unit, pos)
      unit.obj.(unit.posVar) = pos;
    end
    
    function pos = GetPos(unit)
      pos = unit.obj.(unit.posVar);
    end
    
    function fitness = GetFitness(unit)
      fitness = unit.obj.(unit.fitnessVar);
    end
    
    function SetFitness(unit, fitness)
      unit.obj.(unit.fitnessVar) = fitness;
    end
    
  end
  
end