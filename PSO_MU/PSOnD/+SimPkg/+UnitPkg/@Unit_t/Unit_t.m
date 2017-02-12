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
    dmem_if
    jmem_if
    nUnitEval_if
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
      unit.dmem_if      = obj.dmem_if;
      unit.jmem_if      = obj.jmem_if;
      unit.nUnitEval_if = obj.nUnitEval_if;
    end
    
    % Destructor
    function Del(unit)
      delete(unit);
    end
    
    function ApplyPerturb(unit, perturbAmp)
      unit.obj.(unit.unitInput_if) = unit.obj.(unit.unitInput_if) + perturbAmp;
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
    
    function nUnitEval = nUnitEval(unit)
      nUnitEval = unit.obj.(unit.nUnitEval_if);
    end
    
    function dmem = dmem(unit, startIdx, endIdx)
      dmem = unit.obj.(unit.dmem_if)(startIdx:endIdx);
    end
    
    function jmem = jmem(unit, startIdx, endIdx)
      jmem = unit.obj.(unit.jmem_if)(startIdx:endIdx);
    end
    
    function AddMemSample(unit, d, j)
      unit.obj.(unit.nUnitEval_if) = unit.obj.(unit.nUnitEval_if) + 1;
      unit.obj.(unit.dmem_if)(unit.obj.(unit.nUnitEval_if)) = d;
      unit.obj.(unit.jmem_if)(unit.obj.(unit.nUnitEval_if)) = j;
    end
    
  end
  
end