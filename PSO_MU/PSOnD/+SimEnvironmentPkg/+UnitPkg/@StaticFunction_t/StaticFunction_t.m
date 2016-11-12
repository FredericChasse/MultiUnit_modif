classdef StaticFunction_t < UnitPkg.UnitInterface_t
  
  properties
    id
    d
    j
    betaGamma
    
    % Class interface
    perturbVar
    posVar
    fitnessVar
  end
  
  methods
    
    % Constructor
    function f = StaticFunction_t(id)
      f.id          = id;
      f.d           = 0;
      f.j           = 0;
      f.betaGamma   = [0 0];
      
      % Class interface
      f.perturbVar  = 'betaGamma';
      f.posVar      = 'd';
      f.fitnessVar  = 'j';
    end
    
    % Destructor
    function Del(f)
      delete(f);
    end
    
  end
  
end

