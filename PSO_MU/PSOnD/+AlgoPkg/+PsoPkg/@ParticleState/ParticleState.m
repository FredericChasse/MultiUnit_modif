classdef ParticleState
  %PARTICLESTATE defines the possible states of a particle used in
  %Parallel PSO.
  
  enumeration
    SEARCHING
    PERTURB_OCCURED
    TEST_PBEST
    VALIDATE_OPTIMUM
    STEADY_STATE
    
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

