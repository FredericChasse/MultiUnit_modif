% classdef PsoSwarm_t < AlgoPkg.AbstractAlgoInterface_t
classdef PsoSwarm_t < handle
 
  properties
    id
    swarmIteration
    nParticles
    particles
    gbest
    posMin
    posMax
    dimension
    c1
    c2
    omega
    decimals
    posRes
    sentinelMargin
    steadyState
    oMoveParticles
    oResetParticles
    unitArray
    simData
  end
  
  methods (Access = public)
  
    % Constructor
    %======================================================================
    function s = PsoSwarm_t(id, nParticles, unitArray, simData)
      import AlgoPkg.SteadyState_t;
      import AlgoPkg.LinkPkg.*;
      import AlgoPkg.PsoPkg.*
      import AlgoPkg.Position_t;
      s.particles             = Particle_t.empty;
      s.swarmIteration        = 0;
      s.c1                    = 0;
      s.c2                    = 0;
      s.posMin                = 0;
      s.posMax                = 0;
      s.omega                 = 0;
      s.decimals              = 0;
      s.posRes                = 0;
      s.id                    = id;
      s.dimension             = unitArray.nUnits;
      s.sentinelMargin        = 0.05;    % 5% margin for sentinels
      s.steadyState           = SteadyState_t.empty;
      s.nParticles            = 0;
      s.gbest                 = Position_t(s.dimension);
      s.oMoveParticles        = 1;
      s.oResetParticles       = 0;
      s.unitArray             = unitArray;
      s.simData               = simData;
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
        s.particles(iParticle) = Particle_t(iParticle, s.dimension);
        s.nParticles = s.nParticles + 1;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Remove certain particles
    %======================================================================
    function RemoveParticles(s,idx)
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
      speed = zeros(s.nParticles, s.dimension);
      for i = 1 : s.nParticles
        speed(i, :) = s.particles(i).curSpeed;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [pos] = GetParticlesPos(s)
      pos = zeros(s.nParticles, s.dimension);
      for i = 1 : s.nParticles
        pos(i, :) = s.particles(i).pos.curPos;
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
    function [fd] = GetParticlesFitnessDim(s)
      fd = zeros(s.nParticles, s.dimension);
      for i = 1 : s.nParticles
        fd(i, :) = s.particles(i).dimFitness;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [pbest] = GetParticlesPbest(s)
      pbest = zeros(s.nParticles, s.dimension);
      for i = 1 : s.nParticles
        pbest(i, :) = s.particles(i).pbest.curPos;
      end
    end
    %//////////////////////////////////////////////////////////////////////
    
    %======================================================================
    function [gbest] = GetGbest(s)
      gbest = zeros(s.nParticles, s.dimension);
      for i = 1 : s.nParticles
        gbest(i, :) = s.gbest.curPos;
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
    function idx = CheckForDimensionalPerturbation(s, particlesPerturbed)
      idx = [];
      p = s.particles(particlesPerturbed(1));
      for iDim = 1 : s.dimension
        if p.dimFitness(iDim) ~= p.prevDimFitness
          idx = [idx iDim]; %#ok<AGROW>
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
    
    %======================================================================
    function RunIteration(s, iteration)
      
      % Compute pbest and gbest
      %--------------------------------------------------------------------
      for iParticle = 1 : s.nParticles
        s.particles(iParticle).ComputeOverallFitness;
        s.particles(iParticle).ComputePbest;
      end
      s.ComputeGbest;
      %____________________________________________________________________
      
      % Check for steady state
      %--------------------------------------------------------------------
      s.steadyState.AddSample(s.GetParticlesPos);
      s.steadyState.EvaluateSteadyState;
      %____________________________________________________________________
      
      % Check for perturbations
      %--------------------------------------------------------------------
      particlesPerturbed = s.CheckForPerturbation;
      if particlesPerturbed ~= 0 % Perturbation occured
        if s.oMoveParticles == 0
          s.oResetParticles = 1;
          s.oMoveParticles  = 1;
        end
      end
      %____________________________________________________________________
      
      % Compute next positions
      %--------------------------------------------------------------------
      if s.oResetParticles == 1
        s.oResetParticles = 0;
        for iParticle = 1 : s.nParticles
          s.RandomizeParticlesPos();
          s.particles(iParticle).InitSpeed(s);
        end
      else
        if iteration == 1
          for iParticle = 1 : s.nParticles
            s.particles(iParticle).InitSpeed (s);
            s.particles(iParticle).ComputePos(s);
          end
        else
          for iParticle = 1 : s.nParticles
            s.particles(iParticle).ComputeSpeed(s);
            s.particles(iParticle).ComputePos  (s);
          end
        end
      end
      %____________________________________________________________________
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

