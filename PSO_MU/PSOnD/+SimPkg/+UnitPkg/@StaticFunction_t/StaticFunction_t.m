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
    function f = StaticFunction_t(id)
      f.id          = id;
      f.d           = 0;
      f.j           = 0;
      f.a           = -0.002;
      f.dopt        = 100;
      f.jopt        = 20;
      f.beta        = 0;
      f.gamma       = 0;
      f.unitInput   = [0 0];
      
      % Class interface
      f.id_if         = 'id';
      f.unitInput_if  = 'unitInput';
      f.pos_if        = 'd';
      f.fitness_if    = 'j';
      f.beta_if       = 'beta';
      f.gamma_if      = 'gamma';
    end
    
    % Destructor
    function Del(f)
      delete(f);
    end
    
    function EvalObjFunc(f)
      f.j = f.a .* (f.d - f.dopt + f.unitInput(1)).^2 + f.jopt + f.unitInput(2);
    end
    
  end
  
end

