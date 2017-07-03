classdef ParticleState
 
  %PARTICLESTATE defines the possible states of a particle used in
  %Parallel PSO.
  
  enumeration
    SEARCHING
    PERTURB_OCCURED
    VALIDATE_OPTIMUM
    STEADY_STATE
    
    % These are used in RunParaPso. To be removed.
    PERTURB_INIT
    PERTURB_MINUS
    PERTURB_POS
    PERTURB_END
  end
  
  properties
  end
  
  methods
  end
  
end

