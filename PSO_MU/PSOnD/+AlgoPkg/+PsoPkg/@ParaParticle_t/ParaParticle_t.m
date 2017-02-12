classdef ParaParticle_t < handle
  
  properties
    id
    pbest
    pos
    perturbPos % Used in Parallel PSO for perturbing the particle
    curSpeed
    prevSpeed
    oSentinelWarning
    state
    steadyState
  end
  
  methods (Access = public)
    
    % Constructor
    function p = ParaParticle_t(id)
      import AlgoPkg.Position_t;
      import AlgoPkg.PsoPkg.ParticleState;
      import AlgoPkg.SteadyState_t;
      p.id                      = id;
      p.pbest                   = Position_t(1);
      p.pos                     = Position_t(1);
      p.curSpeed                = 0;
      p.prevSpeed               = 0;
      p.oSentinelWarning        = 0;
      p.state                   = ParticleState.SEARCHING;
      p.steadyState             = SteadyState_t.empty;
      p.perturbPos.d            = 0;
      p.perturbPos.j            = 0;
      p.perturbPos.dminus       = 0;
      p.perturbPos.dpos         = 0;
      p.perturbPos.jminus       = 0;
      p.perturbPos.jpos         = 0;
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
    function SentinelEval(p, margin)
      if p.pos.curPos == p.pos.prevPos
        if abs( (p.pos.curFitness - p.pos.prevFitness) / p.pos.curFitness ) >= margin
          p.oSentinelWarning = 1;
        else
          p.oSentinelWarning = 0;
        end
      else
        p.oSentinelWarning = 0;
      end
    end
    
    function oSentinelWarning = GetSentinelState(p)
      oSentinelWarning = p.oSentinelWarning;
    end
    
    % Set steady state settings
    %======================================================================
    function SetSteadyState(p, oscAmp, nSamples)
      import AlgoPkg.SteadyState_t;
      p.steadyState = SteadyState_t(1, oscAmp, nSamples);
    end
    %//////////////////////////////////////////////////////////////////////
    
  end
  
end

