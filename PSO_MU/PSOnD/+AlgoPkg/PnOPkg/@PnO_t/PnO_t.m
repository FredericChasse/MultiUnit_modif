classdef PnO_t < AlgoPkg.AbstractAlgoInterface_t
  % Class PnO_t defines the attributes to be used for simulation
  % for P&O algorithm
  
  properties
    id
    unitArray
    simData
    nSimData
    
    % Algo interface
    id_if
    unitArray_if
    RunAlgoFunc_if
  end
  
  methods
    
    % Constructor
    function pno = PnO_t(id, unitArray)
      import AlgoPkg.PnOPkg.*
      
      pno.id          = id;
      pno.unitArray   = unitArray;
      pno.simData     = PoSimData_t;
      
      % Algo interface
      pno.id_if           = 'id';
      pno.unitArray_if    = 'unitArray';
      pno.RunAlgoFunc_if  = 'RunPnO';
    end
    
    % Destructor
    function Del(pno)
      delete(pno);
    end
    
    % Run Algorithm    
    RunPnO(pno, iteration);
    
  end
  
end

