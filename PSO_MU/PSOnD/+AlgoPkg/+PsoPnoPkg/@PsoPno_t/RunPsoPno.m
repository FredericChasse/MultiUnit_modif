function [ ] = RunPsoPno( algo, iteration )
import AlgoPkg.PsoPnoPkg.*

unitsPerturbed  = {};
unitsToRemove   = {};
nUnitsPerturbed = zeros(1, algo.nParaSwarms + algo.nSeqSwarms + algo.nPnos);
nUnitsToRemove  = zeros(1, algo.nParaSwarms);
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
%     if iteration >= 122
%       oIdxPresent = 0;
%       for aa = 1 : swarm.unitArray.nUnits
%         if swarm.unitArray.units(aa).id == 3
%           oIdxPresent = 1;
%           break;
%         end
%       end
%       if oIdxPresent
%         allo =1;
%       end
%     end
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
      unitsPerturbed{iAlgo}  = particlesPerturbed;
      nUnitsPerturbed(iAlgo) = length(particlesPerturbed);
    end
    %--------------------------------------------------------------------

    %% Check particles which need to be removed
    %--------------------------------------------------------------------
    if ~isempty(idxToRemove)
      unitsToRemove{iAlgo}  = idxToRemove;
      nUnitsToRemove(iAlgo) = length(idxToRemove);
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
      pnoi.j(1) = pnoi.j(2);
      pnoi.j(2) = pno.unitArray.units(iInstance).fitness;
      if pno.iteration == 1
        pnoi.j(1) = pnoi.j(2);
      end
      %--------------------------------------------------------------------

      pnoi.steadyState.AddSample(pnoi.u(2));
      
      if pnoi.j(1) > pnoi.j(2)  % If we were better before
        pnoi.k = -pnoi.k;       % Go the other way
      end

      simData.AddData(pnoi.u(2), pnoi.j(2), pno.iteration);

      if pnoi.j(2) > pnoi.pbestAbs.curFitness
        pnoi.pbestAbs.prevFitness = pnoi.pbestAbs.curFitness;
        pnoi.pbestAbs.prevPos = pnoi.pbestAbs.curPos;
        pnoi.pbestAbs.curFitness = pnoi.j(2);
        pnoi.pbestAbs.curPos = pnoi.u(2);
      end
      
      % OEPPCD
      pnoi.steadyState.EvaluateSteadyState;
      if pnoi.steadyState.oInSteadyState
        if pnoi.oFirstSteadyState
          pnoi.oFirstSteadyState = 0;
          
          pnoi.deltaMem = pnoi.delta;
          pnoi.delta = 1;
          pnoi.steadyState.ResetWithNewDelta(pnoi.delta);
          
          pnoi.u(1) = pnoi.u(2);
          pnoi.u(2) = pnoi.u(2) + pnoi.delta*pnoi.k;
          if pnoi.u(2) < pnoi.umin
            pnoi.u(2) = pnoi.umin;
            pnoi.k = abs(pnoi.k);
          end
          if pnoi.u(2) > pnoi.umax
            pnoi.u(2) = pnoi.umax;
            pnoi.k = -abs(pnoi.k);
          end
        else
          if ~pnoi.oLastPos
            pnoi.oLastPos = 1;
            pnoi.u(1) = pnoi.u(2);
            pnoi.u(2) = pnoi.pbestAbs.curPos;
          else
            if pnoi.u(1) == pnoi.u(2)
              if pnoi.j(2) > pnoi.j(1)*(1+pnoi.margin) || pnoi.j(2) < pnoi.j(1)*(1-pnoi.margin)
                idxToRemove = [idxToRemove iInstance];
              end
              pnoi.diversityCount = pnoi.diversityCount + 1;
              if pnoi.diversityCount == pnoi.diversityMaxCount
                pnoi.diversityCount = 0;
                pnoi.pbestAbs.curFitness = pnoi.j(2);
                pnoi.pbestAbs.curPos = pnoi.u(2);
                pnoi.delta = pnoi.deltaMem;
                pnoi.steadyState.ResetWithNewDelta(pnoi.delta);
                pnoi.oLastPos = 0;
                pnoi.oFirstSteadyState = 1;
              end
            end
            pnoi.u(1) = pnoi.u(2);
          end
        end
      else
        pnoi.u(1) = pnoi.u(2);
        pnoi.u(2) = pnoi.u(2) + pnoi.delta*pnoi.k;
        if pnoi.u(2) < pnoi.umin
          pnoi.u(2) = pnoi.umin;
          pnoi.k = abs(pnoi.k);
        end
        if pnoi.u(2) > pnoi.umax
          pnoi.u(2) = pnoi.umax;
          pnoi.k = -abs(pnoi.k);
        end
      end
              
