function [ ] = RunParaPsoWithPbestAbs( pso, iteration )
import AlgoPkg.PsoPkg.*

for iUnit = 1 : pso.unitArray.nUnits
  pso.unitArray.EvalUnit(iUnit);
end

% for iSwarm = 1 : pso.nSwarms
%   swarm = pso.swarms(iSwarm);
%   
%   % Compute the fitness of each unit
%   %--------------------------------------------------------------------
%   for iParticle = 1 : swarm.nParticles
%     p = swarm.particles(iParticle);
%     iUnit = mod(iParticle - 1, swarm.unitArray.nUnits) + 1;
%     swarm.unitArray.units(iUnit).SetPos(p.pos.curPos);
%     swarm.unitArray.EvalUnit(iUnit);
%     p.SetFitness(swarm.unitArray.units(iUnit).fitness);
%   end
%   %____________________________________________________________________
% end

pso.realTimeElapsed = pso.realTimeElapsed + pso.unitEvalTime;

% Do the Parallel PSO first
%==========================================================================
iSwarm = 1;
swarm = pso.swarms(iSwarm);
swarm.swarmIteration = swarm.swarmIteration + 1;

if swarm.swarmIteration == 17
  allo = 1;
end

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
    if swarm.swarmIteration >= 23 && iParticle == 2
      allo = 1;
    end
    oRemoveFromSwarm = p.FsmStep(swarm);
    if oRemoveFromSwarm
      idxToRemove = [idxToRemove iParticle]; %#ok<AGROW>
    end
    if p.state == ParticleState.PERTURB_OCCURED
      particlesPerturbed = [particlesPerturbed iParticle]; %#ok<AGROW>
    end
    swarm.unitArray.units(iParticle).SetPos(p.pos.curPos);
  end
  %____________________________________________________________________
  
  if ~isempty(particlesPerturbed)
    swarm.RandomizeCertainParticles(particlesPerturbed);
    for iParticle = 1 : swarm.nParticles
      swarm.unitArray.units(iParticle).SetPos(p.pos.curPos);
    end
  end
  
  if ~isempty(idxToRemove)
    swarm.SplitUnitArrayInto1dArrays(idxToRemove, pso);
  end
  
end
%==========================================================================

for iSwarm = 2 : pso.nSwarms
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
      idxToRemove = [];
      particlesPerturbed = [];
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.FsmStep(swarm);
        if p.state == ParticleState.STEADY_STATE
          idxToRemove = [idxToRemove iParticle]; %#ok<AGROW>
        end
        if p.state == ParticleState.PERTURB_OCCURED
          particlesPerturbed = [particlesPerturbed iParticle]; %#ok<AGROW>
        end
      end
      %____________________________________________________________________
  
      if ~isempty(particlesPerturbed)
        swarm.RandomizeParticlesPos;
        for iParticle = 1 : swarm.nParticles
        end
      end
      swarm.unitArray.units(1).SetPos(swarm.particles(1).pos.curPos);
      
    else
      swarm.unitArray.units(1).SetPos(swarm.particles(swarm.iParticle + 1).pos.curPos);
    end
  end
end

end

