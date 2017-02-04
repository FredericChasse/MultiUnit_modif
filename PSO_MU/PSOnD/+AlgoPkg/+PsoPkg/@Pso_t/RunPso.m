function [ ] = RunPso( pso, iteration )

for iSwarm = 1 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  
  % Compute the fitness of each unit
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    for iDim = 1 : swarm.dimension
      swarm.unitArray.units(iDim).SetPos(p.pos.curPos(iDim));
      swarm.unitArray.EvalUnit(iDim);
      p.SetDimFitness(swarm.unitArray.units(iDim).fitness, iDim);
    end
  end
  %____________________________________________________________________
  
  % Compute pbest and gbest
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    swarm.particles(iParticle).ComputeOverallFitness;
    swarm.particles(iParticle).ComputePbest;
  end
  swarm.ComputeGbest;
  %____________________________________________________________________

  % Check for steady state
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
                        , swarm.GetParticlesFitnessDim      ...
                        , swarm.GetParticlesPbest           ...
                        , swarm.GetGbest                    ...
                        , swarm.steadyState.oInSteadyState  ...
                        , iteration                         ...
                        );

  % Check for perturbations
  %--------------------------------------------------------------------
  particlesPerturbed = swarm.CheckForPerturbation;
  if particlesPerturbed ~= 0 % Perturbation occured
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
    if iteration == 1
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
  
end

end
