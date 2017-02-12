classdef StaticFunction_t < SimPkg.UnitPkg.AbstractUnitInterface_t
  
  properties
    id
    d
    j
    a
    dopt
    jopt
    beta
    gamma
    unitInput % [beta gamma]
    dmem
    jmem
    nUnitEval
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
    function f = StaticFunction_t(id)
      f.id          = id;
      f.d           = 0;
      f.j           = 0;
      f.a           = -0.000055;
      f.dopt        = 325;
      f.jopt        = 31;
%       f.a           = -0.002;
%       f.dopt        = 100;
%       f.jopt        = 20;
      f.beta        = 0;
      f.gamma       = 0;
      f.unitInput   = [0 0];
      
      f.dmem = zeros(10000, 1);
      f.jmem = zeros(10000, 1);
      f.nUnitEval = 0;
      
      % Class interface
      f.id_if         = 'id';
      f.unitInput_if  = 'unitInput';
      f.pos_if        = 'd';
      f.fitness_if    = 'j';
      f.beta_if       = 'beta';
      f.gamma_if      = 'gamma';
      f.dmem_if       = 'dmem';
      f.jmem_if       = 'jmem';
      f.nUnitEval_if  = 'nUnitEval';
    end
    
    % Destructor
    function Del(f)
      delete(f);
    end
    
    function EvalObjFunc(f)
      f.j = f.a .* (f.d - f.dopt + f.unitInput(1) + f.beta)^2 + f.jopt + f.unitInput(2) + f.gamma;
    end
    
  end
  
end

