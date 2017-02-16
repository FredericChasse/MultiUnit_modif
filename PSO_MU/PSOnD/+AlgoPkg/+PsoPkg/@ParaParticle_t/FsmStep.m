function [ nextState, oRemoveParticle ] = FsmStep( p, swarm )
import AlgoPkg.PsoPkg.*

switch p.state
  case ParticleState.SEARCHING
    p.ComputeSpeed(swarm);
    p.ComputePos  (swarm);
    p.nextState     = ParticleState.VALIDATE_OPTIMUM;
    oRemoveParticle = 0;
    nextState       = ParticleState.SEARCHING;
            
  case ParticleState.PERTURB_OCCURED
  case ParticleState.TEST_PBEST
  case ParticleState.VALIDATE_OPTIMUM
    if p.optPos.j == 0
      p.optPos.j      = p.pos.curFitness;
      p.optPos.d      = p.pos.curPos;
      p.optPos.dminus = p.pos.curPos - swarm.perturbAmp;
      p.optPos.dpos   = p.pos.curPos + swarm.perturbAmp;

      p.pos.prevPos   = p.pos.curPos;
      p.pos.curPos    = p.pos.curPos - swarm.perturbAmp;
      p.prevSpeed     = p.curSpeed;
      p.curSpeed      = -swarm.perturbAmp;

    elseif p.optPos.jminus == 0
      p.optPos.jminus = p.pos.curFitness;

      p.pos.prevPos   = p.pos.curPos;
      p.pos.curPos    = p.optPos.dpos;
      p.prevSpeed     = p.curSpeed;
      p.curSpeed      = 2*swarm.perturbAmp;

    elseif p.optPos.jpos == 0
      p.optPos.jpos   = p.pos.curFitness;

      p.pos.prevPos   = p.pos.curPos;
      p.pos.curPos    = p.optPos.d;
      p.prevSpeed     = p.curSpeed;
      p.curSpeed      = -swarm.perturbAmp;

    else
      % If no perturbation has occured
      if     p.pos.curFitness < p.optPos.j * (1 + swarm.sentinelMargin) ...
          && p.pos.curFitness > p.optPos.j * (1 - swarm.sentinelMargin)

        % If the final position is an optimum
        if p.optPos.jminus < p.pos.curFitness && p.optPos.jpos < p.pos.curFitness
          p.state = ParticleState.STEADY_STATE;
          p.ComputeSpeed(swarm);
          p.ComputePos  (swarm);
        else
          p.state = ParticleState.SEARCHING;
          idxToRemove = [idxToRemove p.id]; %#ok<AGROW>
          particlesToRemove = [particlesToRemove p]; %#ok<AGROW>
%                 warning('And then?')
        end
      else % Perturbation has occured
        p.state = ParticleState.SEARCHING;
        idxToRemove = [idxToRemove p.id]; %#ok<AGROW>
        particlesToRemove = [particlesToRemove p]; %#ok<AGROW>
        if swarm.swarmIteration == 1
          warning('And then?')
        end
      end
    end
            
  case ParticleState.STEADY_STATE
    
  otherwise
    error('Wrong state!')
end

end

