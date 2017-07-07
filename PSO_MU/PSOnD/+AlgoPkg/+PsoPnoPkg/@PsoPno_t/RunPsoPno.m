function [ ] = RunPsoPno( algo, iteration )
import AlgoPkg.PsoPnoPkg.*

nUnitsPerturbed = {};
nUnitsToRemove = {};
iAlgo = 0;

%% Eval units, update real time elapsed, and update classifier 
for iUnit = 1 : algo.unitArray.nUnits
  algo.unitArray.EvalUnit(iUnit);
end

algo.nIterations = algo.nIterations + 1;

algo.realTimeElapsed = algo.realTimeElapsed + algo.unitEvalTime;

algo.classifier.UpdateValues;


%% Parallel PSO 
%==========================================================================

for iSwarm = 1 : algo.nParaSwarms
  iAlgo = iAlgo + 1;
  
  swarm = algo.paraSwarms(iSwarm);
  swarm.swarmIteration = swarm.swarmIteration + 1;

  if swarm.nParticles ~= 0

    %% Set the fitness of each particle
    %--------------------------------------------------------------------
    for iParticle = 1 : swarm.nParticles
      p = swarm.particles(iParticle);
      p.SetFitness(swarm.unitArray.units(iParticle).fitness);
    end
    %____________________________________________________________________

    %% Compute pbest and gbest
    %--------------------------------------------------------------------
    for iParticle = 1 : swarm.nParticles
      swarm.particles(iParticle).ComputePbest;
    end
    swarm.ComputeGbest;
    %____________________________________________________________________

    %% Check for perturbations
    %--------------------------------------------------------------------
    for iParticle = 1 : swarm.nParticles
      p = swarm.particles(iParticle);
      p.SentinelEval(swarm.sentinelMargin);
    end
    %____________________________________________________________________

    %% Check for steady state
    %--------------------------------------------------------------------
    oSwarmInSs = 1;
    for iParticle = 1 : swarm.nParticles
      p = swarm.particles(iParticle);
      p.steadyState.AddSample(p.pos.curPos);
      if ~p.steadyState.EvaluateSteadyState
        oSwarmInSs = 0;
      end
    end
    %____________________________________________________________________

    %% SimData
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

    %% Particles' FSM
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

    %% Analyze perturbations
    %--------------------------------------------------------------------
    if ~isempty(particlesPerturbed)
      nUnitsPerturbed{iAlgo} = particlesPerturbed;
    end
    %--------------------------------------------------------------------

    %% Check particles which need to be removed
    %--------------------------------------------------------------------
    if ~isempty(idxToRemove)
      nUnitsToRemove{iAlgo} = idxToRemove;
    end
    %--------------------------------------------------------------------

  end
end
%==========================================================================


%% P&O 
%==========================================================================
for iPno = 1 : algo.nPnos
  iAlgo = iAlgo + 1;
  
  pno = algo.pno(iPno);
  
  idxToRemove = [];
  
  if pno.nInstances ~= 0
    pno.iteration = pno.iteration + 1;
    
    for iInstance = 1 : pno.nInstances
      pnoi = pno.instances(iInstance);
      simData = pnoi.simData;

      % Compute the fitness of the unit
      %--------------------------------------------------------------------
      pno.unitArray.units(iInstance).SetPos(pnoi.u(2));
      pno.unitArray.EvalUnit(iInstance);
      pnoi.j(1) = pnoi.j(2);
      pnoi.j(2) = pno.unitArray.units(iInstance).fitness;
      if pno.iteration == 1
        pnoi.j(1) = pnoi.j(2);
      end
      %--------------------------------------------------------------------

      pnoi.steadyState.AddSample(pnoi.u);
      
      if pnoi.j(1) > pnoi.j(2)  % If we were better before
        pnoi.k = -pnoi.k;       % Go the other way
      end

      simData.AddData(pnoi.u(2), pnoi.j(2), pno.iteration);

      pnoi.u(1) = pnoi.u(2);
      if ~pnoi.steadyState.EvaluateSteadyState
        pnoi.u(2) = pnoi.u(2) + pnoi.delta*pnoi.k;
        if pnoi.u(2) < pnoi.umin
          pnoi.u(2) = pnoi.umin;
        elseif pnoi.u(2) > pnoi.umax
          pnoi.u(2) = pnoi.umax;
        end
      else
        pnoi.u(2) = algo.classifier.GetBestPos(pno.unitArray.units(iInstance).id);
        if pnoi.u(2) == pnoi.u(1)
          if pnoi.j(2) > pnoi.j(1)*1.05 || pnoi.j(2) < pnoi.j(1)*0.95
            idxToRemove = [idxToRemove iInstance];
          end
        end
      end
      
      pno.unitArray.units(iInstance).SetPos(pnoi.u);
    end
  end
  
  if ~isempty(idxToRemove)
    nUnitsPerturbed{iAlgo} = idxToRemove;
  end
end
%==========================================================================


%% Sequential PSO 

