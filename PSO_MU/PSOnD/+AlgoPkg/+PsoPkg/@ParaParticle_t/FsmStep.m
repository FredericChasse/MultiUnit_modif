function [ oRemoveParticle ] = FsmStep( p, swarm )
import AlgoPkg.PsoPkg.*

if p.steadyState.oInSteadyState && p.state == ParticleState.SEARCHING
  if swarm.unitArray.nUnits == 1
    p.jSteady = p.pos.curFitness;
    p.oAtOptimum = 1;
    p.state = ParticleState.STEADY_STATE;
  else
    p.state = ParticleState.VALIDATE_OPTIMUM;
  end
end

if p.oSentinelWarning == 1
  p.state = ParticleState.PERTURB_OCCURED;
end

switch p.state
  case ParticleState.SEARCHING
    p.ComputeSpeed(swarm);
    p.ComputePos  (swarm);
    oRemoveParticle = 0;
            
  case ParticleState.PERTURB_OCCURED
    p.InitSpeed(swarm);
    p.InitPos  (swarm);
    p.state = ParticleState.SEARCHING;
    oRemoveParticle = 0;
%     oRemoveParticle = 1;
    
  case ParticleState.VALIDATE_OPTIMUM
    if p.optPos.jinit == 0
      p.optPos.jinit  = p.pos.curFitness;
      p.optPos.dinit  = p.pos.curPos;
      p.optPos.dminus = p.pos.curPos - swarm.perturbAmp;
      p.optPos.dpos   = p.pos.curPos + swarm.perturbAmp;

      p.pos.prevPos   = p.pos.curPos;
      p.pos.curPos    = p.pos.curPos - swarm.perturbAmp;
      p.prevSpeed     = p.curSpeed;
      p.curSpeed      = -swarm.perturbAmp;
      
      oRemoveParticle = 0;

    elseif p.optPos.jminus == 0
      p.optPos.jminus = p.pos.curFitness;

      p.pos.prevPos   = p.pos.curPos;
      p.pos.curPos    = p.optPos.dpos;
      p.prevSpeed     = p.curSpeed;
      p.curSpeed      = 2*swarm.perturbAmp;
      
      oRemoveParticle = 0;

    elseif p.optPos.jpos == 0
      p.optPos.jpos   = p.pos.curFitness;

      p.pos.prevPos   = p.pos.curPos;
      p.pos.curPos    = p.optPos.dinit;
      p.prevSpeed     = p.curSpeed;
      p.curSpeed      = -swarm.perturbAmp;
      
      oRemoveParticle = 0;

    else
      % If no perturbation has occured
      if     p.pos.curFitness < p.optPos.jinit * (1 + swarm.sentinelMargin) ...
          && p.pos.curFitness > p.optPos.jinit * (1 - swarm.sentinelMargin)

        % If the final position is an optimum
        if p.optPos.jminus <= p.pos.curFitness && p.optPos.jpos <= p.pos.curFitness
          p.state = ParticleState.STEADY_STATE;
          p.oAtOptimum = 1;
          p.jSteady = p.pos.curFitness;
          oRemoveParticle = 0;
          p.pos.prevPos     = p.pos.curPos;
          p.pos.prevFitness = p.pos.curFitness;
%           p.ComputeSpeed(swarm);
%           p.ComputePos  (swarm);

        else % If the position is not an optimum
          if p.optPos.dinit == p.pbestAbs.pos % If we were testing for Pbest
            p.state = ParticleState.SEARCHING;
            oRemoveParticle = 1;
          else
            p.pos.prevPos = p.pos.curPos;
            p.pos.curPos  = p.pbestAbs.pos;
            oRemoveParticle = 0;
          end
          p.ResetOptPos;
        end
      else % Perturbation has occured
        p.state = ParticleState.SEARCHING;
        oRemoveParticle = 0;
      end
    end
            
  case ParticleState.STEADY_STATE
    p.pos.prevPos     = p.pos.curPos;
    p.prevSpeed       = p.curSpeed;
    p.curSpeed        = 0;
    p.pos.prevPos     = p.pos.curPos;
    p.pos.prevFitness = p.pos.curFitness;
    oRemoveParticle   = 0;
    
  otherwise
    error('Wrong state!')
end

end

