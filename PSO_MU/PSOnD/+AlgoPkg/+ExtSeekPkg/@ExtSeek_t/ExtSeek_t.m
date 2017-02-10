classdef ExtSeek_t < AlgoPkg.AbstractAlgoInterface_t
  % Class ExtSeek_t defines the attributes to be used for simulation
  % for extremum seeking algorithm
  
  properties
    id
    unitArray
    simData
    nSimData
    nInstances
    instances
    realTimeElapsed
    unitEvalTime
    
    % Algo interface
    id_if
    unitArray_if
    realTimeElapsed_if
    simData_if
    nSimData_if
    RunAlgoFunc_if
  end
  
  methods
    
    % Constructor
    function es = ExtSeek_t(id, unitArray)
      import AlgoPkg.ExtSeekPkg.*
      
      es.id               = id;
      es.realTimeElapsed  = 0;
      es.unitEvalTime     = unitArray.unitEvalTime;
      es.unitArray        = unitArray;
%       es.simData          = {};
      es.nSimData         = 0;
      es.nInstances       = unitArray.nUnits;
      
      es.instances = ExtSeekInstance_t.empty;
      for i = 1 : es.nInstances
        es.instances(i) = ExtSeekInstance_t(i, ExtSeekSimData_t);
        es.nSimData = es.nSimData + 1;
        es.simData{i} = {es.instances(i).simData};
      end
      
      % Algo interface
      es.id_if              = 'id';
      es.unitArray_if       = 'unitArray';
      es.realTimeElapsed_if = 'realTimeElapsed';
      es.simData_if         = 'simData';
      es.nSimData_if        = 'nSimData';
      es.RunAlgoFunc_if     = 'RunExtSeek';
    end
    
    % Destructor
    function Del(es)
      delete(es);
    end
    
    % Run Algorithm    
    RunExtSeek(es, iteration);
    
    % Set all parameters of all instances
    function SetInstancesParameters(es, ap, wp, wl, wh, k, umin, umax, uInit)
      for i = 1 : es.nInstances
        es.instances(i).SetInstanceParameters(ap, wp, wl, wh, k, umin, umax, uInit);
      end
    end
    
  end
  
  methods (Access = private, Static)
    
    % Discrete integrator function
    [y] = TustinZ( u, up, yp, T );
    
    % Discrete high pass filter
    [y] = HpfZ(u, up, yp, T, wh);
    
    % Discrete low pass filter
    [y] = LpfZ(u, up, yp, T, wl);
    
  end
  
end