for iSwarm = 1 : so.nSeqSwarms
  swarm = algo.seqSwarms(iSwarm);
  iAlgo = iAlgo + 1;
  
  if swarm.nParticles ~= 0
    
    swarm.iParticle = swarm.iParticle + 1;
    swarm.particles(swarm.iParticle).SetFitness(swarm.unitArray.units(1).fitness);
    
    if swarm.iParticle == swarm.nParticles
      swarm.iParticle = 0;
      swarm.swarmIteration = swarm.swarmIteration + 1;

      %% Compute pbest and gbest
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).ComputePbest;
      end
      swarm.ComputeGbest;
      %____________________________________________________________________

      %% Check for perturbations
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.SentinelEval(swarm.sentinelMargin);
      end
      %____________________________________________________________________

      %% Check for steady state
      %--------------------------------------------------------------------
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        p.steadyState.AddSample(p.pos.curPos);
        p.steadyState.EvaluateSteadyState;
      end
      %____________________________________________________________________

      %% SimData
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

      %% Particles' FSM
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
  
      %% Analyze perturbations
      %--------------------------------------------------------------------
      if ~isempty(particlesPerturbed)
        nUnitsPerturbed{iAlgo} = particlesPerturbed;
      end
      %--------------------------------------------------------------------
      swarm.unitArray.units(1).SetPos(swarm.particles(1).pos.curPos);
      
    else
      swarm.unitArray.units(1).SetPos(swarm.particles(swarm.iParticle + 1).pos.curPos);
    end
  end
end

if ~isempty(swarmsToDelete)
  algo.RemoveSwarms(swarmsToDelete);
end


%% Classifier decisions 
%--------------------------------------------------------------------

unitsPerturbed = [];

for iPno = 1 : algo.nPno 
  pno = algo.pno(iPno);
  if ~isempty(nUnitsPerturbed{iPno})
    unitsPerturbed = [unitsPerturbed pno.unitArray.units(nUnitsPerturbed{iPno}).id];
    
    if length(unitsPerturbed) == pno.nInstances
      pso.RemovePno(pno.id);
    else
      pno.RemoveInstances(nUnitsPerturbed{iPno});
      pno.unitArray.units(nUnitsPerturbed{iPno}) = [];
    end
  end
end

for iSeqSwarm = 1 : algo.nSeqSwarms 
  swarm = algo.seqSwarms(iSeqSwarm);
  if ~isempty(nUnitsPerturbed{iPno + iSeqSwarm})
    unitsPerturbed = [unitsPerturbed swarm.unitArray.units(nUnitsPerturbed{iSeqSwarm + iPno}).id];
    pso.RemoveSeqSwarms(swarm.id);
  end
end

for iParaSwarm = 1 : algo.nParaSwarms 
  swarm = algo.paraSwarms(iParaSwarm);
  
  if ~isempty(nUnitsToRemove{iParaSwarm})
    pos = [];
    for i = 1 : length(nUnitsToRemove{iSeqSwarm + iPno + iParaSwarm})
      pos(end+1) = swarm.particles(nUnitsToRemove{iSeqSwarm + iPno + iParaSwarm}(i)).pos.curPos;
    end
    swarm.DeleteParticles(nUnitsToRemove{iSeqSwarm + iPno + iParaSwarm});
    idxToRemove = [];
    for iUnit = 1 : length(nUnitsToRemove{iSeqSwarm + iPno + iParaSwarm})
      idxToRemove(end+1) = swarm.unitArray.units(nUnitsToRemove{iSeqSwarm + iPno + iParaSwarm}(iUnit)).id;
    end
    [aSplit, aKeep, idxToKeep] = swarm.unitArray.SplitArray(idxToRemove, 0);
    swarm.unitArray = aKeep;
    pno = pso.CreatePno(aSplit);
    pno.SetInstancesParameters(pso.pnoParam.delta, pso.pnoParam.umin, pso.pnoParam.umax, pso.pnoParam.uInit)
    pno.SetSteadyState(pso.pnoParam.oscAmp, pso.pnoParam.nSamples);
    for i = 1 : pno.nInstances
      pno.instances(i).u(2) = pos(i);
    end
  end
  
  if ~isempty(nUnitsPerturbed{iParaSwarm})
    unitsPerturbed = [unitsPerturbed swarm.unitArray.units(nUnitsPerturbed{iSeqSwarm + iPno + iParaSwarm}).id];
    
    if length(nUnitsPerturbed) == swarm.nParticles
      algo.RemoveParaSwarms(swarm.id);
    else
      swarm.DeleteParticles(nUnitsPerturbed{iSeqSwarm + iPno + iParaSwarm});
      swarm.unitArray.units(nUnitsPerturbed{iSeqSwarm + iPno + iParaSwarm}) = [];
      
      if swarm.nParticles < 3
        pos = [];
        for iParticle = 1 : swarm.nParticles
          pos(iParticle) = swarm.particles(iParticle).pos.curPos;
        end
        unitArray = swarm.unitArray;
        pso.RemoveSeqSwarms(swarm.id);
        pno = pso.CreatePno(unitArray);
        pno.SetInstancesParameters(pso.pnoParam.delta, pso.pnoParam.umin, pso.pnoParam.umax, pso.pnoParam.uInit)
        pno.SetSteadyState(pso.pnoParam.oscAmp, pso.pnoParam.nSamples);
        for i = 1 : pno.nInstances
          pno.instances(i).u(2) = pos(i);
        end
      end
    end
  end
end


if ~isempty(unitsPerturbed) 
  [groups, nGroups] = algo.classifier.ClassifySome(unitsPerturbed);
  algo.classifier.ResetValues(unitsPerturbed);
  
  for iGroup = 1 : nGroups
    group = groups{iGroup};
    nUnits = length(group);
    if nUnits < 3 % Sequential PSO
      algo.CreateSeqSwarms(nUnits, 3, arrays);
    else % Parallel PSO
      algo.CreateParaSwarms(nUnits, 3, arrays);
    end
  end
end

%--------------------------------------------------------------------


end