%       % OEPPCD2
%       pnoi.steadyState.EvaluateSteadyState;
%       if pnoi.oInValMode
%         if pnoi.valPos2.d == 0
%           pnoi.valPos1.j = pnoi.j(2);
%           pnoi.valPos2.d = pnoi.valPos1.d + 2*pnoi.deltaVal;
%           pnoi.u(1) = pnoi.u(2);
%           pnoi.u(2) = pnoi.valPos2.d;
%         elseif pnoi.valPos3.d == 0
%           pnoi.valPos2.j = pnoi.j(2);
%           pnoi.valPos3.d = pnoi.valPos1.d + pnoi.deltaVal;
%           pnoi.u(1) = pnoi.u(2);
%           pnoi.u(2) = pnoi.valPos3.d;
% 
%         else
%           pnoi.valPos3.j = pnoi.j(2);
%           if pnoi.valPos1.j <= pnoi.valPos3.j && pnoi.valPos2.j <= pnoi.valPos3.j
%             pnoi.u(1) = pnoi.u(2);
%             pnoi.pbestAbs.curFitness = pnoi.j(2);
%             pnoi.pbestAbs.curPos = pnoi.u(2);
%           else
%             pnoi.pbestAbs.curFitness = pnoi.j(2);
%             pnoi.pbestAbs.curPos = pnoi.u(2);
%             pnoi.delta = pnoi.deltaMem;
%             pnoi.steadyState.ResetWithNewDelta(pnoi.delta);
%             pnoi.oLastPos = 0;
%             pnoi.oFirstSteadyState = 1;
%           end
%           pnoi.valPos1.d = 0;
%           pnoi.valPos2.d = 0;
%           pnoi.valPos3.d = 0;
%           pnoi.oInValMode = 0;
%           pnoi.oLastPos = 0;
%           pnoi.oFirstSteadyState = 1;
%         end
%       elseif pnoi.steadyState.oInSteadyState
%         if pnoi.oFirstSteadyState
%           pnoi.oFirstSteadyState = 0;
%           
%           pnoi.deltaMem = pnoi.delta;
%           pnoi.delta = 1;
%           pnoi.steadyState.ResetWithNewDelta(pnoi.delta);
%           
%           pnoi.u(1) = pnoi.u(2);
%           pnoi.u(2) = pnoi.u(2) + pnoi.delta*pnoi.k;
%           if pnoi.u(2) < pnoi.umin
%             pnoi.u(2) = pnoi.umin;
%             pnoi.k = abs(pnoi.k);
%           end
%           if pnoi.u(2) > pnoi.umax
%             pnoi.u(2) = pnoi.umax;
%             pnoi.k = -abs(pnoi.k);
%           end
%         else
%           if ~pnoi.oLastPos
%             pnoi.oLastPos = 1;
%             pnoi.u(1) = pnoi.u(2);
%             pnoi.u(2) = pnoi.pbestAbs.curPos;
%           else
%             if pnoi.u(1) == pnoi.u(2)
%               if pnoi.j(2) > pnoi.j(1)*(1+pnoi.margin) || pnoi.j(2) < pnoi.j(1)*(1-pnoi.margin)
%                 idxToRemove = [idxToRemove iInstance];
%               end
%               pnoi.diversityCount = pnoi.diversityCount + 1;
%               if pnoi.diversityCount == pnoi.diversityMaxCount
%                 pnoi.diversityCount = 0;
%                 pnoi.oInValMode = 1;
%                 pnoi.u(1) = pnoi.u(2);
%                 pnoi.valPosMem = pnoi.u(2);
%                 pnoi.valPos1.d = pnoi.u(2) - pnoi.deltaVal;
%                 pnoi.u(2) = pnoi.valPos1.d;
%               end
%             end
%             pnoi.u(1) = pnoi.u(2);
%           end
%         end
%       else
%         pnoi.u(1) = pnoi.u(2);
%         pnoi.u(2) = pnoi.u(2) + pnoi.delta*pnoi.k;
%         if pnoi.u(2) < pnoi.umin
%           pnoi.u(2) = pnoi.umin;
%           pnoi.k = abs(pnoi.k);
%         end
%         if pnoi.u(2) > pnoi.umax
%           pnoi.u(2) = pnoi.umax;
%           pnoi.k = -abs(pnoi.k);
%         end
%       end
              
