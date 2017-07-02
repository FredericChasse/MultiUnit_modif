function [ ] = RunParaPsoAbData( pso, iteration )

import AlgoPkg.PsoPkg.*

for iUnit = 1 : pso.unitArray.nUnits
  pso.unitArray.EvalUnit(iUnit);
end

pso.nIterations = pso.nIterations + 1;

pso.realTimeElapsed = pso.realTimeElapsed + pso.unitEvalTime;

% Do the Parallel PSO first
%==========================================================================
iSwarm = 1;
swarm = pso.swarms(iSwarm);
swarm.swarmIteration = swarm.swarmIteration + 1;

nSwarmsMem = pso.nSwarms;
if swarm.nParticles ~= 0
  
  % Set the fitness of each particle
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    p.SetFitness(swarm.unitArray.units(iParticle).fitness);
  end
  %____________________________________________________________________

  % Compute pbest and gbest
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    swarm.particles(iParticle).ComputePbest;
  end
  swarm.ComputeGbest;
  %____________________________________________________________________

  % Check for perturbations
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    p.SentinelEval(swarm.sentinelMargin);
  end
  %____________________________________________________________________

  % Check for steady state
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    p.steadyState.AddSample(p.pos.curPos);
    p.steadyState.EvaluateSteadyState;
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

  % Particles' FSM
  %--------------------------------------------------------------------
  idxToRemove = [];
  particlesPerturbed = [];
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    oRemoveFromSwarm = p.FsmStep(swarm);
    if oRemoveFromSwarm
      idxToRemove = [idxToRemove iParticle]; %#ok<AGROW>
    end
    if p.oSentinelWarning == 1
      particlesPerturbed = [particlesPerturbed iParticle]; %#ok<AGROW>
    end
    swarm.unitArray.units(iParticle).SetPos(p.pos.curPos);
  end
  %____________________________________________________________________
  
  if ~isempty(particlesPerturbed)
    if length(particlesPerturbed) == swarm.nParticles
      swarm.RandomizeCertainParticles(particlesPerturbed);
      for iParticle = 1 : swarm.nParticles
        swarm.unitArray.units(iParticle).SetPos(p.pos.curPos);
      end
    else
      swarm.SplitUnitArrayInto1dArrays(particlesPerturbed, pso);
    end
  end
  
  if ~isempty(idxToRemove)
    swarm.SplitUnitArrayInto1dArrays(idxToRemove, pso);
  end
  
end
%==========================================================================

swarmsToDelete = [];
for iSwarm = 2 : nSwarmsMem
% for iSwarm = 2 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  if swarm.nParticles ~= 0
    
    swarm.iParticle = swarm.iParticle + 1;
    swarm.particles(swarm.iParticle).SetFitness(swarm.unitArray.units(1).fitness);
    
    if swarm.iParticle == swarm.nParticles
      swarm.iParticle = 0;
      swarm.swarmIteration = swarm.swarmIteration + 1;

      idxToRemove = [];

      % Compute pbest and gbest
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).ComputePbest;
      end
      swarm.ComputeGbest;
      %____________________________________________________________________

      % Check for perturbations
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.SentinelEval(swarm.sentinelMargin);
      end
      %____________________________________________________________________

      % Check for steady state
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.steadyState.AddSample(p.pos.curPos);
        p.steadyState.EvaluateSteadyState;
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

      % Particles' FSM
      %--------------------------------------------------------------------
      idxInSteadyState = [];
      particlesPerturbed = [];
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.FsmStep(swarm);
        if p.state == ParticleState.STEADY_STATE
          idxInSteadyState = [idxInSteadyState iParticle]; %#ok<AGROW>
        end
        if p.oSentinelWarning == 1
          particlesPerturbed = [particlesPerturbed iParticle]; %#ok<AGROW>
        end
      end
%       if ~isempty(idxInSteadyState)
      if length(idxInSteadyState) == swarm.nParticles
        for iParticle = 1 : swarm.nParticles
          p = swarm.particles(iParticle);
          p.state           = ParticleState.STEADY_STATE;
          p.pos.prevPos     = p.pos.curPos;
          p.pos.prevFitness = p.pos.curFitness;
          p.pos.curPos      = swarm.gbest.curPos;
          p.pos.curFitness  = swarm.gbest.curFitness;
          p.jSteady         = p.pos.curFitness;
          p.oAtOptimum      = 1;
        end
      end
      %____________________________________________________________________
  
      if ~isempty(particlesPerturbed)
        
        swarm.RandomizeParticlesPos;
        for iParticle = 1 : swarm.nParticles
          swarm.particles(iParticle).InitSpeed(swarm);
        end
        
        oFirstSwarmActive = 0;
        for iParticle = 1 : pso.swarms(1).nParticles
          if pso.swarms(1).particles(iParticle).state == ParticleState.SEARCHING
            oFirstSwarmActive = 1;
            break;
          end
        end
        
        if oFirstSwarmActive
          pso.swarms(1).unitArray.AddUnitToArray(swarm.unitArray.units(1).obj);
          for i = 1 : length(swarm.particles(1).steadyState.samples)
            swarm.particles(1).steadyState.AddSample(rand*100);
          end
          pso.swarms(1).AddParticle(swarm.particles(1));
          swarmsToDelete = [swarmsToDelete swarm.id]; %#ok<AGROW>
        end
      end
      swarm.unitArray.units(1).SetPos(swarm.particles(1).pos.curPos);
      
    else
      swarm.unitArray.units(1).SetPos(swarm.particles(swarm.iParticle + 1).pos.curPos);
    end
  end
end

if ~isempty(swarmsToDelete)
  pso.RemoveSwarms(swarmsToDelete);
end


end

