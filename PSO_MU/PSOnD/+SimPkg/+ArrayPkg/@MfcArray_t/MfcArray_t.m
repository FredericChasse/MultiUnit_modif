classdef MfcArray_t < SimPkg.ArrayPkg.AbstractArrayInterface_t
  
  properties
    id
    units
    nUnits
    integrationTime
    odeOptions
  end
  
  %Class interface
  properties
    id_if
    nUnits_if
    units_if
    EvaluateFunc_if
  end
  
  methods (Access = public)
    
    % Constructor
    function array = MfcArray_t(id, nUnits)
      import SimPkg.UnitPkg.*
      
      array.id            = id;
      
      array.units = Mfc_t.empty;
      for iMfc = 1 : nUnits
        array.units(iMfc) = Mfc_t(iMfc);
      end
      array.nUnits          = nUnits;
      array.integrationTime = 0;
      array.odeOptions      = odeset('RelTol',1e-6,'AbsTol',1e-9);
      
      % Class interface
      array.id_if             = 'id';
      array.nUnits_if         = 'nUnits';
      array.units_if          = 'units';
      array.EvaluateFunc_if   = 'EvaluateMfc';
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
