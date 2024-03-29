classdef PsoPno_t < AlgoPkg.AbstractAlgoInterface_t
% classdef Pso_t < handle
  % Class Pso_t defines the attributes to be used for simulation
  
  properties
    id
    paraSwarms
    nParaSwarms
    seqSwarms
    nSeqSwarms
    unitArray
    simData
    nSimData
    nIterations
    realTimeElapsed
    unitEvalTime
    classifier
    pno
    nPnos
    nAlgos
    swarmParam
    pnoParam
  end
    
  % Algo interface
  properties
    id_if
    unitArray_if
    simData_if
    nSimData_if
    realTimeElapsed_if
    RunAlgoFunc_if
  end
  
  methods (Access = public)
    
    % Constructor
    function pso = PsoPno_t(id, unitArray)
      import AlgoPkg.PsoPnoPkg.*
      
      pso.nIterations     = 0;
      
      pso.id              = id;
      pso.unitArray       = unitArray;
      pso.realTimeElapsed = 0;
      pso.unitEvalTime    = unitArray.unitEvalTime;
      pso.pno             = Pno_t.empty;
      pso.classifier      = Classifier_t(unitArray, 10);

      pso.nPnos           = 0;
      pso.nSeqSwarms      = 0;
      pso.nParaSwarms     = 1;
      pso.paraSwarms      = ParaPsoSwarm_t.empty;
      pso.seqSwarms       = ParaPsoSwarm_t.empty;
      pso.paraSwarms(1)   = ParaPsoSwarm_t(1, unitArray, PsoSimData_t);
      pso.simData{1}      = {pso.paraSwarms(1).simData};
      pso.nSimData        = 1;
      pso.nAlgos          = 1;
      
      % Swarm parameters
      pso.swarmParam.c1          = 0.5;
      pso.swarmParam.c2          = 1.2;
      pso.swarmParam.omega       = 0.3;
      pso.swarmParam.decimals    = 4;
      pso.swarmParam.posRes      = 0.1;
      pso.swarmParam.posMin      = 10;
      pso.swarmParam.posMax      = 350;
      pso.swarmParam.ssOscAmp    = 0.01; % Steady-state defined @�1% oscillation
      pso.swarmParam.nSamples4ss = 5;   % For that number of iterations
      pso.swarmParam.margin      = 0.03;
      
      % P&O parameters
      pso.pnoParam.delta     = 5;
      pso.pnoParam.umin      = 1;
      pso.pnoParam.umax      = 1000;
      pso.pnoParam.oscAmp    = 2;
      pso.pnoParam.nSamples  = 7;
      pso.pnoParam.margin    = .03;
      
      % Algo interface
      pso.id_if               = 'id';
      pso.unitArray_if        = 'unitArray';
      pso.realTimeElapsed_if  = 'realTimeElapsed';
      pso.simData_if          = 'simData';
      pso.nSimData_if         = 'nSimData';
      pso.RunAlgoFunc_if      = 'RunPsoPno';
    end
    
    % Destructor
    function Del(pso)
      delete(pso);
    end
    
    % Add existing para swarm
    function AddParaSwarm(pso, s)
      if isempty(s)
        error('Empty swarm');
      end
      pso.nParaSwarms = pso.nParaSwarms + 1;
      pso.paraSwarms(pso.nParaSwarms) = s;
      pso.paraSwarms(pso.nParaSwarms).id = pso.nParaSwarms;
    end
    
    % Add existing seq swarm
    function AddSeqSwarm(pso, s)
      if isempty(s)
        error('Empty swarm');
      end
      pso.nSeqSwarms = pso.nSeqSwarms + 1;
      pso.seqSwarms(pso.nSeqSwarms) = s;
      pso.seqSwarms(pso.nSeqSwarms).id = pso.nSeqSwarms;
    end
    
    % Create para swarms
    function swarms = CreateParaSwarms(pso, nSwarms, nParticles, unitArrays)
      import AlgoPkg.PsoPnoPkg.*
      swarms = ParaPsoSwarm_t.empty;
      if length(nParticles) ~= nSwarms
        error('Must specify nParticles for all swarms');
      end
      if length(unitArrays) ~= nSwarms
        error('Must specify a unit array for each swarm!');
      end
      
      iArray = 0;
      for iSwarm = pso.nParaSwarms + 1 : pso.nParaSwarms + nSwarms
        iArray = iArray + 1;
        pso.paraSwarms(iSwarm) = ParaPsoSwarm_t(iSwarm, unitArrays(iArray), PsoSimData_t);
        pso.nParaSwarms = pso.nParaSwarms + 1;
        swarms(end+1) = pso.paraSwarms(pso.nParaSwarms);
      end
    end
    
    % Create seq swarms
    function swarms = CreateSeqSwarms(pso, nSwarms, nParticles, unitArrays)
      import AlgoPkg.PsoPnoPkg.*
      swarms = ParaPsoSwarm_t.empty;
      if length(nParticles) ~= nSwarms
        error('Must specify nParticles for all swarms');
      end
      if length(unitArrays) ~= nSwarms
        error('Must specify a unit array for each swarm!');
      end
      
      iArray = 0;
      for iSwarm = pso.nSeqSwarms + 1 : pso.nSeqSwarms + nSwarms
        iArray = iArray + 1;
        pso.seqSwarms(iSwarm) = ParaPsoSwarm_t(iSwarm, unitArrays(iArray), PsoSimData_t);
        pso.nSeqSwarms = pso.nSeqSwarms + 1;
        swarms(end+1) = pso.seqSwarms(pso.nSeqSwarms);
      end
    end
    
    % Create P&O
    function pno = CreatePno(pso, unitArray)
      import AlgoPkg.PsoPnoPkg.*
      pso.nPnos = pso.nPnos + 1;
      pso.pno(pso.nPnos) = Pno_t(pso.nPnos, unitArray);
      pno = pso.pno(pso.nPnos);
    end
    
    % Remove certain para swarms
    function RemoveParaSwarms(pso,idx)
      if ~isempty(find(idx > pso.nParaSwarms)) || ~isempty(find(idx < 0))
        error('No swarms with at one or more of these indexes.');
      end
      idx = sort(idx);
      for i = length(idx) : -1 : 1
        pso.ShiftParaSwarmsIdLeft(idx(i));
        pso.paraSwarms(idx(i)).Del;
        pso.paraSwarms(idx(i)) = [];
        pso.nParaSwarms = pso.nParaSwarms - 1;
      end
    end
    
    % Remove certain seq swarms
    function RemoveSeqSwarms(pso,idx)
      if ~isempty(find(idx > pso.nSeqSwarms)) || ~isempty(find(idx < 0))
        error('No swarms with at one or more of these indexes.');
      end
      idx = sort(idx);
      for i = length(idx) : -1 : 1
        pso.ShiftSeqSwarmsIdLeft(idx(i));
        pso.seqSwarms(idx(i)).Del;
        pso.seqSwarms(idx(i)) = [];
        pso.nSeqSwarms = pso.nSeqSwarms - 1;
      end
    end
    
    % Remove certain P&O
    function RemovePno(pso,idx)
      if ~isempty(find(idx > pso.nPnos)) || ~isempty(find(idx < 0))
        error('No P&O with at one or more of these indexes.');
      end
      idx = sort(idx);
      for i = length(idx) : -1 : 1
        pso.ShiftPnoIdLeft(idx(i));
        pso.pno(idx(i)).Del;
        pso.pno(idx(i)) = [];
        pso.nPnos = pso.nPnos - 1;
      end
    end
    
    % Set para swarm coefficients
    function SetParaSwarmParam(pso, swarmId, c1, c2, omega, decimals, posRes, posMin, posMax)
      if swarmId > pso.nParaSwarms || swarmId <= 0
        error('Wrong ID.');
      end
      
      pso.paraSwarms(swarmId).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);
    end
    
    % Set seq swarm coefficients
    function SetSeqSwarmParam(pso, swarmId, c1, c2, omega, decimals, posRes, posMin, posMax)
      if swarmId > pso.nSeqSwarms || swarmId <= 0
        error('Wrong ID.');
      end
      
      pso.seqSwarms(swarmId).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);
    end
    
    % Run Algorithm    
    RunPsoPno(pso, iteration);
    
  end
  
  methods (Access = private)
    
    % Shift the IDs of the P&O instances from a certain index to the left
    % To be called when removing swarms
    function ShiftPnoIdLeft(s,idx)
      if (idx > s.nPnos) || (idx <= 0)
        error('Wrong index.');
      end
      if idx < s.nPnos
        for iPno = s.nPnos : -1 : idx + 1
          s.pno(iPno).id = s.pno(iPno - 1).id;
        end
      end
    end
    
    % Shift the IDs of the para swarms from a certain index to the left
    % To be called when removing swarms
    function ShiftParaSwarmsIdLeft(s,idx)
      if (idx > s.nParaSwarms) || (idx <= 0)
        error('Wrong index.');
      end
      if idx < s.nParaSwarms
        for iSwarm = s.nParaSwarms : -1 : idx + 1
          s.paraSwarms(iSwarm).id = s.paraSwarms(iSwarm - 1).id;
        end
      end
    end
    
    % Shift the IDs of the seq swarms from a certain index to the left
    % To be called when removing swarms
    function ShiftSeqSwarmsIdLeft(s,idx)
      if (idx > s.nSeqSwarms) || (idx <= 0)
        error('Wrong index.');
      end
      if idx < s.nSeqSwarms
        for iSwarm = s.nSeqSwarms : -1 : idx + 1
          s.seqSwarms(iSwarm).id = s.seqSwarms(iSwarm - 1).id;
        end
      end
    end
    
  end
  
end

