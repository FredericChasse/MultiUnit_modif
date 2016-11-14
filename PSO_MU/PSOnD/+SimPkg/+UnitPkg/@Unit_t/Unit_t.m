classdef Unit_t < SimPkg.UnitPkg.AbstractUnitInterface_t
  
  properties
    obj
  end
  
  % Class interface
  properties
    id_if
    unitInput_if
    pos_if
    fitness_if
    beta_if
    gamma_if
  end
  
  methods
    
    % Constructor
    function unit = Unit_t(obj)
      unit.obj        = obj;
      
      % Class interface
      unit.id_if        = obj.id_if;
      unit.unitInput_if = obj.unitInput_if;
      unit.pos_if       = obj.pos_if;
      unit.fitness_if   = obj.fitness_if;
      unit.beta_if      = obj.beta_if;
      unit.gamma_if     = obj.gamma_if;
    end
    
    % Destructor
    function Del(unit)
      delete(unit);
    end
    
    function ApplyPerturb(unit, perturbAmp)
      unit.obj.(unit.perturb_if) = unit.obj.(unit.perturb_if) + perturbAmp;
    end
    
    function SetPos(unit, pos)
      unit.obj.(unit.pos_if) = pos;
    end
    
    function pos = GetPos(unit)
      pos = unit.obj.(unit.pos_if);
    end
    
    function fitness = GetFitness(unit)
      fitness = unit.obj.(unit.fitness_if);
    end
    
    function SetFitness(unit, fitness)
      unit.obj.(unit.fitness_if) = fitness;
    end
    
    function id = id(unit)
      id = unit.obj.(unit.id_if);
    end
    
    function unitInput = unitInput(unit)
      unitInput = unit.obj.(unit.unitInput_if);
    end
    
    function pos = pos(unit)
      pos = unit.obj.(unit.pos_if);
    end
    
    function fitness = fitness(unit)
      fitness = unit.obj.(unit.fitness_if);
    end
    
    function beta = beta(unit)
      beta = unit.obj.(unit.beta_if);
    end
    
    function gamma = gamma(unit)
      gamma = unit.obj.(unit.gamma_if);
    end
    
  end
  
end