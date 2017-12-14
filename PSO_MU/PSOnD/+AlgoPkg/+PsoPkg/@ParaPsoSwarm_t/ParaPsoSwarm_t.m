% classdef PsoSwarm_t < AlgoPkg.AbstractAlgoInterface_t
classdef ParaPsoSwarm_t < handle
 
  properties
    id
    iParticle
    swarmIteration
    nParticles
    particles
    gbest
    posMin
    posMax
    c1
    c2
    omega
    decimals
    posRes
    perturbAmp
    sentinelMargin
    nUnitsPerParticle
    minParticles
    steadyState
    oMoveParticles
    oResetParticles
    unitArray
    simData
  end
  
  methods (Access = public)
  
    % Constructor
    %======================================================================
    function s = ParaPsoSwarm_t(id, unitArray, simData, minParticles)
      import AlgoPkg.SteadyState_t;
      import AlgoPkg.PsoPkg.*
      import AlgoPkg.Position_t;
      import AlgoPkg.PsoPkg.ParticleState;
      import SimPkg.ArrayPkg.Array_t
      s.particles             = ParaParticle_t.empty;
      s.swarmIteration        = 0;
      s.iParticle             = 0;
      s.c1                    = 0;
      s.c2                    = 0;
      s.posMin                = 0;
      s.posMax                = 0;
      s.omega                 = 0;
      s.decimals              = 0;
      s.posRes                = 0;
      s.id                    = id;
      s.minParticles          = minParticles;
      s.nUnitsPerParticle     = 1;
      s.perturbAmp            = 15;
      s.sentinelMargin        = 0.03;    % 5% margin for sentinels
      s.steadyState           = SteadyState_t.empty;
      s.nParticles            = 0;
      s.gbest                 = Position_t(1);
      s.oMoveParticles        = 1;
      s.oResetParticles       = 0;
      s.unitArray             = unitArray;
      s.simData               = simData;
      
      nParticles = unitArray.nUnits; %#ok<*PROP>
      if nParticles == 1
        s.nUnitsPerParticle = minParticles;
        nParticles = minParticles;
      else
        while nParticles < s.minParticles
          s.nUnitsPerParticle = s.nUnitsPerParticle * 2;
          nParticles          = nParticles        * 2;
        end
      end
        
      s.CreateParticles(nParticles);
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Destructor
    %======================================================================
    function Del(s)
      delete(s);
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Set steady state settings
    %======================================================================
    function SetSteadyState(s, sizeOfSample, oscAmp, nSamples)
      import AlgoPkg.SteadyState_t;
      s.steadyState = SteadyState_t(sizeOfSample, oscAmp, nSamples);
      for iParticle = 1 : s.nParticles
        s.particles(iParticle).SetSteadyState(oscAmp, nSamples);
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Add existing particle
    %======================================================================
    function AddParticle(s, p)
      s.nParticles = s.nParticles + 1;
      s.particles(s.nParticles) = p;
      s.particles(s.nParticles).id = s.nParticles;
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Create particles
    %======================================================================
    function CreateParticles(s, nParticles)
      import AlgoPkg.PsoPkg.*
      for iParticle = s.nParticles + 1 : s.nParticles + nParticles
        s.particles(iParticle) = ParaParticle_t(iParticle);
        s.nParticles = s.nParticles + 1;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Remove certain particles from swarm without deleting the object
    %======================================================================
    function RemoveParticles(s,idx)
      if ~isempty(find(idx > s.nParticles)) || ~isempty(find(idx < 0))
        error('No particles with at one or more of these indexes.');
      end
      idx = sort(idx);
      for i = length(idx) : -1 : 1
        s.ShiftParticlesIdLeft(idx(i));
        s.particles(idx(i)) = [];
        s.nParticles = s.nParticles - 1;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Delete certain particles from swarm
    %======================================================================
    function DeleteParticles(s,idx)
      if ~isempty(find(idx > s.nParticles)) || ~isempty(find(idx < 0))
        error('No particles with at one or more of these indexes.');
      end
      idx = sort(idx);
      for i = length(idx) : -1 : 1
        s.ShiftParticlesIdLeft(idx(i));
        s.particles(idx(i)).Del;
        s.particles(idx(i)) = [];
        s.nParticles = s.nParticles - 1;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Get the content of certain particles
    %======================================================================
    function p = GetParticles(s,idx)
      import AlgoPkg.PsoPkg.Particle_t
      if ~isempty(find(idx > s.nParticles)) || ~isempty(find(idx < 0))
        error('No particles with at one or more of these indexes.');
      end
      p = Particle_t.empty;
      idx = sort(idx);
      for iParticle = 1 : length(idx)
        p(iParticle) = s.particles(idx(iParticle));
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Set swarm parameters
    %======================================================================
    function SetParam(s, c1, c2, omega, decimals, posRes, posMin, posMax)
      if c1 < 0 || c2 < 0 || omega < 0 || decimals < 0 || posRes < 0 || posMin < 0 || posMax < 0 || posMin >= posMax
        error('Wrong input');
      end
      
      s.c1        = c1;
      s.c2        = c2;
      s.omega     = omega;
      s.decimals  = decimals;
      s.posRes    = posRes;
      s.posMin    = posMin;
      s.posMax    = posMax;
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [speed] = GetParticlesSpeed(s)
      speed = zeros(s.nParticles, 1);
      for i = 1 : s.nParticles
        speed(i) = s.particles(i).curSpeed;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [pos] = GetParticlesPos(s)
      pos = zeros(s.nParticles, 1);
      for i = 1 : s.nParticles
        pos(i) = s.particles(i).pos.curPos;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [f] = GetParticlesFitness(s)
      f = zeros(s.nParticles, 1);
      for i = 1 : s.nParticles
        f(i) = s.particles(i).pos.curFitness;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [pbest] = GetParticlesPbest(s)
      pbest = zeros(s.nParticles, 1);
      for i = 1 : s.nParticles
        pbest(i) = s.particles(i).pbest.curPos;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [gbest] = GetGbest(s)
      gbest = zeros(s.nParticles, 1);
      for i = 1 : s.nParticles
        gbest(i) = s.gbest.curPos;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function idx = CheckForPerturbation(s)
      idx = [];
      nPerturb = 0;
      for iParticle = 1 : s.nParticles
        s.particles(iParticle).SentinelEval(s.sentinelMargin);
        oPerturbOccured = s.particles(iParticle).GetSentinelState;
        if oPerturbOccured == 1
          nPerturb = nPerturb + 1;
          idx(nPerturb) = s.particles(iParticle).id; %#ok<AGROW>
        end
      end
      if isempty(idx)
        idx = 0;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    ComputeGbest(s);
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    RandomizeParticlesPos(s);
    %//////////////////////////////////////////////////////////////////////
    
    RandomizeCertainParticles(s, idx);
    
    %======================================================================
    function SplitUnitArray(s, idxToRemove, pso)
      if ~isempty(idxToRemove)
        if length(idxToRemove) ~= s.unitArray.nUnits
          s.RemoveParticles(idxToRemove);
          
          [aSplit, aKeep, idxToKeep] = pso.unitArray.SplitArray(idxToRemove, pso.nSwarms + 1);
          
          newSwarm = ParaPsoSwarm_t(pso.nSwarms, aSplit, PsoSimData_t);
          
          s.unitArray     = aKeep;

          ss = s.steadyState;
          s.SetSteadyState([s.nParticles 1], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          ss.Del;
          for i = 1 : s.steadyState.nSamplesForSteadyState
            s.steadyState.AddSample(s.GetParticlesPos);
          end
          s.steadyState.EvaluateSteadyState;
          if s.steadyState.oInSteadyState == 1
            s.oMoveParticles = 0;
          end

          newSwarm.SetSteadyState([newSwarm.nParticles 1], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          newSwarm.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
          newSwarm.RandomizeParticlesPos();

          pso.AddSwarm(newSwarm);
          pso.nSimData = pso.nSimData+1;
          pso.simData{pso.nSimData} = {newSwarm.simData};
        else
          s.RandomizeParticlesPos();
          s.oResetParticles = 0;
          s.oMoveParticles  = 1;
        end
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function SplitUnitArrayInto1dArrays(s, idxToRemove, pso)
      import AlgoPkg.PsoPkg.*
      if ~isempty(idxToRemove)
        s.RemoveParticles(idxToRemove);

        idxToRemove = sort(idxToRemove, 'descend');
        idxMem = idxToRemove;
        
        for i = 1 : length(idxMem)
          idxToRemove(i) = s.unitArray.units(idxMem(i)).id;
        end

        aSplit = s.unitArray.empty;

        for iArray = 1 : length(idxToRemove)
          [aSplit(iArray), aKeep, idxToKeep] = pso.unitArray.SplitArray(idxToRemove(iArray), pso.nSwarms + 1);
%           [aSplit(iArray), aKeep, idxToKeep] = s.unitArray.SplitArray(idxToRemove(iArray), pso.nSwarms + 1);
          newSwarm = ParaPsoSwarm_t(pso.nSwarms, aSplit(iArray), PsoSimData_t);
%           s.unitArray = aKeep;

          newSwarm.SetSteadyState([newSwarm.nParticles 1], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
%           newSwarm.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
          newSwarm.SetParam(pso.swarms(1).c1/2, pso.swarms(1).c2/2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
          newSwarm.RandomizeParticlesPos();
          newSwarm.unitArray.units(1).SetPos(newSwarm.particles(1).pos.curPos);

          pso.AddSwarm(newSwarm);
          pso.nSimData = pso.nSimData+1;
          pso.simData{pso.nSimData} = {newSwarm.simData};
        end
        
%         s.unitArray.RemoveUnit(idxToRemove);
        idxToKeep = zeros(pso.nSwarms-1, 1);
        for iSwarm = 2 : pso.nSwarms
          idxToKeep(iSwarm - 1) = pso.swarms(iSwarm).unitArray.units(1).id;
        end
        
%         [aSplit, aKeep, idxToKeep] = pso.unitArray.SplitArray(idxToKeep, 1);
%         [aSplit, aKeep, idxToKeep] = s.unitArray.SplitArray(idxToRemove, 1);
        [aSplit, aKeep, idxToKeep] = s.unitArray.SplitArray(idxMem, 1);
        s.unitArray = aKeep;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
  end
  
  methods (Access = private)
    
    % Shift the IDs of the particles from a certain index to the left
    % To be called when removing particles
    function ShiftParticlesIdLeft(s,idx)
      if (idx > s.nParticles) || (idx <= 0)
        error('Wrong index.');
      end
      if idx < s.nParticles
        for iParticle = s.nParticles : -1 : idx + 1
          s.particles(iParticle).id = s.particles(iParticle - 1).id;
        end
      end
    end
    
  end
  
end

