classdef Mfc_t < UnitPkg.UnitInterface_t
  
  properties
    % Class interface
    id
    perturbVar
    posVar
    fitnessVar
  end
  
  properties
    rext
    dynamics
    pout
    beta
    gamma
    s0
  end
  
  methods
    
    % Constructor
    function mfc = Mfc_t(id)
      mfc.rext        = 0;
      mfc.s0          = 0;
      mfc.pout        = 0;
      mfc.beta        = 0;
      mfc.gamma       = 0;
      mfc.dynamics    = [20.8395 498.2432 2.0000 0.0412];
      % mfcDynamics   = [20.8395  498.2432    2.0000    0.0412];
      % mfcDynamics   = [5.726117682433310 0.030299840936202];
      
      % Class interface
      mfc.id          = id;
      mfc.perturbVar  = 's0';
      mfc.posVar      = 'rext';
      mfc.fitnessVar  = 'pout';
    end
    
    % Destructor
    function Del(mfc)
      delete(mfc);
    end
    
  end
  
end

