classdef Pso_t < AlgoPkg.AbstractAlgoInterface_t
% classdef Pso_t < handle
  % Class Pso_t defines the attributes to be used for simulation
  
  properties
    id
    swarms
    nSwarms
    unitArray
    simData
    nSimData
    realTimeElapsed
    unitEvalTime
    psoType
    
    % Algo interface
    id_if
    unitArray_if
    simData_if
    nSimData_if
    realTimeElapsed_if
    RunAlgoFunc_if
  end
  
  methods (Access = public)
    
    % Constructor
    function pso = Pso_t(id, nParticles, unitArray, psoType)
      import AlgoPkg.PsoPkg.*
      
      pso.id              = id;
      pso.unitArray       = unitArray;
      pso.nSwarms         = 1;
      pso.swarms          = PsoSwarm_t.empty;
      pso.psoType         = psoType;
      
      switch pso.psoType
        case { PsoType.PSO_ND_SINGLE_SWARM, PsoType.PSO_ND_MULTI_SWARM}
          dimension = unitArray.nUnits;
        case PsoType.PARALLEL_PSO
          dimension = 1;
          nParticles = unitArray.nUnits;
        case PsoType.PSO_1D
          dimension = 1;
        otherwise
          error('Must define a valid PSO type!')
      end
      
      pso.swarms(1)       = PsoSwarm_t(1, nParticles, unitArray, PsoSimData_t, dimension);
      pso.simData{1}      = {pso.swarms(1).simData};
      pso.nSimData        = 1;
      pso.realTimeElapsed = 0;
      pso.unitEvalTime    = unitArray.unitEvalTime;
      
      % Algo interface
      pso.id_if               = 'id';
      pso.unitArray_if        = 'unitArray';
      pso.realTimeElapsed_if  = 'realTimeElapsed';
      pso.simData_if          = 'simData';
      pso.nSimData_if         = 'nSimData';
      
      switch pso.psoType
        case { PsoType.PSO_ND_SINGLE_SWARM, PsoType.PSO_ND_MULTI_SWARM}
          pso.RunAlgoFunc_if    = 'RunPso';
        case PsoType.PARALLEL_PSO
          pso.RunAlgoFunc_if    = 'RunParaPso';
        case PsoType.PSO_1D
          error('PSO 1D not implemented!')
        otherwise
          error('Must define a valid PSO type!')
      end
    end
    
    % Destructor
    function Del(pso)
      delete(pso);
    end
    
    % Add existing swarm
    function AddSwarm(pso, s)
      if isempty(s)
        error('Empty swarm');
      end
      pso.nSwarms = pso.nSwarms + 1;
      pso.swarms(pso.nSwarms) = s;
      pso.swarms(pso.nSwarms).id = pso.nSwarms;
    end
    
    % Create swarms
    function CreateSwarms(pso, nSwarms, nParticles, dimensions)
      if length(dimensions) ~= nSwarms
        error('Must specify dimensions for all swarms');
      end
      if length(nParticles) ~= nSwarms
        error('Must specify nParticles for all swarms');
      end
      
      for iSwarm = pso.nSwarms + 1 : pso.nSwarms + nSwarms
        pso.swarms(iSwarm) = Swarm_t(iSwarm, nParticles(iSwarm), dimensions(iSwarm), 0, 0, 0, 0, 0);
        pso.nSwarms = pso.nSwarms + 1;
      end
    end
    
    % Remove certain swarms
    function RemoveSwarms(pso,idx)
      if ~isempty(find(idx > pso.nSwarms)) || ~isempty(find(idx < 0))
        error('No swarms with at one or more of these indexes.');
      end
      idx = sort(idx);
      for i = length(idx) : -1 : 1
        pso.ShiftSwarmsIdLeft(idx(i));
        pso.swarms(idx(i)).Del;
        pso.swarms(idx(i)) = [];
        pso.nSwarms = pso.nSwarms - 1;
      end
    end
    
    % Set swarm coefficients
    function SetSwarmParam(pso, swarmId, c1, c2, omega, decimals, posRes, posMin, posMax)
      if swarmId > pso.nSwarms || swarmId <= 0
        error('Wrong ID.');
      end
      
      pso.swarms(swarmId).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);
    end
    
    % Run Algorithm    
    RunPso(pso, iteration);
    
  end
  
  methods (Access = private)
    
    % Shift the IDs of the swarms from a certain index to the left
    % To be called when removing swarms
    function ShiftSwarmsIdLeft(s,idx)
      if (idx > s.nSwarms) || (idx <= 0)
        error('Wrong index.');
      end
      if idx < s.nSwarms
        for iSwarm = s.nSwarms : -1 : idx + 1
          s.swarms(iSwarm).id = s.swarms(iSwarm - 1).id;
        end
      end
    end
    
  end
  
end