%       % OEPPC
%       if ~pnoi.steadyState.EvaluateSteadyState
%         pnoi.u(1) = pnoi.u(2);
%         pnoi.u(2) = pnoi.u(2) + pnoi.delta*pnoi.k;
%         if pnoi.u(2) < pnoi.umin
%           pnoi.u(2) = pnoi.umin;
%         elseif pnoi.u(2) > pnoi.umax
%           pnoi.u(2) = pnoi.umax;
%         end
%       else
%         if pnoi.u(2) == pnoi.u(1)
%           if pnoi.j(2) > pnoi.j(1)*(1+pnoi.margin) || pnoi.j(2) < pnoi.j(1)*(1-pnoi.margin)
%             idxToRemove = [idxToRemove iInstance];
%           end
%         end
%         pnoi.u(1) = pnoi.u(2);
%         pnoi.u(2) = algo.classifier.GetBestPos(pno.unitArray.units(iInstance).id);
%       end
      
      pno.unitArray.units(iInstance).SetPos(pnoi.u(2));
    end
  end
  
  if ~isempty(idxToRemove)
    unitsPerturbed{iAlgo}  = idxToRemove;
    nUnitsPerturbed(iAlgo) = length(idxToRemove);
  end
end
%==========================================================================


%% Sequential PSO 

for iSwarm = 1 : algo.nSeqSwarms
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
        unitsPerturbed{iAlgo}  = 1;
        nUnitsPerturbed(iAlgo) = 1;
      end
      %--------------------------------------------------------------------
      swarm.unitArray.units(1).SetPos(swarm.particles(1).pos.curPos);
      
    else
      swarm.unitArray.units(1).SetPos(swarm.particles(swarm.iParticle + 1).pos.curPos);
    end
  end
end


%% Classifier decisions 
%--------------------------------------------------------------------
if 1
idxPerturbed = [];
iAlgo = 0;

algoIdxPerturbed = [];

if algo.nPnos ~= 0
  algoIdxPerturbed = [algoIdxPerturbed (algo.nParaSwarms + 1 : algo.nParaSwarms +  algo.nPnos)];
end
if algo.nSeqSwarms ~= 0
  algoIdxPerturbed = [algoIdxPerturbed (algo.nParaSwarms + algo.nPnos + 1 : algo.nParaSwarms + algo.nPnos + algo.nSeqSwarms)];
end
if algo.nParaSwarms ~= 0
  algoIdxPerturbed = [algoIdxPerturbed (1 : algo.nParaSwarms)];
end

%% Assess perturbed P&O units 
%--------------------------------------------------------------------

pnoIdx = 1 : algo.nPnos;
for iPno = 1 : algo.nPnos 
  iAlgo = iAlgo + 1;
  idx = algoIdxPerturbed(iAlgo);
  pno = algo.pno(pnoIdx(iPno));
  if nUnitsPerturbed(idx) ~= 0
    for iUnit = 1 : length(unitsPerturbed{idx})
      idxPerturbed = [idxPerturbed pno.unitArray.units(unitsPerturbed{idx}(iUnit)).id];
    end
