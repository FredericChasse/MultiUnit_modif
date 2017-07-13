classdef Mfc_t < SimPkg.UnitPkg.AbstractUnitInterface_t
  
  properties
    id
    rext
    dynamics
    pout
    beta
    gamma
    s0
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
    function mfc = Mfc_t(id, mfcModel)
      import SimEnvironmentPkg.UnitPkg.*
      mfc.id          = id;
      mfc.rext        = 100;
      mfc.s0          = 0;
      mfc.pout        = 0;
      mfc.beta        = 0;
      mfc.gamma       = 0;
      if strcmp(mfcModel, 'mfcModel')
        mfc.dynamics    = [20.8395 498.2432 2.0000 0.0412];
      elseif strcmp(mfcModel, 'mfcModelFast')
        mfc.dynamics    = [5.726117682433310 0.030299840936202];
      else
        error('Must define a valid model for MFC')
      end
      
      mfc.dmem = zeros(10000, 1);
      mfc.jmem = zeros(10000, 1);
      mfc.nUnitEval = 0;
      
      % Class interface
      mfc.id_if         = 'id';
      mfc.unitInput_if  = 's0';
      mfc.pos_if        = 'rext';
      mfc.fitness_if    = 'pout';
      mfc.beta_if       = 'beta';
      mfc.gamma_if      = 'gamma';
      mfc.dmem_if       = 'dmem';
      mfc.jmem_if       = 'jmem';
      mfc.nUnitEval_if  = 'nUnitEval';
    end
    
    % Destructor
    function Del(mfc)
      delete(mfc);
    end
    
  end
  
end

