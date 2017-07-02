function [ ] = RunPso1D( pso, iteration )
import AlgoPkg.PsoPkg.*

for iUnit = 1 : pso.unitArray.nUnits
  pso.unitArray.EvalUnit(iUnit);
end

pso.nIterations = pso.nIterations + 1;

pso.realTimeElapsed = pso.realTimeElapsed + pso.unitEvalTime;

for iSwarm = 1 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  if swarm.nParticles ~= 0
    
    swarm.iParticle = swarm.iParticle + 1;
    swarm.particles(swarm.iParticle).SetFitness(swarm.unitArray.units(1).fitness);
    
    if swarm.iParticle == swarm.nParticles
      swarm.iParticle = 0;
      swarm.swarmIteration = swarm.swarmIteration + 1;

      % Compute pbest and gbest
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).ComputePbest;
      end
      swarm.ComputeGbest;
      %____________________________________________________________________
      
      if iSwarm == 4 && swarm.swarmIteration >= 40
        allo = 1;
      end

      % Check for perturbations
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.SentinelEval(swarm.sentinelMargin);
        if p.GetSentinelState
          swarm.oResetParticles = 1;
        end
      end
      %____________________________________________________________________

      % Check for steady state of the particles
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.steadyState.AddSample(p.pos.curPos);
        p.steadyState.EvaluateSteadyState;
        if p.steadyState.oInSteadyState
          p.jSteady = p.pos.curFitness;
        end
      end
      %____________________________________________________________________

      % Check for steady state of the swarm
      %--------------------------------------------------------------------
      swarm.steadyState.AddSample(swarm.GetParticlesPos);
      swarm.steadyState.EvaluateSteadyState;
      if swarm.steadyState.oInSteadyState == 1
        swarm.oMoveParticles = 0;
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
  
      % Compute next positions
      %--------------------------------------------------------------------
      if swarm.oResetParticles == 1
        swarm.oResetParticles = 0;
        for iParticle = 1 : swarm.nParticles
          swarm.RandomizeParticlesPos();
          swarm.particles(iParticle).InitSpeed(swarm);
          swarm.particles(iParticle).pbest.curPos = swarm.particles(iParticle).pos.curPos;
          swarm.particles(iParticle).pbest.curFitness = 0;
        end
        swarm.gbest.curFitness = 0;
      else
        if swarm.swarmIteration == 1 && ~swarm.steadyState.oInSteadyState
          for iParticle = 1 : swarm.nParticles
            swarm.particles(iParticle).InitSpeed (swarm);
            swarm.particles(iParticle).ComputePos(swarm);
          end
        else
          for iParticle = 1 : swarm.nParticles
            swarm.particles(iParticle).ComputeSpeed(swarm);
            swarm.particles(iParticle).ComputePos  (swarm);
          end
        end
      end
      %________________________________________________________________________
  
      swarm.unitArray.units(1).SetPos(swarm.particles(1).pos.curPos);
      
    else
      swarm.unitArray.units(1).SetPos(swarm.particles(swarm.iParticle + 1).pos.curPos);
    end
  end
end

end

