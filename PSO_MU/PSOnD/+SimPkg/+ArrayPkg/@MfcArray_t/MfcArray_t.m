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
    SplitArrayFunc_if
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
      array.SplitArrayFunc_if = 'SplitArray';
    end
    
    % Destructor
    function Del(mfcArray)
      delete(mfcArray);
    end
    
    function [a1, a2] = SplitArray(mfcs, idxToSplit, newId)
      import SimPkg.*
      import SimPkg.ArrayPkg.*
      import SimPkg.UnitPkg.*
      
      idxToKeep = [];
      for iUnit = 1 : mfcs.nUnits
        if isempty(find(idxToSplit == iUnit, 1))
          idxToKeep = [idxToKeep iUnit]; %#ok<AGROW>
        end
      end
      
      nUnitsToSplit = length(idxToSplit);
      nUnitsToKeep  = length(idxToKeep );
      
      a1 = MfcArray_t(newId    , nUnitsToSplit);
      a2 = MfcArray_t(newId + 1, nUnitsToKeep);
      
      for iUnit = 1 : nUnitsToSplit
        a1.units(iUnit).Del;
        a1.units(iUnit) = mfcs.units(idxToSplit(iUnit));
      end
      
      for iUnit = 1 : nUnitsToKeep
        a2.units(iUnit).Del;
        a2.units(iUnit) = mfcs.units(idxToKeep(iUnit));
      end
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