%     idxPerturbed = [idxPerturbed pno.unitArray.units(unitsPerturbed{idx}).id];
    
    if length(idxPerturbed) == pno.nInstances
      algo.RemovePno(pno.id);
      pnoIdx = pnoIdx - 1;
    else
      pno.RemoveInstances(unitsPerturbed{idx});
      pno.unitArray.units(unitsPerturbed{idx}) = [];
    end
  end
end
%--------------------------------------------------------------------

%% Assess perturbed Sequential PSO units 
%--------------------------------------------------------------------
seqPsoIdx = 1 : algo.nSeqSwarms;
for iSeqSwarm = 1 : algo.nSeqSwarms 
  iAlgo = iAlgo + 1;
  idx = algoIdxPerturbed(iAlgo);
  swarm = algo.seqSwarms(seqPsoIdx(iSeqSwarm));
  if nUnitsPerturbed(idx) ~= 0
    for iUnit = 1 : length(unitsPerturbed{idx})
      idxPerturbed = [idxPerturbed swarm.unitArray.units(unitsPerturbed{idx}(iUnit)).id];
    end
%     idxPerturbed = [idxPerturbed swarm.unitArray.units(unitsPerturbed{idx}).id];
    algo.RemoveSeqSwarms(swarm.id);
    seqPsoIdx = seqPsoIdx - 1;
  end
end
%--------------------------------------------------------------------

%% Assess perturbed Parallel PSO units 
%--------------------------------------------------------------------
paraPsoIdx = 1 : algo.nParaSwarms;
for iParaSwarm = 1 : algo.nParaSwarms 
  iAlgo = iAlgo + 1;
  idx = algoIdxPerturbed(iAlgo);
  swarm = algo.paraSwarms(paraPsoIdx(iParaSwarm));
  
  if nUnitsToRemove(iParaSwarm) ~= 0
    pos = zeros(1,length(unitsToRemove{iParaSwarm}));
    for i = 1 : length(unitsToRemove{iParaSwarm})
      pos(i) = swarm.particles(unitsToRemove{iParaSwarm}(i)).pos.curPos;
    end
    swarm.DeleteParticles(unitsToRemove{iParaSwarm});
    idxToRemove = [];
%     for iUnit = 1 : length(unitsToRemove{iParaSwarm})
%       idxToRemove(end+1) = swarm.unitArray.units(unitsToRemove{iParaSwarm}(iUnit)).id;
%     end
%     [aSplit, aKeep, idxToKeep] = swarm.unitArray.SplitArray(idxToRemove, 0);
    [aSplit, aKeep, idxToKeep] = swarm.unitArray.SplitArray(unitsToRemove{iParaSwarm}, 0);
    swarm.unitArray = aKeep;
    pno = algo.CreatePno(aSplit);
    pno.SetInstancesParameters(algo.pnoParam.delta, algo.pnoParam.umin, algo.pnoParam.umax, 0, algo.pnoParam.margin)
    pno.SetSteadyState(algo.pnoParam.oscAmp, algo.pnoParam.nSamples);
    for i = 1 : pno.nInstances
      pno.instances(i).u(2) = pos(i);
      pno.unitArray.units(i).SetPos(pos(i));
    end
    if swarm.nParticles < 3
      pos = zeros(1,swarm.nParticles);
      for iParticle = 1 : swarm.nParticles
        pos(iParticle) = swarm.particles(iParticle).pos.curPos;
      end
      unitArray = swarm.unitArray;
      algo.RemoveParaSwarms(swarm.id);
      paraPsoIdx = paraPsoIdx - 1;
      pno = algo.CreatePno(unitArray);
      pno.SetInstancesParameters(algo.pnoParam.delta, algo.pnoParam.umin, algo.pnoParam.umax, 0, algo.pnoParam.margin)
      pno.SetSteadyState(algo.pnoParam.oscAmp, algo.pnoParam.nSamples);
      for i = 1 : pno.nInstances
        if iteration == 101
          allo = 1;
        end
        pno.instances(i).u(2) = pos(i);
        pno.unitArray.units(i).SetPos(pos(i));
      end
    end
  end
  
  if nUnitsPerturbed(idx) ~= 0
    for iUnit = 1 : length(unitsPerturbed{idx})
      idxPerturbed = [idxPerturbed swarm.unitArray.units(unitsPerturbed{idx}(iUnit)).id];
    end
