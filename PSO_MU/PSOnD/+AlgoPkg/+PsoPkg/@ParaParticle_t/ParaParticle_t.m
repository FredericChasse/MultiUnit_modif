classdef ParaParticle_t < handle
  
  properties
    id
    pbest
    oAtOptimum
    pbestAbs
    pos
    optPos % Used in Parallel PSO for perturbing the particle
    curSpeed
    prevSpeed
    jSteady
    oSentinelWarning
    state
    nextState
    steadyState
  end
  
  methods (Access = public)
    
    % Constructor
    function p = ParaParticle_t(id)
      import AlgoPkg.Position_t;
      import AlgoPkg.PsoPkg.ParticleState;
      import AlgoPkg.SteadyState_t;
      p.id                      = id;
      p.oAtOptimum              = 0;
      p.pbest                   = Position_t(1);
      p.pos                     = Position_t(1);
      p.curSpeed                = 0;
      p.prevSpeed               = 0;
      p.pbestAbs.pos            = 0;
      p.pbestAbs.fitness        = 0;
      p.oSentinelWarning        = 0;
      p.state                   = ParticleState.SEARCHING;
      p.nextState               = ParticleState.VALIDATE_OPTIMUM;
      p.steadyState             = SteadyState_t.empty;
      p.jSteady                 = 0;
      p.optPos.dinit            = 0;
      p.optPos.jinit            = 0;
      p.optPos.dminus           = 0;
      p.optPos.dpos             = 0;
      p.optPos.jminus           = 0;
      p.optPos.jpos             = 0;
    end
    
    % Destructor
    function Del(p)
      delete(p);
    end
    
    InitSpeed   ( p, s );
    ComputeSpeed( p, s );
    ComputePbest( p    );
    ComputePos  ( p, s );
    
    function SetFitness (p, f)
      p.pos.prevFitness = p.pos.curFitness;
      p.pos.curFitness  = f;
    end
    
    % Compare previous pos/fitness to current pos/fitness
    %======================================================================
    function SentinelEval(p, margin)
      import AlgoPkg.PsoPkg.ParticleState
      if p.state == ParticleState.STEADY_STATE
        jCompare = p.jSteady;
      else
        jCompare = p.pos.prevFitness;
      end
      if p.pos.curPos == p.pos.prevPos
        if abs( (p.pos.curFitness - jCompare) / p.pos.curFitness ) >= margin
          p.oSentinelWarning = 1;
        else
          p.oSentinelWarning = 0;
        end
      else
        p.oSentinelWarning = 0;
      end
    end
    %======================================================================
    
    %======================================================================
    function oSentinelWarning = GetSentinelState(p)
      oSentinelWarning = p.oSentinelWarning;
    end
    %======================================================================
    
    %======================================================================
    function ResetOptPos(p)
      p.optPos.d      = 0;
      p.optPos.j      = 0;
      p.optPos.dinit  = 0;
      p.optPos.jinit  = 0;
      p.optPos.dminus = 0;
      p.optPos.dpos   = 0;
      p.optPos.jminus = 0;
      p.optPos.jpos   = 0;
    end
    %======================================================================
    
    % Set steady state settings
    %======================================================================
    function SetSteadyState(p, oscAmp, nSamples)
      import AlgoPkg.SteadyState_t;
      p.steadyState = SteadyState_t(1, oscAmp, nSamples);
    end
    %//////////////////////////////////////////////////////////////////////
    
    % Finite State Machine of the particle
    %======================================================================
    [oRemoveParticle] = FsmStep(p, s);
    %//////////////////////////////////////////////////////////////////////
    
    % Randomize position of the particle
    %======================================================================
    InitPos(p, s);
    %//////////////////////////////////////////////////////////////////////
    
  end
  
end

