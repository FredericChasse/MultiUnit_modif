classdef Pso_t < handle
  % Class Pso_t defines the attributes to be used for simulation
  
  properties
    swarms
    nSwarms
  end
  
  methods (Access = public)
    
    % Constructor
    function pso = Pso_t(nSwarms, nParticles, dimensions)
      if length(nParticles) ~= nSwarms
        error('Must specify nParticles for all swarms');
      end
      if length(dimensions) ~= nSwarms
        error('Must specify dimension for all swarms');
      end
      
      pso.nSwarms = nSwarms;
      
      pso.swarms = Swarm_t.empty;
      for iSwarm = 1 : nSwarms
        pso.swarms(iSwarm) = Swarm_t(iSwarm, nParticles(iSwarm), dimensions(iSwarm));
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

