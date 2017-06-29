classdef Pno_t < AlgoPkg.AbstractAlgoInterface_t
  %PNO_T Summary of this class goes here
  %   Detailed explanation goes here

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
    function pno = Pno_t(id, unitArray)
      import AlgoPkg.PnoPkg.*

      pno.id               = id;
      pno.realTimeElapsed  = 0;
      pno.unitEvalTime     = unitArray.unitEvalTime;
      pno.unitArray        = unitArray;
  %       es.simData          = {};
      pno.nSimData         = 0;
      pno.nInstances       = unitArray.nUnits;

      pno.instances = PnoInstance_t.empty;
      for i = 1 : pno.nInstances
        pno.instances(i) = PnoInstance_t(i, PnoSimData_t);
        pno.nSimData = pno.nSimData + 1;
        pno.simData{i} = {pno.instances(i).simData};
      end

      % Algo interface
      pno.id_if              = 'id';
      pno.unitArray_if       = 'unitArray';
      pno.realTimeElapsed_if = 'realTimeElapsed';
      pno.simData_if         = 'simData';
      pno.nSimData_if        = 'nSimData';
      pno.RunAlgoFunc_if     = 'RunPno';
    end

    % Destructor
    function Del(pno)
      delete(pno);
    end

    % Run Algorithm    
    RunPno(pno, iteration);

    % Set all parameters of all instances
    function SetInstancesParameters(pno, delta, umin, umax, uInit)
      for i = 1 : pno.nInstances
        pno.instances(i).SetInstanceParameters(delta, umin, umax, uInit);
      end
    end

    % Set all parameters of all instances
    function SetOneInstancesParameters(pno, id, delta, umin, umax, uInit)
      for i = 1 : pno.nInstances
        if pno.instances(i).id == id
          oFoundId = 1;
          break;
        else
          oFoundId = 0;
        end
      end
      if ~oFoundId
        error('No instance with this id');
      end
      pno.instances(i).SetInstanceParameters(delta, umin, umax, uInit);
    end

  end
    
end

