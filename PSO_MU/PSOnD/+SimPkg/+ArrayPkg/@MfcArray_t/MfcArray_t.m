classdef MfcArray_t < SimPkg.ArrayPkg.AbstractArrayInterface_t
  
  properties
    id
    units
    nUnits
    mfcModel
    realTimeElapsed
    integrationTime
    odeOptions
  end
  
  %Class interface
  properties
    id_if
    nUnits_if
    units_if
    realTime_if
    integrationTime_if
    EvaluateFunc_if
    SplitArrayFunc_if
    AddUnitToArray_if
  end
  
  methods (Access = public)
    
    % Constructor
    function array = MfcArray_t(id, nUnits, integrationTime, mfcModel)
      import SimPkg.UnitPkg.*
      
      array.id              = id;
      array.realTimeElapsed = 0;
      
      array.units = Mfc_t.empty;
      for iMfc = 1 : nUnits
        array.units(iMfc) = Mfc_t(iMfc, mfcModel);
      end
      array.nUnits          = nUnits;
      array.integrationTime = integrationTime;
      array.odeOptions      = odeset('RelTol',1e-6,'AbsTol',1e-9);
      array.mfcModel        = mfcModel;
      
      % Class interface
      array.id_if               = 'id';
      array.nUnits_if           = 'nUnits';
      array.units_if            = 'units';
      array.realTime_if         = 'realTimeElapsed';
      array.integrationTime_if  = 'integrationTime';
      array.EvaluateFunc_if     = 'EvaluateMfc';
      array.SplitArrayFunc_if   = 'SplitArray';
      array.AddUnitToArray_if   = 'AddUnitToArray';
    end
    
    % Destructor
    function Del(mfcArray)
      delete(mfcArray);
    end
    
    function [aSplit, aKeep, idxToKeep] = SplitArray(mfcs, idxToSplit, newId)
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
      
      aSplit = MfcArray_t(newId    , nUnitsToSplit, mfcs.integrationTime, mfcs.mfcModel);
      aKeep  = MfcArray_t(newId + 1, nUnitsToKeep , mfcs.integrationTime, mfcs.mfcModel);
      
      for iUnit = 1 : nUnitsToSplit
        aSplit.units(iUnit).Del;
        aSplit.units(iUnit) = mfcs.units(idxToSplit(iUnit));
      end
      
      for iUnit = 1 : nUnitsToKeep
        aKeep.units(iUnit).Del;
        aKeep.units(iUnit) = mfcs.units(idxToKeep(iUnit));
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
      [time, dynamics] = ode15s(mfcs.mfcModel, [0 mfcs.integrationTime], mfcs.units(id).dynamics, mfcs.odeOptions, mfcs.units(id).s0, mfcs.units(id).rext);
      mfcs.units(id).dynamics = dynamics(end, :);
      timeElapsed = time(end);
      mfcs.realTimeElapsed = mfcs.realTimeElapsed+ timeElapsed;
      fh = str2func(mfcs.mfcModel);
      [~, mfcs.units(id).pout] = fh(mfcs.integrationTime, mfcs.units(id).dynamics, mfcs.odeOptions, mfcs.units(id).s0, mfcs.units(id).rext);
    end
    
    function AddUnitToArray(mfcs, unit)
      mfcs.nUnits = mfcs.nUnits + 1;
      mfcs.units(mfcs.nUnits) = unit;
    end
    
  end
  
end

