classdef ParaPso_t < AlgoPkg.AbstractAlgoInterface_t
% classdef Pso_t < handle
  % Class Pso_t defines the attributes to be used for simulation
  
  properties
    id
    swarms
    nSwarms
    unitArray
    simData
    nSimData
    nIterations
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
    function pso = ParaPso_t(id, unitArray, psoType)
      import AlgoPkg.PsoPkg.*
      
      if (psoType ~= PsoType.PARALLEL_PSO) && (psoType ~= PsoType.PARALLEL_PSO_PBEST_ABS) && (psoType ~= PsoType.PSO_1D)
        error('Wrong algorithm!')
      end
      
      pso.nIterations     = 0;
      
      pso.id              = id;
      pso.unitArray       = unitArray;
      pso.psoType         = psoType;
      pso.realTimeElapsed = 0;
      pso.unitEvalTime    = unitArray.unitEvalTime;

      if psoType == PsoType.PARALLEL_PSO
        pso.nSwarms         = 1;
        pso.swarms          = ParaPsoSwarm_t.empty;
        pso.swarms(1)       = ParaPsoSwarm_t(1, unitArray, PsoSimData_t);
        pso.simData{1}      = {pso.swarms(1).simData};
        pso.nSimData        = 1;
      elseif psoType == PsoType.PSO_1D
        pso.nSwarms         = unitArray.nUnits;
        pso.swarms          = ParaPsoSwarm_t.empty;
        singleArrays = unitArray.empty;
        for iUnit = 1 : unitArray.nUnits
          [singleArrays(iUnit), aKeep, idxToKeep] = unitArray.SplitArray(iUnit, iUnit);
          pso.swarms (iUnit) = ParaPsoSwarm_t(iUnit, singleArrays(iUnit), PsoSimData_t);
          pso.simData{iUnit} = {pso.swarms(iUnit).simData};
        end
        pso.nSimData        = pso.nSwarms;
      else % PARALLEL_PSO_PBEST_ABS
        pso.nSwarms         = 1;
        pso.swarms          = ParaPsoSwarm_t.empty;
        pso.swarms(1)       = ParaPsoSwarm_t(1, unitArray, PsoSimData_t);
        pso.simData{1}      = {pso.swarms(1).simData};
        pso.nSimData        = 1;
      end
      
      % Algo interface
      pso.id_if               = 'id';
      pso.unitArray_if        = 'unitArray';
      pso.realTimeElapsed_if  = 'realTimeElapsed';
      pso.simData_if          = 'simData';
      pso.nSimData_if         = 'nSimData';
      
      if psoType == PsoType.PARALLEL_PSO
        pso.RunAlgoFunc_if    = 'RunParaPso';
      elseif psoType == PsoType.PSO_1D
        pso.RunAlgoFunc_if    = 'RunPso1D';
      else % PARALLEL_PSO_PBEST_ABS
        pso.RunAlgoFunc_if    = 'RunParaPsoWithPbestAbs';
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
    function CreateSwarms(pso, nSwarms, nParticles, unitArrays)
      if length(nParticles) ~= nSwarms
        error('Must specify nParticles for all swarms');
      end
      if length(unitArrays) ~= nSwarms
        error('Must specify a unit array for each swarm!');
      end
      
      for iSwarm = pso.nSwarms + 1 : pso.nSwarms + nSwarms
        pso.swarms(iSwarm) = ParaPsoSwarm_t(iSwarm, nParticles(iSwarm), unitArrays(iSwarm));
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
    RunParaPso(pso, iteration);
    
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

