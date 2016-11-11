classdef MfcArray_t < handle
  
  properties
    units
    nUnits
    integrationTime
    odeOptions
  end
  
  methods (Access = public)
    
    % Constructor
    function array = MfcArray_t(nUnits)
      array.units = Mfc_t.empty;
      for iMfc = 1 : nUnits
        array.units(iMfc) = Mfc_t(iMfc);
      end
      array.nUnits          = nUnits;
      array.integrationTime = 0;
      array.odeOptions      = odeset('RelTol',1e-6,'AbsTol',1e-9);
    end
    
    % Destructor
    function Del(mfcArray)
      delete(mfcArray);
    end
    
    function ComputeBetaGamma(mfcs, ids, meanRext, meanPout)
      % Using first MFC as reference
      for iUnit = 2 : length(ids)
        mfcs.units(ids(iUnit)).beta  = meanRext(1) - meanRext(iUnit);
        mfcs.units(ids(iUnit)).gamma = meanPout(1) - meanPout(iUnit);
      end
    end
    
    function timeElapsed = EvaluateMfc(mfcs, id)
      [time, dynamics] = ode15s('mfcModel', [0 mfcs.integrationTime], mfcs.units(id).dynamics, mfcs.odeOptions, mfcs.units(id).s0, mfcs.units(id).rext);
      mfcs.units(id).dynamics = dynamics(end, :);
      timeElapsed = time(end);
      [~, mfcs.units(id).pout] = mfcModel(mfcs.integrationTime, mfcs.units(id).dynamics, mfcs.odeOptions, mfcs.units(id).s0, mfcs.units(id).rext);
    end
    
  end
  
end

