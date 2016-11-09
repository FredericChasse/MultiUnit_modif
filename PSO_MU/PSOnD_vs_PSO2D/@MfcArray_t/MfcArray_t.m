classdef MfcArray_t < handle
  
  properties
    units
    nMfcs
    integrationTime
    odeOptions
  end
  
  methods (Access = public)
    
    % Constructor
    function array = MfcArray_t(nMfcs)
      array.units = Mfc_t.empty;
      for iMfc = 1 : nMfcs
        array.units(iMfc) = Mfc_t(iMfc);
      end
      array.nMfcs = nMfcs;
      array.integrationTime = 0;
    end
    
    % Destructor
    function Del(mfcArray)
      delete(mfcArray);
    end
    
    function EvaluateMfc(mfcs, id)
      [~, dynamics] = ode15s('mfcModel', [0 mfcs.integrationTime], mfcs.units(id).dynamics, mfcs.odeOptions, mfcs.units(id).s0, mfcs.units(id).rext);
      mfcs.units(id).dynamics = dynamics(end, :);
      [~, mfcs.units(id).pout] = mfcModel(mfcs.integrationTime, mfcs.units(id).dynamics, mfcs.odeOptions, mfcs.units(id).s0, mfcs.units(id).rext);
    end
    
  end
  
end

