function [ ] = RunParaPsoWithPbestAbs( pso, iteration )

import AlgoPkg.PsoPkg.*

for iSwarm = 1 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  
  % Compute the fitness of each unit
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    iUnit = mod(iParticle - 1, swarm.unitArray.nUnits) + 1;
    swarm.unitArray.units(iUnit).SetPos(p.pos.curPos);
    swarm.unitArray.EvalUnit(iUnit);
    p.SetFitness(swarm.unitArray.units(iUnit).fitness);
  end
  %____________________________________________________________________
end

for iSwarm = 1 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  swarm.swarmIteration = swarm.swarmIteration + 1;
  
  % Particles' FSM
  %--------------------------------------------------------------------
  idxToRemove = [];
  for iParticle = 1 : swarm.nParticles
    [pState, oRemoveFromSwarm] = swarm.particles(iParticle).FsmStep(swarm);
    if oRemoveFromSwarm
      idxToRemove = [idxToRemove iParticle]; %#ok<AGROW>
    end
  end
  %____________________________________________________________________
  
  % Compute pbest and gbest
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    swarm.particles(iParticle).ComputePbest;
  end
  swarm.ComputeGbest;
  %____________________________________________________________________

  % Check for steady state
  %--------------------------------------------------------------------
  if swarm.swarmIteration == 1
    warning('To be adjusted.')
  end
  if swarm.particles(1).state == ParticleState.SEARCHING;
    swarm.steadyState.AddSample(swarm.GetParticlesPos);
    swarm.steadyState.EvaluateSteadyState;
    if swarm.steadyState.oInSteadyState == 1
      swarm.oMoveParticles = 0;

      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).state = ParticleState.PERTURB_INIT;
      end
    end
  end
  %____________________________________________________________________

  % SimData
  %--------------------------------------------------------------------
  swarm.simData.AddData ( swarm.GetParticlesSpeed           ...
                        , swarm.GetParticlesPos             ...
                        , swarm.GetParticlesFitness         ...
                        , 0                                 ... %, swarm.GetParticlesFitnessDim      ...
                        , swarm.GetParticlesPbest           ...
                        , swarm.GetGbest                    ...
                        , swarm.steadyState.oInSteadyState  ...
                        , swarm.swarmIteration              ...
                        );
  %____________________________________________________________________

  % Check for perturbations
  %--------------------------------------------------------------------
  particlesPerturbedIdx = swarm.CheckForPerturbation;
  if particlesPerturbedIdx ~= 0 % Perturbation occured
    if swarm.oMoveParticles == 0
      swarm.oResetParticles = 1;
      swarm.oMoveParticles  = 1;
    end
  end
  %____________________________________________________________________
  
  % Compute next positions
  %--------------------------------------------------------------------
  if swarm.oResetParticles == 1
    swarm.oResetParticles = 0;
    for iParticle = 1 : swarm.nParticles
      swarm.RandomizeParticlesPos();
      swarm.particles(iParticle).InitSpeed(swarm);
    end
  else
    if swarm.swarmIteration == 1 %&& ~swarm.steadyState.oInSteadyState
      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).InitSpeed (swarm);
        swarm.particles(iParticle).ComputePos(swarm);
      end
    else
      idxToRemove = [];
      particlesToRemove = ParaParticle_t.empty;
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        switch p.state
          case ParticleState.SEARCHING
            p.ComputeSpeed(swarm);
            p.ComputePos  (swarm);
            
          case ParticleState.PERTURB_INIT
            p.perturbPos.j  = p.pos.curFitness;
            p.perturbPos.d  = p.pos.curPos;
            p.perturbPos.dminus = p.pos.curPos - swarm.perturbAmp;
            p.perturbPos.dpos   = p.pos.curPos + swarm.perturbAmp;
            
            p.pos.prevPos   = p.pos.curPos;
            p.pos.curPos    = p.pos.curPos - swarm.perturbAmp;
            p.prevSpeed     = p.curSpeed;
            p.curSpeed      = -swarm.perturbAmp;
            p.state         = ParticleState.PERTURB_MINUS;
            
          case ParticleState.PERTURB_MINUS
            p.perturbPos.jminus  = p.pos.curFitness;
            
            p.pos.prevPos   = p.pos.curPos;
            p.pos.curPos    = p.perturbPos.dpos;
            p.prevSpeed     = p.curSpeed;
            p.curSpeed      = 2*swarm.perturbAmp;
            p.state         = ParticleState.PERTURB_POS;
            
          case ParticleState.PERTURB_POS
            p.perturbPos.jpos  = p.pos.curFitness;
            
            p.pos.prevPos   = p.pos.curPos;
            p.pos.curPos    = p.perturbPos.d;
            p.prevSpeed     = p.curSpeed;
            p.curSpeed      = -swarm.perturbAmp;
            p.state         = ParticleState.PERTURB_END;
            
          case ParticleState.PERTURB_END
            % If no perturbation has occured
            if     p.pos.curFitness < p.perturbPos.j * (1 + swarm.sentinelMargin) ...
                && p.pos.curFitness > p.perturbPos.j * (1 - swarm.sentinelMargin)
              
              % If the final position is an optimum
              if p.perturbPos.jminus < p.pos.curFitness && p.perturbPos.jpos < p.pos.curFitness
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
            
          case ParticleState.STEADY_STATE
            p.ComputeSpeed(swarm);
            p.ComputePos  (swarm);
            
          otherwise
            error('Invalid state!')
        end
      end
      if ~isempty(idxToRemove)
        if length(idxToRemove) ~= swarm.unitArray.nUnits
          swarm.RemoveParticles(idxToRemove);
          
          [aSplit, aKeep, idxToKeep] = pso.unitArray.SplitArray(idxToRemove, pso.nSwarms + 1);
          
          newSwarm = ParaPsoSwarm_t(pso.nSwarms, aSplit, PsoSimData_t);
          
          swarm.unitArray     = aKeep;

          ss = swarm.steadyState;
          swarm.SetSteadyState([swarm.nParticles 1], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          ss.Del;
          for i = 1 : swarm.steadyState.nSamplesForSteadyState
            swarm.steadyState.AddSample(swarm.GetParticlesPos);
          end
          swarm.steadyState.EvaluateSteadyState;
          if swarm.steadyState.oInSteadyState == 1
            swarm.oMoveParticles = 0;
          end

          newSwarm.SetSteadyState([newSwarm.nParticles 1], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          newSwarm.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
          newSwarm.RandomizeParticlesPos();

          pso.AddSwarm(newSwarm);
          pso.nSimData = pso.nSimData+1;
          pso.simData{pso.nSimData} = {newSwarm.simData};
        else
          swarm.RandomizeParticlesPos();
          swarm.oResetParticles = 0;
          swarm.oMoveParticles  = 1;
        end
      end
    end
  end
  %________________________________________________________________________
  
end

end

