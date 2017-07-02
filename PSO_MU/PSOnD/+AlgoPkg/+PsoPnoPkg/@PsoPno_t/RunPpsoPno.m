function [ ] = RunPpsoPno( pso, iteration )
import AlgoPkg.PsoPkg.*
import AlgoPkg.PnoPkg.*

persistent oDoPno;
persistent oStayPut;

for iUnit = 1 : pso.unitArray.nUnits
  pso.unitArray.EvalUnit(iUnit);
end

if isempty(oDoPno)
  iSwarm = 1;

  pso.nIterations = pso.nIterations + 1;

  pso.realTimeElapsed = pso.realTimeElapsed + pso.unitEvalTime;

  swarm = pso.swarms(1);
  if swarm.nParticles ~= 0

    for iParticle = 1 : swarm.nParticles
      swarm.particles(iParticle).SetFitness(swarm.unitArray.units(iParticle).fitness);
    end

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

    if swarm.swarmIteration >= 90
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
      oDoPno = 1;
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
    
    if ~isempty(oDoPno)
      pso.pno = Pno_t(2, pso.unitArray);
      delta = 5;
      umin = 10;
      umax = 500;
      for iUnit = 1 : pso.unitArray.nUnits
        pso.pno.SetOneInstancesParameters(iUnit, delta, umin, umax, pso.swarms(1).particles(iUnit).pos.curPos);
      end
      pso.pno.SetSteadyState(2,7);
    end

    for iUnit = 1 : swarm.unitArray.nUnits
      swarm.unitArray.units(iUnit).SetPos(swarm.particles(iUnit).pos.curPos);
    end
  end

elseif isempty(oStayPut)
  pno = pso.pno;
  pno.realTimeElapsed = pno.realTimeElapsed + pno.unitEvalTime;
  for iInstance = 1 : pno.nInstances
    pnoi = pno.instances(iInstance);

    % Compute the fitness of the unit
    %--------------------------------------------------------------------
%     pno.unitArray.units(i).SetPos(pnoi.u);
%     pno.unitArray.EvalUnit(i);
    pnoi.j(1) = pnoi.j(2);
    pnoi.j(2) = pno.unitArray.units(iInstance).fitness;
    if pno.realTimeElapsed == pno.unitEvalTime
      pnoi.j(1) = pnoi.j(2);
    end
    %--------------------------------------------------------------------
    
    pnoi.steadyState.AddSample(pnoi.u);

    if pnoi.j(1) > pnoi.j(2)  % If we were better before
      pnoi.k = -pnoi.k;       % Go the other way
    end

    pnoi.u = pnoi.u + pnoi.delta*pnoi.k;
    if pnoi.u < pnoi.umin
      pnoi.u = pnoi.umin;
    elseif pnoi.u > pnoi.umax
      pnoi.u = pnoi.umax;
    end
  end
  
  for iUnit = 1 : pno.unitArray.nUnits
    pno.unitArray.units(iUnit).SetPos(pno.instances(iUnit).u);
  end
  
  oInSs = 1;
  for i = 1 : pno.nInstances
    pnoi = pno.instances(i);
    if ~pnoi.steadyState.EvaluateSteadyState
      oInSs = 0;
    end
  end
  
  if oInSs == 1
    oStayPut = 1;
  end
  
else
  
  for iUnit = 1 : pso.pno.unitArray.nUnits
    pso.pno.unitArray.units(iUnit).SetPos(pso.pno.instances(iUnit).u);
  end
  
end

end

