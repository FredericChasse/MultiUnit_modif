classdef Mfc_t < SimPkg.UnitPkg.AbstractUnitInterface_t
  
  properties
    id
    rext
    dynamics
    pout
    beta
    gamma
    s0
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
    function mfc = Mfc_t(id)
      import SimEnvironmentPkg.UnitPkg.*
      mfc.id          = id;
      mfc.rext        = 0;
      mfc.s0          = 0;
      mfc.pout        = 0;
      mfc.beta        = 0;
      mfc.gamma       = 0;
      mfc.dynamics    = [20.8395 498.2432 2.0000 0.0412];
      % mfcDynamics   = [20.8395  498.2432    2.0000    0.0412];
      % mfcDynamics   = [5.726117682433310 0.030299840936202];
      
      % Class interface
      mfc.id_if         = 'id';
      mfc.unitInput_if  = 's0';
      mfc.pos_if        = 'rext';
      mfc.fitness_if    = 'pout';
      mfc.beta_if       = 'beta';
      mfc.gamma_if      = 'gamma';
    end
    
    % Destructor
    function Del(mfc)
      delete(mfc);
    end
    
  end
  
end