%     idxPerturbed = [idxPerturbed swarm.unitArray.units(unitsPerturbed{idx}).id];
    
    if length(unitsPerturbed{idx}) == swarm.nParticles
      algo.RemoveParaSwarms(swarm.id);
      paraPsoIdx = paraPsoIdx - 1;
    else
      swarm.DeleteParticles(unitsPerturbed{idx});
      [aSplit, aKeep, idxToKeep] = swarm.unitArray.SplitArray(unitsPerturbed{idx}, 0);
      swarm.unitArray = aKeep;
      
      if swarm.nParticles < 3
        pos = zeros(1,swarm.nParticles);
        for iParticle = 1 : swarm.nParticles
          pos(iParticle) = swarm.particles(iParticle).pos.curPos;
        end
        unitArray = swarm.unitArray;
        algo.RemoveParaSwarms(swarm.id);
        paraPsoIdx = paraPsoIdx - 1;
        pno = algo.CreatePno(unitArray);
        pno.SetInstancesParameters(algo.pnoParam.delta, algo.pnoParam.umin, algo.pnoParam.umax, 0, algo.pnoParam.margin)
        pno.SetSteadyState(algo.pnoParam.oscAmp, algo.pnoParam.nSamples);
        for i = 1 : pno.nInstances
          if iteration == 101
            allo = 1;
          end
          pno.instances(i).u(2) = pos(i);
          pno.unitArray.units(i).SetPos(pos(i));
        end
      end
    end
  end
end
%--------------------------------------------------------------------

%% Reposition peturbed units 
%--------------------------------------------------------------------
if ~isempty(idxPerturbed) 
  [groups, nGroups] = algo.classifier.ClassifySome(idxPerturbed);
  fprintf(['Iteration ' num2str(algo.nIterations) '\n']);
  for i = 1 : nGroups
    fprintf(['Group ' num2str(i) ' = ' num2str(groups{i}) '\n']);
  end
  algo.classifier.ResetValues(idxPerturbed);
  
  for iGroup = 1 : nGroups
    group = groups{iGroup};
    nUnits = length(group);
    if nUnits < 3 % Sequential PSO
      error('Classified with group less than 3')
      for iSwarm = 1 : nUnits
        [aSplit, aKeep, idxToKeep] = algo.unitArray.SplitArray(group(iSwarm), 0);
        swarm = algo.CreateSeqSwarms(1, 3, aSplit);
        swarm.SetParam(algo.swarmParam.c1, algo.swarmParam.c2, algo.swarmParam.omega, algo.swarmParam.decimals, algo.swarmParam.posRes, algo.swarmParam.posMin, algo.swarmParam.posMax, algo.swarmParam.margin);
        swarm.SetSteadyState([swarm.nParticles 1], algo.swarmParam.ssOscAmp, algo.swarmParam.nSamples4ss);
        swarm.RandomizeParticlesPos;
        swarm.unitArray.units(1).SetPos(swarm.particles(1).pos.curPos);
      end
      
    else % Parallel PSO
      [aSplit, aKeep, idxToKeep] = algo.unitArray.SplitArray(group, 0);
      swarm = algo.CreateParaSwarms(1, 3, aSplit);
      swarm.SetParam(algo.swarmParam.c1, algo.swarmParam.c2, algo.swarmParam.omega, algo.swarmParam.decimals, algo.swarmParam.posRes, algo.swarmParam.posMin, algo.swarmParam.posMax, algo.swarmParam.margin);
      swarm.SetSteadyState([swarm.nParticles 1], algo.swarmParam.ssOscAmp, algo.swarmParam.nSamples4ss);
      swarm.RandomizeParticlesPos;
      for iParticle = 1 : swarm.nParticles
        swarm.unitArray.units(iParticle).SetPos(swarm.particles(iParticle).pos.curPos);
      end
    end
  end
end
%--------------------------------------------------------------------

%--------------------------------------------------------------------

end


end

